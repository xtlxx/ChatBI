import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_create_connection(client: AsyncClient, auth_headers: dict, test_user):
    """Test creating a new database connection."""
    payload = {
        "name": "Test DB",
        "type": "mysql",
        "host": "localhost",
        "port": 3306,
        "username": "root",
        "password": "password",
        "database_name": "test_db",
    }
    response = await client.post("/connections", json=payload, headers=auth_headers)
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Test DB"
    assert "password" not in data  # Password should not be in default response
    assert "id" in data


@pytest.mark.asyncio
async def test_get_connections(client: AsyncClient, auth_headers: dict, test_user):
    """Test retrieving connections."""
    # Create two connections
    payload1 = {
        "name": "DB 1",
        "type": "postgresql",
        "host": "localhost",
        "port": 5432,
        "username": "postgres",
        "password": "pw1",
        "database_name": "db1",
    }
    await client.post("/connections", json=payload1, headers=auth_headers)

    payload2 = {
        "name": "DB 2",
        "type": "mysql",
        "host": "127.0.0.1",
        "port": 3306,
        "username": "root",
        "password": "pw2",
        "database_name": "db2",
    }
    await client.post("/connections", json=payload2, headers=auth_headers)

    response = await client.get("/connections", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 2


@pytest.mark.asyncio
async def test_get_connection_for_edit(client: AsyncClient, auth_headers: dict, test_user):
    """Test retrieving connection with password for edit."""
    # Create connection
    payload = {
        "name": "Edit DB",
        "type": "mysql",
        "host": "localhost",
        "port": 3306,
        "username": "root",
        "password": "secret_password",
        "database_name": "edit_db",
    }
    create_res = await client.post("/connections", json=payload, headers=auth_headers)
    conn_id = create_res.json()["id"]

    # Get for edit
    response = await client.get(f"/connections/{conn_id}/edit", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert data["password"] == "secret_password"  # Should return decrypted password


@pytest.mark.asyncio
async def test_update_connection(client: AsyncClient, auth_headers: dict, test_user):
    """Test updating connection details."""
    # Create connection
    payload = {
        "name": "Update DB",
        "type": "mysql",
        "host": "localhost",
        "port": 3306,
        "username": "root",
        "password": "old_password",
        "database_name": "update_db",
    }
    create_res = await client.post("/connections", json=payload, headers=auth_headers)
    conn_id = create_res.json()["id"]

    # Update name and password
    update_payload = {"name": "Updated DB Name", "password": "new_password"}
    response = await client.put(
        f"/connections/{conn_id}", json=update_payload, headers=auth_headers
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Updated DB Name"

    # Verify password updated via edit endpoint
    edit_res = await client.get(f"/connections/{conn_id}/edit", headers=auth_headers)
    assert edit_res.json()["password"] == "new_password"


@pytest.mark.asyncio
async def test_delete_connection(client: AsyncClient, auth_headers: dict, test_user):
    """Test deleting connection."""
    payload = {
        "name": "Delete DB",
        "type": "sqlite",
        "host": "memory",
        "port": 3306,
        "username": "na",
        "password": "na",
        "database_name": "na",
    }
    create_res = await client.post("/connections", json=payload, headers=auth_headers)
    conn_id = create_res.json()["id"]

    response = await client.delete(f"/connections/{conn_id}", headers=auth_headers)
    assert response.status_code == 204

    # Verify gone
    get_res = await client.get(f"/connections/{conn_id}", headers=auth_headers)
    assert get_res.status_code == 404
