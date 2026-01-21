"""
Agent 工具定义
包含数据库查询、RAG 检索等工具
"""
import json
from typing import Optional, Dict, Any, List
from langchain_core.tools import StructuredTool
from pydantic import BaseModel, Field
from tenacity import retry, stop_after_attempt, wait_exponential
from sqlalchemy import text  # 添加 text 导入

import sys
import os

# Add parent directory to sys.path to allow imports from backend root
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

try:
    from logging_config import get_logger
except ImportError:
    # Fallback for relative imports if running as package
    from ...logging_config import get_logger

logger = get_logger(__name__)


# === 工具输入模型 ===

class SQLQueryInput(BaseModel):
    """SQL 查询工具输入"""
    query: str = Field(description="要执行的 SQL 查询语句，必须是 SELECT 语句")


class SchemaSearchInput(BaseModel):
    """数据库模式搜索工具输入"""
    keywords: str = Field(description="搜索关键词，用于查找相关的表和字段")


class KnowledgeSearchInput(BaseModel):
    """知识库搜索工具输入"""
    query: str = Field(description="搜索查询，用于检索相关的业务知识和文档")


# === 工具实现 ===

class DatabaseTools:
    """数据库相关工具集合"""
    
    def __init__(self, db_engine):
        self.db_engine = db_engine
        self.logger = get_logger(self.__class__.__name__)
    
    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=4, max=10),
        reraise=True
    )
    async def execute_sql_query(self, query: str) -> str:
        """
        执行 SQL 查询并返回结果
        
        Args:
            query: SQL 查询语句
            
        Returns:
            查询结果的 JSON 字符串
        """
        try:
            # 安全检查：只允许 SELECT 语句
            if not query.strip().upper().startswith("SELECT"):
                return json.dumps({
                    "error": "安全限制：只允许执行 SELECT 查询",
                    "query": query
                }, ensure_ascii=False)
            
            self.logger.info("executing_sql_query", query=query[:200])
            
            # 执行查询 - 使用 text() 包装 SQL 字符串
            async with self.db_engine.connect() as conn:
                result = await conn.execute(text(query))
                rows = result.fetchall()
                
                # 转换为字典列表
                columns = result.keys()
                data = [dict(zip(columns, row)) for row in rows]
                
                self.logger.info(
                    "sql_query_executed",
                    row_count=len(data),
                    query=query[:100]
                )
                
                return json.dumps({
                    "success": True,
                    "row_count": len(data),
                    "data": data[:100],  # 限制返回前100行
                    "truncated": len(data) > 100
                }, ensure_ascii=False, default=str)
                
        except Exception as e:
            self.logger.error(
                "sql_query_failed",
                error=str(e),
                query=query[:200],
                exc_info=True
            )
            return json.dumps({
                "error": f"SQL 执行失败: {str(e)}",
                "query": query
            }, ensure_ascii=False)
    
    async def get_table_schema(self, table_name: str) -> str:
        """
        获取表结构信息
        
        Args:
            table_name: 表名
            
        Returns:
            表结构的 JSON 字符串
        """
        try:
            query = f"""
            SELECT 
                COLUMN_NAME,
                DATA_TYPE,
                COLUMN_TYPE,
                IS_NULLABLE,
                COLUMN_KEY,
                COLUMN_COMMENT
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = '{table_name}'
            ORDER BY ORDINAL_POSITION
            """
            
            async with self.db_engine.connect() as conn:
                result = await conn.execute(text(query))
                rows = result.fetchall()
                columns = result.keys()
                schema = [dict(zip(columns, row)) for row in rows]
                
                return json.dumps({
                    "table": table_name,
                    "columns": schema
                }, ensure_ascii=False, default=str)
                
        except Exception as e:
            self.logger.error("get_table_schema_failed", error=str(e), table=table_name)
            return json.dumps({"error": str(e)}, ensure_ascii=False)
    
    async def search_schema(self, keywords: str) -> str:
        """
        搜索数据库模式中的表和字段
        
        Args:
            keywords: 搜索关键词
            
        Returns:
            匹配的表和字段信息
        """
        try:
            query = f"""
            SELECT 
                TABLE_NAME,
                COLUMN_NAME,
                DATA_TYPE,
                COLUMN_COMMENT
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
            AND (
                TABLE_NAME LIKE '%{keywords}%'
                OR COLUMN_NAME LIKE '%{keywords}%'
                OR COLUMN_COMMENT LIKE '%{keywords}%'
            )
            LIMIT 50
            """
            
            async with self.db_engine.connect() as conn:
                result = await conn.execute(text(query))
                rows = result.fetchall()
                columns = result.keys()
                matches = [dict(zip(columns, row)) for row in rows]
                
                return json.dumps({
                    "keyword": keywords,
                    "matches": matches
                }, ensure_ascii=False, default=str)
                
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
        
        Args:
            query: 搜索查询
            
        Returns:
            检索到的文档
        """
        try:
            if not self.retriever:
                return json.dumps({
                    "message": "知识库检索器未配置"
                }, ensure_ascii=False)
            
            self.logger.info("searching_knowledge", query=query)
            
            # 执行检索
            docs = await self.retriever.aget_relevant_documents(query)
            
            results = [
                {
                    "content": doc.page_content,
                    "metadata": doc.metadata,
                    "score": doc.metadata.get("score", 0)
                }
                for doc in docs
            ]
            
            self.logger.info("knowledge_search_completed", doc_count=len(results))
            
            return json.dumps({
                "query": query,
                "documents": results
            }, ensure_ascii=False)
            
        except Exception as e:
            self.logger.error("knowledge_search_failed", error=str(e), query=query)
            return json.dumps({"error": str(e)}, ensure_ascii=False)


def create_tools(db_engine, retriever=None) -> List[StructuredTool]:
    """
    创建 Agent 工具集合
    
    Args:
        db_engine: 数据库引擎
        retriever: 知识库检索器（可选）
        
    Returns:
        工具列表
    """
    db_tools = DatabaseTools(db_engine)
    knowledge_tools = KnowledgeTools(retriever)
    
    tools = [
        StructuredTool.from_function(
            func=db_tools.execute_sql_query,
            name="execute_sql",
            description="执行 SQL SELECT 查询并返回结果。只能执行 SELECT 语句，不允许修改数据。",
            args_schema=SQLQueryInput,
            coroutine=db_tools.execute_sql_query
        ),
        StructuredTool.from_function(
            func=db_tools.get_table_schema,
            name="get_table_schema",
            description="获取指定表的结构信息，包括字段名、类型、注释等。",
            coroutine=db_tools.get_table_schema
        ),
        StructuredTool.from_function(
            func=db_tools.search_schema,
            name="search_schema",
            description="在数据库模式中搜索相关的表和字段。用于探索数据库结构。",
            args_schema=SchemaSearchInput,
            coroutine=db_tools.search_schema
        ),
    ]
    
    # 如果配置了知识库检索器，添加知识搜索工具
    if retriever:
        tools.append(
            StructuredTool.from_function(
                func=knowledge_tools.search_knowledge,
                name="search_knowledge",
                description="搜索业务知识库，获取相关的业务规则、术语定义和最佳实践。",
                args_schema=KnowledgeSearchInput,
                coroutine=knowledge_tools.search_knowledge
            )
        )
    
    return tools
