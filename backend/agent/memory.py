"""
内存管理系统
实现多层次的对话记忆，包括短期记忆、摘要记忆和实体追踪
"""
import time
from typing import Dict, List, Any, Optional
from langchain_core.messages import BaseMessage, HumanMessage, AIMessage
from langchain_core.chat_history import BaseChatMessageHistory

# Conditional import for ChatAnthropic
try:
    from langchain_anthropic import ChatAnthropic
    ANTHROPIC_AVAILABLE = True
except ImportError:
    ChatAnthropic = None
    ANTHROPIC_AVAILABLE = False

import sys
import os

# Add parent directory to sys.path to allow imports from backend root
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

try:
    from config import settings
    from logging_config import get_logger
except ImportError:
    # Fallback for relative imports if running as package
    from ...config import settings
    from ...logging_config import get_logger

logger = get_logger(__name__)


class ConversationMemoryManager:
    """对话记忆管理器"""
    
    def __init__(
        self,
        llm: Optional[Any] = None,  # Changed from ChatAnthropic to Any
        max_token_limit: int = 4000,
        summary_threshold: int = 10
    ):
        """
        初始化记忆管理器
        
        Args:
            llm: 用于生成摘要的 LLM
            max_token_limit: 最大 token 限制
            summary_threshold: 触发摘要的消息数量阈值
        """
        self.logger = get_logger(self.__class__.__name__)
        
        if llm:
            self.llm = llm
        elif ANTHROPIC_AVAILABLE and settings.ANTHROPIC_API_KEY:
            self.llm = ChatAnthropic(
                model=settings.ANTHROPIC_MODEL,
                api_key=settings.ANTHROPIC_API_KEY,
                temperature=0.0
            )
        else:
            # Create a mock LLM for development
            from langchain_core.language_models import BaseLanguageModel
            from langchain_core.messages import AIMessage
            
            class MockLLM(BaseLanguageModel):
                def __init__(self, **kwargs):
                    pass
                
                async def ainvoke(self, messages, **kwargs):
                    return AIMessage(content="Mock summary: LLM not configured.")
                
                def invoke(self, messages, **kwargs):
                    return AIMessage(content="Mock summary: LLM not configured.")
                
                def generate_prompt(self, messages, **kwargs):
                    return "Mock prompt"
                
                async def agenerate_prompt(self, messages, **kwargs):
                    return "Mock prompt"
                
                def bind_tools(self, tools):
                    return self
            
            self.llm = MockLLM()
            self.logger.warning("using_mock_llm", message="LLM not configured, using mock for memory management")
        self.max_token_limit = max_token_limit
        self.summary_threshold = summary_threshold
        
        # 存储会话记忆
        self.sessions: Dict[str, Dict[str, Any]] = {}
    
    def get_session(self, session_id: str) -> Dict[str, Any]:
        """
        获取会话记忆
        
        Args:
            session_id: 会话 ID
            
        Returns:
            会话记忆数据
        """
        if session_id not in self.sessions:
            self.sessions[session_id] = {
                "messages": [],
                "summary": None,
                "entities": {},
                "created_at": time.time(),
                "last_updated": time.time()
            }
        
        return self.sessions[session_id]
    
    def add_message(self, session_id: str, message: BaseMessage) -> None:
        """
        添加消息到会话记忆
        
        Args:
            session_id: 会话 ID
            message: 消息对象
        """
        session = self.get_session(session_id)
        session["messages"].append(message)
        session["last_updated"] = time.time()
        
        # 检查是否需要生成摘要
        if len(session["messages"]) >= self.summary_threshold:
            self._maybe_summarize(session_id)
    
    def get_messages(
        self,
        session_id: str,
        limit: Optional[int] = None
    ) -> List[BaseMessage]:
        """
        获取会话消息
        
        Args:
            session_id: 会话 ID
            limit: 返回的消息数量限制
            
        Returns:
            消息列表
        """
        session = self.get_session(session_id)
        messages = session["messages"]
        
        if limit:
            return messages[-limit:]
        
        return messages
    
    def get_context(self, session_id: str) -> str:
        """
        获取会话上下文（包括摘要和最近消息）
        
        Args:
            session_id: 会话 ID
            
        Returns:
            格式化的上下文字符串
        """
        session = self.get_session(session_id)
        
        context_parts = []
        
        # 添加摘要
        if session["summary"]:
            context_parts.append(f"对话摘要：{session['summary']}")
        
        # 添加实体信息
        if session["entities"]:
            entities_str = ", ".join(
                f"{k}: {v}" for k, v in session["entities"].items()
            )
            context_parts.append(f"关键实体：{entities_str}")
        
        # 添加最近的消息
        recent_messages = self.get_messages(session_id, limit=5)
        if recent_messages:
            messages_str = "\n".join(
                f"{'用户' if isinstance(m, HumanMessage) else 'AI'}: {m.content}"
                for m in recent_messages
            )
            context_parts.append(f"最近对话：\n{messages_str}")
        
        return "\n\n".join(context_parts)
    
    async def _maybe_summarize(self, session_id: str) -> None:
        """
        如果需要，生成对话摘要
        
        Args:
            session_id: 会话 ID
        """
        try:
            session = self.get_session(session_id)
            messages = session["messages"]
            
            # 构建摘要提示
            conversation_text = "\n".join(
                f"{'用户' if isinstance(m, HumanMessage) else 'AI'}: {m.content}"
                for m in messages
            )
            
            summary_prompt = f"""请对以下对话进行简洁的摘要，保留关键信息和上下文：

{conversation_text}

摘要："""
            
            # 生成摘要
            response = await self.llm.ainvoke([HumanMessage(content=summary_prompt)])
            summary = response.content
            
            # 更新会话
            session["summary"] = summary
            session["messages"] = messages[-5:]  # 只保留最近5条消息
            
            self.logger.info(
                "conversation_summarized",
                session_id=session_id,
                message_count=len(messages)
            )
            
        except Exception as e:
            self.logger.error(
                "summarization_failed",
                error=str(e),
                session_id=session_id,
                exc_info=True
            )
    
    def extract_entities(self, session_id: str, text: str) -> None:
        """
        从文本中提取实体（简化版本）
        
        Args:
            session_id: 会话 ID
            text: 文本内容
        """
        session = self.get_session(session_id)
        
        # 这里可以使用 NER 模型或规则提取实体
        # 简化实现：提取常见的业务实体
        
        # 示例：提取客户名称、订单号等
        # 实际应用中应该使用更复杂的实体识别逻辑
        
        entities = session["entities"]
        
        # 简单的关键词匹配示例
        if "客户" in text:
            # 提取客户相关信息
            pass
        
        if "订单" in text:
            # 提取订单相关信息
            pass
    
    def clear_session(self, session_id: str) -> None:
        """
        清除会话记忆
        
        Args:
            session_id: 会话 ID
        """
        if session_id in self.sessions:
            del self.sessions[session_id]
            self.logger.info("session_cleared", session_id=session_id)
    
    def get_session_stats(self, session_id: str) -> Dict[str, Any]:
        """
        获取会话统计信息
        
        Args:
            session_id: 会话 ID
            
        Returns:
            统计信息
        """
        session = self.get_session(session_id)
        
        return {
            "message_count": len(session["messages"]),
            "has_summary": session["summary"] is not None,
            "entity_count": len(session["entities"]),
            "created_at": session["created_at"],
            "last_updated": session["last_updated"],
            "duration": time.time() - session["created_at"]
        }


class SimpleChatHistory(BaseChatMessageHistory):
    """简单的聊天历史实现"""
    
    def __init__(self, session_id: str, memory_manager: ConversationMemoryManager):
        self.session_id = session_id
        self.memory_manager = memory_manager
    
    @property
    def messages(self) -> List[BaseMessage]:
        """获取消息列表"""
        return self.memory_manager.get_messages(self.session_id)
    
    def add_message(self, message: BaseMessage) -> None:
        """添加消息"""
        self.memory_manager.add_message(self.session_id, message)
    
    def clear(self) -> None:
        """清除历史"""
        self.memory_manager.clear_session(self.session_id)
