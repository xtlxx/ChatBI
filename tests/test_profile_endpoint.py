import os
import sys

# Add backend to sys.path to allow imports like 'from core.security'
sys.path.append(os.getcwd())
sys.path.append(os.path.join(os.getcwd(), 'backend'))

# Set env vars before importing app modules to satisfy Settings validation
os.environ.setdefault("DB_HOST", "localhost")
os.environ.setdefault("DB_USER", "test")
os.environ.setdefault("DB_PASSWORD", "test")
os.environ.setdefault("DB_NAME", "test")
os.environ.setdefault("JWT_SECRET_KEY", "test_secret_key")
os.environ.setdefault("ENCRYPTION_KEY", "test_encryption_key_must_be_long_enough_32_chars__")

import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from types import SimpleNamespace
from backend.routes.profile import get_user_profile, PROFILE_CACHE
from backend.models.user import User
import backend.models.chat # Ensure ChatSession is registered for SQLAlchemy relationships
# Remove app import if not needed for unit test, or mock it if it causes side effects
# from backend.app import app 
import time

@pytest.mark.asyncio
async def test_get_user_profile_success():
    # Setup mocks
    mock_db = AsyncMock()
    mock_user = User(id=1, username="testuser", email="test@example.com")
    
    # Mock result for customer query
    mock_customer_result = MagicMock()
    mock_customer_result.one_or_none.return_value = SimpleNamespace(
        id=101,
        name="Test Customer",
        code="CUST001",
        email="test@example.com",
        contact_person="John Doe",
        phone="1234567890",
        address="123 Main St",
        business_state="Active",
        payment_type="Credit"
    )
    
    # Mock result for orders query
    mock_orders_result = MagicMock()
    mock_orders_result.all.return_value = [
        SimpleNamespace(order_month="2025-01", total_quantity=100),
        SimpleNamespace(order_month="2025-02", total_quantity=150)
    ]
    
    # Configure db.execute to return different results based on call count or query content
    # Since we can't easily inspect the query string in side_effect without complexity,
    # we'll just return the customer result first, then orders result.
    mock_db.execute.side_effect = [mock_customer_result, mock_orders_result]
    
    # Clear cache
    PROFILE_CACHE.clear()
    
    # Execute
    profile = await get_user_profile(current_user=mock_user, db=mock_db)
    
    # Verify
    assert profile.id == 101
    assert profile.name == "Test Customer"
    assert profile.email == "test@example.com"
    assert len(profile.recent_orders) == 2
    assert profile.recent_orders[0].total_quantity == 100
    assert profile.cached is False
    
    # Verify Cache was populated
    assert 1 in PROFILE_CACHE
    
    # Test Cache Hit
    cached_profile = await get_user_profile(current_user=mock_user, db=mock_db)
    assert cached_profile.cached is True
    assert cached_profile.id == 101

@pytest.mark.asyncio
async def test_get_user_profile_no_customer():
    # Setup mocks
    mock_db = AsyncMock()
    mock_user = User(id=2, username="guestuser", email="guest@example.com")
    
    # Mock result for customer query (None)
    mock_customer_result = MagicMock()
    mock_customer_result.one_or_none.return_value = None
    
    mock_db.execute.return_value = mock_customer_result
    
    # Execute
    profile = await get_user_profile(current_user=mock_user, db=mock_db)
    
    # Verify Fallback
    assert profile.id == 0
    assert profile.name == "guestuser"
    assert profile.code == "GUEST"

@pytest.mark.asyncio
async def test_get_user_profile_error_handling():
    # Setup mocks
    mock_db = AsyncMock()
    mock_user = User(id=3, username="erroruser", email="error@example.com")
    
    # Mock db.execute raising exception
    mock_db.execute.side_effect = Exception("DB Connection Failed")
    
    # Execute
    profile = await get_user_profile(current_user=mock_user, db=mock_db)
    
    # Verify Degradation
    assert profile.id == 0
    assert profile.name == "erroruser"
    assert profile.code == "ERROR"
