"""
LangGraph Agent 核心实现
使用 StateGraph 构建 ReAct Agent
"""
from typing import Literal, Dict, Any
from langchain_core.messages import HumanMessage, AIMessage, SystemMessage
from langgraph.graph import StateGraph, START, END
from langgraph.prebuilt import ToolNode
from langgraph.checkpoint.memory import MemorySaver

import sys
import os

# Add parent directory to sys.path to allow imports from backend root
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from .state import AgentState
from .tools import create_tools
from .prompts import get_system_prompt

try:
    from config import settings
    from logging_config import get_logger
except ImportError:
    # Fallback for relative imports if running as package
    from ...config import settings
    from ...logging_config import get_logger

# 条件导入 ChatAnthropic
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
        
        # 初始化 LLM
        if llm:
            self.llm = llm
        elif not ANTHROPIC_AVAILABLE or not settings.ANTHROPIC_API_KEY:
            self.logger.warning("anthropic_api_key_missing", message="ANTHROPIC_API_KEY not set or langchain_anthropic not available, using mock LLM")
            # Create a mock LLM for development
            from langchain_core.language_models import BaseLanguageModel
            from langchain_core.messages import AIMessage
            
            class MockLLM(BaseLanguageModel):
                def __init__(self, **kwargs):
                    pass
                
                async def ainvoke(self, messages, **kwargs):
                    return AIMessage(content="Mock response: LLM not configured. Please set ANTHROPIC_API_KEY in your environment.")
                
                def invoke(self, messages, **kwargs):
                    return AIMessage(content="Mock response: LLM not configured.")
                
                def generate_prompt(self, messages, **kwargs):
                    return "Mock prompt"
                
                async def agenerate_prompt(self, messages, **kwargs):
                    return "Mock prompt"
                
                def bind_tools(self, tools):
                    return self
            
            self.llm = MockLLM()
        else:
            self.llm = ChatAnthropic(
                model=settings.ANTHROPIC_MODEL,
                api_key=settings.ANTHROPIC_API_KEY,
                temperature=settings.LLM_TEMPERATURE,
                max_tokens=settings.LLM_MAX_TOKENS,
                timeout=settings.LLM_TIMEOUT,
                streaming=settings.ENABLE_STREAMING
            )
        
        # 创建工具
        self.tools = create_tools(db_engine, retriever)
        
        # 绑定工具到 LLM
        self.llm_with_tools = self.llm.bind_tools(self.tools)
        
        # 创建状态图
        self.graph = self._create_graph()
        
        self.logger.info(
            "agent_initialized",
            model=settings.ANTHROPIC_MODEL,
            tool_count=len(self.tools)
        )
    
    def _create_graph(self) -> StateGraph:
        """创建 LangGraph 状态图"""
        
        # 创建工具节点
        tool_node = ToolNode(self.tools)
        
        # 定义节点函数
        async def agent_node(state: AgentState) -> AgentState:
            """Agent 推理节点"""
            try:
                self.logger.info("agent_reasoning", query=state.get("query", ""))
                
                # 构建消息
                messages = state.get("messages", [])
                if not messages:
                    # 首次调用，添加系统提示和用户查询
                    system_prompt = get_system_prompt()
                    messages = [
                        SystemMessage(content=system_prompt),
                        HumanMessage(content=state["query"])
                    ]
                
                # 调用 LLM
                response = await self.llm_with_tools.ainvoke(messages)
                
                # 更新状态
                return {
                    **state,
                    "messages": messages + [response],
                    "steps": state.get("steps", []) + ["agent_reasoning"]
                }
                
            except Exception as e:
                self.logger.error("agent_reasoning_failed", error=str(e), exc_info=True)
                return {
                    **state,
                    "error": f"Agent 推理失败: {str(e)}",
                    "steps": state.get("steps", []) + ["agent_error"]
                }
        
        async def tools_node(state: AgentState) -> AgentState:
            """工具执行节点"""
            try:
                self.logger.info("executing_tools")
                
                # 执行工具
                result = await tool_node.ainvoke(state)
                
                return {
                    **state,
                    **result,
                    "steps": state.get("steps", []) + ["tool_execution"]
                }
                
            except Exception as e:
                self.logger.error("tool_execution_failed", error=str(e), exc_info=True)
                return {
                    **state,
                    "error": f"工具执行失败: {str(e)}",
                    "steps": state.get("steps", []) + ["tool_error"]
                }
        
        def should_continue(state: AgentState) -> Literal["tools", "end"]:
            """决定是否继续执行工具"""
            messages = state.get("messages", [])
            if not messages:
                return "end"
            
            last_message = messages[-1]
            
            # 检查是否有工具调用
            if hasattr(last_message, "tool_calls") and last_message.tool_calls:
                return "tools"
            
            return "end"
        
        # 构建状态图
        workflow = StateGraph(AgentState)
        
        # 添加节点
        workflow.add_node("agent", agent_node)
        workflow.add_node("tools", tools_node)
        
        # 添加边
        workflow.add_edge(START, "agent")
        workflow.add_conditional_edges(
            "agent",
            should_continue,
            {
                "tools": "tools",
                "end": END
            }
        )
        workflow.add_edge("tools", "agent")
        
        # 添加检查点（用于持久化状态）
        memory = MemorySaver()
        
        # 编译图
        return workflow.compile(checkpointer=memory)
    
    async def ainvoke(
        self,
        query: str,
        session_id: str = "default",
        metadata: Dict[str, Any] = None
    ) -> Dict[str, Any]:
        """
        异步调用 Agent
        
        Args:
            query: 用户查询
            session_id: 会话 ID
            metadata: 元数据
            
        Returns:
            Agent 响应
        """
        try:
            self.logger.info("agent_invoked", query=query, session_id=session_id)
            
            # 初始化状态
            initial_state: AgentState = {
                "messages": [],
                "query": query,
                "context": [],
                "sql_query": None,
                "sql_result": None,
                "data_insight": None,
                "echarts_option": None,
                "error": None,
                "retry_count": 0,
                "steps": [],
                "session_id": session_id,
                "metadata": metadata or {}
            }
            
            # 执行图
            config = {"configurable": {"thread_id": session_id}}
            result = await self.graph.ainvoke(initial_state, config)
            
            # 提取最终答案
            final_response = self._extract_final_answer(result)
            
            self.logger.info(
                "agent_completed",
                session_id=session_id,
                steps=len(result.get("steps", []))
            )
            
            return final_response
            
        except Exception as e:
            self.logger.error(
                "agent_invocation_failed",
                error=str(e),
                query=query,
                exc_info=True
            )
            return {
                "error": f"Agent 执行失败: {str(e)}",
                "query": query
            }
    
    async def astream(
        self,
        query: str,
        session_id: str = "default",
        metadata: Dict[str, Any] = None
    ):
        """
        异步流式调用 Agent
        
        Args:
            query: 用户查询
            session_id: 会话 ID
            metadata: 元数据
            
        Yields:
            Agent 执行过程中的事件
        """
        try:
            self.logger.info("agent_stream_started", query=query, session_id=session_id)
            
            # 初始化状态
            initial_state: AgentState = {
                "messages": [],
                "query": query,
                "context": [],
                "sql_query": None,
                "sql_result": None,
                "data_insight": None,
                "echarts_option": None,
                "error": None,
                "retry_count": 0,
                "steps": [],
                "session_id": session_id,
                "metadata": metadata or {}
            }
            
            # 流式执行图
            config = {"configurable": {"thread_id": session_id}}
            async for event in self.graph.astream(initial_state, config):
                yield event
            
            self.logger.info("agent_stream_completed", session_id=session_id)
            
        except Exception as e:
            self.logger.error(
                "agent_stream_failed",
                error=str(e),
                query=query,
                exc_info=True
            )
            yield {"error": str(e)}
    
    def _extract_final_answer(self, state: AgentState) -> Dict[str, Any]:
        """
        从状态中提取最终答案
        
        Args:
            state: Agent 状态
            
        Returns:
            格式化的最终答案
        """
        messages = state.get("messages", [])
        
        if not messages:
            return {
                "summary": "未能生成答案",
                "sql": None,
                "chartOption": None
            }
        
        # 获取最后一条 AI 消息
        last_message = messages[-1]
        
        if isinstance(last_message, AIMessage):
            return {
                "summary": last_message.content,
                "sql": state.get("sql_query"),
                "chartOption": state.get("echarts_option"),
                "error": state.get("error")
            }
        
        return {
            "summary": str(last_message),
            "sql": state.get("sql_query"),
            "chartOption": state.get("echarts_option"),
            "error": state.get("error")
        }
