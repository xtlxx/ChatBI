# utils/redis_cache.py
import json
from typing import Any, Optional

from redis.asyncio import Redis, from_url

from config import settings
from logging_config import get_logger

logger = get_logger(__name__)

class RedisCache:
    _redis: Optional[Redis] = None

    @classmethod
    async def init_redis(cls):
        """初始化 Redis 连接池"""
        if cls._redis is None:
            try:
                cls._redis = await from_url(settings.REDIS_URL, encoding="utf-8", decode_responses=True)
                await cls._redis.ping()
                logger.info("redis_connected", url=settings.REDIS_URL)
            except Exception as e:
                logger.error("redis_connection_failed", error=str(e))
                cls._redis = None

    @classmethod
    async def close_redis(cls):
        """关闭 Redis 连接"""
        if cls._redis is not None:
            await cls._redis.aclose()
            logger.info("redis_connection_closed")
            cls._redis = None

    @classmethod
    async def get(cls, key: str) -> Optional[str]:
        """获取缓存"""
        if cls._redis is None:
            return None
        try:
            return await cls._redis.get(key)
        except Exception as e:
            logger.error("redis_get_failed", key=key, error=str(e))
            return None

    @classmethod
    async def set(cls, key: str, value: str, ttl: int = None) -> bool:
        """设置缓存"""
        if cls._redis is None:
            return False
        try:
            if ttl is None:
                ttl = settings.SCHEMA_CACHE_TTL
            await cls._redis.set(key, value, ex=ttl)
            return True
        except Exception as e:
            logger.error("redis_set_failed", key=key, error=str(e))
            return False

    @classmethod
    async def delete(cls, key: str) -> bool:
        """删除缓存"""
        if cls._redis is None:
            return False
        try:
            await cls._redis.delete(key)
            return True
        except Exception as e:
            logger.error("redis_delete_failed", key=key, error=str(e))
            return False
