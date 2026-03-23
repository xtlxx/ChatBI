# utils/engine_cache.py

import asyncio

from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine

from logging_config import get_logger

logger = get_logger(__name__)

class EngineCache:
    """
    缓存数据库引擎，避免每次请求都新建连接。
    键：(connection_id, updated_at_timestamp)
    值：AsyncEngine

    🔒 并发安全说明：
    统一使用 _global_lock 管理所有状态，消除了原版「在持有 connection-level lock 的同时
    请求 _global_lock」导致的潜在死锁问题。引擎创建极少发生，单锁不产生性能瓶颈。
    """
    _engines: dict[tuple[int, float], AsyncEngine] = {}
    _ref_counts: dict[tuple[int, float], int] = {}
    _orphaned_engines: dict[tuple[int, float], AsyncEngine] = {}  # 待销毁的旧引擎

    _global_lock = asyncio.Lock()

    @classmethod
    def _calc_key(cls, db_config) -> tuple[int, float]:
        """根据 db_config 计算缓存 key"""
        timestamp = db_config.updated_at.timestamp() if db_config.updated_at else (
            db_config.created_at.timestamp() if db_config.created_at else 0
        )
        return (db_config.id, timestamp)

    @classmethod
    async def acquire(cls, db_config, adapter) -> tuple[AsyncEngine, tuple[int, float]]:
        """
        获取引擎并增加引用计数
        Returns: (engine, cache_key)
        """
        engine = await cls.get_engine(db_config, adapter)
        key = cls._calc_key(db_config)

        async with cls._global_lock:
            cls._ref_counts[key] = cls._ref_counts.get(key, 0) + 1
            logger.debug(f"Engine acquired for {key}. Ref count: {cls._ref_counts[key]}")

        return engine, key

    @classmethod
    async def release(cls, key: tuple[int, float]):
        """
        释放引擎引用计数。
        如果引用计数归零且该引擎已是「孤儿」（已被新引擎取代），则执行延迟销毁。
        """
        engine_to_dispose = None
        connection_id = key[0]

        async with cls._global_lock:
            current_count = cls._ref_counts.get(key, 0)
            if current_count > 0:
                cls._ref_counts[key] = current_count - 1
                logger.debug(f"Engine released for {key}. Ref count: {cls._ref_counts[key]}")

            # 引用归零 + 是孤儿引擎 → 可以销毁
            if cls._ref_counts.get(key, 0) == 0 and key in cls._orphaned_engines:
                engine_to_dispose = cls._orphaned_engines.pop(key)
                cls._ref_counts.pop(key, None)

        if engine_to_dispose:
            asyncio.create_task(cls._delayed_dispose(engine_to_dispose, connection_id))

    @classmethod
    async def _delayed_dispose(cls, engine: AsyncEngine, connection_id: int, delay: int = 60):
        """后台延迟释放旧引擎，防止粗暴切断正在执行的长查询"""
        logger.info(f"Engine for connection {connection_id} scheduled for disposal in {delay}s")
        await asyncio.sleep(delay)
        try:
            await engine.dispose()
            logger.info(f"Successfully disposed old engine for connection {connection_id}")
        except Exception as e:
            logger.error(f"Error disposing engine for connection {connection_id}: {e}")

    @classmethod
    async def get_engine(cls, db_config, adapter) -> AsyncEngine:
        """获取已存在的引擎或新建一个（仅使用单一全局锁，无嵌套锁）"""
        key = cls._calc_key(db_config)

        # 无锁快速路径
        if key in cls._engines:
            return cls._engines[key]

        async with cls._global_lock:
            # 双重检查
            if key in cls._engines:
                return cls._engines[key]

            # 清理同一 connection_id 的旧引擎
            keys_to_remove = [k for k in cls._engines if k[0] == db_config.id]
            old_engines: dict[tuple[int, float], AsyncEngine] = {}
            for k in keys_to_remove:
                old_engines[k] = cls._engines.pop(k)

            # 创建新引擎
            logger.info(f"Creating new engine for connection {db_config.id}")
            from core.db_adapter import DatabaseDetector
            db_url = DatabaseDetector.get_connection_url(db_config)

            engine = create_async_engine(
                db_url,
                echo=False,
                **adapter.pool_args
            )
            cls._engines[key] = engine
            logger.info(f"Created new engine for connection {db_config.id}")

            # 在持有锁时处理旧引擎（不存在嵌套锁问题）
            for k, old_engine in old_engines.items():
                ref_count = cls._ref_counts.get(k, 0)
                if ref_count > 0:
                    cls._orphaned_engines[k] = old_engine
                    logger.info(f"Engine {k} moved to orphans (ref_count={ref_count})")
                else:
                    # 无引用，后台延迟销毁
                    asyncio.create_task(cls._delayed_dispose(old_engine, db_config.id))

            return engine

    @classmethod
    async def cleanup(cls):
        """应用关闭时清理所有数据库引擎连接"""
        async with cls._global_lock:
            for engine in cls._engines.values():
                try:
                    await engine.dispose()
                except Exception as e:
                    logger.error(f"Error disposing engine during cleanup: {e}")
            for engine in cls._orphaned_engines.values():
                try:
                    await engine.dispose()
                except Exception as e:
                    logger.error(f"Error disposing orphaned engine during cleanup: {e}")

            cls._engines.clear()
            cls._orphaned_engines.clear()
            cls._ref_counts.clear()