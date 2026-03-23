import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_create_llm_config(client: AsyncClient, auth_headers: dict, test_user):
    """Test creating a new LLM config."""
    payload = {
        "provider": "openai",
        "model_name": "gpt-4",
        "api_key": "sk-test-key",
        "base_url": "https://api.openai.com/v1",
    }
    response = await client.post("/llm-configs", json=payload, headers=auth_headers)
    assert response.status_code == 201
    data = response.json()
    assert data["provider"] == "openai"
    assert data["model_name"] == "gpt-4"
    assert "api_key" not in data  # Key should not be in default response
    assert "id" in data


@pytest.mark.asyncio
async def test_get_llm_configs(client: AsyncClient, auth_headers: dict, test_user):
    """Test retrieving LLM configs."""
    # Create two configs
    payload1 = {"provider": "anthropic", "model_name": "claude-3", "api_key": "sk-ant-key"}
    await client.post("/llm-configs", json=payload1, headers=auth_headers)

    payload2 = {
        "provider": "ollama",
        "model_name": "llama3",
        "api_key": "na",
        "base_url": "http://localhost:11434",
    }
    await client.post("/llm-configs", json=payload2, headers=auth_headers)

    response = await client.get("/llm-configs", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 2


@pytest.mark.asyncio
async def test_get_llm_config_for_edit(client: AsyncClient, auth_headers: dict, test_user):
    """Test retrieving LLM config with key for edit."""
    # Create config
    payload = {"provider": "deepseek", "model_name": "deepseek-coder", "api_key": "sk-deepseek-key"}
    create_res = await client.post("/llm-configs", json=payload, headers=auth_headers)
    config_id = create_res.json()["id"]

    # Get for edit
    response = await client.get(f"/llm-configs/{config_id}/edit", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert data["api_key"] == "sk-deepseek-key"  # Should return decrypted key


@pytest.mark.asyncio
async def test_update_llm_config(client: AsyncClient, auth_headers: dict, test_user):
    """Test updating LLM config."""
    # Create config
    payload = {"provider": "openai", "model_name": "gpt-3.5", "api_key": "old-key"}
    create_res = await client.post("/llm-configs", json=payload, headers=auth_headers)
    config_id = create_res.json()["id"]

    # Update model and key
    update_payload = {"model_name": "gpt-4-turbo", "api_key": "new-key"}
    response = await client.put(
        f"/llm-configs/{config_id}", json=update_payload, headers=auth_headers
    )
    assert response.status_code == 200
    data = response.json()
    assert data["model_name"] == "gpt-4-turbo"

    # Verify key updated via edit endpoint
    edit_res = await client.get(f"/llm-configs/{config_id}/edit", headers=auth_headers)
    assert edit_res.json()["api_key"] == "new-key"


@pytest.mark.asyncio
async def test_delete_llm_config(client: AsyncClient, auth_headers: dict, test_user):
    """Test deleting LLM config."""
    payload = {"provider": "other", "model_name": "test-model", "api_key": "test-key"}
    create_res = await client.post("/llm-configs", json=payload, headers=auth_headers)
    config_id = create_res.json()["id"]

    response = await client.delete(f"/llm-configs/{config_id}", headers=auth_headers)
    assert response.status_code == 204

    # Verify gone
    get_res = await client.get(f"/llm-configs/{config_id}", headers=auth_headers)
    assert get_res.status_code == 404
