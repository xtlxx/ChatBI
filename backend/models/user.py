"""
用户数据模型
使用 SQLAlchemy 定义用户表结构
"""
from sqlalchemy import Column, BigInteger, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime
from passlib.context import CryptContext

Base = declarative_base()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class User(Base):
    """用户模型 (优化版)"""
    __tablename__ = "users"
    
    id = Column(BigInteger, primary_key=True, index=True, autoincrement=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    email = Column(String(100), unique=True, nullable=False, index=True)
    hashed_password = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 关系 (如果需要)
    # connections = relationship("DbConnection", back_populates="user")
    # llm_configs = relationship("LlmConfig", back_populates="user")
    
    def verify_password(self, password: str) -> bool:
        """
        验证密码
        
        Args:
            password: 明文密码
            
        Returns:
            密码是否正确
        """
        return pwd_context.verify(password, self.hashed_password)
    
    @staticmethod
    def hash_password(password: str) -> str:
        """
        哈希密码
        
        Args:
            password: 明文密码
            
        Returns:
            哈希后的密码
        """
        return pwd_context.hash(password)
    
    def to_dict(self, include_sensitive: bool = False):
        """
        转换为字典
        
        Args:
            include_sensitive: 是否包含敏感信息
            
        Returns:
            用户字典
        """
        data = {
            "id": self.id,
            "username": self.username,
            "email": self.email,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
        
        if include_sensitive:
            data["hashed_password"] = self.hashed_password
        
        return data
