from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, AsyncEngine
from sqlalchemy import select
from fastapi import HTTPException
from models.db_connection import DbConnection, DbType
from models.llm_config import LlmConfig, LlmProvider
from agent.graph import ChatBIAgent
from langchain_openai import ChatOpenAI
from langchain_anthropic import ChatAnthropic
from typing import Tuple, Optional

async def create_agent_from_config(
    user_id: int,
    connection_id: int,
    llm_config_id: int,
    db_session: AsyncSession
) -> Tuple[ChatBIAgent, AsyncEngine]:
    """
    根据用户配置创建 ChatBIAgent 实例
    
    Args:
        user_id: 用户 ID
        connection_id: 数据库连接 ID
        llm_config_id: LLM 配置 ID
        db_session: 系统数据库会话 (用于查询配置)
        
    Returns:
        (ChatBIAgent 实例, 临时的数据库引擎)
        注意: 调用者负责在通过后关闭数据库引擎 await engine.dispose()
    """
    
    # 1. 获取数据库连接配置
    result = await db_session.execute(
        select(DbConnection).where(
            DbConnection.id == connection_id,
            DbConnection.user_id == user_id
        )
    )
    db_conn_config = result.scalar_one_or_none()
    
    if not db_conn_config:
        raise HTTPException(status_code=404, detail="数据库连接配置不存在或无权访问")
    
    # 构建数据库 URL
    password = db_conn_config.get_password()
    
    # 根据类型构建 URL
    # 目前支持 MySQL 和 PostgreSQL
    if db_conn_config.type == DbType.mysql:
        # mysql+aiomysql://user:password@host:port/dbname
        db_url = f"mysql+aiomysql://{db_conn_config.username}:{password}@{db_conn_config.host}:{db_conn_config.port}/{db_conn_config.database_name}"
    elif db_conn_config.type == DbType.postgresql:
        # postgresql+asyncpg://user:password@host:port/dbname
        db_url = f"postgresql+asyncpg://{db_conn_config.username}:{password}@{db_conn_config.host}:{db_conn_config.port}/{db_conn_config.database_name}"
    else:
        # 尝试通用构建，假设是兼容的
        # 为了兼容性，如果是其他类型，可能需要更多处理
        # 这里先只支持这两种主流库
        raise HTTPException(status_code=400, detail=f"暂时不支持该数据库类型: {db_conn_config.type}")

    # 创建临时的分析目标数据库引擎
    target_db_engine = create_async_engine(db_url, echo=False)
    
    # 2. 获取 LLM 配置
    result = await db_session.execute(
        select(LlmConfig).where(
            LlmConfig.id == llm_config_id,
            LlmConfig.user_id == user_id
        )
    )
    llm_config = result.scalar_one_or_none()
    
    if not llm_config:
        # 清理已创建的引擎
        await target_db_engine.dispose()
        raise HTTPException(status_code=404, detail="LLM 配置不存在或无权访问")
    
    # 构建 LLM 实例
    api_key = llm_config.get_api_key()
    
    if llm_config.provider == LlmProvider.anthropic:
        llm = ChatAnthropic(
            model=llm_config.model_name,
            api_key=api_key,
            temperature=0,
            streaming=True
        )
    else:
        # 默认为 OpenAI 兼容接口 (包括 OpenAI, DeepSeek, Qwen 等)
        # 如果 base_url 为空，ChatOpenAI 默认使用 OpenAI 官方地址
        openai_kwargs = {
            "model": llm_config.model_name,
            "api_key": api_key,
            "temperature": 0,
            "streaming": True
        }
        
        if llm_config.base_url:
            openai_kwargs["base_url"] = llm_config.base_url
            
        llm = ChatOpenAI(**openai_kwargs)
    
    # 3. 创建 Agent
    try:
        agent = ChatBIAgent(db_engine=target_db_engine, llm=llm)
    except Exception as e:
        await target_db_engine.dispose()
        raise HTTPException(status_code=500, detail=f"Agent 初始化失败: {str(e)}")
        
    return agent, target_db_engine
