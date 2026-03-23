# models/llm_config.py
# LLM 配置模型 (优化版 - 支持加密)
# 用于存储用户配置的 LLM (大语言模型) 信息
# 这是 业务级 的配置，用于实际的 SQL 生成和问答，支持用户动态切换模型。
"""
LLM 配置模型 (优化版 - 支持加密)
用于存储用户配置的 LLM (大语言模型) 信息
"""
# models/llm_config.py
import enum
import logging

from sqlalchemy import Enum as SQLEnum
from sqlalchemy import ForeignKey, LargeBinary, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from utils.encryption import decrypt_api_key, encrypt_api_key

from .base import Base
from .user import User

logger = logging.getLogger(__name__)


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

    @staticmethod
    def get_default_base_url(provider: "LlmProvider") -> str | None:
        """获取提供商默认 Base URL"""
        url_map = {
            LlmProvider.ollama: "http://localhost:11434/v1",
            LlmProvider.deepseek: "https://api.deepseek.com",
            LlmProvider.qwen: "https://dashscope.aliyuncs.com/compatible-mode/v1",
            LlmProvider.moonshot: "https://api.moonshot.cn/v1",
            LlmProvider.gemini: "https://generativelanguage.googleapis.com/v1beta/openai/",
        }
        return url_map.get(provider)


class LlmConfig(Base):
    __tablename__ = "llm_configs"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    provider: Mapped[LlmProvider] = mapped_column(SQLEnum(LlmProvider))
    model_name: Mapped[str] = mapped_column(String(100))
    encrypted_api_key: Mapped[bytes] = mapped_column(LargeBinary(1024))
    base_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    temperature: Mapped[float] = mapped_column(default=0.7)

    user: Mapped["User"] = relationship(back_populates="llm_configs")

    @property
    def api_key(self) -> str:
        if not self.encrypted_api_key:
            return ""
        try:
            return decrypt_api_key(self.encrypted_api_key)
        except Exception as e:
            logger.warning(f"Failed to decrypt api_key for config {self.id}: {e}")
            return ""

    @api_key.setter
    def api_key(self, plain_key: str):
        self.encrypted_api_key = encrypt_api_key(plain_key)