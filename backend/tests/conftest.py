import sys
from unittest.mock import MagicMock

# Mock psycopg and psycopg_pool before any other imports
try:
    import psycopg
except ImportError:
    mock_psycopg = MagicMock()
    # Mock specific attributes required by langgraph.checkpoint.postgres
    mock_psycopg.Capabilities = MagicMock()
    mock_psycopg.Connection = MagicMock()
    mock_psycopg.Cursor = MagicMock()
    mock_psycopg.Pipeline = MagicMock()
    mock_psycopg.pq = MagicMock()  # Mock libpq wrapper
    mock_psycopg.__version__ = "3.2.0"  # Mock version for psycopg_pool compatibility
    mock_psycopg.__path__ = []  # Make it look like a package

    sys.modules["psycopg"] = mock_psycopg
    sys.modules["psycopg.pq"] = mock_psycopg.pq
    
    # Mock psycopg.rows
    mock_psycopg_rows = MagicMock()
    mock_psycopg_rows.DictRow = MagicMock()
    mock_psycopg_rows.dict_row = MagicMock()
    sys.modules["psycopg.rows"] = mock_psycopg_rows

    # Mock psycopg.types.json
    mock_psycopg_types = MagicMock()
    mock_psycopg_types.json = MagicMock()
    sys.modules["psycopg.types"] = mock_psycopg_types
    sys.modules["psycopg.types.json"] = mock_psycopg_types.json

try:
    import psycopg_pool
except ImportError:
    mock_psycopg_pool = MagicMock()
    mock_psycopg_pool.AsyncConnectionPool = MagicMock
    sys.modules["psycopg_pool"] = mock_psycopg_pool

import uuid
from collections.abc import AsyncGenerator

import pytest
import pytest_asyncio
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app import app, get_system_db
from core.database import get_db
from models.base import Base
from models.user import User
from utils.jwt_auth import create_access_token

# Use an in-memory SQLite database for testing
TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"

@pytest_asyncio.fixture(scope="session")
async def db_engine():
    engine = create_async_engine(
        TEST_DATABASE_URL,
        connect_args={"check_same_thread": False},
        echo=False,
    )

    # Create tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    yield engine

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

    await engine.dispose()

@pytest_asyncio.fixture(scope="function")
async def db_session(db_engine) -> AsyncGenerator[AsyncSession, None]:
    async_session = async_sessionmaker(db_engine, expire_on_commit=False)

    async with async_session() as session:
        yield session
        await session.rollback()

@pytest_asyncio.fixture(scope="function")
async def client(db_session) -> AsyncGenerator[AsyncClient, None]:
    # Override the get_db dependency
    async def override_get_db():
        yield db_session
    async def override_get_system_db():
        yield db_session

    app.dependency_overrides[get_db] = override_get_db
    app.dependency_overrides[get_system_db] = override_get_system_db

    async with AsyncClient(transport=ASGITransport(app=app, raise_app_exceptions=False), base_url="http://test") as c:
        yield c

    app.dependency_overrides.clear()

@pytest_asyncio.fixture(scope="function")
async def test_user(db_session: AsyncSession) -> User:
    suffix = uuid.uuid4().hex
    user = User(
        username=f"testuser_{suffix}",
        email=f"test_{suffix}@example.com",
        hashed_password="hashed_password",
        role="user"
    )
    db_session.add(user)
    await db_session.commit()
    await db_session.refresh(user)
    return user

@pytest.fixture(scope="function")
def auth_headers(test_user: User) -> dict:
    token = create_access_token(data={"sub": str(test_user.id)})
    return {"Authorization": f"Bearer {token}"}
