# models/chat.py
#聊天会话和消息模型

from datetime import UTC, datetime
from sqlalchemy import JSON, ForeignKey, Index, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base
from .user import User


def utcnow():
    return datetime.now(UTC).replace(tzinfo=None)

class ChatSession(Base):
    __tablename__ = "chat_sessions"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)  # UUID
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    title: Mapped[str] = mapped_column(String(200))
    created_at: Mapped[datetime] = mapped_column(default=utcnow)
    updated_at: Mapped[datetime] = mapped_column(default=utcnow, onupdate=utcnow)

    # 关系
    user: Mapped["User"] = relationship(back_populates="chat_sessions")
    messages: Mapped[list["ChatMessage"]] = relationship(
        back_populates="session", cascade="all, delete-orphan", order_by="ChatMessage.created_at"
    )


class ChatMessage(Base):
    __tablename__ = "chat_messages"
    __table_args__ = (
        Index("idx_chat_messages_role_feedback_created", "role", "feedback", "created_at"),
        Index("idx_chat_messages_session_role_created", "session_id", "role", "created_at"),
    )

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    session_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("chat_sessions.id", ondelete="CASCADE"), index=True
    )
    role: Mapped[str] = mapped_column(String(10))  # 'user', 'ai', 'system'
    content: Mapped[str] = mapped_column(Text)
    message_metadata: Mapped[dict | None] = mapped_column(
        JSON, nullable=True
    )  # 存储 SQL、图表等
    feedback: Mapped[str | None] = mapped_column(String(20), nullable=True)  # 'like', 'dislike'
    feedback_text: Mapped[str | None] = mapped_column(Text, nullable=True)  # 反馈详情
    created_at: Mapped[datetime] = mapped_column(default=utcnow, index=True)
    updated_at: Mapped[datetime] = mapped_column(default=utcnow, onupdate=utcnow)

    # 关系
    session: Mapped["ChatSession"] = relationship(back_populates="messages")