# config.py
"""
生产级配置管理
支持环境变量、配置验证和安全的密钥管理
全局默认配置 ( config.py ) ：这是 系统级 的兜底配置，主要用于后台任务（如对话记忆摘要）。
"""

import logging

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

logger = logging.getLogger(__name__)


class Settings(BaseSettings):
    """应用配置类 - 使用 Pydantic v2 进行验证"""

    model_config = SettingsConfigDict(
        env_file=".env", env_file_encoding="utf-8", extra="ignore", case_sensitive=True
    )

    # === 数据库配置 ===
    DATABASE_URL: str | None = Field(default=None, description="完整数据库连接 URL")
    DB_HOST: str = Field(description="MySQL 数据库主机地址")
    DB_PORT: int = Field(default=3306, description="MySQL 数据库端口")
    DB_USER: str = Field(description="数据库用户名")
    DB_PASSWORD: str = Field(description="数据库密码")
    DB_NAME: str = Field(description="数据库名称")
    DB_POOL_SIZE: int = Field(default=10, description="数据库连接池大小")
    DB_MAX_OVERFLOW: int = Field(default=20, description="连接池最大溢出")

    # === LangSmith 配置 ===
    LANGCHAIN_TRACING_V2: bool = Field(default=False, description="启用 LangSmith 追踪")
    LANGCHAIN_API_KEY: str | None = Field(default=None, description="LangSmith API 密钥")
    LANGCHAIN_PROJECT: str = Field(default="chatbi-production", description="LangSmith 项目名称")
    LANGCHAIN_ENDPOINT: str = Field(
        default="https://api.smith.langchain.com", description="LangSmith 端点"
    )

    # === LangGraph Checkpoint 配置 ===
    CHECKPOINT_DATABASE_URL: str | None = Field(
        default=None, description="LangGraph Checkpoint 数据库连接 URL (PostgreSQL)"
    )

    # === Redis 缓存配置 ===
    REDIS_URL: str = Field(default="redis://localhost:6379/0", description="Redis 连接 URL")
    SCHEMA_CACHE_TTL: int = Field(default=21600, description="Schema 缓存过期时间(秒)")


    # === 安全配置 ===
    JWT_SECRET_KEY: str = Field(
        default="your-secret-key-change-this-in-production", description="JWT 签名密钥"
    )
    ENCRYPTION_KEY: str | None = Field(
        default=None, description="数据加密密钥 (用于加密数据库密码和 API Key)"
    )
    ENCRYPTION_SALT: str | None = Field(
        default=None,
        description="PBKDF2 Salt（生产环境必须设置，不同于默认值以防止彩虹表攻击）"
    )
    ALLOWED_ORIGINS: list[str] = Field(
        default=["http://localhost:3000", "http://localhost:5173"], description="允许的 CORS 源"
    )
    API_KEY_HEADER: str = Field(default="X-API-Key", description="API 密钥请求头名称")
    ENABLE_AUTH: bool = Field(default=False, description="启用 API 认证")

    # === 监控配置 ===
    ENABLE_METRICS: bool = Field(default=False, description="启用 Prometheus 指标")
    METRICS_PORT: int = Field(default=9090, description="Prometheus 指标端口")
    LOG_LEVEL: str = Field(default="INFO", description="日志级别")
    DEV_MODE: bool = Field(default=False, description="开发模式开关")

    # === 讯飞语音配置 ===
    XUNFEI_APP_ID: str | None = Field(default=None, description="讯飞 APP ID")
    XUNFEI_API_KEY: str | None = Field(default=None, description="讯飞 API Key")
    XUNFEI_API_SECRET: str | None = Field(default=None, description="讯飞 API Secret")

    @field_validator("ALLOWED_ORIGINS", mode="before")
    @classmethod
    def parse_allowed_origins(cls, v):
        """解析 ALLOWED_ORIGINS (支持 JSON 字符串或列表)"""
        if isinstance(v, str):
            import json

            try:
                return json.loads(v)
            except json.JSONDecodeError:
                # 如果不是 JSON,按逗号分割
                return [origin.strip() for origin in v.split(",")]
        return v

    @field_validator("LOG_LEVEL")
    @classmethod
    def validate_log_level(cls, v: str) -> str:
        """验证日志级别"""
        valid_levels = ["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"]
        if v.upper() not in valid_levels:
            raise ValueError(f"日志级别必须是 {valid_levels} 之一")
        return v.upper()

    @property
    def database_url(self) -> str:
        """构建数据库连接 URL"""
        # 优先使用完整的 DATABASE_URL 环境变量
        if self.DATABASE_URL:
            return self.DATABASE_URL
        # 如果没有 DATABASE_URL，则使用其他字段构建
        return f"mysql+aiomysql://{self.DB_USER}:{self.DB_PASSWORD}@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"


# 全局配置实例
settings = Settings()
logger.debug("Loaded configuration: DB_HOST=%s, DB_PORT=%s", settings.DB_HOST, settings.DB_PORT)