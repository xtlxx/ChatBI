# agent/tools.py
"""
Agent 工具定义
包含数据库查询、RAG 检索等工具
"""
import json
import decimal
import datetime
from typing import Optional, Dict, Any, List, Union
from langchain_core.tools import StructuredTool
from pydantic import BaseModel, Field
from tenacity import retry, stop_after_attempt, wait_exponential
from sqlalchemy import text

# === 配置与日志导入 ===
try:
    from logging_config import get_logger
except ImportError:
    # 兼容性 Fallback
    try:
        from ..logging_config import get_logger
    except ImportError:
        import logging
        get_logger = logging.getLogger

logger = get_logger(__name__)


# === 工具输入模型 (Pydantic) ===

class SQLQueryInput(BaseModel):
    """SQL 查询工具输入模型"""
    query: str = Field(
        description="要执行的 SQL 查询语句。必须是 SELECT 语句，严禁使用 INSERT/UPDATE/DELETE/DROP。"
    )


class SchemaSearchInput(BaseModel):
    """数据库模式搜索工具输入模型"""
    keywords: str = Field(description="搜索关键词，用于查找相关的表名、字段名或注释")


class KnowledgeSearchInput(BaseModel):
    """知识库搜索工具输入模型"""
    query: str = Field(description="搜索查询，用于检索相关的业务知识和文档")


# === 辅助函数 ===

def safe_serializer(obj: Any) -> Any:
    """JSON 序列化辅助函数，处理非标准类型"""
    if isinstance(obj, (datetime.datetime, datetime.date)):
        return obj.isoformat()
    if isinstance(obj, decimal.Decimal):
        return float(obj)  # 或者 str(obj) 以保持精度
    return str(obj)


def validate_sql_safety(query: str) -> Optional[str]:
    """
    简单的 SQL 安全检查
    返回 None 表示通过，返回字符串表示错误信息
    """
    q = query.strip().upper()
    if not q.startswith("SELECT") and not q.startswith("WITH"): # 支持 WITH 子句
        return "安全拒绝: SQL 语句必须以 SELECT 或 WITH 开头"

    # 黑名单关键词检查
    forbidden = ["DROP ", "DELETE ", "UPDATE ", "INSERT ", "TRUNCATE ", "ALTER ", "GRANT ", "EXEC "]
    for word in forbidden:
        if word in q:
            return f"安全拒绝: 包含禁止的关键词 '{word.strip()}'"
    return None


# === 工具实现 ===

class DatabaseTools:
    """数据库相关工具集合"""

    def __init__(self, db_engine):
        self.db_engine = db_engine
        self.logger = get_logger(self.__class__.__name__)

    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=2, max=10),
        reraise=False  # 不抛出异常，而是返回错误 JSON
    )
    async def execute_sql_query(self, query: str) -> str:
        """
        执行 SQL 查询并返回结果
        """
        try:
            # 1. 安全检查
            error_msg = validate_sql_safety(query)
            if error_msg:
                return json.dumps({"error": error_msg, "query": query}, ensure_ascii=False)

            self.logger.info("executing_sql_query", query=query[:200])

            # 2. 执行查询
            async with self.db_engine.connect() as conn:
                # 使用 text() 包装 SQL 字符串
                result = await conn.execute(text(query))

                # 获取列名
                columns = result.keys()
                rows = result.fetchall()

                # 3. 数据转换
                data = [dict(zip(columns, row)) for row in rows]
                row_count = len(data)

                # 限制返回行数，防止 Context 溢出
                limit = 100
                is_truncated = row_count > limit

                response = {
                    "success": True,
                    "executed_sql": query,
                    "row_count": row_count,
                    "data": data[:limit],
                    "truncated": is_truncated,
                    "message": f"查询成功，共 {row_count} 行" + (" (仅显示前100行)" if is_truncated else "")
                }

                self.logger.info("sql_query_executed", row_count=row_count)

                return json.dumps(response, ensure_ascii=False, default=safe_serializer)

        except Exception as e:
            self.logger.error("sql_query_failed", error=str(e), query=query[:200], exc_info=True)
            return json.dumps({
                "success": False,
                "error": f"SQL 执行失败: {str(e)}",
                "query": query
            }, ensure_ascii=False)

    async def get_table_schema(self, table_name: str) -> str:
        """
        获取表结构信息
        """
        try:
            # 注意：此处使用参数化查询不太容易（表名不能参数化），
            # 但 table_name 通常来自 Agent 内部决策。
            # 仍需防止极其恶意的注入，虽然主要由 LLM 控制。
            clean_table_name = table_name.replace("'", "").replace(";", "").split()[0]

            query = text("""
            SELECT 
                COLUMN_NAME, DATA_TYPE, COLUMN_TYPE, 
                IS_NULLABLE, COLUMN_KEY, COLUMN_COMMENT
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = :table_name
            ORDER BY ORDINAL_POSITION
            """)

            async with self.db_engine.connect() as conn:
                result = await conn.execute(query, {"table_name": clean_table_name})
                rows = result.fetchall()
                columns = result.keys()
                schema = [dict(zip(columns, row)) for row in rows]

                if not schema:
                    return json.dumps({"error": f"表 '{clean_table_name}' 不存在或无权限"}, ensure_ascii=False)

                return json.dumps({
                    "table": clean_table_name,
                    "columns": schema
                }, ensure_ascii=False, default=safe_serializer)

        except Exception as e:
            self.logger.error("get_table_schema_failed", error=str(e), table=table_name)
            return json.dumps({"error": str(e)}, ensure_ascii=False)

    async def search_schema(self, keywords: str) -> str:
        """
        搜索数据库模式中的表和字段
        """
        try:
            # 清理关键词，防止破坏 LIKE 语句
            safe_kw = keywords.replace("'", "").replace("%", "")

            query = text("""
            SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, COLUMN_COMMENT
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
            AND (
                TABLE_NAME LIKE :kw
                OR COLUMN_NAME LIKE :kw
                OR COLUMN_COMMENT LIKE :kw
            )
            LIMIT 50
            """)

            async with self.db_engine.connect() as conn:
                result = await conn.execute(query, {"kw": f"%{safe_kw}%"})
                rows = result.fetchall()
                columns = result.keys()
                matches = [dict(zip(columns, row)) for row in rows]

                return json.dumps({
                    "keyword": keywords,
                    "matches": matches,
                    "count": len(matches)
                }, ensure_ascii=False, default=safe_serializer)

        except Exception as e:
            self.logger.error("search_schema_failed", error=str(e), keywords=keywords)
            return json.dumps({"error": str(e)}, ensure_ascii=False)


class KnowledgeTools:
    """知识库相关工具集合"""

    def __init__(self, retriever=None):
        self.retriever = retriever
        self.logger = get_logger(self.__class__.__name__)

    async def search_knowledge(self, query: str) -> str:
        """
        搜索知识库
        """
        try:
            if not self.retriever:
                return json.dumps({
                    "message": "知识库检索器未配置，无法搜索",
                    "documents": []
                }, ensure_ascii=False)

            self.logger.info("searching_knowledge", query=query)

            # 执行异步检索
            # 注意：取决于你的 retriever 实现，可能是 aget_relevant_documents 或 ainvoke
            if hasattr(self.retriever, "ainvoke"):
                docs = await self.retriever.ainvoke(query)
            else:
                docs = await self.retriever.aget_relevant_documents(query)

            results = []
            for doc in docs:
                results.append({
                    "content": doc.page_content,
                    "metadata": doc.metadata,
                    # 尝试获取相关度分数
                    "score": getattr(doc, "score", None) or doc.metadata.get("score")
                })

            return json.dumps({
                "query": query,
                "documents": results,
                "count": len(results)
            }, ensure_ascii=False, default=safe_serializer)

        except Exception as e:
            self.logger.error("knowledge_search_failed", error=str(e), query=query)
            return json.dumps({"error": f"知识检索失败: {str(e)}"}, ensure_ascii=False)


def create_tools(db_engine, retriever=None) -> List[StructuredTool]:
    """
    创建并返回 LangGraph Agent 所需的工具列表

    Args:
        db_engine: 异步数据库引擎 (SQLAlchemy AsyncEngine)
        retriever: LangChain Retriever 实例
    """
    db_tools = DatabaseTools(db_engine)
    knowledge_tools = KnowledgeTools(retriever)

    tools = [
        StructuredTool.from_function(
            func=None, # 同步 func 留空
            coroutine=db_tools.execute_sql_query,
            name="execute_sql",
            description="执行 SQL 查询。只允许 SELECT 语句。返回 JSON 格式的数据结果。",
            args_schema=SQLQueryInput
        ),
        StructuredTool.from_function(
            func=None,
            coroutine=db_tools.get_table_schema,
            name="get_table_schema",
            description="查看指定表的详细结构（列名、类型、注释）。在编写 SQL 前必须使用此工具确认字段。",
            args_schema=None # 使用默认推断，或如果只是单字符串参数可不写
        ),
        StructuredTool.from_function(
            func=None,
            coroutine=db_tools.search_schema,
            name="search_schema",
            description="模糊搜索数据库表和字段。当你不知道表名是什么时使用。",
            args_schema=SchemaSearchInput
        ),
    ]

    # 仅当 retriever 存在时添加知识库工具
    if retriever:
        tools.append(
            StructuredTool.from_function(
                func=None,
                coroutine=knowledge_tools.search_knowledge,
                name="search_knowledge",
                description="搜索业务文档和知识库。用于理解业务术语、计算公式或特殊规则。",
                args_schema=KnowledgeSearchInput
            )
        )
    
    return tools
