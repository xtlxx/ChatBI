"""
生产级配置管理
支持环境变量、配置验证和安全的密钥管理
"""
from typing import Optional, List
from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """应用配置类 - 使用 Pydantic v2 进行验证"""
    
    model_config = SettingsConfigDict(
        env_file='.env',
        env_file_encoding='utf-8',
        extra='ignore',
        case_sensitive=True
    )
    
    # === 数据库配置 ===
    DATABASE_URL: Optional[str] = Field(default=None, description="完整数据库连接 URL")
    DB_HOST: str = Field(description="MySQL 数据库主机地址")
    DB_PORT: int = Field(default=3306, description="MySQL 数据库端口")
    DB_USER: str = Field(description="数据库用户名")
    DB_PASSWORD: str = Field(description="数据库密码")
    DB_NAME: str = Field(description="数据库名称")
    DB_POOL_SIZE: int = Field(default=10, description="数据库连接池大小")
    DB_MAX_OVERFLOW: int = Field(default=20, description="连接池最大溢出")
    
    # === LLM 配置 (Claude Sonnet 4.5) ===
    ANTHROPIC_API_KEY: Optional[str] = Field(default=None, description="Anthropic API 密钥")
    ANTHROPIC_MODEL: str = Field(default="claude-sonnet-4-20250514", description="Claude 模型名称")
    LLM_TEMPERATURE: float = Field(default=0.1, ge=0.0, le=1.0, description="LLM 温度参数")
    LLM_MAX_TOKENS: int = Field(default=4096, description="最大生成 token 数")
    LLM_TIMEOUT: int = Field(default=60, description="LLM 请求超时时间(秒)")
    
    # === 嵌入模型配置 (Voyage AI) ===
    VOYAGE_API_KEY: Optional[str] = Field(default=None, description="Voyage AI API 密钥")
    VOYAGE_MODEL: str = Field(default="voyage-3-large", description="Voyage 嵌入模型")
    EMBEDDING_DIMENSION: int = Field(default=1024, description="嵌入向量维度")
    
    # === Vector Store 配置 (Pinecone) ===
    PINECONE_API_KEY: Optional[str] = Field(default=None, description="Pinecone API 密钥")
    PINECONE_ENVIRONMENT: Optional[str] = Field(default=None, description="Pinecone 环境")
    PINECONE_INDEX_NAME: str = Field(default="chatbi-knowledge", description="Pinecone 索引名称")
    
    # === Redis 缓存配置 ===
    REDIS_HOST: str = Field(default="localhost", description="Redis 主机地址")
    REDIS_PORT: int = Field(default=6379, description="Redis 端口")
    REDIS_DB: int = Field(default=0, description="Redis 数据库编号")
    REDIS_PASSWORD: Optional[str] = Field(default=None, description="Redis 密码")
    CACHE_TTL: int = Field(default=3600, description="缓存过期时间(秒)")
    
    # === LangSmith 配置 ===
    LANGCHAIN_TRACING_V2: bool = Field(default=True, description="启用 LangSmith 追踪")
    LANGCHAIN_API_KEY: Optional[str] = Field(default=None, description="LangSmith API 密钥")
    LANGCHAIN_PROJECT: str = Field(default="chatbi-production", description="LangSmith 项目名称")
    LANGCHAIN_ENDPOINT: str = Field(default="https://api.smith.langchain.com", description="LangSmith 端点")
    
    # === Agent 配置 ===
    MAX_AGENT_ITERATIONS: int = Field(default=15, description="Agent 最大迭代次数")
    MAX_EXECUTION_TIME: int = Field(default=120, description="Agent 最大执行时间(秒)")
    ENABLE_STREAMING: bool = Field(default=True, description="启用流式响应")
    
    # === RAG 配置 ===
    RETRIEVER_K: int = Field(default=20, description="检索器返回的文档数量")
    RETRIEVER_ALPHA: float = Field(default=0.5, ge=0.0, le=1.0, description="混合搜索权重")
    ENABLE_RERANKING: bool = Field(default=True, description="启用重排序")
    COHERE_API_KEY: Optional[str] = Field(default=None, description="Cohere API 密钥(用于重排序)")
    
    # === 安全配置 ===
    JWT_SECRET_KEY: str = Field(
        default="your-secret-key-change-this-in-production",
        description="JWT 签名密钥"
    )
    ENCRYPTION_KEY: Optional[str] = Field(
        default=None,
        description="数据加密密钥 (用于加密数据库密码和 API Key)"
    )
    ALLOWED_ORIGINS: List[str] = Field(
        default=["http://localhost:3000", "http://localhost:5173"],
        description="允许的 CORS 源"
    )
    API_KEY_HEADER: str = Field(default="X-API-Key", description="API 密钥请求头名称")
    ENABLE_AUTH: bool = Field(default=False, description="启用 API 认证")
    
    # === 监控配置 ===
    ENABLE_METRICS: bool = Field(default=False, description="启用 Prometheus 指标")
    METRICS_PORT: int = Field(default=9090, description="Prometheus 指标端口")
    LOG_LEVEL: str = Field(default="INFO", description="日志级别")
    
    # === 重试配置 ===
    MAX_RETRIES: int = Field(default=3, description="最大重试次数")
    RETRY_MIN_WAIT: int = Field(default=4, description="重试最小等待时间(秒)")
    RETRY_MAX_WAIT: int = Field(default=10, description="重试最大等待时间(秒)")
    
    
    @field_validator('ALLOWED_ORIGINS', mode='before')
    @classmethod
    def parse_allowed_origins(cls, v):
        """解析 ALLOWED_ORIGINS (支持 JSON 字符串或列表)"""
        if isinstance(v, str):
            import json
            try:
                return json.loads(v)
            except json.JSONDecodeError:
                # 如果不是 JSON,按逗号分割
                return [origin.strip() for origin in v.split(',')]
        return v
    
    @field_validator('LOG_LEVEL')
    @classmethod
    def validate_log_level(cls, v: str) -> str:
        """验证日志级别"""
        valid_levels = ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL']
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
    
    @property
    def redis_url(self) -> str:
        """构建 Redis 连接 URL"""
        if self.REDIS_PASSWORD:
            return f"redis://:{self.REDIS_PASSWORD}@{self.REDIS_HOST}:{self.REDIS_PORT}/{self.REDIS_DB}"
        return f"redis://{self.REDIS_HOST}:{self.REDIS_PORT}/{self.REDIS_DB}"


# 全局配置实例
settings = Settings()
