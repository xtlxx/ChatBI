# models/user.py
from typing import List, Optional
from sqlalchemy import String, LargeBinary
from sqlalchemy.orm import Mapped, mapped_column, relationship
import bcrypt
from .base import Base
# 使用 TYPE_CHECKING 避免运行时循环导入，同时保留类型提示
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from .db_connection import DbConnection
    from .llm_config import LlmConfig
    from .chat import ChatSession

class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True, index=True, autoincrement=True)
    username: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    email: Mapped[str] = mapped_column(String(100), unique=True, index=True)
    # 密码哈希通常存储为字符串，但在某些数据库中 bytes 更省空间，这里保持 str
    hashed_password: Mapped[str] = mapped_column(String(255))

    # 定义关系
    connections: Mapped[List["DbConnection"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
    llm_configs: Mapped[List["LlmConfig"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )
    chat_sessions: Mapped[List["ChatSession"]] = relationship(
        back_populates="user", cascade="all, delete-orphan"
    )

    def verify_password(self, password: str) -> bool:
        """验证密码"""
        if isinstance(password, str):
            password_bytes = password.encode('utf-8')
        else:
            password_bytes = password

        return bcrypt.checkpw(password_bytes, self.hashed_password.encode('utf-8'))

    @staticmethod
    def hash_password(password: str) -> str:
        """生成密码哈希"""
        password_bytes = password.encode('utf-8')
        if len(password_bytes) > 72:
            raise ValueError("Password too long")

        return bcrypt.hashpw(password_bytes, bcrypt.gensalt()).decode('utf-8')
