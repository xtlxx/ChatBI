# agent/graph.py
# 定义 ChatBIAgent 的状态图
import ast
import json
import re
from datetime import datetime
from typing import Any, Literal

from langchain_core.messages import AIMessage, HumanMessage
from langchain_core.output_parsers import StrOutputParser
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import END, START, StateGraph

from core.db_adapter import AdapterFactory
from logging_config import get_logger
from models.db_connection import DbType

from .prompts import (
  THINKING_SYSTEM,
  SQL_GEN_SYSTEM,
  RESPONSE_GEN_SYSTEM,
  CHART_GEN_SYSTEM,
  SCHEMA_CONTEXT,
  format_few_shot_examples,
  select_few_shot_examples,
)
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from .schemas import GenerateResponseOutput, GenerateSQLOutput, EChartsConfig
from .state import AgentState
from .tools import DatabaseTools, validate_and_format_sql

logger = get_logger(__name__)

class ChatBIAgent:
  def __init__(
    self, db_engine, retriever=None, llm=None, checkpointer=None, db_type: DbType = DbType.mysql,
    dynamic_prompts: dict[str, str] = None
  ):
    self.db_engine = db_engine
    self.retriever = retriever
    self.checkpointer = checkpointer if checkpointer else MemorySaver()
    self.db_type = db_type
    self.dynamic_prompts = dynamic_prompts or {}
    self.logger = get_logger(self.__class__.__name__)

    if llm:
      self.llm = llm
    else:
      raise ValueError("必须提供一个LLM实例给ChatBIAgent")

    self.db_tools = DatabaseTools(db_engine, db_type=db_type)
    self.adapter = AdapterFactory.get_adapter(db_type)

    # 动态构造 Prompts
    self.thinking_prompt = ChatPromptTemplate.from_messages([
        ("system", self.dynamic_prompts.get("THINKING_SYSTEM", THINKING_SYSTEM)),
        MessagesPlaceholder(variable_name="messages"),
        ("human", "{query}"),
    ])

    self.sql_gen_prompt = ChatPromptTemplate.from_messages([
        ("system", self.dynamic_prompts.get("SQL_GEN_SYSTEM", SQL_GEN_SYSTEM)),
        MessagesPlaceholder(variable_name="messages"),
        ("human", "用户问题：{query}\n\nSchema Context（必须严格遵守）：\n{schema_context}\n\n请直接输出 JSON。"),
    ])

    self.response_gen_prompt = ChatPromptTemplate.from_messages([
        ("system", self.dynamic_prompts.get("RESPONSE_GEN_SYSTEM", RESPONSE_GEN_SYSTEM)),
        MessagesPlaceholder(variable_name="messages"),
        ("human", "用户问题：{query}\n\nSQL 查询结果（JSON 格式）：{sql_result}\n\n请生成完整的分析报告。"),
    ])

    self.chart_gen_prompt = ChatPromptTemplate.from_messages([
        ("system", self.dynamic_prompts.get("CHART_GEN_SYSTEM", CHART_GEN_SYSTEM)),
        ("human", "用户问题：{query}\nSQL 结果：{sql_result}"),
    ])

    self.logger.info(
      "agent_initialized",
      llm_type=type(self.llm).__name__,
      db_type=db_type.value,
      mode="optimized_state_management",
      timestamp=datetime.now().isoformat()
    )

    self.graph = self._create_graph()

  def _log_node_execution(self, node_name: str, state: AgentState, extra: dict = None):
    """统一的节点执行日志记录"""
    log_data = {
      "node": node_name,
      "session_id": state.get("session_id"),
      "current_phase": state.get("current_phase", "unknown"),
      "step_count": len(state.get("steps", [])),
      "has_error": state.get("has_error", False),
      "retry_counts": state.get("retry_counts", {})
    }
    if extra:
      log_data.update(extra)
    self.logger.info("node_execution", **log_data)


  def _format_user_friendly_error(self, error_msg: str) -> str:
    if not error_msg:
      return "查询执行失败，请稍后重试"
    error_msg = re.sub(r'\(Background on this error.*?\)', '', error_msg, flags=re.DOTALL)
    error_msg = re.sub(r'\[SQL:.*?\]', '', error_msg, flags=re.DOTALL)
    patterns = [
      (r"Unknown column '([^']+)'", "字段 '{}' 不存在，请检查字段名是否正确"),
      (r"Unknown table '([^']+)'", "表 '{}' 不存在，请检查表名是否正确"),
      (r"Syntax error.*?near '([^']+)'", "SQL 语法错误，请检查查询语句"),
      (r"Expression #\d+ of SELECT list is not in GROUP BY", "分组查询错误：SELECT 的字段必须在 GROUP BY 中或使用聚合函数"),
      (r"Duplicate column name '([^']+)'", "字段名 '{}' 重复"),
      (r"Division by zero", "除零错误，请检查计算逻辑"),
      (r"User location is not supported", "当前地区不支持该 AI 模型服务，请切换模型或使用代理"),
      (r"rate.?limit|too many requests|429", "AI 模型调用过于频繁，请稍后重试"),
      (r"(401|authentication|unauthorized)", "AI 模型认证失败，请检查 API Key 配置"),
      (r"(timeout|timed? ?out)", "AI 模型响应超时，请稍后重试"),
      (r"(500|502|503|internal.?server.?error)", "AI 模型服务暂时不可用，请稍后重试"),
      (r"context.?length|token.?limit|too.?long", "查询数据量过大，超出 AI 模型处理能力，请缩小查询范围"),
      (r"Range of input length", "输入内容过长（Schema超过模型限制），请切换到支持长上下文的模型（如 GPT-4o / Qwen-Plus）"),
    ]
    for pattern, template in patterns:
      match = re.search(pattern, error_msg, re.IGNORECASE)
      if match:
        if '{}' in template:
          return template.format(match.group(1))
        return template
    first_line = error_msg.split('\n')[0].strip()
    if 'Error:' in first_line:
      first_line = first_line.split('Error:', 1)[1].strip()
    if len(first_line) > 150:
      first_line = first_line[:150] + "..."
    return f"查询执行失败：{first_line}"

  def _generate_simple_report(self, state: AgentState) -> dict[str, Any]:
    try:
      sql_result = state.get("execution_result", {}).get("data", [])
      if not sql_result:
        return {"content": "查询执行成功，但未能生成详细报告。"}
      rows = sql_result
      if not rows:
        return {"content": "查询执行成功，但未返回任何数据。"}
      columns = list(rows[0].keys()) if rows else []
      max_rows = 10
      table_md = f"| {' | '.join(columns)} |\n"
      table_md += f"| {' | '.join(['---'] * len(columns))} |\n"
      for row in rows[:max_rows]:
        row_values = [row.get(col) for col in columns]
        row_str = [str(item).replace("|", "\\|") for item in row_values]
        table_md += f"| {' | '.join(row_str)} |\n"
      if len(rows) > max_rows:
        table_md += f"\n*... 共 {len(rows)} 条数据，仅显示前 {max_rows} 条 ...*"
      content = f"### 数据查询结果 (自动生成)\n\n由于 AI 响应超时，以下是直接查询结果：\n\n{table_md}"
      return {"content": content, "chart_option": None}
    except Exception as e:
      self.logger.error(f"Failed to generate simple report: {e}")
      return {"content": "查询执行成功，但在生成备用报告时出错。", "chart_option": None}

  def _create_graph(self) -> StateGraph:
    """创建 LangGraph 状态图"""

    # ────────────────────────────────────────────────
    # 节点 0：Schema 检索
    # ────────────────────────────────────────────────
    async def retrieve_schema_node(state: AgentState) -> dict[str, Any]:
      node_start = datetime.now()
      try:
        dialect_info = ""
        if self.adapter:
          date_func = self.adapter.get_date_format_function() or "DATE_FORMAT"
          limit_syntax = self.adapter.get_limit_syntax() or "LIMIT 100"
          dialect_info = (
            f"\n### 数据库方言\n"
            f"当前连接的数据库类型为: {self.db_type.value}\n"
            f"日期处理建议: 使用 {date_func}\n"
            f"分页语法示例: {limit_syntax}\n"
          )

        dynamic_tables = await self.db_tools.get_all_tables_info()

        full_schema_context = (
          f"{SCHEMA_CONTEXT}\n"
          f"{dialect_info}\n"
          f"### 当前数据库全量表列表\n{dynamic_tables}"
        )

        duration_ms = (datetime.now() - node_start).total_seconds() * 1000
        self._log_node_execution("retrieve_schema", state, {
          "status": "success",
          "duration_ms": duration_ms,
          "context_length": len(full_schema_context)
        })

        return {
          "current_phase": "retrieve_schema",
          "schema_context": full_schema_context,
          "steps": ["retrieve_schema"],
          "timings": {**state.get("timings", {}), "retrieve_schema": duration_ms},
          "has_error": False,
          "last_error": None,
          "fallback_used": False,
        }
      except Exception as e:
        duration_ms = (datetime.now() - node_start).total_seconds() * 1000
        self.logger.error("schema_retrieval_failed", error=str(e), duration_ms=duration_ms, exc_info=True)
        return {
          "current_phase": "retrieve_schema",
          "schema_context": SCHEMA_CONTEXT,
          "fallback_used": True,
          "has_error": True,
          "last_error": self._format_user_friendly_error(str(e)),
          "error_phase": "retrieve_schema",
          "steps": ["retrieve_schema_error"],
          "timings": {**state.get("timings", {}), "retrieve_schema": duration_ms},
        }

    # ────────────────────────────────────────────────
    # 节点 1：显式业务思考
    # ────────────────────────────────────────────────
    async def explicit_thinking_node(state: AgentState) -> dict[str, Any]:
      node_start = datetime.now()
      try:
        if state.get("thinking"):
          self._log_node_execution("explicit_thinking", state, {"status": "skipped"})
          return {
            "steps": ["explicit_thinking_skipped"],
          }

        prompt_template = self.thinking_prompt
        # 在 explicit_thinking 节点加上 tags 避免被流式输出误捕获
        chain = prompt_template | self.llm.with_config({"tags": ["explicit_thinking_llm"]}) | StrOutputParser()
        thinking_text = await chain.ainvoke({
          "query": state["query"],
          "messages": state["messages"],
          "schema_context": state.get("schema_context", ""),
          "current_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        })

        duration_ms = (datetime.now() - node_start).total_seconds() * 1000
        self._log_node_execution("explicit_thinking", state, {
          "status": "success",
          "duration_ms": duration_ms,
          "thinking_length": len(thinking_text)
        })

        return {
          "current_phase": "explicit_thinking",
          "thinking": thinking_text.strip(),
          "steps": ["explicit_thinking"],
          "timings": {**state.get("timings", {}), "explicit_thinking": duration_ms},
          "has_error": False,
          "last_error": None,
        }
      except Exception as e:
        duration_ms = (datetime.now() - node_start).total_seconds() * 1000
        self.logger.error("explicit_thinking_failed", error=str(e), duration_ms=duration_ms, exc_info=True)
        return {
          "current_phase": "explicit_thinking",
          "thinking": None,
          "has_error": True,
          "last_error": self._format_user_friendly_error(str(e)),
          "error_phase": "explicit_thinking",
          "steps": ["explicit_thinking_error"],
          "timings": {**state.get("timings", {}), "explicit_thinking": duration_ms},
        }

    # ────────────────────────────────────────────────
    # 节点 2：生成 SQL (🌟移除 @retry，拥抱状态循环🌟)
    # ────────────────────────────────────────────────
    async def generate_sql_node(state: AgentState) -> dict[str, Any]:
      node_start = datetime.now()
      query = state["query"]
      retry_count = state["retry_counts"].get("generate_sql", 0)

      try:
        full_schema_context = state.get("schema_context")
        if not full_schema_context:
          full_schema_context = SCHEMA_CONTEXT
          fallback_used = True
        else:
          fallback_used = False

        # 移除手动拼接 error_context 到 query 的逻辑
        # 改为通过 messages 历史传递详细错误信息，让 LLM 自我纠错
        
        selected_examples = select_few_shot_examples(state["query"], max_examples=3, mode="sql")
        few_shot_examples_text = format_few_shot_examples(selected_examples)

        structured_llm = self.llm.with_structured_output(GenerateSQLOutput)
        prompt_template = self.sql_gen_prompt
        chain = prompt_template | structured_llm

        result = await chain.ainvoke(
          {
            "query": query,
            "messages": state["messages"],
            "schema_context": full_schema_context,
            "few_shot_examples": few_shot_examples_text,
            "current_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
          }
        )

        if not isinstance(result, GenerateSQLOutput):
          self.logger.warning(f"意外的输出类型: {type(result)}")
          if isinstance(result, dict):
             result = GenerateSQLOutput(**result)

        clean_sql = result.sql
        thought = result.thought

        duration_ms = (datetime.now() - node_start).total_seconds() * 1000
        self._log_node_execution("generate_sql", state, {
          "status": "success",
          "duration_ms": duration_ms,
          "sql_length": len(clean_sql)
        })

        return {
          "current_phase": "generate_sql",
          "sql_attempt": {
            "query": clean_sql,
            "thought": thought,
            "generated_at": datetime.now().isoformat(),
            "attempt": retry_count + 1
          },
          "retry_counts": {**state["retry_counts"], "generate_sql": retry_count + 1},
          "timings": {**state.get("timings", {}), "generate_sql": duration_ms},
          "steps": ["generate_sql"],
          "has_error": False, # 🌟 关键修复：显式重置为 False
          "last_error": None, # 清除上一轮的错误信息
          "error_phase": None, # 清除错误阶段标记
          "fallback_used": state.get("fallback_used", False) or fallback_used,
        }
      except Exception as e:
        duration_ms = (datetime.now() - node_start).total_seconds() * 1000
        is_fatal = any(x in str(e) for x in ["Range of input length", "context length exceeded", "InvalidParameter"])
        retry_increment = 3 if is_fatal else 1
        friendly_error = self._format_user_friendly_error(str(e))
        self.logger.error("sql_generation_failed", error=str(e), is_fatal=is_fatal, duration_ms=duration_ms, exc_info=True)

        # 🌟 关键修复：将详细错误回传给 State 的 messages，触发 Self-Correction
        error_feedback_msg = HumanMessage(
            content=f"结构化输出验证失败（第 {retry_count + 1} 次尝试）：{str(e)}。请分析 schema 定义并修正输出格式。"
        )

        return {
          "current_phase": "generate_sql",
          "sql_attempt": None,
          "has_error": True,
          "last_error": friendly_error, # UI展示用友好错误
          "error_phase": "generate_sql",
          "retry_counts": {**state["retry_counts"], "generate_sql": retry_count + retry_increment},
          "steps": ["generate_sql_error"],
          "timings": {**state.get("timings", {}), "generate_sql": duration_ms},
          "messages": [error_feedback_msg] # 追加错误反馈
        }

    # ────────────────────────────────────────────────
    # 节点 3：验证 SQL
    # ────────────────────────────────────────────────
    async def validate_sql_node(state: AgentState) -> dict[str, Any]:
      node_start = datetime.now()
      try:
        if state.get("has_error"):
           self._log_node_execution("validate_sql", state, {"status": "skipped_due_to_error"})
           return {
            "validation_result": {"is_valid": False, "issues": ["Skipped due to prior error"], "message": "跳过验证"},
            "steps": ["validate_sql_skip_due_to_error"],
           }

        sql = state.get("sql_attempt", {}).get("query", "")
        if not sql:
          raise ValueError("No SQL query to validate")

        error = None
        try:
            dialect = getattr(self.adapter, "sqlglot_dialect", "postgres") if hasattr(self, "adapter") and self.adapter else "postgres"
            validate_and_format_sql(sql, dialect=dialect)
        except ValueError as e:
            error = str(e)

        duration_ms = (datetime.now() - node_start).total_seconds() * 1000

        if error:
          self._log_node_execution("validate_sql", state, {
            "status": "failed",
            "duration_ms": duration_ms,
            "error_type": "safety_violation"
          })
          
          # 🌟 关键修复：将 SQL 校验错误回传给 State 的 messages
          error_feedback_msg = HumanMessage(
              content=f"SQL 安全校验失败：{error}。请修正 SQL 查询以符合安全规则。"
          )
          
          return {
            "current_phase": "validate_sql",
            "validation_result": {"is_valid": False, "issues": [error], "message": "SQL 安全校验失败"},
            "retry_counts": {**state["retry_counts"], "generate_sql": state["retry_counts"].get("generate_sql", 0) + 1},  # 验证失败计入生成重试
            "has_error": True,
            "last_error": error,
            "error_phase": "validate_sql",
            "steps": ["validate_sql_fail"],
            "timings": {**state.get("timings", {}), "validate_sql": duration_ms},
            "messages": [error_feedback_msg] # 追加错误反馈
          }

        self._log_node_execution("validate_sql", state, {
          "status": "success",
          "duration_ms": duration_ms
        })

        return {
          "current_phase": "validate_sql",
          "validation_result": {"is_valid": True, "issues": [], "message": "SQL 通过校验"},
          "steps": ["validate_sql_pass"],
          "timings": {**state.get("timings", {}), "validate_sql": duration_ms},
          "has_error": False,
          "last_error": None,
        }
      except Exception as e:
        duration_ms = (datetime.now() - node_start).total_seconds() * 1000
        self.logger.error("validate_sql_exception", error=str(e), duration_ms=duration_ms, exc_info=True)
        
        error_feedback_msg = HumanMessage(
            content=f"SQL Validation Exception: {str(e)}. Please fix the SQL."
        )
        
        return {
          "current_phase": "validate_sql",
          "validation_result": {"is_valid": False, "issues": [str(e)], "message": "SQL 验证异常"},
          "has_error": True,
          "last_error": self._format_user_friendly_error(str(e)),
          "error_phase": "validate_sql",
          "retry_counts": {**state["retry_counts"], "generate_sql": state["retry_counts"].get("generate_sql", 0) + 1},
          "steps": ["validate_sql_exception"],
          "timings": {**state.get("timings", {}), "validate_sql": duration_ms},
          "messages": [error_feedback_msg] # 追加错误反馈
        }

    # ────────────────────────────────────────────────
    # 节点 4：执行 SQL
    # ────────────────────────────────────────────────
    async def execute_sql_node(state: AgentState) -> dict[str, Any]:
      node_start = datetime.now()
      sql = state.get("sql_attempt", {}).get("query", "")
      try:
        result_json_str = await self.db_tools.execute_sql_query(sql)
        result_data = json.loads(result_json_str)
        duration_ms = (datetime.now() - node_start).total_seconds() * 1000

        if "error" in result_data:
          self._log_node_execution("execute_sql", state, {
            "status": "failed",
            "duration_ms": duration_ms,
            "error_type": "execution_error"
          })
          return {
            "current_phase": "execute_sql",
            "execution_result": {"data": None, "row_count": 0, "truncated": False, "error": result_data["error"]},
            "has_error": True,
            "last_error": self._format_user_friendly_error(result_data["error"]),
            "error_phase": "execute_sql",
            "retry_counts": {**state["retry_counts"], "execute_sql": state["retry_counts"].get("execute_sql", 0) + 1},
            "steps": ["execute_sql_fail"],
            "timings": {**state.get("timings", {}), "execute_sql": duration_ms},
            "messages": [HumanMessage(content=f"SQL 执行失败: {result_data['error']}。请修正 SQL 并重试。")],
          }

        self._log_node_execution("execute_sql", state, {
          "status": "success",
          "duration_ms": duration_ms,
          "row_count": result_data.get("row_count", 0)
        })

        return {
          "current_phase": "execute_sql",
          "execution_result": {
            "data": result_data.get("data", []),
            "row_count": result_data.get("row_count", 0),
            "truncated": result_data.get("truncated", False),
            "error": None
          },
          "steps": ["execute_sql_success"],
          "timings": {**state.get("timings", {}), "execute_sql": duration_ms},
          "has_error": False,
          "last_error": None,
        }
      except Exception as e:
        duration_ms = (datetime.now() - node_start).total_seconds() * 1000
        self.logger.error("execute_sql_exception", error=str(e), duration_ms=duration_ms, exc_info=True)
        return {
          "current_phase": "execute_sql",
          "execution_result": {"data": None, "row_count": 0, "truncated": False, "error": str(e)},
          "has_error": True,
          "last_error": self._format_user_friendly_error(str(e)),
          "error_phase": "execute_sql",
          "retry_counts": {**state["retry_counts"], "execute_sql": state["retry_counts"].get("execute_sql", 0) + 1},
          "steps": ["execute_sql_exception"],
          "timings": {**state.get("timings", {}), "execute_sql": duration_ms},
          "messages": [HumanMessage(content=f"SQL 执行异常: {str(e)}。请修正 SQL 并重试。")],
        }

    # ────────────────────────────────────────────────
    # 节点 5：生成最终响应 (🌟 重构：恢复流式输出)
    # ────────────────────────────────────────────────
    async def generate_response_node(state: AgentState) -> dict[str, Any]:
      node_start = datetime.now()
      try:
        import asyncio
        from langchain_core.output_parsers import StrOutputParser

        # 文本生成链（带标签以便流式输出时识别）
        text_llm = self.llm.with_config({"tags": ["report_generator"]})
        text_chain = self.response_gen_prompt | text_llm | StrOutputParser()

        # 图表生成链
        chart_llm = self.llm.with_structured_output(EChartsConfig)
        chart_chain = self.chart_gen_prompt | chart_llm

        selected_examples = select_few_shot_examples(state["query"], max_examples=2, mode="response")
        few_shot_examples_text = format_few_shot_examples(selected_examples)

        sql_result_data = (state.get("execution_result") or {}).get("data", [])
        
        # 截断数据，防止上下文过载
        max_rows = 20
        truncated_data = sql_result_data[:max_rows]
        data_note = ""
        if len(sql_result_data) > max_rows:
            data_note = f"\n(注：为节省性能，仅展示前 {max_rows} 条样本，总数据共 {len(sql_result_data)} 条)"

        sql_result_json = json.dumps(truncated_data, ensure_ascii=False, default=str) + data_note

        self.logger.info("generate_response_start",
          query=state["query"],
          sql_result_length=len(sql_result_data),
          has_few_shot=bool(few_shot_examples_text))

        fallback_used = False
        content = ""
        chart_config = None

        try:
          # 增加超时控制，并发执行文本和图表生成
          content, chart_config = await asyncio.wait_for(
            asyncio.gather(
              text_chain.ainvoke({
                "query": state["query"],
                "sql_result": sql_result_json,
                "messages": state["messages"],
                "few_shot_examples": few_shot_examples_text,
                "current_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
              }),
              chart_chain.ainvoke({
                "query": state["query"],
                "sql_result": sql_result_json,
              })
            ),
            timeout=600.0
          )
        except TimeoutError:
          self.logger.warning("response_generation_timeout", duration_ms=600000)
          simple_report = self._generate_simple_report(state)
          content = simple_report["content"]
          chart_config = None
          fallback_used = True
        except Exception as e:
           raise e

        # 转换为 dict 用于前端 (Pydantic model_dump)
        chart_dict = chart_config.model_dump(exclude_none=True) if chart_config else None

        # --- 关键修复：防止重复渲染错误信息 ---
        if state.get("has_error") and fallback_used:
            content = f"⚠️ **系统提示**：由于{state.get('last_error', '未知原因')}，未能完成完整分析。以下为系统直接提取的原始数据。\n\n---\n\n{content}"

        response_message = AIMessage(content=content)
        duration_ms = (datetime.now() - node_start).total_seconds() * 1000

        self._log_node_execution("generate_response", state, {
          "status": "success",
          "duration_ms": duration_ms,
          "content_length": len(content),
          "has_chart": bool(chart_dict)
        })

        return {
          "current_phase": "generate_response",
          "final_output": {
            "content": content,
            "chart_option": chart_dict,
            "summary": content[:200] + "..." if len(content) > 200 else content,
            "generated_at": datetime.now().isoformat()
          },
          "messages": [response_message],
          "steps": ["generate_response"],
          "timings": {**state.get("timings", {}), "generate_response": duration_ms},
          "has_error": False,
          "last_error": None,
          "fallback_used": state.get("fallback_used", False) or fallback_used,
        }
      except Exception as e:
        duration_ms = (datetime.now() - node_start).total_seconds() * 1000
        friendly_error = self._format_user_friendly_error(str(e))
        self.logger.error("response_generation_failed", error=str(e), duration_ms=duration_ms, exc_info=True)
        return {
          "current_phase": "generate_response",
          "final_output": None,
          "messages": [AIMessage(content=friendly_error)], # 🌟优化：依赖于 add_messages 只需返回新的 list 即可
          "has_error": True,
          "last_error": friendly_error,
          "error_phase": "generate_response",
          "steps": ["generate_response_error"],
          "timings": {**state.get("timings", {}), "generate_response": duration_ms},
        }

    # --- 条件判断路由（利用新状态字段） ---
    def route_after_retrieve_schema(state: AgentState) -> str:
      if state.get("has_error"):
        return END
      return "explicit_thinking"

    def route_after_thinking(state: AgentState) -> str:
      if state.get("has_error"):
        return END
      return "generate_sql"

    def route_after_generate_sql(state: AgentState) -> str:
      if state.get("has_error"):
        if state["retry_counts"].get("generate_sql", 0) >= 3:
          return END
        return "generate_sql"
      return "validate_sql"

    def route_after_validation(state: AgentState) -> str:
      if state.get("has_error"):
        if state["retry_counts"].get("generate_sql", 0) >= 3:
          return END
        return "generate_sql"
      if state.get("validation_result", {}).get("is_valid", False):
        return "execute_sql"
      else:
        if state["retry_counts"].get("generate_sql", 0) >= 3:
          return END
        return "generate_sql"

    def route_after_execution(state: AgentState) -> str:
      if state.get("has_error"):
        if state["retry_counts"].get("execute_sql", 0) >= 3:
          return END
        return "generate_sql"  # 执行失败回退到生成阶段
      if state.get("execution_result") and not state.get("execution_result").get("error"):
        return "generate_response"
      else:
        if state["retry_counts"].get("execute_sql", 0) >= 3:
          return END
        return "generate_sql"

    # route_after_response 已移除：generate_response 节点直接通过 add_edge 连接到 END

    # --- 构建图 ---
    workflow = StateGraph(AgentState)

    workflow.add_node("retrieve_schema", retrieve_schema_node)
    workflow.add_node("explicit_thinking", explicit_thinking_node)
    workflow.add_node("generate_sql", generate_sql_node)
    workflow.add_node("validate_sql", validate_sql_node)
    workflow.add_node("execute_sql", execute_sql_node)
    workflow.add_node("generate_response", generate_response_node)

    workflow.add_edge(START, "retrieve_schema")
    workflow.add_conditional_edges("retrieve_schema", route_after_retrieve_schema)
    workflow.add_conditional_edges("explicit_thinking", route_after_thinking)
    workflow.add_conditional_edges("generate_sql", route_after_generate_sql)
    workflow.add_conditional_edges("validate_sql", route_after_validation)
    workflow.add_conditional_edges("execute_sql", route_after_execution)
    workflow.add_edge("generate_response", END)  # 最终节点直接结束，无需条件路由

    return workflow.compile(checkpointer=self.checkpointer)

  async def ainvoke(
    self, query: str, session_id: str = "default", metadata: dict[str, Any] = None
  ) -> dict[str, Any]:
    try:
      self.logger.info("agent_invoked", query=query, session_id=session_id)
      metadata = metadata or {}
      initial_inputs = {
        "messages": [HumanMessage(content=query)],
        "query": query,
        "session_id": session_id,
        "metadata": metadata,
        "current_phase": "init",
        "steps": [],
        "retry_counts": {},
        "has_error": False,
        "last_error": None,
        "error_phase": None,
        "fallback_used": False,
        "timings": {},
        "schema_context": None,
        "thinking": None,
        "sql_attempt": None,
        "validation_result": None,
        "execution_result": None,
        "final_output": None,
      }
      config = {"configurable": {"thread_id": session_id}}
      result = await self.graph.ainvoke(initial_inputs, config)
      final_response = self._extract_final_answer(result)
      self.logger.info("agent_completed", session_id=session_id, timings=result.get("timings"))
      return final_response
    except Exception as e:
      import traceback
      traceback.print_exc()
      self.logger.error("agent_invocation_failed", error=str(e), exc_info=True)
      return {
        "summary": f"系统错误: {str(e)}",
        "error": str(e),
        "sql": None,
        "chartOption": None,
        "thinking": None,
      }

  async def astream(
    self, query: str, session_id: str = "default", metadata: dict[str, Any] = None
  ):
    try:
      self.logger.info("agent_stream_started", query=query, session_id=session_id)

      metadata = metadata or {}
      initial_inputs = {
        "messages": [HumanMessage(content=query)],
        "query": query,
        "session_id": session_id,
        "metadata": metadata,
        "current_phase": "init",
        "steps": [],
        "retry_counts": {},
        "has_error": False,
        "last_error": None,
        "error_phase": None,
        "fallback_used": False,
        "timings": {},
        "schema_context": None,
        "thinking": None,
        "sql_attempt": None,
        "validation_result": None,
        "execution_result": None,
        "final_output": None,
      }

      config = {"configurable": {"thread_id": session_id}}

      accumulated_thinking = ""
      current_sql = None
      last_phase = None
      has_streamed_final_answer = False

      yield {
        "type": "status",
        "content": "Agent 核心已启动",
        "done": False
      }

      async for event in self.graph.astream_events(initial_inputs, config, version="v2"):
        kind = event["event"]
        node_name = event.get("metadata", {}).get("langgraph_node")
        event_name = event.get("name") # 获取事件名称

        self.logger.info("graph_event", kind=kind, node=node_name, name=event_name)

        if not node_name:
          continue

        # 利用 current_phase 统一处理状态通知
        event_data = event.get("data", {})
        if isinstance(event_data, dict):
          output_data = event_data.get("output", {})
          if isinstance(output_data, dict):
            current_phase = output_data.get("current_phase", last_phase)
          else:
             current_phase = last_phase
        else:
           current_phase = last_phase
        if current_phase != last_phase:
          last_phase = current_phase
          phase_messages = {
            "init": "正在初始化分析环境...",
            "retrieve_schema": "正在检索数据库结构...",
            "explicit_thinking": "开始深度思考...",
            "generate_sql": "正在生成 SQL 查询...",
            "validate_sql": "正在校验 SQL 安全性...",
            "execute_sql": "正在执行数据库查询...",
            "generate_response": "正在生成最终分析报告...",
            "completed": "处理完成！",
            "failed": "处理失败，请稍后重试"
          }
          # 如果是没有翻译的内部状态，过滤掉下划线，首字母大写
          formatted_phase = current_phase.replace("_", " ").title() if current_phase else "处理中"
          status_msg = phase_messages.get(current_phase, f"正在处理: {formatted_phase}...")
          yield {
            "type": "status",
            "content": status_msg,
            "done": False
          }

        # 1. 思考节点
        if kind == "on_chat_model_stream" and node_name == "explicit_thinking":
          tags = event.get("tags", [])
          if "explicit_thinking_llm" in tags:
              chunk = event["data"]["chunk"]
              content = chunk.content
              if content:
                  accumulated_thinking += content
                  yield {
                    "type": "thinking",
                    "content": content,
                    "done": False
                  }
        elif kind == "on_chain_end" and node_name == "explicit_thinking":
          if accumulated_thinking:
            self.logger.info(f"Explicit Thinking Process: {accumulated_thinking}")

        # 2. SQL 生成节点
        elif node_name == "generate_sql":
          if kind == "on_chain_start" and event_name == "generate_sql":
            yield {
              "type": "status",
              "content": "开始分析数据并生成 SQL...",
              "done": False
            }
          elif kind == "on_chain_end" and event_name == "generate_sql":
            node_data = event["data"]["output"]
            if isinstance(node_data, dict) and "sql_attempt" in node_data:
              sql_attempt = node_data.get("sql_attempt")
              if sql_attempt:
                current_sql = sql_attempt.get("query")
                sql_thought = sql_attempt.get("thought", "")
                yield {
                  "type": "sql_generated",
                  "content": current_sql,
                  "thought": sql_thought,
                  "done": False
                }
                if sql_thought:
                  if "**📊 数据策略分析：**" in accumulated_thinking:
                    prefix = "\n\n**🔄 修正策略分析：**\n"
                  else:
                    prefix = "\n\n**📊 数据策略分析：**\n" if accumulated_thinking else "**📊 数据策略分析：**\n"
                  
                  accumulated_thinking += prefix + sql_thought
                  yield {
                    "type": "thinking",
                    "content": prefix + sql_thought,
                    "done": False
                  }

        # 3. SQL 校验节点
        elif kind == "on_chain_end" and node_name == "validate_sql":
          node_data = event["data"]["output"]
          if isinstance(node_data, dict) and "validation_result" in node_data:
            validation = node_data.get("validation_result", {})
            if validation.get("is_valid"):
              yield {
                "type": "status",
                "content": "SQL 校验通过",
                "done": False
              }
            else:
              yield {
                "type": "error",
                "content": self._format_user_friendly_error(validation.get("message", "SQL 校验失败")),
                "done": False
              }

        # 4. SQL 执行节点
        elif kind == "on_chain_end" and node_name == "execute_sql":
          node_data = event["data"]["output"]
          if isinstance(node_data, dict) and "execution_result" in node_data:
            exec_result = node_data.get("execution_result", {})
            if exec_result.get("data") is not None:
              row_count = exec_result.get("row_count", 0)
              is_truncated = exec_result.get("truncated", False)
              msg = f"查询成功，返回 {row_count} 条记录"
              if is_truncated:
                msg += " (已截断)"
              yield {
                "type": "execution_result",
                "content": msg,
                "done": False
              }
            elif exec_result.get("error"):
              yield {
                "type": "error",
                "content": self._format_user_friendly_error(exec_result["error"]),
                "done": False
              }

        # 5. 最终回答节点
        elif node_name == "generate_response":
          if kind == "on_chat_model_stream":
            tags = event.get("tags", [])
            if "report_generator" in tags:
                chunk = event["data"]["chunk"]
                if hasattr(chunk, "content"):
                    content = chunk.content
                else:
                    content = str(chunk)
                if content:
                    yield {
                        "type": "answer_chunk",
                        "content": content,
                        "done": False
                    }
          elif kind == "on_chain_start":
            self.logger.info("generate_response_node_started", session_id=session_id)
          elif kind == "on_chain_end":
            node_data = event["data"].get("output", {})
            self.logger.info("generate_response_node_ended", session_id=session_id)
            if isinstance(node_data, dict) and "final_output" in node_data:
              final_out = node_data.get("final_output")
              if final_out and not has_streamed_final_answer:
                has_streamed_final_answer = True
                yield {
                  "type": "final_answer",
                  "content": final_out.get("content", ""),
                  "thinking": accumulated_thinking,
                  "sql": current_sql,
                  "chartOption": final_out.get("chart_option"),
                  "done": True
                }
                self.logger.info("final_answer_sent", session_id=session_id, content_length=len(final_out.get("content", "")))
              elif not final_out:
                # 节点内部捕获了异常，返回 final_output: None，发送具体错误信息
                err_detail = node_data.get("last_error", "报告生成失败，请重试")
                self.logger.error("generate_response_failed_silently", session_id=session_id, error=err_detail)
                yield {
                  "type": "error",
                  "content": err_detail,
                  "done": True
                }
                has_streamed_final_answer = True  # 防止最后 fallback 重复发送
          elif kind == "on_chain_error":
            error_msg = event.get("data", {}).get("error", "未知错误")
            self.logger.error("generate_response_node_error", session_id=session_id, error=error_msg)
            yield {
              "type": "error",
              "content": f"报告生成失败：{self._format_user_friendly_error(error_msg)}",
              "done": False
            }

      if not has_streamed_final_answer:
        # 如果重试次数耗尽，从 state 中提取最后的错误信息并展示
        last_err = "未知错误"
        
        # 尝试从状态图中获取最后的状态
        try:
          current_state = self.graph.get_state(config).values
          if current_state and current_state.get("last_error"):
            last_err = current_state.get("last_error")
          elif current_state and current_state.get("messages"):
             # 从 messages 中提取最后一个 HumanMessage（通常是错误反馈）
             for msg in reversed(current_state["messages"]):
                if isinstance(msg, HumanMessage) and ("失败" in msg.content or "异常" in msg.content):
                   last_err = msg.content
                   break
        except Exception:
          pass

        yield {
          "type": "error",
          "content": f"未能生成有效回答：重试次数已耗尽。\n\n**最后一次错误原因**：\n{last_err}",
          "done": True
        }

      self.logger.info("agent_stream_completed", session_id=session_id)

    except Exception as e:
      import traceback
      traceback.print_exc()
      self.logger.error("agent_stream_failed", error=str(e), exc_info=True)
      yield {
        "type": "error",
        "content": self._format_user_friendly_error(str(e)),
        "done": True
      }

  def _extract_final_answer(self, state: AgentState) -> dict[str, Any]:
    final_out = state.get("final_output", {})
    exec_result = state.get("execution_result", {})
    thinking = state.get("thinking", "")
    sql_attempt = state.get("sql_attempt", {})
    error = state.get("last_error") or state.get("has_error", False)

    response = {
      "summary": error if error else final_out.get("summary", "未能生成有效回答"),
      "sql": sql_attempt.get("query", None),
      "chartOption": final_out.get("chart_option", None),
      "data": exec_result.get("data", None),
      "thinking": thinking,
      "error": state.get("last_error", None),
    }

    # 兼容旧逻辑：如果 messages 有内容，补充 summary
    messages = state.get("messages", [])
    if messages and not response["summary"]:
      last_message = messages[-1]
      if isinstance(last_message, AIMessage):
        response["summary"] = last_message.content

    return response
