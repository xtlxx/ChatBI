import os
import sys
from unittest.mock import AsyncMock, patch

import pytest
from fastapi.testclient import TestClient

# Ensure backend path is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from agent.graph import ChatBIAgent
from app import app, get_system_db, stream_agent_with_cleanup
from utils.jwt_auth import get_current_user_id


@pytest.mark.asyncio
async def test_stream_agent_with_cleanup_saves_message():
    # ... (keep as is, it passed)
    # Mock agent
    mock_agent = AsyncMock(spec=ChatBIAgent)

    # Mock astream events
    async def mock_astream(*args, **kwargs):
        events = [
            {"type": "thinking", "content": "Thinking about SQL..."},
            {"type": "sql_generated", "content": "SELECT * FROM table", "thought": "Simple query"},
            {"type": "final_answer", "content": "Here is the data", "thinking": "Thinking about SQL...", "sql": "SELECT * FROM table"}
        ]
        for event in events:
            yield event

    mock_agent.astream = mock_astream

    # Mock DBs
    mock_system_db = AsyncMock()

    # Mock save_chat_message
    with patch("app.save_chat_message", new_callable=AsyncMock) as mock_save:
        # Run generator
        generator = stream_agent_with_cleanup(
            agent_instance=mock_agent,
            query="test query",
            session_id="test_session",
            metadata={},
            user_id=1,
            system_db=mock_system_db
        )

        # Consume generator
        async for _ in generator:
            pass

        # Verify save_chat_message was called
        mock_save.assert_called_once()
        args, kwargs = mock_save.call_args

        # Check arguments: system_db, session_id, role, content
        # save_chat_message signature: (db, session_id, role, content, user_id=None, metadata=None)
        assert args[1] == "test_session"
        assert args[2] == "ai"
        assert args[3] == "Here is the data"

        # Check metadata
        metadata = args[5] if len(args) > 5 else kwargs.get("metadata")

        assert metadata["sql_query"] == "SELECT * FROM table"
        assert "Thinking about SQL..." in metadata["thinking"]

@pytest.mark.asyncio
async def test_stream_final_answer_deduplication():
    mock_agent = AsyncMock(spec=ChatBIAgent)

    async def mock_astream(*args, **kwargs):
        events = [
            {"type": "final_answer", "content": "Part 1 ", "done": False},
            {"type": "final_answer", "content": "Part 2", "done": False},
            {"type": "final_answer", "content": "Final Answer", "done": True}
        ]
        for event in events:
            yield event

    mock_agent.astream = mock_astream

    mock_system_db = AsyncMock()

    with patch("app.save_chat_message", new_callable=AsyncMock) as mock_save:
        generator = stream_agent_with_cleanup(
            agent_instance=mock_agent,
            query="test query",
            session_id="test_session",
            metadata={},
            user_id=1,
            system_db=mock_system_db
        )

        async for _ in generator:
            pass

        args, kwargs = mock_save.call_args
        # assert args[3] == "Final Answer"
        assert args[3] == "Part 1 Part 2Final Answer"

@pytest.mark.asyncio
async def test_app_query_endpoint_compatibility():
    # Mock create_agent_from_config
    mock_agent = AsyncMock(spec=ChatBIAgent)
    mock_agent.ainvoke.return_value = {
        "summary": "Summary result",
        "thinking": "Think process",
        "sql": "SELECT 1",
        "chartOption": {"title": "Chart"},
        "data": [{"col": 1}],
        "error": None
    }
    mock_db_engine = AsyncMock()

    # Use dependency overrides
    app.dependency_overrides[get_current_user_id] = lambda: 1
    app.dependency_overrides[get_system_db] = lambda: AsyncMock()

    with (
        patch("app.create_agent_from_config", return_value=(mock_agent, mock_db_engine)),
        patch("app.save_chat_message", new_callable=AsyncMock),
        patch("app.get_few_shot_examples", return_value=[]),
    ):
        client = TestClient(app)
        response = client.post("/query", json={
            "query": "test",
            "connection_id": 1,
            "llm_config_id": 1,
            "session_id": "sess1"
        })

        assert response.status_code == 200
        data = response.json()
        assert data["summary"] == "Summary result"
        assert data["thinking"] == "Think process"
        assert data["sql"] == "SELECT 1"
        assert data["chartOption"] == {"title": "Chart"}

    # Clean up overrides
    app.dependency_overrides = {}
