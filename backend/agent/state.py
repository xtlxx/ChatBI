#agent/state.py
"""
LangGraph Agent 状态定义
定义 Agent 执行过程中的状态结构
"""
from typing import TypedDict, Annotated, List, Dict, Any, Optional
from operator import add
from langchain_core.messages import BaseMessage
from langgraph.graph.message import add_messages

class AgentState(TypedDict):
    """Agent 状态定义"""
    #消息历史 -使用LangGraph内置的add_messages，处理ID去重
    messages: Annotated[List[BaseMessage], add_messages]

    # 用户原始查询
    query: str
    
    # 检索到的上下文
    context: Annotated[List[Dict[str, Any]], add]
    
    # 生成的 SQL 查询
    sql_query: Optional[str]
    
    # SQL 执行结果
    sql_result: Optional[Any]
    
    # 数据洞察
    data_insight: Optional[str]
    
    # ECharts 配置
    echarts_option: Optional[Dict[str, Any]]
    
    # 错误信息
    error: Optional[str]
    
    # 重试计数
    retry_count: int
    
    # 执行步骤追踪
    steps: Annotated[List[str], add]
    
    # 会话 ID
    session_id: str
    
    # 元数据
    metadata: Dict[str, Any]


class ConversationMemory(TypedDict):
    """对话记忆状态"""
    
    # 会话 ID
    session_id: str
    
    # 消息历史
    messages: List[BaseMessage]
    
    # 实体追踪
    entities: Dict[str, Any]
    
    # 对话摘要
    summary: Optional[str]
    
    # 最后更新时间
    last_updated: float
