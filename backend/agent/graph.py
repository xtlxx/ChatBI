# agent/graph.py
import logging
from typing import Literal, Dict, Any, List, cast
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage, BaseMessage
from langgraph.graph import StateGraph, START, END
from langgraph.prebuilt import ToolNode
from langgraph.checkpoint.memory import MemorySaver

# === 导入配置与工具 ===
try:
    # 生产环境：假设 config 在项目根目录，作为包的一部分运行
    from config import settings
    from logging_config import get_logger
except ImportError:
    # 开发环境/回退：尝试相对导入
    try:
        from ..config import settings
        from ..logging_config import get_logger
    except ImportError:
        # 最后的兜底，仅用于防止 Import 错误导致 Crash
        import logging
        get_logger = logging.getLogger
        class Settings:
            ANTHROPIC_API_KEY = None
            ANTHROPIC_MODEL = "claude-3-opus-20240229"
            LLM_TEMPERATURE = 0
            LLM_MAX_TOKENS = 4000
            LLM_TIMEOUT = 30
            ENABLE_STREAMING = True
        settings = Settings()

# === 内部模块导入 ===
from .state import AgentState
from .tools import create_tools
from .prompts import get_system_prompt

# === 条件导入 Anthropic ===
try:
    from langchain_anthropic import ChatAnthropic
    ANTHROPIC_AVAILABLE = True
except ImportError:
    ChatAnthropic = None
    ANTHROPIC_AVAILABLE = False

logger = get_logger(__name__)


class ChatBIAgent:
    """ChatBI Agent - 基于 LangGraph 的 SQL 分析 Agent"""

    def __init__(self, db_engine, retriever=None, llm=None):
        """
        初始化 Agent

        Args:
            db_engine: 数据库引擎
            retriever: 知识库检索器（可选）
            llm: 预配置的 LLM 实例（可选）
        """
        self.db_engine = db_engine
        self.retriever = retriever
        self.logger = get_logger(self.__class__.__name__)

        # 1. 初始化 LLM
        if llm:
            self.llm = llm
        elif not ANTHROPIC_AVAILABLE or not settings.ANTHROPIC_API_KEY:
            self.logger.warning(
                "anthropic_api_key_missing",
                message="ANTHROPIC_API_KEY 未设置或库不可用，使用 Mock LLM"
            )
            # 创建支持 bind_tools 的 Fake LLM
            from langchain_community.llms.fake import FakeListLLM

            class FakeLLMWithTools(FakeListLLM):
                """支持 bind_tools 的 Fake LLM"""
                def bind_tools(self, tools, **kwargs):
                    return self

                async def ainvoke(self, input, *args, **kwargs):
                    # 模拟一个简单的回复
                    return AIMessage(content="[Mock] 这是一个模拟回复。请配置 ANTHROPIC_API_KEY 以获得真实响应。")

            self.llm = FakeLLMWithTools(responses=["Mock Response"])
        else:
            self.llm = ChatAnthropic(
                model=settings.ANTHROPIC_MODEL,
                api_key=settings.ANTHROPIC_API_KEY,
                temperature=settings.LLM_TEMPERATURE,
                max_tokens=settings.LLM_MAX_TOKENS,
                timeout=settings.LLM_TIMEOUT,
                streaming=settings.ENABLE_STREAMING
            )

        # 2. 创建并绑定工具
        self.tools = create_tools(db_engine, retriever)
        self.llm_with_tools = self.llm.bind_tools(self.tools)

        # 3. 创建状态图
        self.graph = self._create_graph()

        self.logger.info(
            "agent_initialized",
            model=settings.ANTHROPIC_MODEL,
            tool_count=len(self.tools)
        )

    def _create_graph(self) -> StateGraph:
        """创建 LangGraph 状态图"""

        # 创建 LangGraph 标准工具节点
        tool_node = ToolNode(self.tools)

        # --- 节点定义 ---

        async def agent_node(state: AgentState) -> Dict[str, Any]:
            """
            Agent 核心推理节点
            负责构建 Prompt 并调用 LLM
            """
            try:
                current_messages = state.get("messages", [])
                query = state.get("query", "")

                self.logger.info("agent_reasoning", query=query, history_len=len(current_messages))

                # --- 构建 Prompt ---
                # 为了保持状态（State）的清洁，我们不把 System Prompt 永久写入 State 的 message list，
                # 而是每次在调用 LLM 时临时构建一个新的 message list。

                system_text = get_system_prompt()

                # 增强指令：强制要求思考过程和格式
                enhanced_instruction = """
IMPORTANT: You MUST follow this strict 4-step format for your response:
1. **Thought Process**: Explain your thinking, analyze the schema, and plan the query.
2. **Decision**: State what you are going to do.
3. **Execute SQL**: You MUST use the `execute_sql` tool. Do NOT just print the SQL code.
4. **Report**: After getting the data, generate a summary and ECharts option.
"""
                system_message = SystemMessage(content=f"{system_text}\n{enhanced_instruction}")

                # 检查历史消息中是否已经包含 SystemMessage (避免重复)
                # 如果没有，则在本次推理的输入中临时添加
                input_messages = list(current_messages)
                if not input_messages or not isinstance(input_messages[0], SystemMessage):
                    input_messages.insert(0, system_message)

                # --- 调用 LLM ---
                response = await self.llm_with_tools.ainvoke(input_messages)

                # --- 返回结果 ---
                # 关键修复：因为 State 定义中 messages 使用了 add_messages (append)
                # 所以这里我们只返回 [新生成的消息]，而不是 [历史 + 新消息]
                return {
                    "messages": [response],
                    "steps": ["agent_reasoning"] # 这里会追加到 steps 列表
                }

            except Exception as e:
                self.logger.error("agent_reasoning_failed", error=str(e), exc_info=True)
                # 返回错误信息给用户，而不是让程序崩溃
                return {
                    "messages": [AIMessage(content=f"抱歉，推理过程中发生错误: {str(e)}")],
                    "error": f"Agent 推理失败: {str(e)}",
                    "steps": ["agent_error"]
                }

        async def tools_node_wrapper(state: AgentState) -> Dict[str, Any]:
            """
            工具执行节点包装器
            """
            try:
                self.logger.info("executing_tools")

                # 调用 LangGraph 预置的 ToolNode
                # 它会执行 last_message 中的 tool_calls，并返回 ToolMessages
                result = await tool_node.ainvoke(state)

                # result 格式为 {"messages": [ToolMessage, ...]}
                return {
                    "messages": result["messages"],
                    "steps": ["tool_execution"]
                }

            except Exception as e:
                self.logger.error("tool_execution_failed", error=str(e), exc_info=True)
                return {
                    "error": f"工具执行失败: {str(e)}",
                    "steps": ["tool_error"]
                }

        def should_continue(state: AgentState) -> Literal["tools", "end"]:
            """
            条件边：决定下一步是继续执行工具还是结束
            """
            messages = state.get("messages", [])
            if not messages:
                return "end"

            last_message = messages[-1]

            # 检查最后一条消息是否有工具调用请求
            if hasattr(last_message, "tool_calls") and last_message.tool_calls:
                return "tools"

            return "end"

        # --- 构建图结构 ---
        workflow = StateGraph(AgentState)

        # 添加节点
        workflow.add_node("agent", agent_node)
        workflow.add_node("tools", tools_node_wrapper)

        # 添加边
        workflow.add_edge(START, "agent")

        # 添加条件边
        workflow.add_conditional_edges(
            "agent",
            should_continue,
            {
                "tools": "tools",
                "end": END
            }
        )

        # 工具执行完后，必须回到 Agent 节点进行解释/总结
        workflow.add_edge("tools", "agent")

        # 添加持久化记忆
        memory = MemorySaver()

        return workflow.compile(checkpointer=memory)

    async def ainvoke(
        self,
        query: str,
        session_id: str = "default",
        metadata: Dict[str, Any] = None
    ) -> Dict[str, Any]:
        """
        异步调用 Agent (入口)
        """
        try:
            self.logger.info("agent_invoked", query=query, session_id=session_id)

            # 初始化输入状态
            # 注意：这里的 query 会被放入 state["query"]，
            # 但我们需要明确地将用户的 query 转化为一条 HumanMessage 放入 messages
            initial_inputs = {
                "messages": [HumanMessage(content=query)],
                "query": query,
                "session_id": session_id,
                "metadata": metadata or {},
                # 初始化其他字段，防止 KeyError（虽然 TypedDict 允许缺省，但明确更好）
                "steps": [],
                "error": None
            }

            config = {"configurable": {"thread_id": session_id}}

            # 执行图
            result = await self.graph.ainvoke(initial_inputs, config)

            # 提取结果
            final_response = self._extract_final_answer(result)

            self.logger.info(
                "agent_completed",
                session_id=session_id,
                steps_count=len(result.get("steps", []))
            )

            return final_response

        except Exception as e:
            self.logger.error("agent_invocation_failed", error=str(e), exc_info=True)
            return {
                "summary": f"系统错误: {str(e)}",
                "error": str(e),
                "sql": None,
                "chartOption": None
            }

    async def astream(
        self,
        query: str,
        session_id: str = "default",
        metadata: Dict[str, Any] = None
    ):
        """
        异步流式调用 Agent
        Yields: Delta updates or full state snapshots
        """
        try:
            self.logger.info("agent_stream_started", query=query, session_id=session_id)

            initial_inputs = {
                "messages": [HumanMessage(content=query)],
                "query": query,
                "session_id": session_id,
                "metadata": metadata or {},
                "steps": []
            }

            config = {"configurable": {"thread_id": session_id}}

            async for event in self.graph.astream(initial_inputs, config):
                yield event

            self.logger.info("agent_stream_completed", session_id=session_id)

        except Exception as e:
            self.logger.error("agent_stream_failed", error=str(e), exc_info=True)
            yield {"error": str(e)}

    def _extract_final_answer(self, state: AgentState) -> Dict[str, Any]:
        """
        从最终状态中提取标准化输出
        """
        messages = state.get("messages", [])

        # 默认值
        response = {
            "summary": "未能生成有效回答",
            "sql": None,
            "chartOption": None,
            "data": None,
            "error": state.get("error")
        }

        if not messages:
            return response

        # 1. 获取最后的 AI 回复
        last_message = messages[-1]
        if isinstance(last_message, AIMessage):
            response["summary"] = last_message.content
        elif isinstance(last_message, BaseMessage):
            response["summary"] = str(last_message.content)
        # 2. 倒序查找最近的一次 SQL 执行记录 (ToolMessage)
        import json
        from langchain_core.messages import ToolMessage

        # 倒序遍历消息
        for msg in reversed(messages):
            # 找到工具执行结果
            if isinstance(msg, ToolMessage) and msg.name == "execute_sql":
                try:
                    # 工具返回的是 JSON 字符串，需要解析
                    content = msg.content
                    if isinstance(content, str):
                        data_json = json.loads(content)
                        if data_json.get("success"):
                            response["data"] = data_json.get("data")
                            # 如果 ToolMessage 没有保存 SQL，我们需要找调用它的那条 AIMessage
                            # 但通常 execute_sql 的结果里最好包含执行的 SQL
                            # 这里假设 execute_sql 返回结果没有包含原始 SQL，我们需要去 ToolCall 找
                            pass
                except Exception as e:
                    self.logger.warning(f"解析 ToolMessage 失败: {e}")

            # 找到触发工具调用的 AI 消息，提取 SQL
            if isinstance(msg, AIMessage) and msg.tool_calls:
                for tool_call in msg.tool_calls:
                    try:
                        if tool_call.get("name") == "execute_sql":
                            # 处理 args：可能是字典或 JSON 字符串
                            args = tool_call.get("args")
                            
                            if isinstance(args, dict):
                                # 直接是字典，正常获取
                                response["sql"] = args.get("query")
                            elif isinstance(args, str):
                                # 是字符串，尝试解析为 JSON
                                try:
                                    args_dict = json.loads(args)
                                    response["sql"] = args_dict.get("query")
                                except json.JSONDecodeError:
                                    self.logger.warning(f"无法解析 tool_call args: {args}")
                            else:
                                self.logger.warning(f"未知的 args 类型: {type(args)}")
                            
                            # 找到最近的一个 SQL 就可以停止了
                            if response["data"]:
                                break
                    except Exception as e:
                        self.logger.warning(f"提取 SQL 失败: {e}")
                        continue

            # 如果 SQL 和 Data 都找到了，就退出循环
            if response["sql"] and response["data"]:
                break
        # 3. 尝试提取图表配置（支持多种格式）
        import re
        if response["summary"]:
            chart_json = None
            
            # 方法1: 匹配 markdown 代码块中的 JSON
            # 支持 ```json ... ``` 或 ```echarts ... ``` 或单纯的 ```{...}```
            pattern1 = r"```(?:json|echarts)?\s*(\{.*?\})\s*```"
            match1 = re.search(pattern1, response["summary"], re.DOTALL)
            if match1:
                try:
                    chart_json = json.loads(match1.group(1))
                    self.logger.info("从 markdown 代码块提取图表配置")
                except:
                    pass
            
            # 方法2: 匹配 Analysis: 标签后的 JSON （Qwen 常用格式）
            if not chart_json:
                pattern2 = r"Analysis:\s*(\{[^`]*?\})"
                match2 = re.search(pattern2, response["summary"], re.DOTALL)
                if match2:
                    try:
                        # 清理可能的额外空白和换行
                        json_str = match2.group(1).strip()
                        chart_json = json.loads(json_str)
                        self.logger.info("从 Analysis 标签提取图表配置")
                    except Exception as e:
                        self.logger.warning(f"解析 Analysis JSON 失败: {e}")
            
            # 方法3: 在整个响应中查找任何看起来像 ECharts 配置的 JSON
            if not chart_json:
                # 查找包含 series 或 xAxis 的 JSON 对象
                pattern3 = r"\{[^{}]*(?:\{[^{}]*\}[^{}]*)*(?:\"series\"|\"xAxis\"|\"yAxis\")[^{}]*(?:\{[^{}]*\}[^{}]*)*\}"
                matches3 = re.findall(pattern3, response["summary"], re.DOTALL)
                for match_str in matches3:
                    try:
                        chart_json = json.loads(match_str)
                        if "series" in chart_json or "xAxis" in chart_json:
                            self.logger.info("从响应文本提取图表配置")
                            break
                    except:
                        continue
            
            # 如果成功提取到图表配置，进行验证和存储
            if chart_json:
                # 简单的特征检查，确认是 ECharts 配置
                if isinstance(chart_json, dict) and ("series" in chart_json or "xAxis" in chart_json or "yAxis" in chart_json):
                    response["chartOption"] = chart_json
                    chart_type = "unknown"
                    if chart_json.get("series") and len(chart_json["series"]) > 0:
                        chart_type = chart_json["series"][0].get("type", "unknown")
                    self.logger.info(f"成功提取图表配置，类型: {chart_type}")
                    # 可选：从 summary 中移除 JSON，让回复更干净
                    # response["summary"] = re.sub(pattern1, "", response["summary"], flags=re.DOTALL).strip()
        return response
