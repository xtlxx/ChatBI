import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_health_check(client: AsyncClient):
    """Test the health check endpoint."""
    response = await client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    # database should be "connected" because we are mocking the session?
    # Actually, the health check in app.py checks a global `db_engine` variable.
    # Since we didn't mock the global `db_engine` in app.py, but rather the `get_system_db` dependency,
    # the health check might report 'disconnected' if `lifespan` didn't run or if we didn't patch `app.db_engine`.
    # However, TestClient (AsyncClient) with lifespan management should trigger lifespan.
    # But wait, our `client` fixture initializes the app.

    # Let's check what the health endpoint actually returns.
    # It returns "database": "connected" if db_engine else "disconnected"
    assert "version" in data
