
from unittest.mock import AsyncMock, patch

import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_stream_chart_saving(client: AsyncClient, auth_headers: dict):
    """
    Test that echarts_option from agent stream is correctly saved as chartOption in database metadata.
    """

    # 1. Mock Data
    payload = {
        "query": "Show me sales trend",
        "connection_id": 1,
        "llm_config_id": 1,
        "session_id": "test-session-stream",
        "stream": True
    }

    mock_chart_option = {
        "title": {"text": "Sales Trend"},
        "series": [{"data": [10, 20, 30]}]
    }

    # 2. Mock Agent & Stream
    mock_agent = AsyncMock()

    async def mock_astream(*args, **kwargs):
        # Simulate agent yielding events
        yield {
            "type": "thinking",
            "content": "Analyzing data...",
            "done": False
        }

        # Simulate final answer with chart
        yield {
            "type": "final_answer",
            "content": "Here is the sales trend.",
            "thinking": "Thinking process...",
            "sql": "SELECT * FROM sales",
            "chartOption": mock_chart_option, # graph.py converts echarts_option to chartOption
            "done": True
        }

        yield {
            "type": "end",
            "content": "Done",
            "done": True
        }

    mock_agent.astream = mock_astream

    mock_db_engine = AsyncMock()
    mock_db_engine.dispose = AsyncMock()

    # 3. Patch dependencies
    with patch("app.create_agent_from_config", new_callable=AsyncMock) as mock_create_agent:
        mock_create_agent.return_value = (mock_agent, mock_db_engine)

        with patch("app.save_chat_message", new_callable=AsyncMock) as mock_save:
            # 4. Make Request
            async with client.stream("POST", "/query/stream", json=payload, headers=auth_headers) as response:
                assert response.status_code == 200
                async for _ in response.aiter_lines():
                    pass # Consume stream

            # 5. Verify save_chat_message was called with correct metadata
            # save_chat_message is called multiple times:
            # 1. User message
            # 2. (Optional) Partial save on error
            # 3. AI message at the end

            # Find the call for AI message
            ai_call_args = None
            for call in mock_save.call_args_list:
                args, kwargs = call
                # args: (db, session_id, role, content, user_id, metadata)
                # Check based on role='ai'
                if len(args) >= 3 and args[2] == 'ai':
                    ai_call_args = kwargs if kwargs else {'metadata': args[5] if len(args) > 5 else kwargs.get('metadata')}
                    # If called with positional args, we need to extract metadata
                    if len(args) > 5:
                         ai_call_args['metadata'] = args[5]
                    break

            if not ai_call_args:
                 # Check kwargs
                 for call in mock_save.call_args_list:
                     if call.kwargs.get('role') == 'ai':
                         ai_call_args = call.kwargs
                         break

            assert ai_call_args is not None, "save_chat_message not called for AI role"

            metadata = ai_call_args.get('metadata')
            assert metadata is not None
            assert "chartOption" in metadata
            assert metadata["chartOption"] == mock_chart_option
            # assert metadata["is_complete"] is True
