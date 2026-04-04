# routes/connections.py
import logging
import time
from datetime import datetime
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, ConfigDict, Field
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.pool import NullPool

from core.database import get_db
from core.db_adapter import AdapterFactory, DatabaseDetector
from models.db_connection import DbConnection, DbType
from utils.jwt_auth import get_current_user_id
from utils.redis_cache import RedisCache

# 配置日志
logger = logging.getLogger(__name__)
router = APIRouter(prefix="/connections", tags=["Connections"])

DbSession = Annotated[AsyncSession, Depends(get_db)]
CurrentUserId = Annotated[int, Depends(get_current_user_id)]

class DbConnectionBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    type: DbType
    host: str
    port: int
    username: str
    database_name: str

class DbConnectionCreate(DbConnectionBase):
     password: str = Field(..., min_length=1)

class DbConnectionUpdate(BaseModel):
    name: str | None = None
    type: DbType | None = None
    host: str | None = None
    port: int | None = Field(None, gt=0, lt=65536)
    username: str | None = None
    password: str | None = None
    database_name: str | None = None

class DbConnectionResponse(DbConnectionBase):
    id: int
    model_config = ConfigDict(from_attributes=True)

class DbConnectionEditResponse(DbConnectionBase):
    id: int
    password: str  # 编辑时返回密码
    model_config = ConfigDict(from_attributes=True)

class ConnectionTestRequest(DbConnectionBase):
    password: str

class ConnectionTestResponse(BaseModel):
    success: bool
    message: str
    duration_ms: float = 0
    error_detail: str = None
    timestamp: str = None

# === API 端点 ===

@router.get("", response_model=list[DbConnectionResponse])
async def get_all_connections(user_id: CurrentUserId, db: DbSession):
    result = await db.execute(select(DbConnection).where(DbConnection.user_id == user_id))
    return result.scalars().all()

@router.get("/{connection_id}", response_model=DbConnectionResponse)
async def get_connection(connection_id: int, user_id: CurrentUserId, db: DbSession):
    result = await db.execute(select(DbConnection).where(DbConnection.id == connection_id))
    connection = result.scalar_one_or_none()

    if not connection or connection.user_id != user_id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="数据库连接不存在")

    return connection

@router.get("/{connection_id}/edit", response_model=DbConnectionEditResponse)
async def get_connection_for_edit(connection_id: int, user_id: CurrentUserId, db: DbSession):
    stmt = select(DbConnection).where(DbConnection.id == connection_id)
    result = await db.execute(stmt)
    connection = result.scalar_one_or_none()

    if not connection or connection.user_id != user_id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="数据库连接不存在")

    return connection

@router.post("", response_model=DbConnectionResponse, status_code=status.HTTP_201_CREATED)
async def create_connection(data: DbConnectionCreate, user_id: CurrentUserId, db: DbSession):
    """创建新的数据库连接"""
    logger.info(f"User {user_id} creating connection: {data.name}")

    # 排除 password 字段，因为我们要通过 setter 方法处理加密
    conn_data = data.model_dump(exclude={"password"})

    new_connection = DbConnection(**conn_data, user_id=user_id)

    # 利用 model 中的 property setter 自动加密
    new_connection.password = data.password

    db.add(new_connection)
    try:
        await db.commit()
        await db.refresh(new_connection)
    except Exception as e:
        await db.rollback()
        logger.error(f"Create connection failed: {e}")
        raise HTTPException(status_code=500, detail="创建连接失败") from e

    return new_connection

@router.put("/{connection_id}", response_model=DbConnectionResponse)
async def update_connection(
    connection_id: int, data: DbConnectionUpdate, user_id: CurrentUserId, db: DbSession
):
    """更新数据库连接"""
    stmt = select(DbConnection).where(DbConnection.id == connection_id)
    result = await db.execute(stmt)
    connection = result.scalar_one_or_none()

    if not connection or connection.user_id != user_id:
        raise HTTPException(status_code=404, detail="数据库连接不存在")

    # 只更新传入的字段 (partial update)
    update_data = data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if field == "password":
            connection.password = value  # 自动加密
        else:
            setattr(connection, field, value)

    try:
        await db.commit()
        await db.refresh(connection)
    except Exception as e:
        await db.rollback()
        logger.error(f"Update connection failed: {e}")
        raise HTTPException(status_code=500, detail="更新失败") from e

    return connection

@router.delete("/{connection_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_connection(connection_id: int, user_id: CurrentUserId, db: DbSession):
    """
    删除数据库连接
    返回 204 No Content
    """
    stmt = select(DbConnection).where(DbConnection.id == connection_id)
    result = await db.execute(stmt)
    connection = result.scalar_one_or_none()

    if not connection or connection.user_id != user_id:
        # 为了安全，这里也可以返回 404，不暴露资源是否存在
        raise HTTPException(status_code=404, detail="数据库连接不存在")

    await db.delete(connection)
    await db.commit()
    return None

@router.post("/{connection_id}/refresh-schema", status_code=status.HTTP_200_OK)
async def refresh_schema_cache(connection_id: int, user_id: CurrentUserId, db: DbSession):
    """手动刷新/清除特定数据库的 Schema 缓存"""
    stmt = select(DbConnection).where(DbConnection.id == connection_id)
    result = await db.execute(stmt)
    connection = result.scalar_one_or_none()

    if not connection or connection.user_id != user_id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="数据库连接不存在")

    try:
        import hashlib
        db_url = str(DatabaseDetector.get_connection_url(connection))
        url_hash = hashlib.md5(db_url.encode('utf-8')).hexdigest()
        cache_key = f"schema_cache:{url_hash}"
        
        success = await RedisCache.delete(cache_key)
        if success:
            return {"success": True, "message": "缓存已清除，下次查询将重新拉取表结构"}
        else:
            return {"success": True, "message": "未找到相关缓存，无需清除"}
    except Exception as e:
        logger.error(f"Failed to clear schema cache for connection {connection_id}: {e}")
        raise HTTPException(status_code=500, detail=f"清除缓存失败: {str(e)}")

@router.post("/test", response_model=ConnectionTestResponse)
async def test_connection_endpoint(data: DbConnectionCreate, user_id: CurrentUserId):
    """
    测试数据库连接 (标准化重构版)
    复用核心 Adapter 逻辑，支持所有已适配的数据库类型
    """
    start_time = time.perf_counter()
    timestamp = datetime.now().isoformat()
    try:
        # 1. 获取适配器
        adapter = AdapterFactory.get_adapter(data.type)
        
        # 2. 构造连接 URL (复用核心逻辑)
        try:
            db_url = DatabaseDetector.get_connection_url(data)
        except Exception as e:
            return ConnectionTestResponse(
                success=False, 
                message=f"URL 构造失败: {str(e)}", 
                timestamp=timestamp
            )
        
        # 3. 创建临时引擎，使用 NullPool 避免建立完整连接池带来资源浪费
        test_engine = create_async_engine(
            db_url,
            echo=False,
            poolclass=NullPool,
        )
        
        # 4. 执行简单的连通性测试
        try:
            async with test_engine.connect() as conn:
                await conn.execute(text("SELECT 1"))
        finally:
            # 确保销毁引擎
            await test_engine.dispose()
            
        duration = (time.perf_counter() - start_time) * 1000
        logger.info(
            f"DB Test Success | User: {user_id} | Type: {data.type} | Host: {data.host} | Duration: {duration:.2f}ms"
        )
        
        return ConnectionTestResponse(
            success=True,
            message=f"{data.type.value} 连接测试成功",
            duration_ms=round(duration, 2),
            timestamp=timestamp,
        )
    except ImportError as e:
        # 捕获驱动缺失错误
        return ConnectionTestResponse(
            success=False, 
            message=f"服务器缺少必要的数据库驱动: {str(e)}", 
            timestamp=timestamp
        )
    except Exception as e:
        logger.warning(
            f"DB Test Failed | User: {user_id} | Type: {data.type} | Host: {data.host} | Error: {str(e)}"
        )
        duration = (time.perf_counter() - start_time) * 1000
        return ConnectionTestResponse(
            success=False,
            message="连接失败",
            error_detail=str(e),
            duration_ms=round(duration, 2),
            timestamp=timestamp,
        )