# core/db_adapter.py
# 数据库方言适配器
# 用于将 SQL 语句转换为目标数据库方言
import logging
from abc import ABC, abstractmethod
from typing import Any

import sqlglot

from models.db_connection import DbType

logger = logging.getLogger(__name__)


class DialectAdapter(ABC):
    """数据库方言适配器的抽象基类。"""

    @property
    @abstractmethod
    def sqlglot_dialect(self) -> str:
        """返回 sqlglot 方言字符串。"""
        pass

    @property
    @abstractmethod
    def driver_name(self) -> str:
        """返回 SQLAlchemy 驱动名称（例如 'mysql+aiomysql'）。"""
        pass

    @property
    def pool_args(self) -> dict[str, Any]:
        """返回特定的连接池参数。"""
        return {"pool_size": 5, "max_overflow": 10, "pool_pre_ping": True, "pool_recycle": 3600}

    @abstractmethod
    def get_date_format_function(self) -> str:
        """返回日期格式化函数名称（例如 'DATE_FORMAT'、'TO_CHAR'）。"""
        pass

    def transpile_sql(self, sql: str, source_dialect: str = None) -> str:
        """使用 sqlglot 将 SQL 转换为目标方言。
        参数：
            sql (str): 要转换的 SQL 语句。
            source_dialect (str, 可选): 源 SQL 方言（例如 'mysql'、'postgres'）。
                                        如果未指定，sqlglot 将尝试猜测或采用通用方言。
        返回：
            str: 转换后的 SQL 语句。
        """
        try:
            # 如果未指定源方言，让 sqlglot 自行猜测或采用通用方言
            # transpile 返回一个字符串列表，通常只有一个语句
            transpiled = sqlglot.transpile(sql, read=source_dialect, write=self.sqlglot_dialect)[0]
            return transpiled
        except Exception as e:
            logger.warning(f"SQL 转换失败：{e}。返回原始 SQL。")
            return sql

    def get_feature_matrix(self) -> dict[str, bool]:
        """返回支持的功能。"""
        return {"window_functions": True, "cte": True, "json_type": False, "recursive_cte": False}

    def get_limit_syntax(self) -> str | None:
        """返回 LIMIT 子句的语法。
        返回：
            str: LIMIT 子句语法（例如 'LIMIT 100'）。
            None: 如果不支持 LIMIT 或以不同方式处理（例如 MSSQL TOP、Oracle ROWNUM）。
        """
        return "LIMIT 100"


class MySQLAdapter(DialectAdapter):
    @property
    def sqlglot_dialect(self) -> str:
        return "mysql"

    @property
    def driver_name(self) -> str:
        return "mysql+aiomysql"

    @property
    def pool_args(self) -> dict[str, Any]:
        args = super().pool_args
        # MySQL 特定：如需优化预处理语句（但 aiomysql 处理方式不同）
        # 可在此添加 'connect_args'
        return args

    def get_date_format_function(self) -> str:
        return "DATE_FORMAT"

    def get_feature_matrix(self) -> dict[str, bool]:
        return {
            "window_functions": True,  # MySQL 8.0+
            "cte": True,  # MySQL 8.0+
            "json_type": True,
            "recursive_cte": True,
        }


class PostgresAdapter(DialectAdapter):
    @property
    def sqlglot_dialect(self) -> str:
        return "postgres"

    @property
    def driver_name(self) -> str:
        return "postgresql+asyncpg"

    @property
    def pool_args(self) -> dict[str, Any]:
        args = super().pool_args
        # asyncpg 特定优化？
        return args

    def get_date_format_function(self) -> str:
        return "TO_CHAR"

    def get_feature_matrix(self) -> dict[str, bool]:
        return {"window_functions": True, "cte": True, "json_type": True, "recursive_cte": True}


class MSSQLAdapter(DialectAdapter):
    @property
    def sqlglot_dialect(self) -> str:
        return "tsql"

    @property
    def driver_name(self) -> str:
        return "mssql+aioodbc"

    def get_date_format_function(self) -> str:
        return "FORMAT"  # 或 CONVERT

    def get_limit_syntax(self) -> str | None:
        return None  # MSSQL 在 SELECT 子句中使用 TOP N


class OracleAdapter(DialectAdapter):
    @property
    def sqlglot_dialect(self) -> str:
        return "oracle"

    @property
    def driver_name(self) -> str:
        return "oracle+oracledb"  # 假设使用 thick/thin 客户端

    def get_date_format_function(self) -> str:
        return "TO_CHAR"

    def get_limit_syntax(self) -> str | None:
        return "FETCH FIRST 100 ROWS ONLY"


class SQLiteAdapter(DialectAdapter):
    @property
    def sqlglot_dialect(self) -> str:
        return "sqlite"

    @property
    def driver_name(self) -> str:
        return "sqlite+aiosqlite"

    def get_date_format_function(self) -> str:
        return "strftime"


class AdapterFactory:
    _adapters = {
        DbType.mysql: MySQLAdapter(),
        DbType.postgresql: PostgresAdapter(),
        DbType.mssql: MSSQLAdapter(),
        DbType.oracle: OracleAdapter(),
        DbType.sqlite: SQLiteAdapter(),
        # 默认回退
        DbType.other: MySQLAdapter(),  # 回退到类 MySQL 行为或通用行为
    }

    @classmethod
    def get_adapter(cls, db_type: DbType) -> DialectAdapter:
        return cls._adapters.get(db_type, cls._adapters[DbType.other])

    @classmethod
    def get_adapter_by_name(cls, name: str) -> DialectAdapter:
        try:
            return cls.get_adapter(DbType(name.lower()))
        except ValueError:
            return cls._adapters[DbType.other]


class DatabaseDetector:
    """根据连接详情检测数据库类型。"""

    @staticmethod
    def detect_type(url: str) -> DbType:
        """
        基于 URL 模式的简单启发式检测。
        """
        url_lower = url.lower()
        if "mysql" in url_lower:
            return DbType.mysql
        elif "postgres" in url_lower:
            return DbType.postgresql
        elif "mssql" in url_lower or "sqlserver" in url_lower:
            return DbType.mssql
        elif "oracle" in url_lower:
            return DbType.oracle
        elif "sqlite" in url_lower:
            return DbType.sqlite
        else:
            return DbType.other

    @staticmethod
    def get_connection_url(db_config: Any) -> str:
        """
        根据配置和检测到的类型构造连接 URL。
        集中目前位于 agent_factory.py 中的逻辑。
        """
        from urllib.parse import quote_plus
        
        # SQLite 不需要用户名密码主机端口
        if db_config.type == DbType.sqlite:
            adapter = AdapterFactory.get_adapter(db_config.type)
            return f"{adapter.driver_name}:///{db_config.database_name}"

        # 确保其他数据库具有必要的连接信息
        if not all([db_config.username, db_config.password, db_config.host, db_config.port, db_config.database_name]):
            raise ValueError("数据库连接信息不完整")

        password = quote_plus(str(db_config.password))
        username = quote_plus(str(db_config.username))

        adapter = AdapterFactory.get_adapter(db_config.type)
        driver = adapter.driver_name

        url = f"{driver}://{username}:{password}@{db_config.host}:{db_config.port}/{db_config.database_name}"

        if db_config.type == DbType.mssql:
            driver_str = quote_plus("ODBC Driver 17 for SQL Server")
            url += f"?driver={driver_str}"
        return url
