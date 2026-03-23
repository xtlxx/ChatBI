from unittest.mock import AsyncMock, patch

import pytest
from httpx import AsyncClient

from config import settings


@pytest.mark.asyncio
async def test_query_endpoint(client: AsyncClient, auth_headers: dict, test_user):
    """Test the /query endpoint with mocked agent."""

    # 1. Setup prerequisite data (Connection & LLM Config) and User is created by test_user fixture
    # Actually, the real create_agent_from_config needs these in DB.
    # But since we MOCK create_agent_from_config, we don't strictly need them in DB
    # UNLESS the route validation checks them before calling the factory.
    # Looking at app.py, it only checks if connection_id and llm_config_id are provided in request.
    # But wait, create_agent_from_config is called. We mock it.

    payload = {
        "query": "Show me total sales",
        "connection_id": 1,
        "llm_config_id": 1,
        "session_id": "test-session-123",
    }

    # Mock return values
    mock_agent = AsyncMock()
    mock_agent.ainvoke.return_value = {
        "summary": "Total sales is 1000",
        "sql": "SELECT sum(sales) FROM table",
        "chartOption": None,
        "data": None,
    }

    # Mock stream generator for other tests if needed

    mock_db_engine = AsyncMock()
    mock_db_engine.dispose = AsyncMock()

    # Patch create_agent_from_config in app module
    with patch("app.create_agent_from_config", new_callable=AsyncMock) as mock_create:
        mock_create.return_value = (mock_agent, mock_db_engine)

        response = await client.post("/query", json=payload, headers=auth_headers)

        assert response.status_code == 200
        data = response.json()
        assert data["summary"] == "Total sales is 1000"
        assert data["sql"] == "SELECT sum(sales) FROM table"
        assert data["session_id"] == "test-session-123"

        # Verify mock was called
        mock_create.assert_called_once()
        mock_agent.ainvoke.assert_called_once()
        # mock_db_engine.dispose.assert_called_once()  # Should be called after request


@pytest.mark.asyncio
async def test_query_missing_params(client: AsyncClient, auth_headers: dict):
    """Test query with missing parameters."""
    payload = {
        "query": "Show me something"
        # missing connection_id and llm_config_id
    }
    response = await client.post("/query", json=payload, headers=auth_headers)
    assert response.status_code == 400
    assert "必须提供 connection_id" in response.json()["detail"]


@pytest.mark.asyncio
async def test_query_error_detail_sanitized(client: AsyncClient, auth_headers: dict, monkeypatch):
    payload = {
        "query": "Show me total sales",
        "connection_id": 1,
        "llm_config_id": 1,
        "session_id": "test-session-123",
    }

    async def raise_error(*args, **kwargs):
        raise Exception("secret_info_should_not_leak")

    monkeypatch.setattr(settings, "DEV_MODE", False)

    with patch("app.create_agent_from_config", new_callable=AsyncMock) as mock_create:
        mock_create.side_effect = raise_error
        response = await client.post("/query", json=payload, headers=auth_headers)
        assert response.status_code == 500
        assert response.json()["detail"] == "Global Processing Error"
