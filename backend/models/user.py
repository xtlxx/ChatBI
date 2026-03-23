# models/user.py
# 使用 TYPE_CHECKING 避免运行时循环导入，同时保留类型提示
from typing import TYPE_CHECKING

import bcrypt
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base

if TYPE_CHECKING:
    from .chat import ChatSession
    from .db_connection import DbConnection
    from .llm_config import LlmConfig


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True, index=True, autoincrement=True)
    username: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    email: Mapped[str] = mapped_column(String(100), unique=True, index=True)
    # 密码哈希通常存储为字符串，但在某些数据库中 bytes 更省空间，这里保持 str
    hashed_password: Mapped[str] = mapped_column(String(255))
    role: Mapped[str] = mapped_column(String(20), default="user", server_default="user")

    # 定义关系
    connections: Mapped[list["DbConnection"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
    llm_configs: Mapped[list["LlmConfig"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
    chat_sessions: Mapped[list["ChatSession"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )

    def verify_password(self, password: str) -> bool:
        """验证密码"""
        password_bytes = password.encode("utf-8") if isinstance(password, str) else password

        return bcrypt.checkpw(password_bytes, self.hashed_password.encode("utf-8"))

    @staticmethod
    def hash_password(password: str) -> str:
        """生成密码哈希"""
        password_bytes = password.encode("utf-8")
        if len(password_bytes) > 72:
            raise ValueError("Password too long")

        return bcrypt.hashpw(password_bytes, bcrypt.gensalt()).decode("utf-8")