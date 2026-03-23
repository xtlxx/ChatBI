# run_migration.py
"""
数据库迁移脚本
用于添加或修改数据库表结构
"""
import asyncio
import logging

from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

from config import settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


async def run_migration():
    if not settings.DATABASE_URL:
        logger.error("DATABASE_URL is not set")
        return

    logger.info(f"Connecting to database: {settings.DATABASE_URL}")
    engine = create_async_engine(settings.DATABASE_URL)

    try:
        async with engine.begin() as conn:
            # Check if column exists
            logger.info("Checking if 'temperature' column exists in 'llm_configs' table...")
            # For MySQL, we can check information_schema, but simple 'SELECT temperature FROM llm_configs LIMIT 1' is easier to try/except

            try:
                await conn.execute(text("SELECT temperature FROM llm_configs LIMIT 1"))
                logger.info("Column 'temperature' already exists. Skipping migration.")
            except Exception:
                logger.info("Column 'temperature' does not exist. Adding column...")
                await conn.execute(
                    text(
                        "ALTER TABLE llm_configs ADD COLUMN temperature FLOAT DEFAULT 0.7 COMMENT '模型温度'"
                    )
                )
                logger.info("Migration completed successfully.")

    except Exception as e:
        logger.error(f"Migration failed: {e}")
    finally:
        await engine.dispose()


if __name__ == "__main__":
    asyncio.run(run_migration())
