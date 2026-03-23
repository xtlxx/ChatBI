"""
Agent 工具测试
"""

from unittest.mock import AsyncMock, MagicMock

import pytest

from agent.tools import DatabaseTools, KnowledgeTools, create_tools


@pytest.fixture
def mock_db_engine():
    """模拟数据库引擎"""
    engine = MagicMock()
    return engine


@pytest.fixture
def db_tools(mock_db_engine):
    """创建数据库工具实例"""
    return DatabaseTools(mock_db_engine)


class TestDatabaseTools:
    """数据库工具测试"""

    @pytest.mark.asyncio
    async def test_execute_sql_query_security(self, db_tools):
        """测试 SQL 安全检查"""
        # 测试非 SELECT 语句被拒绝
        result = await db_tools.execute_sql_query("DROP TABLE users")
        # assert "安全限制" in result # It seems the actual output is different, let's just check for error key
        import json

        res_json = json.loads(result)
        assert "error" in res_json
        assert "安全拒绝" in res_json["error"]

    @pytest.mark.asyncio
    async def test_execute_sql_query_success(self, db_tools, mock_db_engine):
        """测试 SQL 查询成功执行"""
        # 模拟数据库连接和结果
        mock_conn = AsyncMock()
        mock_result = MagicMock()
        mock_result.fetchmany.return_value = [(1, "Product A", 100), (2, "Product B", 200)]
        mock_result.keys.return_value = ["id", "name", "price"]

        mock_conn.execute = AsyncMock(return_value=mock_result)
        # connect() is not async, it returns a context manager. So use MagicMock.
        mock_db_engine.connect = MagicMock(return_value=mock_conn)
        mock_conn.__aenter__ = AsyncMock(return_value=mock_conn)
        mock_conn.__aexit__ = AsyncMock()

        # 执行查询
        result = await db_tools.execute_sql_query("SELECT * FROM products")

        # 验证结果
        import json

        result_data = json.loads(result)
        assert result_data["success"] is True
        assert result_data["row_count"] == 2
        assert len(result_data["data"]) == 2


class TestKnowledgeTools:
    """知识库工具测试"""

    @pytest.mark.asyncio
    async def test_search_knowledge_no_retriever(self):
        """测试没有检索器时的行为"""
        tools = KnowledgeTools(retriever=None)
        result = await tools.search_knowledge("test query")

        import json

        result_data = json.loads(result)
        assert "知识库检索器未配置" in result_data["message"]

    @pytest.mark.asyncio
    async def test_search_knowledge_success(self):
        """测试知识库检索成功"""
        # 模拟检索器
        mock_retriever = MagicMock()
        mock_doc = MagicMock()
        mock_doc.page_content = "测试文档内容"
        mock_doc.metadata = {"source": "test.pdf", "score": 0.95}

        mock_retriever.ainvoke = AsyncMock(return_value=[mock_doc])

        tools = KnowledgeTools(retriever=mock_retriever)
        result = await tools.search_knowledge("test query")

        import json

        result_data = json.loads(result)
        assert result_data["query"] == "test query"
        assert len(result_data["documents"]) == 1
        assert result_data["documents"][0]["content"] == "测试文档内容"


class TestCreateTools:
    """工具创建测试"""

    def test_create_tools_without_retriever(self, mock_db_engine):
        """测试创建工具（不含检索器）"""
        tools = create_tools(mock_db_engine, retriever=None)

        # 应该有 3 个数据库工具
        assert len(tools) == 3
        tool_names = [tool.name for tool in tools]
        assert "execute_sql" in tool_names
        assert "get_table_schema" in tool_names
        assert "search_schema" in tool_names

    def test_create_tools_with_retriever(self, mock_db_engine):
        """测试创建工具（含检索器）"""
        mock_retriever = MagicMock()
        tools = create_tools(mock_db_engine, retriever=mock_retriever)

        # 应该有 4 个工具（3 个数据库 + 1 个知识库）
        assert len(tools) == 4
        tool_names = [tool.name for tool in tools]
        assert "search_knowledge" in tool_names
