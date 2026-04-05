# app.py
"""
生产级 ChatBI Agent API
基于 LangChain 0.1+ 和 LangGraph 构建的 SQL 分析 Agent
适配最新的 ChatBIAgent 状态图架构
"""
import asyncio
import json
import os
import sys
import time
from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager
from datetime import UTC, date, datetime
from typing import Any

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import uvicorn
from fastapi import Depends, FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, StreamingResponse
from langgraph.checkpoint.memory import MemorySaver
from langgraph.checkpoint.postgres import PostgresSaver
from prometheus_client import CONTENT_TYPE_LATEST, REGISTRY, generate_latest
from psycopg_pool import AsyncConnectionPool
from pydantic import BaseModel, Field
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine

from agent.graph import ChatBIAgent
from config import settings
from core.database import AsyncSessionLocal
from core.database import engine as db_engine  # 直接使用 core.database 已配置好的 engine
from logging_config import get_logger
from models.chat import ChatMessage, ChatSession
from routes import auth_router, chat_router, connections_router, llm_configs_router, profile_router
from routes.speech import router as speech_router
from utils.agent_factory import agent_context
from utils.engine_cache import EngineCache  # ✅ 导入 EngineCache 用于关机清理
from utils.jwt_auth import get_current_user_id
from utils.redis_cache import RedisCache

logger = get_logger(__name__)

agent_checkpointer: Any | None = None
checkpoint_pool: AsyncConnectionPool | None = None

class SafeJSONEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, date | datetime):
            return obj.isoformat()
        if hasattr(obj, "model_dump") and callable(obj.model_dump):
            return obj.model_dump()
        try:
            return super().default(obj)
        except TypeError:
            return str(obj)

class QueryRequest(BaseModel):
    query: str = Field(..., description="用户查询问题")
    connection_id: int | None = Field(default=None, description="数据库连接ID")
    llm_config_id: int | None = Field(default=None, description="LLM配置ID")
    session_id: str | None = Field(default="default", description="会话 ID")
    stream: bool = Field(default=False, description="是否使用流式响应")
    metadata: dict[str, Any] | None = Field(default=None, description="额外的元数据")

class QueryResponse(BaseModel):
    summary: str | None = Field(None, description="数据洞察摘要")
    thinking: str | None = Field(None, description="Agent的思考过程")
    sql: str | None = Field(None, description="执行的 SQL 查询")
    chartOption: dict[str, Any] | None = Field(None, description="ECharts 配置")  # noqa: N815
    data: list[dict[str, Any]] | None = Field(None, description="查询结果数据")
    error: str | None = Field(None, description="错误信息")
    session_id: str = Field(..., description="会话 ID")
    execution_time: float | None = Field(None, description="执行耗时（秒）")

class HealthResponse(BaseModel):
    status: str
    database: str
    agent: str
    memory: str
    version: str

@asynccontextmanager
async def lifespan(app: FastAPI):
    global agent_checkpointer, checkpoint_pool
    logger.info("application_starting", version="3.0.0")

    try:
        # 使用 core.database 已经配置好的 engine 验证连接（不再重新创建）
        logger.info("verifying_system_database_connection")
        async with db_engine.connect() as conn:
            await conn.execute(text("SELECT 1"))
        logger.info("system_database_connected")
        
        # 初始化 Redis 缓存
        await RedisCache.init_redis()

        if settings.CHECKPOINT_DATABASE_URL and settings.CHECKPOINT_DATABASE_URL.startswith("postgresql"):
                checkpoint_pool = AsyncConnectionPool(
                    conninfo=settings.CHECKPOINT_DATABASE_URL,
                    open=False,
                    max_size=20,
                    kwargs={"autocommit": True},
                )
                await checkpoint_pool.open()
                agent_checkpointer = PostgresSaver(checkpoint_pool)
                await agent_checkpointer.setup()
        else:
            agent_checkpointer = MemorySaver()
        yield

    finally:
        # 清理所有目标数据库连接（用户配置的）
        await EngineCache.cleanup()
        logger.info("engine_cache_cleaned_up")
        # 清理系统数据库连接
        await db_engine.dispose()
        # 清理 Redis 连接
        await RedisCache.close_redis()
        if checkpoint_pool:
            await checkpoint_pool.close()

app = FastAPI(
    title="ChatBI Agent API",
    description="生产级 AI 数据库查询助手 (LangGraph版)",
    version="3.0.0",
    lifespan=lifespan,
    docs_url="/docs",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Global exception: {exc}", exc_info=True)
    if settings.DEV_MODE:
        return JSONResponse(
            status_code=500,
            content={"detail": "Global Processing Error", "message": str(exc)}
        )
    return JSONResponse(
        status_code=500,
        content={"detail": "Global Processing Error"}
    )

app.include_router(auth_router)
app.include_router(connections_router)
app.include_router(llm_configs_router)
app.include_router(chat_router)
app.include_router(profile_router)
app.include_router(speech_router)

async def get_system_db() -> AsyncGenerator[AsyncSession, None]:
    if not db_engine:
        raise HTTPException(status_code=503, detail="系统数据库尚未初始化")
    async with AsyncSessionLocal() as session:
        yield session

async def save_chat_message(
    db: AsyncSession,
    session_id: str,
    role: str,
    content: str,
    user_id: int | None = None,
    metadata: dict[str, Any] | None = None,
) -> None:
    try:
        stmt = select(ChatSession).where(ChatSession.id == session_id)
        result = await db.execute(stmt)
        session = result.scalar_one_or_none()
        if not session and user_id:
            session = ChatSession(id=session_id, user_id=user_id, title=content[:50])
            db.add(session)
            await db.flush()
        if session:
            new_message = ChatMessage(
                session_id=session_id, role=role, content=content, message_metadata=metadata or {}
            )
            db.add(new_message)
            session.updated_at = datetime.now(UTC).replace(tzinfo=None)
            await db.commit()
    except Exception as e:
        logger.error(f"Failed to save chat message: {e}")

async def get_few_shot_examples(db_session: AsyncSession, limit: int = 3):
    try:
        stmt = (
            select(ChatMessage)
            .where(ChatMessage.role == "ai", ChatMessage.feedback == "like")
            .order_by(ChatMessage.created_at.desc())
            .limit(limit)
        )
        result = await db_session.execute(stmt)
        ai_msgs = result.scalars().all()

        examples = []
        for ai_msg in ai_msgs:
            user_msg_stmt = (
                select(ChatMessage.content)
                .where(
                    ChatMessage.session_id == ai_msg.session_id,
                    ChatMessage.role == "user",
                    ChatMessage.created_at < ai_msg.created_at
                )
                .order_by(ChatMessage.created_at.desc())
                .limit(1)
            )
            user_result = await db_session.execute(user_msg_stmt)
            user_content = user_result.scalar_one_or_none()

            if user_content and ai_msg.message_metadata:
                sql = ai_msg.message_metadata.get("sql_query")
                if sql:
                    examples.append({"question": user_content, "sql": sql})
        return examples
    except Exception:
        return []

async def stream_agent_with_cleanup(
    agent_instance: ChatBIAgent,
    query: str,
    session_id: str,
    metadata: dict[str, Any] | None,
    user_id: int,
    system_db: AsyncSession,
):
    full_answer = ""
    accumulated_thinking = ""
    generated_sql = None
    chart_option = None
    error_msg = None
    is_completed = False
    start_time = time.time()
    try:
        yield f"data: {json.dumps({'type': 'start', 'content': '开始处理'}, cls=SafeJSONEncoder, ensure_ascii=False)}\n\n"
        async for event in agent_instance.astream(query=query, session_id=session_id, metadata=metadata):
            event_type = event.get("type")
            if event_type == "final_answer":
                content = event.get("content", "")
                if content:
                    full_answer = content
                if event.get("chartOption"):
                    chart_option = event.get("chartOption")
                if event.get("thinking"):
                    accumulated_thinking = event.get("thinking")
                if event.get("sql"):
                    generated_sql = event.get("sql")
            elif event_type == "answer_chunk":
                full_answer += event.get("content", "")
            elif event_type == "thinking":
                accumulated_thinking += event.get("content", "")
            elif event_type == "sql_generated":
                generated_sql = event.get("content")
            elif event_type == "error":
                error_msg = event.get("content")
            yield f"data: {json.dumps(event, cls=SafeJSONEncoder, ensure_ascii=False)}\n\n"
        is_completed = True
    except asyncio.CancelledError:
        logger.warning(f"流意外中断 (CancelledError): 客户端可能已断开连接 session_{session_id}")
        error_msg = "流意外中断: 客户端已断开连接"
        # 客户端断开时不应再 yield，直接 return，让 finally 处理持久化
        return
    except Exception as e:
        logger.error(f"流处理错误: {e}", exc_info=True)
        error_msg = str(e)
        error_content = f"处理出错: {str(e)}" if settings.DEV_MODE else "Global Processing Error"
        yield f"data: {json.dumps({'type': 'error', 'content': error_content, 'done': True}, ensure_ascii=False)}\n\n"
    finally:
        execution_time = time.time() - start_time
        # 关键：先执行数据库保存，不依赖 yield，保证持久化绝对执行
        # 使用 asyncio.shield 保护持久化过程，防止因客户端断开连接被中止
        try:
            content_to_save = full_answer if full_answer else (error_msg or "无回答")
            # 扩展存储完整的信息
            msg_metadata = {
                "sql_query": generated_sql,
                "thinking": accumulated_thinking,
                "chartOption": chart_option,
                "error": error_msg,
                "execution_time": round(execution_time, 2),
                "used_prompts": getattr(agent_instance, "dynamic_prompts", {}) # 保存执行时使用的确切Prompt快照
            }
            # 如果有图表生成时的执行数据，可以在此处记录，如果这里拿不到原始数据，需要在 graph 中抛出
            # 这里先将已知的数据全部存下
            
            # 使用 shield 保护，防止当前 Task 被取消影响保存
            await asyncio.shield(save_chat_message(
                system_db, session_id, "ai", content_to_save, user_id, msg_metadata
            ))
        except Exception as e:
            logger.error(f"保存消息失败: {e}")
            
        # 仅在连接未断开时发送结束信号
        if not asyncio.current_task().cancelled():
            try:
                yield f"data: {json.dumps({'type': 'execution_time', 'content': f'{execution_time:.2f}秒'}, cls=SafeJSONEncoder, ensure_ascii=False)}\n\n"
                if not is_completed and not error_msg:
                     yield f"data: {json.dumps({'type': 'error', 'content': '流意外中断', 'done': True}, ensure_ascii=False)}\n\n"
                else:
                    # ✅ 关键修复：始终发送 end 事件通知前端流已结束（解锁 isLoading 状态）
                    yield f"data: {json.dumps({'type': 'end', 'content': '完成', 'done': True}, cls=SafeJSONEncoder, ensure_ascii=False)}\n\n"
            except Exception as e:
                logger.error(f"发送最终流状态失败: {e}")

@app.get("/", tags=["Root"])
async def root():
    return {"message": "Welcome to ChatBI Agent API", "docs": "/docs", "health": "/health"}

@app.get("/health", response_model=HealthResponse, tags=["Health"])
async def health_check():
    return HealthResponse(
        status="healthy", database="connected" if db_engine else "disconnected",
        agent="ready", memory="langgraph_checkpointer", version="3.0.0",
    )

@app.post("/query", response_model=QueryResponse, tags=["Query"])
async def query_database(
    request: QueryRequest,
    current_user_id: int = Depends(get_current_user_id),
    system_db: AsyncSession = Depends(get_system_db),
):
    if not request.connection_id or not request.llm_config_id:
        raise HTTPException(status_code=400, detail="必须提供 connection_id 和 llm_config_id")

    few_shot = await get_few_shot_examples(system_db)
    metadata = request.metadata or {}
    metadata["few_shot_examples"] = few_shot

    # ✅ 修复：使用上下文管理器，并修正了 try 语法错误
    async with agent_context(
        user_id=current_user_id,
        connection_id=request.connection_id,
        llm_config_id=request.llm_config_id,
        db_session=system_db,
        checkpointer=agent_checkpointer
    ) as agent_instance:

        # 先保存用户消息（小修复：原来缺失此步骤）
        await save_chat_message(system_db, request.session_id, "user", request.query, user_id=current_user_id)

        start_time = time.time()
        try:
            result = await agent_instance.ainvoke(
                query=request.query, 
                session_id=request.session_id, 
                metadata=metadata
            )
        except Exception as e:
            logger.error(f"查询执行错误: {e}", exc_info=True)
            raise HTTPException(status_code=500, detail=str(e))
            
        execution_time = time.time() - start_time

        ai_content = result.get("summary", "")
        msg_metadata = {
            "sql_query": result.get("sql"), "chartOption": result.get("chartOption"),
            "thinking": result.get("thinking"), "error": result.get("error"),
            "execution_time": round(execution_time, 2)
        }
        await save_chat_message(system_db, request.session_id, "ai", ai_content, user_id=current_user_id, metadata=msg_metadata)

        return QueryResponse(
            summary=result.get("summary"), thinking=result.get("thinking"), sql=result.get("sql"),
            chartOption=result.get("chartOption"), data=result.get("data"), error=result.get("error"),
            session_id=request.session_id, execution_time=round(execution_time, 2),
        )

@app.post("/query/stream", tags=["Query"])
async def query_database_stream(
    request: QueryRequest,
    current_user_id: int = Depends(get_current_user_id),
    system_db: AsyncSession = Depends(get_system_db),
):
    if not request.connection_id or not request.llm_config_id:
        raise HTTPException(status_code=400, detail="必须提供 connection_id 和 llm_config_id")

    async def stream_generator():
        few_shot = await get_few_shot_examples(system_db)
        metadata = request.metadata or {}
        metadata["few_shot_examples"] = few_shot

        # ✅ 修复：在生成器内部使用上下文管理器
        async with agent_context(
            user_id=current_user_id,
            connection_id=request.connection_id,
            llm_config_id=request.llm_config_id,
            db_session=system_db,
            checkpointer=agent_checkpointer,
        ) as agent_instance:

            await save_chat_message(system_db, request.session_id, "user", request.query, user_id=current_user_id)

            async for chunk in stream_agent_with_cleanup(
                agent_instance=agent_instance, 
                query=request.query, 
                session_id=request.session_id,
                metadata=metadata, 
                user_id=current_user_id, 
                system_db=system_db,
            ):
                yield chunk

    return StreamingResponse(
        stream_generator(),
        media_type="text/event-stream",
        headers={"Cache-Control": "no-cache", "Connection": "keep-alive"},
    )

@app.post("/test/stream", tags=["Test"])
async def test_stream(request: QueryRequest):
    async def mock_generator():
        yield f"data: {json.dumps({'type': 'start', 'content': '开始测试流'}, ensure_ascii=False)}\n\n"
        yield f"data: {json.dumps({'type': 'end', 'content': '完成', 'done': True}, ensure_ascii=False)}\n\n"
    return StreamingResponse(mock_generator(), media_type="text/event-stream")

@app.get("/metrics", tags=["Monitoring"])
async def metrics():
    if not settings.ENABLE_METRICS:
        raise HTTPException(status_code=404, detail="Metrics disabled")
    return JSONResponse(content=generate_latest(REGISTRY).decode("utf-8"), media_type=CONTENT_TYPE_LATEST)

@app.delete("/session/{session_id}", tags=["Session"])
async def clear_session(
    session_id: str,
    current_user_id: int = Depends(get_current_user_id),
    system_db: AsyncSession = Depends(get_system_db),
):
    stmt = select(ChatSession).where(ChatSession.id == session_id, ChatSession.user_id == current_user_id)
    session = (await system_db.execute(stmt)).scalar_one_or_none()
    if session:
        await system_db.delete(session)
        await system_db.commit()
    return {"message": "Session cleared"}

if __name__ == "__main__":
    uvicorn.run("app:app", host="0.0.0.0", port=8000, reload=True)

# === 启动命令 ===
# uvicorn app:app --host 0.0.0.0 --port 8000 --reload
