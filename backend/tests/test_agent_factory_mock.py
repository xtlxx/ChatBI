from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from fastapi import HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from models.db_connection import DbConnection, DbType
from models.llm_config import LlmConfig, LlmProvider
from utils.agent_factory import agent_context, create_agent_from_config


@pytest.fixture
def mock_db_session():
    session = AsyncMock(spec=AsyncSession)
    # Mock execute result for DbConnection
    mock_result_conn = MagicMock()
    mock_result_conn.scalar_one_or_none.return_value = DbConnection(
        id=1, user_id=1, type=DbType.mysql,
        host="localhost", port=3306, username="root",
        encrypted_password=b"pass", database_name="test_db"
    )

    # Mock execute result for LlmConfig
    mock_result_llm = MagicMock()
    mock_result_llm.scalar_one_or_none.return_value = LlmConfig(
        id=1, user_id=1, provider=LlmProvider.openai,
        api_key="sk-test", model_name="gpt-3.5-turbo", temperature=0.5
    )

    # Configure side_effect to return different results for consecutive calls
    session.execute.side_effect = [mock_result_conn, mock_result_llm]
    return session

@pytest.mark.asyncio
async def test_create_agent_success(mock_db_session):
    with patch("utils.agent_factory.AdapterFactory") as mock_adapter_factory, \
         patch("utils.agent_factory.EngineCache") as mock_engine_cache, \
         patch("utils.agent_factory.ChatOpenAI") as mock_chat_openai, \
         patch("utils.agent_factory.ChatBIAgent") as mock_agent_cls:

        # Setup mocks
        mock_adapter = MagicMock()
        mock_adapter_factory.get_adapter.return_value = mock_adapter

        mock_engine = AsyncMock()
        # Configure get_engine as an AsyncMock to support await
        mock_engine_cache.get_engine = AsyncMock(return_value=mock_engine)

        mock_llm = MagicMock()
        mock_chat_openai.return_value = mock_llm

        mock_agent = MagicMock()
        mock_agent_cls.return_value = mock_agent

        # Execute
        agent, engine = await create_agent_from_config(
            user_id=1, connection_id=1, llm_config_id=1, db_session=mock_db_session
        )

        # Verify
        assert agent == mock_agent
        assert engine == mock_engine

        # Verify EngineCache usage
        mock_engine_cache.get_engine.assert_called_once()
        args, _ = mock_engine_cache.get_engine.call_args
        assert isinstance(args[0], DbConnection)
        assert args[1] == mock_adapter

@pytest.mark.asyncio
async def test_create_agent_db_conn_not_found(mock_db_session):
    # Override session to return None for DbConnection
    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = None
    mock_db_session.execute.side_effect = [mock_result]

    with pytest.raises(HTTPException) as exc:
        await create_agent_from_config(
            user_id=1, connection_id=1, llm_config_id=1, db_session=mock_db_session
        )
    assert exc.value.status_code == 404
    assert "数据库连接配置不存在" in exc.value.detail

@pytest.mark.asyncio
async def test_create_agent_llm_config_not_found(mock_db_session):
    # Override session to return valid DbConnection but None for LlmConfig
    mock_result_conn = MagicMock()
    mock_result_conn.scalar_one_or_none.return_value = DbConnection(
        id=1, user_id=1, type=DbType.mysql
    )

    mock_result_llm = MagicMock()
    mock_result_llm.scalar_one_or_none.return_value = None

    mock_db_session.execute.side_effect = [mock_result_conn, mock_result_llm]

    with patch("utils.agent_factory.EngineCache") as mock_engine_cache, \
         patch("utils.agent_factory.AdapterFactory"):

        mock_engine = AsyncMock()
        mock_engine_cache.get_engine = AsyncMock(return_value=mock_engine)

        with pytest.raises(HTTPException) as exc:
            await create_agent_from_config(
                user_id=1, connection_id=1, llm_config_id=1, db_session=mock_db_session
            )

        assert exc.value.status_code == 404
        assert "LLM 配置不存在" in exc.value.detail


@pytest.mark.asyncio
async def test_create_agent_connection_error_sanitized(mock_db_session):
    with patch("utils.agent_factory.AdapterFactory") as mock_adapter_factory, \
         patch("utils.agent_factory.EngineCache") as mock_engine_cache, \
         patch("utils.agent_factory.settings") as mock_settings:

        mock_settings.DEV_MODE = False
        mock_adapter = MagicMock()
        mock_adapter_factory.get_adapter.return_value = mock_adapter

        async def raise_error(*args, **kwargs):
            raise Exception("mysql+aiomysql://user:pass@host:3306/db")

        mock_engine_cache.get_engine = AsyncMock(side_effect=raise_error)

        with pytest.raises(HTTPException) as exc:
            await create_agent_from_config(
                user_id=1, connection_id=1, llm_config_id=1, db_session=mock_db_session
            )

        assert exc.value.status_code == 503
        assert exc.value.detail == "无法连接目标数据库"

@pytest.mark.asyncio
async def test_create_agent_anthropic(mock_db_session):
    # Mock Anthropic config
    mock_result_conn = MagicMock()
    mock_result_conn.scalar_one_or_none.return_value = DbConnection(
        id=1, user_id=1, type=DbType.postgresql
    )

    mock_result_llm = MagicMock()
    mock_result_llm.scalar_one_or_none.return_value = LlmConfig(
        id=2, user_id=1, provider=LlmProvider.anthropic,
        api_key="sk-ant-test", model_name="claude-3-opus", temperature=0.7
    )

    mock_db_session.execute.side_effect = [mock_result_conn, mock_result_llm]

    with patch("utils.agent_factory.AdapterFactory"), \
         patch("utils.agent_factory.EngineCache") as mock_engine_cache, \
         patch("utils.agent_factory.ChatAnthropic") as mock_chat_anthropic, \
         patch("utils.agent_factory.ChatBIAgent"):

        mock_engine = AsyncMock()
        mock_engine_cache.get_engine = AsyncMock(return_value=mock_engine)

        await create_agent_from_config(
            user_id=1, connection_id=1, llm_config_id=2, db_session=mock_db_session
        )

        mock_chat_anthropic.assert_called_once()
        call_kwargs = mock_chat_anthropic.call_args.kwargs
        assert call_kwargs["model"] == "claude-3-opus"
        assert call_kwargs["streaming"] is True

@pytest.mark.asyncio
async def test_create_agent_engine_failure(mock_db_session):
    with patch("utils.agent_factory.EngineCache") as mock_engine_cache, \
         patch("utils.agent_factory.AdapterFactory"), \
         patch("utils.agent_factory.settings") as mock_settings:

        mock_settings.DEV_MODE = False
        mock_engine_cache.get_engine = AsyncMock(side_effect=Exception("Connection failed"))

        with pytest.raises(HTTPException) as exc:
            await create_agent_from_config(
                user_id=1, connection_id=1, llm_config_id=1, db_session=mock_db_session
            )

        assert exc.value.status_code == 503
        assert "无法连接目标数据库" in exc.value.detail

@pytest.mark.asyncio
async def test_create_agent_openai_base_url(mock_db_session):
    # Mock OpenAI config with base_url
    mock_result_conn = MagicMock()
    mock_result_conn.scalar_one_or_none.return_value = DbConnection(
        id=1, user_id=1, type=DbType.mysql,
        host="localhost", port=3306, username="root",
        encrypted_password=b"pass", database_name="test_db"
    )

    mock_result_llm = MagicMock()
    mock_result_llm.scalar_one_or_none.return_value = LlmConfig(
        id=1, user_id=1, provider=LlmProvider.openai,
        api_key="sk-test", model_name="gpt-4", temperature=0.1,
        base_url="https://custom.openai.com/v1"
    )

    mock_db_session.execute.side_effect = [mock_result_conn, mock_result_llm]

    with patch("utils.agent_factory.AdapterFactory"), \
         patch("utils.agent_factory.EngineCache") as mock_engine_cache, \
         patch("utils.agent_factory.ChatOpenAI") as mock_chat_openai, \
         patch("utils.agent_factory.ChatBIAgent"):

        mock_engine = AsyncMock()
        mock_engine_cache.get_engine = AsyncMock(return_value=mock_engine)

        await create_agent_from_config(
            user_id=1, connection_id=1, llm_config_id=1, db_session=mock_db_session
        )

        mock_chat_openai.assert_called_once()
        call_kwargs = mock_chat_openai.call_args.kwargs
        assert call_kwargs["base_url"] == "https://custom.openai.com/v1"

@pytest.mark.asyncio
async def test_create_agent_default_base_url(mock_db_session):
    mock_result_conn = MagicMock()
    mock_result_conn.scalar_one_or_none.return_value = DbConnection(
        id=1, user_id=1, type=DbType.mysql,
        host="localhost", port=3306, username="root",
        encrypted_password=b"pass", database_name="test_db"
    )

    mock_result_llm = MagicMock()
    mock_result_llm.scalar_one_or_none.return_value = LlmConfig(
        id=1, user_id=1, provider=LlmProvider.openai,
        api_key="sk-test", model_name="gpt-4", temperature=0.1,
        base_url=None
    )

    mock_db_session.execute.side_effect = [mock_result_conn, mock_result_llm]

    with patch("utils.agent_factory.AdapterFactory"), \
         patch("utils.agent_factory.EngineCache") as mock_engine_cache, \
         patch("utils.agent_factory.ChatOpenAI") as mock_chat_openai, \
         patch("utils.agent_factory.ChatBIAgent"), \
         patch("models.llm_config.LlmProvider.get_default_base_url", return_value="https://default.api.com"):

        mock_engine = AsyncMock()
        mock_engine_cache.get_engine = AsyncMock(return_value=mock_engine)

        await create_agent_from_config(
            user_id=1, connection_id=1, llm_config_id=1, db_session=mock_db_session
        )

        mock_chat_openai.assert_called_once()
        call_kwargs = mock_chat_openai.call_args.kwargs
        assert call_kwargs["base_url"] == "https://default.api.com"

@pytest.mark.asyncio
async def test_create_agent_init_exception(mock_db_session):
    # Test exception during agent initialization
    mock_result_conn = MagicMock()
    mock_result_conn.scalar_one_or_none.return_value = DbConnection(
        id=1, user_id=1, type=DbType.mysql,
        host="localhost", port=3306, username="root",
        encrypted_password=b"pass", database_name="test_db"
    )

    mock_result_llm = MagicMock()
    mock_result_llm.scalar_one_or_none.return_value = LlmConfig(
        id=1, user_id=1, provider=LlmProvider.openai,
        api_key="sk-test", model_name="gpt-4"
    )

    # We need to set side_effect twice because we call create_agent_from_config twice below?
    # No, just once per call.
    mock_db_session.execute.side_effect = [mock_result_conn, mock_result_llm]

    with patch("utils.agent_factory.AdapterFactory"), \
         patch("utils.agent_factory.EngineCache") as mock_engine_cache, \
         patch("utils.agent_factory.ChatOpenAI", side_effect=Exception("Invalid api_key provided")):

        mock_engine = AsyncMock()
        # mock_key = (1, 1234567890.0)
        mock_engine_cache.get_engine = AsyncMock(return_value=mock_engine)
        # mock_engine_cache.release = AsyncMock()

        with pytest.raises(HTTPException) as exc:
            await create_agent_from_config(
                user_id=1, connection_id=1, llm_config_id=1, db_session=mock_db_session
            )

        assert exc.value.status_code == 401
        assert "LLM API 密钥无效" in exc.value.detail
        # mock_engine_cache.release.assert_awaited_once_with(mock_key)


@pytest.mark.asyncio
async def test_agent_context(mock_db_session):
    with patch("utils.agent_factory.create_agent_from_config") as mock_create:
        mock_agent = MagicMock()
        mock_engine = AsyncMock()
        # mock_key = (1, 1234567890.0)
        mock_create.return_value = (mock_agent, mock_engine)
        # mock_engine_cache.release = AsyncMock()

        async with agent_context(1, 1, 1, mock_db_session) as (agent, engine):
            assert agent == mock_agent
            assert engine == mock_engine

        # mock_engine_cache.release.assert_awaited_once_with(mock_key)
