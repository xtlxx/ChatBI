# agent/memory.py
"""
内存管理系统
实现多层次的对话记忆，包括短期记忆、摘要记忆和实体追踪
"""
import time
import asyncio
import logging
from typing import Dict, List, Any, Optional, Union
from langchain_core.messages import BaseMessage, HumanMessage, AIMessage, SystemMessage
from langchain_core.chat_history import BaseChatMessageHistory
from langchain_core.language_models import BaseLanguageModel

# === 配置与日志导入 ===
try:
    from config import settings
    from logging_config import get_logger
except ImportError:
    # Fallback for standalone usage
    import logging

    get_logger = logging.getLogger


    class Settings:
        ANTHROPIC_API_KEY = None
        ANTHROPIC_MODEL = "claude-3-haiku-20240307"


    settings = Settings()

logger = get_logger(__name__)

# === 依赖导入 ===
# 尝试导入 Anthropic，如果失败则标记不可用
try:
    from langchain_anthropic import ChatAnthropic

    ANTHROPIC_AVAILABLE = True
except ImportError:
    ChatAnthropic = None
    ANTHROPIC_AVAILABLE = False


class MockSummaryLLM:
    """
    当缺少 API Key 或依赖库时的 Mock LLM
    用于防止内存管理器初始化失败
    """

    async def ainvoke(self, input_data: Any, **kwargs) -> AIMessage:
        return AIMessage(content="[Mock Summary] 由于未配置 LLM，此处为模拟摘要。")


class ConversationMemoryManager:
    """
    对话记忆管理器
    负责存储消息、生成摘要和管理实体上下文
    """

    def __init__(
            self,
            llm: Optional[BaseLanguageModel] = None,
            max_token_limit: int = 4000,
            summary_threshold: int = 10
    ):
        """
        初始化记忆管理器

        Args:
            llm: 用于生成摘要的 LLM 实例
            max_token_limit: 最大 token 限制 (估算)
            summary_threshold: 触发摘要的消息数量阈值
        """
        self.logger = get_logger(self.__class__.__name__)

        # 1. 初始化 LLM
        if llm:
            self.llm = llm
        elif ANTHROPIC_AVAILABLE and settings.ANTHROPIC_API_KEY:
            # 使用较便宜的模型做摘要 (如 Haiku)
            self.llm = ChatAnthropic(
                model=settings.ANTHROPIC_MODEL,
                api_key=settings.ANTHROPIC_API_KEY,
                temperature=0.0,
                max_tokens=1024
            )
        else:
            self.logger.warning(
                "using_mock_llm_for_memory",
                message="未配置 Anthropic Key，使用 Mock LLM 进行记忆管理"
            )
            self.llm = MockSummaryLLM()

        self.max_token_limit = max_token_limit
        self.summary_threshold = summary_threshold

        # 内存存储结构: { session_id: { messages: [], summary: str, entities: {}, ... } }
        self.sessions: Dict[str, Dict[str, Any]] = {}

    def get_session(self, session_id: str) -> Dict[str, Any]:
        """获取或创建会话对象"""
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
        [同步] 添加消息到会话记忆
        注意：此方法仅做内存追加，不会触发异步摘要生成，以保证线程安全。
        """
        session = self.get_session(session_id)
        session["messages"].append(message)
        session["last_updated"] = time.time()

    async def add_message_async(self, session_id: str, message: BaseMessage) -> None:
        """
        [异步] 添加消息并尝试生成摘要
        推荐在 Async 环境下使用此方法
        """
        self.add_message(session_id, message)
        await self.process_new_message(session_id)

    async def process_new_message(self, session_id: str) -> None:
        """
        [异步] 处理新消息事件：检查是否需要生成摘要
        """
        session = self.get_session(session_id)
        # 检查是否触发摘要阈值
        if len(session["messages"]) >= self.summary_threshold:
            await self._generate_summary(session_id)

    def get_messages(
            self,
            session_id: str,
            limit: Optional[int] = None
    ) -> List[BaseMessage]:
        """获取会话消息列表"""
        session = self.get_session(session_id)
        messages = session["messages"]
        if limit:
            return messages[-limit:]
        return messages

    def get_context(self, session_id: str) -> str:
        """
        获取拼接好的上下文 Prompt (包含摘要、实体和最近消息)
        """
        session = self.get_session(session_id)
        context_parts = []

        # 1. 历史摘要
        if session["summary"]:
            context_parts.append(f"【历史对话摘要】：\n{session['summary']}")

        # 2. 关键实体
        if session["entities"]:
            entities_str = ", ".join(f"{k}: {v}" for k, v in session["entities"].items())
            context_parts.append(f"【已知信息】：\n{entities_str}")

        # 3. 最近消息 (保留最近 5-10 条)
        recent_limit = 10 if not session["summary"] else 5
        recent_messages = self.get_messages(session_id, limit=recent_limit)

        if recent_messages:
            msgs_str = []
            for m in recent_messages:
                role = "用户" if isinstance(m, HumanMessage) else "AI助手"
                msgs_str.append(f"{role}: {m.content}")

            context_parts.append("【近期对话】：\n" + "\n".join(msgs_str))

        return "\n\n".join(context_parts)

    async def _generate_summary(self, session_id: str) -> None:
        """
        [内部异步] 生成并更新对话摘要
        """
        try:
            session = self.get_session(session_id)
            messages = session["messages"]

            # 如果消息太少，无需摘要
            if len(messages) < 3:
                return

            # 构建摘要 Prompt
            # 注意：这里我们提取所有待摘要的消息文本
            conversation_text = "\n".join(
                f"{'User' if isinstance(m, HumanMessage) else 'AI'}: {m.content}"
                for m in messages
            )

            existing_summary = session.get("summary", "")
            prompt_content = f"""
请对以下对话历史进行简洁的摘要更新。
保留关键的业务实体、用户需求和查询结果。忽略寒暄语。

原有摘要: {existing_summary or "无"}

新的对话片段:
{conversation_text}

请输出更新后的完整摘要：
"""

            # 调用 LLM
            response = await self.llm.ainvoke([HumanMessage(content=prompt_content)])
            new_summary = response.content

            # 更新状态
            session["summary"] = new_summary
            # 策略：生成摘要后，我们可以清理掉部分旧消息，只保留最近的 N 条
            # 例如保留最后 5 条用于保持对话流畅性
            keep_count = 5
            if len(messages) > keep_count:
                session["messages"] = messages[-keep_count:]

            self.logger.info(
                "conversation_summarized",
                session_id=session_id,
                old_len=len(messages),
                new_len=len(session["messages"])
            )

        except Exception as e:
            self.logger.error(
                "summarization_failed",
                error=str(e),
                session_id=session_id,
                exc_info=True
            )
            # 失败时不清除消息，防止丢失上下文

    def extract_entities(self, session_id: str, text: str) -> None:
        """
        [同步] 简单的关键词实体提取 (占位符)
        在实际生产中，建议使用专门的 NER 模型或 LLM 工具调用
        """
        session = self.get_session(session_id)
        entities = session["entities"]

        # 示例规则
        keywords = ["订单", "客户", "产品", "库存", "价格"]
        for kw in keywords:
            if kw in text:
                # 仅记录出现过的关键词，后续可作为 Context 检索的 Hint
                entities[f"related_{kw}"] = "True"

    def clear_session(self, session_id: str) -> None:
        """清除会话"""
        if session_id in self.sessions:
            del self.sessions[session_id]
            self.logger.info("session_cleared", session_id=session_id)

    def get_session_stats(self, session_id: str) -> Dict[str, Any]:
        """获取统计信息"""
        session = self.get_session(session_id)
        return {
            "message_count": len(session["messages"]),
            "has_summary": bool(session["summary"]),
            "entity_count": len(session["entities"]),
            "duration_seconds": int(time.time() - session["created_at"])
        }


class SimpleChatHistory(BaseChatMessageHistory):
    """
    适配 LangChain 的聊天历史类
    注意：此类必须保持同步接口，以兼容 BaseChatMessageHistory
    """

    def __init__(self, session_id: str, memory_manager: ConversationMemoryManager):
        self.session_id = session_id
        self.memory_manager = memory_manager

    @property
    def messages(self) -> List[BaseMessage]:
        """获取消息列表"""
        return self.memory_manager.get_messages(self.session_id)

    def add_message(self, message: BaseMessage) -> None:
        """
        添加消息 (同步)
        警告：此处不会触发自动摘要，因为父类方法是同步的。
        如果需要自动摘要，请在外部显式调用 memory_manager.process_new_message()
        """
        self.memory_manager.add_message(self.session_id, message)

    def clear(self) -> None:
        """清除历史"""
        self.memory_manager.clear_session(self.session_id)
