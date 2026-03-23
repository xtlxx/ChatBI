# models/db_connection.py
# 数据库连接模型
# 用于存储用户配置的数据库连接信息（加密存储密码）
import enum
import logging

from sqlalchemy import Enum as SQLEnum
from sqlalchemy import ForeignKey, Integer, LargeBinary, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from utils.encryption import decrypt_password, encrypt_password

from .base import Base
from .user import User

logger = logging.getLogger(__name__)


class DbType(str, enum.Enum):
    mysql = "mysql"
    postgresql = "postgresql"
    mssql = "mssql"
    clickhouse = "clickhouse"
    sqlite = "sqlite"
    oracle = "oracle"
    other = "other"


class DbConnection(Base):
    __tablename__ = "db_connections"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    name: Mapped[str] = mapped_column(String(100))
    type: Mapped[DbType] = mapped_column(SQLEnum(DbType))
    host: Mapped[str] = mapped_column(String(255))
    port: Mapped[int] = mapped_column(Integer)
    username: Mapped[str] = mapped_column(String(100))
    encrypted_password: Mapped[bytes] = mapped_column(LargeBinary(512))
    database_name: Mapped[str] = mapped_column(String(100))

    # 反向关系
    user: Mapped["User"] = relationship(back_populates="connections")

    @property
    def password(self) -> str:
        """获取解密后的密码（属性访问）"""
        if not self.encrypted_password:
            return ""
        try:
            return decrypt_password(self.encrypted_password)
        except Exception as e:
            logger.warning(f"Failed to decrypt password for connection {self.id}: {e}")
            return ""

    @password.setter
    def password(self, plain_password: str):
        """设置密码（自动加密）"""
        self.encrypted_password = encrypt_password(plain_password)

    def to_dict(self, include_password: bool = False):
        data = {
            "id": self.id,
            "name": self.name,
            "type": self.type.value,
            "host": self.host,
            "port": self.port,
            "username": self.username,
            "database_name": self.database_name,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
        if include_password:
            try:
                data["password"] = self.password
            except Exception:
                data["password"] = None
        return data