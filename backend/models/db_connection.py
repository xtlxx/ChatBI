"""
数据库连接配置模型 (优化版 - 支持加密)
用于存储用户配置的数据库连接信息
"""
from sqlalchemy import Column, BigInteger, String, Integer, ForeignKey, DateTime, LargeBinary, Enum as SQLEnum
from sqlalchemy.orm import relationship
from datetime import datetime
from .user import Base
from utils.encryption import encrypt_password, decrypt_password
import enum


class DbType(str, enum.Enum):
    """数据库类型枚举"""
    mysql = "mysql"
    postgresql = "postgresql"
    mssql = "mssql"
    clickhouse = "clickhouse"
    sqlite = "sqlite"
    oracle = "oracle"
    other = "other"


class DbConnection(Base):
    """数据库连接配置模型 (优化版)"""
    __tablename__ = "db_connections"
    
    id = Column(BigInteger, primary_key=True, index=True, autoincrement=True)
    user_id = Column(BigInteger, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String(100), nullable=False)
    type = Column(SQLEnum(DbType), nullable=False)
    host = Column(String(255), nullable=False)
    port = Column(Integer, nullable=False)
    username = Column(String(100), nullable=False)
    encrypted_password = Column(LargeBinary(512), nullable=False)  # 加密存储
    database_name = Column(String(100), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 关系
    # user = relationship("User", back_populates="connections")
    
    def set_password(self, plain_password: str):
        """
        设置密码 (自动加密)
        
        Args:
            plain_password: 明文密码
        """
        self.encrypted_password = encrypt_password(plain_password)
    
    def get_password(self) -> str:
        """
        获取密码 (自动解密)
        
        Returns:
            明文密码
        """
        if not self.encrypted_password:
            raise ValueError("密码未设置")
        return decrypt_password(self.encrypted_password)
    
    def to_dict(self, include_password: bool = False):
        """
        转换为字典
        
        Args:
            include_password: 是否包含密码 (默认不包含,保护安全)
        """
        data = {
            "id": self.id,
            "name": self.name,
            "type": self.type.value if isinstance(self.type, DbType) else self.type,
            "host": self.host,
            "port": self.port,
            "username": self.username,
            "database_name": self.database_name,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
        
        if include_password:
            # 仅在明确需要时返回明文密码 (如连接测试)
            try:
                data["password"] = self.get_password()
            except:
                data["password"] = None
        
        return data
