from config import settings


def test_settings_load():
    """Test that settings can be loaded correctly."""
    # DB_POOL_SIZE might be overridden by env vars, so just check type and reasonable range
    assert isinstance(settings.DB_POOL_SIZE, int)
    assert settings.DB_POOL_SIZE > 0
    # Add more assertions based on default values or env vars if available


def test_imports():
    """Test that modules can be imported without error."""
    try:
        from agent.graph import ChatBIAgent  # noqa: F401
        from agent.tools import create_tools  # noqa: F401
    except ImportError as e:
        raise AssertionError(f"Import failed: {e}") from e
