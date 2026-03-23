from datetime import UTC, datetime
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from utils.engine_cache import EngineCache


# Mock DbConnection object
class MockDbConfig:
    def __init__(self, id, updated_at=None, created_at=None):
        self.id = id
        self.updated_at = updated_at
        self.created_at = created_at
        self.host = "localhost"
        self.port = 3306
        self.username = "user"
        self.password = "pass"
        self.database = "db"

@pytest.fixture
def mock_db_config():
    return MockDbConfig(
        id=1,
        created_at=datetime(2024, 1, 1, tzinfo=UTC),
        updated_at=datetime(2024, 1, 1, tzinfo=UTC)
    )

@pytest.fixture
def mock_adapter():
    adapter = MagicMock()
    adapter.pool_args = {"pool_size": 5}
    return adapter

@pytest.fixture(autouse=True)
async def cleanup_cache():
    # Setup: clear cache before test
    await EngineCache.cleanup()
    yield
    # Teardown: clear cache after test
    await EngineCache.cleanup()

@pytest.mark.asyncio
async def test_acquire_creates_new_engine(mock_db_config, mock_adapter):
    """Test that acquire creates a new engine and sets ref count to 1"""
    with patch("utils.engine_cache.create_async_engine") as mock_create_engine, \
         patch("core.db_adapter.DatabaseDetector.get_connection_url", return_value="mysql+aiomysql://..."):

        mock_engine = AsyncMock()
        mock_create_engine.return_value = mock_engine

        engine, key = await EngineCache.acquire(mock_db_config, mock_adapter)

        assert engine == mock_engine
        assert key == (1, mock_db_config.updated_at.timestamp())

        # Verify ref count
        assert EngineCache._ref_counts[key] == 1
        # Verify engine is in active cache
        assert EngineCache._engines[key] == engine

@pytest.mark.asyncio
async def test_acquire_increments_ref_count(mock_db_config, mock_adapter):
    """Test that acquiring the same engine increments ref count"""
    with patch("utils.engine_cache.create_async_engine") as mock_create_engine, \
         patch("core.db_adapter.DatabaseDetector.get_connection_url", return_value="mysql+aiomysql://..."):

        mock_engine = AsyncMock()
        mock_create_engine.return_value = mock_engine

        # First acquire
        engine1, key1 = await EngineCache.acquire(mock_db_config, mock_adapter)
        assert EngineCache._ref_counts[key1] == 1

        # Second acquire
        engine2, key2 = await EngineCache.acquire(mock_db_config, mock_adapter)
        assert engine2 == engine1
        assert key2 == key1
        assert EngineCache._ref_counts[key1] == 2

        mock_create_engine.assert_called_once()

@pytest.mark.asyncio
async def test_release_decrements_ref_count(mock_db_config, mock_adapter):
    """Test that release decrements ref count but does not dispose active engine"""
    with patch("utils.engine_cache.create_async_engine") as mock_create_engine, \
         patch("core.db_adapter.DatabaseDetector.get_connection_url", return_value="mysql+aiomysql://..."), \
         patch("utils.engine_cache.EngineCache._delayed_dispose") as mock_delayed_dispose:

        mock_engine = AsyncMock()
        mock_create_engine.return_value = mock_engine

        engine, key = await EngineCache.acquire(mock_db_config, mock_adapter)
        assert EngineCache._ref_counts[key] == 1

        await EngineCache.release(key)

        assert EngineCache._ref_counts[key] == 0
        # Should NOT be disposed because it is still in active cache
        mock_delayed_dispose.assert_not_called()
        assert key in EngineCache._engines

@pytest.mark.asyncio
async def test_orphan_engine_lifecycle(mock_db_config, mock_adapter):
    """Test full lifecycle: acquire -> update config (orphan) -> release -> dispose"""
    with patch("utils.engine_cache.create_async_engine") as mock_create_engine, \
         patch("core.db_adapter.DatabaseDetector.get_connection_url", return_value="mysql+aiomysql://..."), \
         patch("utils.engine_cache.EngineCache._delayed_dispose") as mock_delayed_dispose:

        # Setup mocks for two different engines
        engine1 = AsyncMock(name="engine1")
        engine2 = AsyncMock(name="engine2")
        mock_create_engine.side_effect = [engine1, engine2]

        # 1. Acquire first engine
        e1, key1 = await EngineCache.acquire(mock_db_config, mock_adapter)
        assert e1 == engine1
        assert EngineCache._ref_counts[key1] == 1

        # 2. Update config to trigger new engine creation
        mock_db_config.updated_at = datetime(2024, 1, 2, tzinfo=UTC)

        # 3. Acquire new engine (this should move engine1 to orphans)
        e2, key2 = await EngineCache.acquire(mock_db_config, mock_adapter)
        assert e2 == engine2
        assert key2 != key1

        # Verify engine1 is orphaned
        assert key1 not in EngineCache._engines
        assert key1 in EngineCache._orphaned_engines
        assert EngineCache._orphaned_engines[key1] == engine1
        # Ref count for key1 should still be 1 (from step 1)
        assert EngineCache._ref_counts[key1] == 1

        # 4. Release engine1 (should trigger disposal)
        await EngineCache.release(key1)

        assert EngineCache._ref_counts.get(key1, 0) == 0
        assert key1 not in EngineCache._orphaned_engines

        # Verify delayed dispose was called for engine1
        mock_delayed_dispose.assert_called_once()
        args, _ = mock_delayed_dispose.call_args
        assert args[0] == engine1

        # 5. Release engine2 (should NOT trigger disposal as it is active)
        await EngineCache.release(key2)
        mock_delayed_dispose.assert_called_once() # Count remains 1

@pytest.mark.asyncio
async def test_orphan_engine_immediate_disposal(mock_db_config, mock_adapter):
    """Test that if an engine has 0 ref count when replaced, it is disposed immediately"""
    with patch("utils.engine_cache.create_async_engine") as mock_create_engine, \
         patch("core.db_adapter.DatabaseDetector.get_connection_url", return_value="mysql+aiomysql://..."), \
         patch("utils.engine_cache.EngineCache._delayed_dispose") as mock_delayed_dispose:

        engine1 = AsyncMock(name="engine1")
        engine2 = AsyncMock(name="engine2")
        mock_create_engine.side_effect = [engine1, engine2]

        # 1. Acquire and Release engine1 (ref count -> 0)
        e1, key1 = await EngineCache.acquire(mock_db_config, mock_adapter)
        await EngineCache.release(key1)
        assert EngineCache._ref_counts[key1] == 0

        # 2. Update config
        mock_db_config.updated_at = datetime(2024, 1, 2, tzinfo=UTC)

        # 3. Acquire new engine (this should dispose engine1 immediately)
        e2, key2 = await EngineCache.acquire(mock_db_config, mock_adapter)

        # Verify engine1 was disposed
        assert key1 not in EngineCache._orphaned_engines
        # assert delayed_dispose was called for engine1
        # Note: delayed_dispose is called inside get_engine when replacing

        # We need to verify that delayed_dispose was called.
        # Since release() called it once (when ref count dropped to 0 but it was active? No wait)
        # When we released engine1, ref count -> 0. Is it disposed?
        # Logic in release: if ref_count == 0: if key in orphaned -> dispose. if key in active -> do nothing.
        # So release() did NOT dispose engine1 because it was still in active cache.

        # Then get_engine() is called for engine2.
        # It finds engine1 in active cache (key mismatch).
        # It pops engine1.
        # It checks ref count of engine1. It is 0.
        # It calls delayed_dispose(engine1).

        mock_delayed_dispose.assert_called_once()
        args, _ = mock_delayed_dispose.call_args
        assert args[0] == engine1

@pytest.mark.asyncio
async def test_cleanup(mock_db_config, mock_adapter):
    with patch("utils.engine_cache.create_async_engine") as mock_create_engine, \
         patch("core.db_adapter.DatabaseDetector.get_connection_url", return_value="mysql+aiomysql://..."):

        mock_engine = AsyncMock()
        mock_create_engine.return_value = mock_engine

        await EngineCache.acquire(mock_db_config, mock_adapter)

        assert len(EngineCache._engines) == 1

        await EngineCache.cleanup()

        assert len(EngineCache._engines) == 0
        assert mock_engine.dispose.call_count == 1
