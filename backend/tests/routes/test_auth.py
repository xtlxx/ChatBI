import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_register_user(client: AsyncClient):
    """Test user registration."""
    payload = {"username": "testuser", "email": "test@example.com", "password": "password123"}
    response = await client.post("/auth/register", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["username"] == "testuser"
    assert "token" in data
    assert "id" in data


@pytest.mark.asyncio
async def test_register_duplicate_username(client: AsyncClient):
    """Test registration with duplicate username."""
    # First registration
    payload = {"username": "duplicate", "email": "dup@example.com", "password": "password123"}
    await client.post("/auth/register", json=payload)

    # Second registration with same username
    payload2 = {"username": "duplicate", "email": "other@example.com", "password": "password456"}
    response = await client.post("/auth/register", json=payload2)
    assert response.status_code == 400
    assert response.json()["detail"] == "用户名已存在"


@pytest.mark.asyncio
async def test_login_user(client: AsyncClient):
    """Test user login."""
    # Register first
    register_payload = {
        "username": "loginuser",
        "email": "login@example.com",
        "password": "password123",
    }
    await client.post("/auth/register", json=register_payload)

    # Login
    login_payload = {"username": "loginuser", "password": "password123"}
    response = await client.post("/auth/login", json=login_payload)
    assert response.status_code == 200
    data = response.json()
    assert data["username"] == "loginuser"
    assert "token" in data


@pytest.mark.asyncio
async def test_login_invalid_password(client: AsyncClient):
    """Test login with invalid password."""
    # Register first
    register_payload = {
        "username": "wrongpass",
        "email": "wrongpass@example.com",
        "password": "password123",
    }
    await client.post("/auth/register", json=register_payload)

    # Login with wrong password
    login_payload = {"username": "wrongpass", "password": "wrongpassword"}
    response = await client.post("/auth/login", json=login_payload)
    assert response.status_code == 401
    assert response.json()["detail"] == "用户名或密码错误"


@pytest.mark.asyncio
async def test_login_nonexistent_user(client: AsyncClient):
    """Test login with nonexistent user."""
    login_payload = {"username": "nonexistent", "password": "password123"}
    response = await client.post("/auth/login", json=login_payload)
    assert response.status_code == 401
    assert response.json()["detail"] == "用户名或密码错误"
