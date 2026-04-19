# utils/agent_factory.py
# 工厂类，用于创建 ChatBIAgent 实例
# 强制使用上下文管理器以管理数据库连接生命周期
from contextlib import asynccontextmanager
from typing import Any, AsyncGenerator

from fastapi import HTTPException
from langchain_anthropic import ChatAnthropic
from langchain_openai import ChatOpenAI
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from agent.graph import ChatBIAgent
from core.db_adapter import AdapterFactory
from logging_config import get_logger
from models.db_connection import DbConnection
from models.llm_config import LlmConfig, LlmProvider
from utils.engine_cache import EngineCache
from utils.prompt_manager import PromptManager
from agent.prompts import THINKING_SYSTEM, SQL_GEN_SYSTEM, RESPONSE_GEN_SYSTEM, CHART_GEN_SYSTEM

logger = get_logger(__name__)

@asynccontextmanager
async def agent_context(
    user_id: int,
    connection_id: int,
    llm_config_id: int,
    db_session: AsyncSession,
    checkpointer: Any | None = None,
) -> AsyncGenerator[ChatBIAgent, None]:
    """
    创建 ChatBIAgent 的上下文管理器。
    负责自动管理数据库引擎的生命周期（获取引用 -> 使用 -> 释放引用）。
    """
    cache_key = None
    
    try:
        # 1. 获取数据库连接配置
        stmt = select(DbConnection).where(
            DbConnection.id == connection_id, 
            DbConnection.user_id == user_id
        )
        result = await db_session.execute(stmt)
        db_conn_config = result.scalar_one_or_none()
        
        if not db_conn_config:
            raise HTTPException(status_code=404, detail="数据库连接配置不存在或无权访问")

        # 2. 获取并锁定目标数据库引擎 (关键修复：使用 acquire)
        adapter = AdapterFactory.get_adapter(db_conn_config.type)
        try:
            target_db_engine, cache_key = await EngineCache.acquire(db_conn_config, adapter)
        except Exception as e:
            logger.error("target_db_connect_failed", exc_info=True)
            raise HTTPException(503, f"无法连接目标数据库: {str(e)}") from e

        # 3. 获取 LLM 配置
        stmt = select(LlmConfig).where(LlmConfig.id == llm_config_id, LlmConfig.user_id == user_id)
        result = await db_session.execute(stmt)
        llm_config = result.scalar_one_or_none()

        if not llm_config:
            raise HTTPException(status_code=404, detail="LLM 配置不存在或无权访问")

        # 4. 初始化 LLM
        api_key = llm_config.api_key
        temperature = llm_config.temperature if llm_config.temperature is not None else 0

        if llm_config.provider == LlmProvider.anthropic:
            llm = ChatAnthropic(
                model=llm_config.model_name,
                api_key=api_key,
                temperature=temperature,
                streaming=True,
                max_tokens=16384,
            )
        else:
            # OpenAI 兼容
            openai_kwargs = {
                "model": llm_config.model_name,
                "api_key": api_key,
                "temperature": temperature,
                "streaming": True,
                "max_tokens": 16384,
            }
            
            # 智能推断 Base URL
            if llm_config.base_url:
                openai_kwargs["base_url"] = llm_config.base_url
            else:
                default_url = LlmProvider.get_default_base_url(llm_config.provider)
                if default_url:
                    openai_kwargs["base_url"] = default_url

            llm = ChatOpenAI(**openai_kwargs)

        # 5. Load dynamic prompts
        thinking_sys = await PromptManager.get_prompt(db_session, "THINKING_SYSTEM", THINKING_SYSTEM)
        sql_gen_sys = await PromptManager.get_prompt(db_session, "SQL_GEN_SYSTEM", SQL_GEN_SYSTEM)
        response_gen_sys = await PromptManager.get_prompt(db_session, "RESPONSE_GEN_SYSTEM", RESPONSE_GEN_SYSTEM)
        chart_gen_sys = await PromptManager.get_prompt(db_session, "CHART_GEN_SYSTEM", CHART_GEN_SYSTEM)

        dynamic_prompts = {
            "THINKING_SYSTEM": thinking_sys,
            "SQL_GEN_SYSTEM": sql_gen_sys,
            "RESPONSE_GEN_SYSTEM": response_gen_sys,
            "CHART_GEN_SYSTEM": chart_gen_sys,
        }

        # 6. 创建 Agent
        agent = ChatBIAgent(
            db_engine=target_db_engine,
            retriever=None,
            llm=llm,
            checkpointer=checkpointer,
            db_type=db_conn_config.type,
            dynamic_prompts=dynamic_prompts,
        )
        
        yield agent

    except Exception as e:
        logger.error("agent_init_failed", exc_info=True)
        if "authentication" in str(e).lower() or "api_key" in str(e).lower():
            raise HTTPException(status_code=401, detail="LLM API 密钥无效或过期") from e
        raise HTTPException(status_code=500, detail=f"Agent 初始化失败: {str(e)}") from e
    finally:
        # 6. 关键修复：释放引擎引用
        if cache_key:
            await EngineCache.release(cache_key)