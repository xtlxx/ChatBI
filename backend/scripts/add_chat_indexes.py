#scripts/add_chat_indexes.py
# Add indexes to chat_messages table
# 数据库迁移脚本 。用于给 chat_messages 表添加索引，优化查询性能。
import asyncio
import logging
import os
import sys

# Add backend directory to sys.path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

from config import settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

async def add_indexes():
    if not settings.DATABASE_URL:
        logger.error("DATABASE_URL is not set")
        return

    logger.info(f"Connecting to database: {settings.DATABASE_URL}")
    engine = create_async_engine(settings.DATABASE_URL)

    try:
        async with engine.begin() as conn:
            # 1. Index for role, feedback, created_at
            logger.info("Creating index 'idx_chat_messages_role_feedback_created'...")
            try:
                # Try creating index without IF NOT EXISTS for better compatibility (e.g. MySQL 5.7)
                await conn.execute(text(
                    "CREATE INDEX idx_chat_messages_role_feedback_created ON chat_messages (role, feedback, created_at)"
                ))
                logger.info("Index 'idx_chat_messages_role_feedback_created' created.")
            except Exception as e:
                # Check if error is "Duplicate key name" (MySQL 1061) or "Relation already exists" (Postgres 42P07)
                error_str = str(e).lower()
                if "duplicate key" in error_str or "already exists" in error_str or "1061" in error_str:
                     logger.info("Index 'idx_chat_messages_role_feedback_created' already exists.")
                else:
                    logger.warning(f"Could not create index 'idx_chat_messages_role_feedback_created': {e}")

            # 2. Index for session_id, role, created_at
            logger.info("Creating index 'idx_chat_messages_session_role_created'...")
            try:
                await conn.execute(text(
                    "CREATE INDEX idx_chat_messages_session_role_created ON chat_messages (session_id, role, created_at)"
                ))
                logger.info("Index 'idx_chat_messages_session_role_created' created.")
            except Exception as e:
                error_str = str(e).lower()
                if "duplicate key" in error_str or "already exists" in error_str or "1061" in error_str:
                     logger.info("Index 'idx_chat_messages_session_role_created' already exists.")
                else:
                    logger.warning(f"Could not create index 'idx_chat_messages_session_role_created': {e}")

    except Exception as e:
        logger.error(f"Migration failed: {e}")
    finally:
        await engine.dispose()

if __name__ == "__main__":
    asyncio.run(add_indexes())
