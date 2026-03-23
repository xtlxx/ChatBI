import pytest
from httpx import AsyncClient

from config import settings


@pytest.mark.asyncio
async def test_create_session(client: AsyncClient, auth_headers: dict, test_user, monkeypatch):
    """Test creating a new chat session."""
    monkeypatch.setattr(settings, "DEV_MODE", True)
    payload = {"title": "Test Session"}
    response = await client.post("/chat/sessions", json=payload, headers=auth_headers)
    assert response.status_code == 201
    data = response.json()
    assert data["title"] == "Test Session"
    assert "id" in data
    assert "created_at" in data


@pytest.mark.asyncio
async def test_get_sessions(client: AsyncClient, auth_headers: dict, test_user):
    """Test retrieving chat sessions."""
    # Create a session first
    await client.post("/chat/sessions", json={"title": "Session 1"}, headers=auth_headers)
    await client.post("/chat/sessions", json={"title": "Session 2"}, headers=auth_headers)

    response = await client.get("/chat/sessions", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 2
    # Verify order (latest updated first)
    assert data[0]["title"] == "Session 2"
    assert data[1]["title"] == "Session 1"


@pytest.mark.asyncio
async def test_get_session_details(client: AsyncClient, auth_headers: dict, test_user):
    """Test retrieving a specific session with messages."""
    # Create session
    create_res = await client.post(
        "/chat/sessions", json={"title": "Detail Test"}, headers=auth_headers
    )
    session_id = create_res.json()["id"]

    # Add message
    msg_payload = {"role": "user", "content": "Hello AI"}
    await client.post(
        f"/chat/sessions/{session_id}/messages", json=msg_payload, headers=auth_headers
    )

    # Get details
    response = await client.get(f"/chat/sessions/{session_id}", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == session_id
    assert len(data["messages"]) == 1
    assert data["messages"][0]["content"] == "Hello AI"


@pytest.mark.asyncio
async def test_update_session(client: AsyncClient, auth_headers: dict, test_user):
    """Test updating a session title."""
    # Create session
    create_res = await client.post(
        "/chat/sessions", json={"title": "Old Title"}, headers=auth_headers
    )
    session_id = create_res.json()["id"]

    # Update
    payload = {"title": "New Title"}
    response = await client.put(f"/chat/sessions/{session_id}", json=payload, headers=auth_headers)
    assert response.status_code == 200
    assert response.json()["title"] == "New Title"


@pytest.mark.asyncio
async def test_delete_session(client: AsyncClient, auth_headers: dict, test_user):
    """Test deleting a session."""
    # Create session
    create_res = await client.post(
        "/chat/sessions", json={"title": "Delete Me"}, headers=auth_headers
    )
    session_id = create_res.json()["id"]

    # Delete
    response = await client.delete(f"/chat/sessions/{session_id}", headers=auth_headers)
    assert response.status_code == 204

    # Verify gone
    get_res = await client.get(f"/chat/sessions/{session_id}", headers=auth_headers)
    assert get_res.status_code == 404
