"""
生产级 ChatBI Agent API
基于 LangChain 0.1+ 和 LangGraph 构建的 SQL 分析 Agent
"""
import os
import json
import asyncio
import time  # [修复] 移至顶部
import uvicorn  # [修复] 移至顶部
from contextlib import asynccontextmanager
from typing import Optional, Dict, Any

from fastapi import FastAPI, HTTPException, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse, JSONResponse
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import create_async_engine, AsyncEngine
from sqlalchemy import text  # [修复] 移至顶部，用于 SQL 执行
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from prometheus_client import REGISTRY as DEFAULT_REGISTRY, CollectorRegistry

# [优化] 创建新的 Registry 实例，避免与默认 Registry 混淆
REGISTRY = CollectorRegistry()

# 假设这些模块存在于你的项目中
from config import settings
from logging_config import get_logger
from agent.graph import ChatBIAgent
from agent.memory import ConversationMemoryManager
# 假设 routes 模块存在
from routes import auth_router, connections_router, llm_configs_router

# 初始化日志
logger = get_logger(__name__)

# === Prometheus 指标 ===
# Disable metrics in development to avoid duplicate registration errors
if settings.ENABLE_METRICS and not os.getenv('DEV_MODE'):
    REQUEST_COUNT = Counter(
        'chatbi_requests_total',
        'Total number of requests',
        ['endpoint', 'method', 'status'],
        registry=REGISTRY
    )
    REQUEST_DURATION = Histogram(
        'chatbi_request_duration_seconds',
        'Request duration in seconds',
        ['endpoint'],
        registry=REGISTRY
    )
    AGENT_EXECUTION_TIME = Histogram(
        'chatbi_agent_execution_seconds',
        'Agent execution time in seconds',
        registry=REGISTRY
    )
    SQL_QUERY_COUNT = Counter(
        'chatbi_sql_queries_total',
        'Total number of SQL queries executed',
        ['status'],
        registry=REGISTRY
    )
else:
    # Create dummy metrics for development
    REQUEST_COUNT = None
    REQUEST_DURATION = None
    AGENT_EXECUTION_TIME = None
    SQL_QUERY_COUNT = None

# === 全局资源 ===
db_engine: Optional[AsyncEngine] = None
agent: Optional[ChatBIAgent] = None
memory_manager: Optional[ConversationMemoryManager] = None


# === Pydantic 模型 ===

class QueryRequest(BaseModel):
    """查询请求模型"""
    query: str = Field(..., description="用户查询问题")
    connection_id: Optional[int] = Field(default=None, description="数据库连接ID")
    llm_config_id: Optional[int] = Field(default=None, description="LLM配置ID")
    session_id: Optional[str] = Field(default="default", description="会话 ID")
    stream: bool = Field(default=False, description="是否使用流式响应")
    metadata: Optional[Dict[str, Any]] = Field(default=None, description="额外的元数据")


class QueryResponse(BaseModel):
    """查询响应模型"""
    summary: Optional[str] = Field(None, description="数据洞察摘要")
    sql: Optional[str] = Field(None, description="执行的 SQL 查询")
    chartOption: Optional[Dict[str, Any]] = Field(None, description="ECharts 配置")
    error: Optional[str] = Field(None, description="错误信息")
    session_id: str = Field(..., description="会话 ID")


class HealthResponse(BaseModel):
    """健康检查响应"""
    status: str
    database: str
    agent: str
    memory: str
    version: str


# === 应用生命周期管理 ===

@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用生命周期管理"""
    global db_engine, agent, memory_manager
    
    logger.info("application_starting", version="3.0.0")
    
    try:
        # 1. 初始化数据库连接
        logger.info("initializing_database")
        db_engine = create_async_engine(
            settings.database_url,
            pool_size=settings.DB_POOL_SIZE,
            max_overflow=settings.DB_MAX_OVERFLOW,
            pool_pre_ping=True,
            echo=settings.LOG_LEVEL == "DEBUG"
        )
        
        # 测试数据库连接
        # [修复] 移除了内部 import，使用顶部的 text
        async with db_engine.connect() as conn:
            await conn.execute(text("SELECT 1"))
        
        logger.info("database_initialized", url=settings.database_url.split("@")[1])
        
        # 2. 初始化记忆管理器
        logger.info("initializing_memory_manager")
        memory_manager = ConversationMemoryManager()
        logger.info("memory_manager_initialized")
        
        # 3. 初始化 Agent
        logger.info("initializing_agent", model=settings.ANTHROPIC_MODEL)
        agent = ChatBIAgent(db_engine=db_engine, retriever=None)
        logger.info("agent_initialized")
        
        # 4. 设置 LangSmith 追踪
        if settings.LANGCHAIN_TRACING_V2 and settings.LANGCHAIN_API_KEY:
            os.environ["LANGCHAIN_TRACING_V2"] = "true"
            os.environ["LANGCHAIN_API_KEY"] = settings.LANGCHAIN_API_KEY
            os.environ["LANGCHAIN_PROJECT"] = settings.LANGCHAIN_PROJECT
            logger.info("langsmith_tracing_enabled", project=settings.LANGCHAIN_PROJECT)
        
        logger.info("application_started")
        
        yield
        
    except Exception as e:
        logger.error("application_startup_failed", error=str(e), exc_info=True)
        raise
    
    finally:
        # 清理资源
        logger.info("application_shutting_down")
        
        if db_engine:
            await db_engine.dispose()
            logger.info("database_connection_closed")
        
        logger.info("application_shutdown_complete")


# === FastAPI 应用初始化 ===

app = FastAPI(
    title="ChatBI Agent API",
    description="生产级 AI 数据库查询助手，基于 LangChain 0.1+ 和 LangGraph",
    version="3.0.0",
    lifespan=lifespan,
    docs_url="/docs",
)  # [修复] 添加了缺失的闭合括号

# CORS 配置
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# === 注册路由 ===
app.include_router(auth_router)
app.include_router(connections_router)
app.include_router(llm_configs_router)

# === 依赖注入 ===

from utils.agent_factory import create_agent_from_config
from utils.jwt_auth import get_current_user_id
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.asyncio import AsyncSession

# ... existing imports ...

# === 依赖注入 ===

async def get_system_db() -> AsyncSession:
    """获取系统数据库会话"""
    if not db_engine:
        raise HTTPException(
            status_code=503,
            detail="系统数据库尚未初始化"
        )
    
    # 创建会话工厂
    async_session = sessionmaker(
        db_engine,
        class_=AsyncSession,
        expire_on_commit=False
    )
    
    async with async_session() as session:
        try:
            yield session
        finally:
            await session.close()

async def get_agent() -> ChatBIAgent:
    """获取默认 Agent 实例 (保留用于健康检查)"""
    if agent is None:
        raise HTTPException(
            status_code=503,
            detail="Agent 尚未初始化，请稍后再试"
        )
    return agent

async def get_memory_manager() -> ConversationMemoryManager:
    """获取记忆管理器实例"""
    if memory_manager is None:
        raise HTTPException(
            status_code=503,
            detail="记忆管理器尚未初始化，请稍后再试"
        )
    return memory_manager

# === API 端点 ===

# ... root and health check remain same ...

@app.post("/query", response_model=QueryResponse, tags=["Query"])
async def query_database(
    request: QueryRequest,
    current_user_id: int = Depends(get_current_user_id),
    system_db: AsyncSession = Depends(get_system_db)
):
    """
    执行数据库查询
    
    支持流式和非流式两种模式
    需要 JWT 认证，并根据 connection_id 和 llm_config_id 动态创建 Agent
    """
    target_db_engine = None
    
    try:
        # 验证请求参数
        if not request.connection_id:
            raise HTTPException(status_code=400, detail="必须提供 connection_id")
        if not request.llm_config_id:
            raise HTTPException(status_code=400, detail="必须提供 llm_config_id")
            
        logger.info(
            "query_received",
            query=request.query,
            session_id=request.session_id,
            user_id=current_user_id,
            connection_id=request.connection_id,
            llm_config_id=request.llm_config_id
        )
        
        # 动态创建 Agent
        # 这会创建一个新的 AsyncEngine 连接到目标数据库，需要确保最后关闭它
        agent_instance, target_db_engine = await create_agent_from_config(
            user_id=current_user_id,
            connection_id=request.connection_id,
            llm_config_id=request.llm_config_id,
            db_session=system_db
        )
        
        if settings.ENABLE_METRICS and REQUEST_COUNT:
            REQUEST_COUNT.labels(
                endpoint="/query",
                method="POST",
                status="processing"
            ).inc()
        
        # 流式响应
        if request.stream:
            # 使用包装器来确保流结束时关闭数据库连接
            return StreamingResponse(
                stream_agent_with_cleanup(
                    agent_instance,
                    request.query,
                    request.session_id,
                    request.metadata,
                    target_db_engine
                ),
                media_type="text/event-stream"
            )
        
        # 非流式响应
        start_time = time.time()
        
        try:
            result = await agent_instance.ainvoke(
                query=request.query,
                session_id=request.session_id,
                metadata=request.metadata
            )
        finally:
            # 非流式模式下，执行完毕立即关闭连接
            await target_db_engine.dispose()
        
        execution_time = time.time() - start_time
        
        if settings.ENABLE_METRICS and AGENT_EXECUTION_TIME:
            AGENT_EXECUTION_TIME.observe(execution_time)
        if settings.ENABLE_METRICS and REQUEST_COUNT:
            REQUEST_COUNT.labels(
                endpoint="/query",
                method="POST",
                status="success"
            ).inc()
        
        logger.info(
            "query_completed",
            session_id=request.session_id,
            execution_time=execution_time
        )
        
        return QueryResponse(
            summary=result.get("summary"),
            sql=result.get("sql"),
            chartOption=result.get("chartOption"),
            error=result.get("error"),
            session_id=request.session_id
        )
        
    except HTTPException:
        # 如果是 HTTPException，直接抛出，但在抛出前清理资源
        if target_db_engine:
            await target_db_engine.dispose()
        raise
        
    except Exception as e:
        # 清理资源
        if target_db_engine:
            await target_db_engine.dispose()
            
        logger.error(
            "query_failed",
            error=str(e),
            query=request.query,
            exc_info=True
        )
        
        if settings.ENABLE_METRICS and REQUEST_COUNT:
            REQUEST_COUNT.labels(
                endpoint="/query",
                method="POST",
                status="error"
            ).inc()
        
        raise HTTPException(status_code=500, detail=f"查询失败: {str(e)}")


async def stream_agent_with_cleanup(
    agent_instance: ChatBIAgent,
    query: str,
    session_id: str,
    metadata: Optional[Dict[str, Any]],
    db_engine: AsyncEngine
):
    """
    流式响应包装器，确保流结束时关闭数据库引擎
    """
    try:
        async for chunk in stream_agent_response(agent_instance, query, session_id, metadata):
            yield chunk
    finally:
        logger.info("closing_target_db_engine", session_id=session_id)
        await db_engine.dispose()


def serialize_event(event: Dict[str, Any]) -> Dict[str, Any]:
    """
    序列化事件数据，将 LangChain 消息对象转换为可 JSON 序列化的格式
    """
    from langchain_core.messages import BaseMessage
    
    def serialize_value(value):
        """递归序列化值"""
        if isinstance(value, BaseMessage):
            # 将 LangChain 消息转换为字典
            return {
                "type": value.__class__.__name__,
                "content": value.content,
            }
        elif isinstance(value, dict):
            return {k: serialize_value(v) for k, v in value.items()}
        elif isinstance(value, (list, tuple)):
            return [serialize_value(item) for item in value]
        else:
            return value
    
    return serialize_value(event)


async def stream_agent_response(
    agent_instance: ChatBIAgent,
    query: str,
    session_id: str,
    metadata: Optional[Dict[str, Any]]
):
    """
    流式传输 Agent 响应 (核心逻辑)
    将 LangGraph 事件转换为前端期望的格式
    """
    try:
        logger.info("stream_started", query=query, session_id=session_id)
        
        # 用于累积最终结果
        final_state = None
        
        async for event in agent_instance.astream(query, session_id, metadata):
            # LangGraph 返回的事件格式: {node_name: node_output}
            # 例如: {'agent': {...state...}} 或 {'tools': {...state...}}
            
            # 提取节点名称和状态
            for node_name, node_state in event.items():
                if node_name == 'agent':
                    # Agent 节点 - 可能包含思考过程
                    messages = node_state.get('messages', [])
                    if messages:
                        last_msg = messages[-1]
                        # 检查是否是 AI 消息
                        if hasattr(last_msg, 'content') and last_msg.content:
                            # 发送思考过程
                            sse_data = {
                                "type": "thought",
                                "content": f"正在分析: {last_msg.content[:100]}..."
                            }
                            yield f"data: {json.dumps(sse_data, ensure_ascii=False)}\n\n"
                
                elif node_name == 'tools':
                    # 工具节点 - 发送观察结果
                    sse_data = {
                        "type": "observation",
                        "content": "正在执行数据库查询..."
                    }
                    yield f"data: {json.dumps(sse_data, ensure_ascii=False)}\n\n"
                
                # 保存最终状态
                final_state = node_state
        
        # 流结束后，发送最终输出
        if final_state:
            messages = final_state.get('messages', [])
            final_content = ""
            
            if messages:
                # 获取最后一条 AI 消息
                for msg in reversed(messages):
                    if hasattr(msg, 'content') and msg.content:
                        final_content = msg.content
                        break
            
            # 提取 SQL 和图表数据
            sql_query = final_state.get('sql_query')
            chart_data = final_state.get('echarts_option')
            
            # 发送最终输出
            sse_data = {
                "type": "final_output",
                "content": {
                    "summary": final_content or "分析完成",
                    "sql": sql_query,
                    "chartOption": chart_data
                }
            }
            yield f"data: {json.dumps(sse_data, ensure_ascii=False)}\n\n"
        
        # 发送结束事件
        sse_end = {"type": "end"}
        yield f"data: {json.dumps(sse_end, ensure_ascii=False)}\n\n"
        
        logger.info("stream_completed", session_id=session_id)
        
    except Exception as e:
        logger.error(
            "stream_failed",
            error=str(e),
            query=query,
            exc_info=True
        )
        
        sse_error = {
            "type": "error",
            "content": str(e)
        }
        yield f"data: {json.dumps(sse_error, ensure_ascii=False)}\n\n"


@app.get("/metrics", tags=["Monitoring"])
async def metrics():
    """Prometheus 指标端点"""
    if not settings.ENABLE_METRICS:
        raise HTTPException(status_code=404, detail="指标收集未启用")
    
    return JSONResponse(
        content=generate_latest(REGISTRY).decode("utf-8"),
        media_type=CONTENT_TYPE_LATEST
    )


@app.delete("/session/{session_id}", tags=["Session"])
async def clear_session(
    session_id: str,
    memory: ConversationMemoryManager = Depends(get_memory_manager),
    current_user_id: int = Depends(get_current_user_id)
):
    """清除会话记忆"""
    try:
        memory.clear_session(session_id)
        logger.info("session_cleared", session_id=session_id)
        return {"message": f"会话 {session_id} 已清除"}
    except Exception as e:
        logger.error("clear_session_failed", error=str(e), session_id=session_id)
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/session/{session_id}/stats", tags=["Session"])
async def get_session_stats(
    session_id: str,
    memory: ConversationMemoryManager = Depends(get_memory_manager),
    current_user_id: int = Depends(get_current_user_id)
):
    """获取会话统计信息"""
    try:
        stats = memory.get_session_stats(session_id)
        return stats
    except Exception as e:
        logger.error("get_session_stats_failed", error=str(e), session_id=session_id)
        raise HTTPException(status_code=500, detail=str(e))


# === 启动命令 ===
# uvicorn app:app --host 0.0.0.0 --port 8000 --reload

if __name__ == "__main__":
    # [修复] 修正了缩进，并使用顶部导入的 uvicorn
    uvicorn.run(
        "app:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level=settings.LOG_LEVEL.lower()
    )
