"""
LLM 配置模型 (优化版 - 支持加密)
用于存储用户配置的 LLM (大语言模型) 信息
"""
# models/llm_config.py
import enum
from typing import Optional
from sqlalchemy import String, ForeignKey, LargeBinary, Enum as SQLEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from .base import Base
from .user import User
from utils.encryption import encrypt_api_key, decrypt_api_key
class LlmProvider(str, enum.Enum):
    """LLM 提供商枚举"""
    openai = "openai"
    qwen = "qwen"
    deepseek = "deepseek"
    anthropic = "anthropic"
    moonshot = "moonshot"
    ollama = "ollama"
    gemini = "gemini"
    other = "other"


class LlmConfig(Base):
    __tablename__ = "llm_configs"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    provider: Mapped[LlmProvider] = mapped_column(SQLEnum(LlmProvider))
    model_name: Mapped[str] = mapped_column(String(100))
    encrypted_api_key: Mapped[bytes] = mapped_column(LargeBinary(1024))
    base_url: Mapped[Optional[str]] = mapped_column(String(512), nullable=True)

    user: Mapped["User"] = relationship(back_populates="llm_configs")

    @property
    def api_key(self) -> str:
        if not self.encrypted_api_key:
            raise ValueError("API Key not set")
        return decrypt_api_key(self.encrypted_api_key)

    @api_key.setter
    def api_key(self, plain_key: str):
        self.encrypted_api_key = encrypt_api_key(plain_key)
