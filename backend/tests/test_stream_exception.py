import json
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app import stream_agent_with_cleanup
from config import settings


@pytest.mark.asyncio
async def test_stream_exception_handling(monkeypatch):
    """
    Test that stream_agent_with_cleanup correctly handles exceptions
    and returns localized error messages based on DEV_MODE.
    """
    # 1. Mock dependencies
    mock_agent = MagicMock()

    # Define a generator that raises an exception immediately
    async def mock_astream_error(*args, **kwargs):
        yield {"type": "start", "content": "starting"}
        raise ValueError("Simulated failure")

    mock_agent.astream = mock_astream_error

    mock_system_db = AsyncMock()

    # Case A: DEV_MODE = True
    monkeypatch.setattr(settings, "DEV_MODE", True)
    with patch("app.save_chat_message", new_callable=AsyncMock):
        generator = stream_agent_with_cleanup(
            agent_instance=mock_agent,
            query="test",
            session_id="123",
            metadata={},
            user_id=1,
            system_db=mock_system_db
        )

        results = []
        async for chunk in generator:
            results.append(chunk)

    # Check results
    # Expect: start -> start (from mock) -> error -> execution_time
    assert len(results) >= 2

    # Find the error event
    error_event = None
    for chunk in results:
        if "data: " in chunk:
            try:
                data = json.loads(chunk.replace("data: ", "").strip())
                if data.get("type") == "error":
                    error_event = data
                    break
            except json.JSONDecodeError:
                continue

    assert error_event is not None
    assert error_event["done"] is True

    # Case B: DEV_MODE = False
    monkeypatch.setattr(settings, "DEV_MODE", False)
    with patch("app.save_chat_message", new_callable=AsyncMock):
        generator = stream_agent_with_cleanup(
            agent_instance=mock_agent,
            query="test",
            session_id="123",
            metadata={},
            user_id=1,
            system_db=mock_system_db
        )

        results = []
        async for chunk in generator:
            results.append(chunk)

    # Find the error event
    error_event = None
    for chunk in results:
        if "data: " in chunk:
            try:
                data = json.loads(chunk.replace("data: ", "").strip())
                if data.get("type") == "error":
                    error_event = data
                    break
            except json.JSONDecodeError:
                continue

    assert error_event is not None
    assert error_event["type"] == "error"
    assert error_event["content"] == "Global Processing Error"
    assert error_event["done"] is True
