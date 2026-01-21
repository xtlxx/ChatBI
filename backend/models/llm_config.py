"""
LLM 配置模型 (优化版 - 支持加密)
用于存储用户配置的 LLM (大语言模型) 信息
"""
from sqlalchemy import Column, BigInteger, String, ForeignKey, DateTime, LargeBinary, Enum as SQLEnum
from sqlalchemy.orm import relationship
from datetime import datetime
from .user import Base
from utils.encryption import encrypt_api_key, decrypt_api_key
import enum


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
    """LLM 配置模型 (优化版)"""
    __tablename__ = "llm_configs"
    
    id = Column(BigInteger, primary_key=True, index=True, autoincrement=True)
    user_id = Column(BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    provider = Column(SQLEnum(LlmProvider), nullable=False)
    model_name = Column(String(100), nullable=False)
    encrypted_api_key = Column(LargeBinary(1024), nullable=False)  # 加密存储
    base_url = Column(String(512), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 关系
    # user = relationship("User", back_populates="llm_configs")
    
    def set_api_key(self, plain_api_key: str):
        """
        设置 API 密钥 (自动加密)
        
        Args:
            plain_api_key: 明文 API 密钥
        """
        self.encrypted_api_key = encrypt_api_key(plain_api_key)
    
    def get_api_key(self) -> str:
        """
        获取 API 密钥 (自动解密)
        
        Returns:
            明文 API 密钥
        """
        if not self.encrypted_api_key:
            raise ValueError("API密钥未设置")
        return decrypt_api_key(self.encrypted_api_key)
    
    def to_dict(self, include_api_key: bool = False):
        """
        转换为字典
        
        Args:
            include_api_key: 是否包含 API key (默认不包含,保护安全)
        """
        data = {
            "id": self.id,
            "provider": self.provider.value if isinstance(self.provider, LlmProvider) else self.provider,
            "model_name": self.model_name,
            "base_url": self.base_url,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
        
        if include_api_key:
            # 仅在明确需要时返回明文 API key (如配置测试)
            try:
                data["api_key"] = self.get_api_key()
            except:
                data["api_key"] = None
        
        return data
