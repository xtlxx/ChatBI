import logging
from typing import Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from models.system_prompt import SystemPrompt
from utils.redis_cache import RedisCache

logger = logging.getLogger(__name__)

class PromptManager:
    """
    负责从数据库（带有 Redis 缓存）加载动态 Prompt。
    """
    
    @classmethod
    async def get_prompt(cls, db_session: AsyncSession, prompt_key: str, default_content: str = "") -> str:
        """
        获取指定 key 的 prompt。
        如果在缓存中存在，则直接返回；否则查询数据库。
        如果数据库也不存在，则使用默认值并自动将其写入数据库。
        """
        cache_key = f"system_prompt:{prompt_key}"
        
        # 1. 尝试从 Redis 读取
        try:
            cached_prompt = await RedisCache.get(cache_key)
            # 只有当 cached_prompt 不为空，且不仅仅是空字符串时，才认为缓存命中
            if cached_prompt and cached_prompt.strip():
                return cached_prompt
        except Exception as e:
            logger.warning(f"Failed to read prompt from cache: {e}")

        # 2. 缓存未命中，查库
        try:
            stmt = select(SystemPrompt).where(SystemPrompt.prompt_key == prompt_key)
            result = await db_session.execute(stmt)
            prompt_record = result.scalar_one_or_none()

            if prompt_record and prompt_record.content and prompt_record.content.strip():
                content = prompt_record.content
            else:
                # 数据库不存在或者内容为空，插入默认值
                content = default_content
                
                # 如果记录存在但为空，则更新它
                if prompt_record:
                    prompt_record.content = content
                else:
                    new_prompt = SystemPrompt(
                        prompt_key=prompt_key,
                        content=content,
                        description=f"Auto-generated for {prompt_key}"
                    )
                    db_session.add(new_prompt)
                
                await db_session.commit()
                logger.info(f"Initialized/Updated default prompt for {prompt_key}")

            # 3. 写入缓存 (TTL 可设置长一些，比如 24 小时，修改时主动清除)
            try:
                await RedisCache.set(cache_key, content, ttl=86400)
            except Exception as e:
                logger.warning(f"Failed to cache prompt: {e}")

            return content
        except Exception as e:
            logger.error(f"Error fetching prompt {prompt_key} from db: {e}")
            return default_content

    @classmethod
    async def refresh_prompt_cache(cls, prompt_key: str) -> None:
        """
        手动清理指定 prompt 的缓存（当后台更新了 Prompt 时调用）
        """
        cache_key = f"system_prompt:{prompt_key}"
        await RedisCache.delete(cache_key)
