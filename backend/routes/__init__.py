# routes/__init__.py
# Routes 包初始化
from .auth import router as auth_router
from .chat import router as chat_router
from .connections import router as connections_router
from .llm_configs import router as llm_configs_router
from .profile import router as profile_router

__all__ = ["auth_router", "connections_router", "llm_configs_router", "chat_router", "profile_router"]