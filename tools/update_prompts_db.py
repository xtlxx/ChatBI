import asyncio
import sys
import os
sys.path.insert(0, os.path.abspath('.'))

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import update
from core.database import DATABASE_URL
from models.system_prompt import SystemPrompt
from agent.prompts import THINKING_SYSTEM, SQL_GEN_SYSTEM, RESPONSE_GEN_SYSTEM, CHART_GEN_SYSTEM
from utils.redis_cache import RedisCache

async def main():
    engine = create_async_engine(DATABASE_URL)
    async_session = sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)
    
    async with async_session() as session:
        for key, content in [
            ("THINKING_SYSTEM", THINKING_SYSTEM),
            ("SQL_GEN_SYSTEM", SQL_GEN_SYSTEM),
            ("RESPONSE_GEN_SYSTEM", RESPONSE_GEN_SYSTEM),
            ("CHART_GEN_SYSTEM", CHART_GEN_SYSTEM),
        ]:
            stmt = update(SystemPrompt).where(SystemPrompt.prompt_key == key).values(content=content)
            await session.execute(stmt)
            await RedisCache.delete(f"system_prompt:{key}")
        await session.commit()
        print("Prompts updated successfully in DB and Redis cache cleared.")

asyncio.run(main())
