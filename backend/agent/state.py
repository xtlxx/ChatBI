# agent/state.py
# 定义 Agent 执行过程中的状态结构
# 包含核心输入、流程控制、中间产物、错误与降级等
import operator
from typing import Annotated, Any, TypedDict

from langchain_core.messages import BaseMessage


class AgentState(TypedDict):
    # ── 核心输入 ──
    query: str                                             # 用户原始问题
    session_id: str                                        # 会话标识
    messages: Annotated[list[BaseMessage], operator.add]   # 完整对话历史
    metadata: dict[str, Any]                               # few_shot_examples、user_id 等

    # ── 流程控制 ──
    current_phase: str
    steps: Annotated[list[str], operator.add]          # 执行过的节点名日志
    retry_counts: dict[str, int]                       # 按阶段统计重试次数（更精细）

    # ── 中间产物 ──
    schema_context: str | None                         # 动态获取的 schema
    thinking: str | None                               # 业务思考过程（自然语言）
    sql_attempt: dict[str, Any] | None                 # 最新一次 SQL 生成结果
    validation_result: dict[str, Any] | None           # { "is_valid": bool, "issues": list[str], "message": str }
    execution_result: dict[str, Any] | None            # { "data": list[dict], "row_count": int, "truncated": bool, "error": str | None }
    final_output: dict[str, Any] | None                # 最终给前端的结构化结果

    # ── 错误与降级 ──
    has_error: bool                                    # 是否进入错误路径
    last_error: str | None                             # 用户友好错误信息
    error_phase: str | None                            # 出错的阶段名称
    fallback_used: bool                                # 是否使用了降级方案（静态、schema 、简单报告）

    # ── 元信息（调试 & 监控用） ──
    timings: dict[str, float]                          # 各阶段耗时（毫秒）
    #token_usage: dict[str, int]                        # 如果能拿到 LLM token 消耗