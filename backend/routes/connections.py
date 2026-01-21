"""
数据库连接管理路由
提供数据库连接的 CRUD 操作
"""
from typing import List, Optional
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel

# 确保这些模型在你的项目中存在
from models.db_connection import DbConnection, DbType
from utils.jwt_auth import get_current_user_id
from logging_config import get_logger

# 初始化日志和路由
logger = get_logger(__name__)
router = APIRouter(
    prefix="/connections",
    tags=["Connections"]
)

# === Pydantic 模型 (必须放在路由函数之前) ===

class DbConnectionForm(BaseModel):
    """数据库连接表单"""
    name: str
    type: str  # mysql, postgresql, mssql
    host: str
    port: int
    username: str
    password: str
    database_name: str


class DbConnectionResponse(BaseModel):
    """数据库连接响应 (不包含密码)"""
    id: int
    name: str
    type: str
    host: str
    port: int
    username: str
    database_name: str


class ConnectionTestResponse(BaseModel):
    """连接测试响应"""
    success: bool
    message: str


# === 数据库依赖 ===

async def get_db():
    """
    获取数据库会话
    注意：这里使用了延迟导入 app 以避免循环引用
    """
    from sqlalchemy.orm import sessionmaker
    
    # 延迟导入 app，防止循环导入错误
    import app
    
    if not app.db_engine:
        raise HTTPException(
            status_code=503,
            detail="数据库引擎尚未初始化,请稍后再试"
        )
    
    # 创建会话工厂
    async_session = sessionmaker(
        app.db_engine,
        class_=AsyncSession,
        expire_on_commit=False
    )
    
    async with async_session() as session:
        try:
            yield session
        finally:
            await session.close()


# === API 端点 ===

@router.get("", response_model=List[DbConnectionResponse])
async def get_all_connections(
    current_user_id: int = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """获取当前用户的所有数据库连接"""
    result = await db.execute(
        select(DbConnection).where(DbConnection.user_id == current_user_id)
    )
    connections = result.scalars().all()
    
    return [
        DbConnectionResponse(**conn.to_dict(include_password=False))
        for conn in connections
    ]


@router.get("/{connection_id}", response_model=DbConnectionResponse)
async def get_connection(
    connection_id: int,
    current_user_id: int = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """获取指定数据库连接"""
    connection = await db.get(DbConnection, connection_id)
    
    if not connection or connection.user_id != current_user_id:
        raise HTTPException(status_code=404, detail="数据库连接不存在")
    
    return DbConnectionResponse(**connection.to_dict(include_password=False))


@router.post("", response_model=DbConnectionResponse, status_code=201)
async def create_connection(
    data: DbConnectionForm,
    current_user_id: int = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """创建新的数据库连接"""
    logger.info(f"Creating connection: name={data.name}, type={data.type}, user_id={current_user_id}")
    
    # 清理和规范化数据
    normalized_type = data.type.lower().strip()
    
    try:
        enum_type = DbType(normalized_type)
    except ValueError:
        logger.warning(f"Invalid DbType: {normalized_type}, using 'other'")
        enum_type = DbType.other

    new_connection = DbConnection(
        user_id=current_user_id,
        name=data.name,
        type=enum_type,
        host=data.host,
        port=data.port,
        username=data.username,
        database_name=data.database_name
    )
    
    # 设置密码（加密）
    new_connection.set_password(data.password)
    
    db.add(new_connection)
    await db.commit()
    await db.refresh(new_connection)
    
    return DbConnectionResponse(**new_connection.to_dict(include_password=False))


@router.put("/{connection_id}", response_model=DbConnectionResponse)
async def update_connection(
    connection_id: int,
    data: DbConnectionForm,
    current_user_id: int = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """更新数据库连接"""
    connection = await db.get(DbConnection, connection_id)
    
    if not connection or connection.user_id != current_user_id:
        raise HTTPException(status_code=404, detail="数据库连接不存在")
    
    # 更新字段
    connection.name = data.name
    
    try:
        connection.type = DbType(data.type.lower().strip())
    except ValueError:
        connection.type = DbType.other

    connection.host = data.host
    connection.port = data.port
    connection.username = data.username
    connection.database_name = data.database_name
    
    if data.password:
        connection.set_password(data.password)
    
    await db.commit()
    await db.refresh(connection)
    
    return DbConnectionResponse(**connection.to_dict(include_password=False))


@router.delete("/{connection_id}")
async def delete_connection(
    connection_id: int,
    current_user_id: int = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """删除数据库连接"""
    connection = await db.get(DbConnection, connection_id)
    
    if not connection or connection.user_id != current_user_id:
        raise HTTPException(status_code=404, detail="数据库连接不存在")
    
    await db.delete(connection)
    await db.commit()
    
    return {"message": "数据库连接已删除"}


@router.post("/test", response_model=ConnectionTestResponse)
async def test_connection(data: DbConnectionForm):
    """测试数据库连接"""
    try:
        if data.type == "mysql":
            import aiomysql
            conn = await aiomysql.connect(
                host=data.host,
                port=data.port,
                user=data.username,
                password=data.password,
                db=data.database_name,
                connect_timeout=5
            )
            conn.close()
            return ConnectionTestResponse(success=True, message="MySQL 连接成功")
        
        elif data.type == "postgresql":
            import asyncpg
            conn = await asyncpg.connect(
                host=data.host,
                port=data.port,
                user=data.username,
                password=data.password,
                database=data.database_name,
                timeout=5
            )
            await conn.close()
            return ConnectionTestResponse(success=True, message="PostgreSQL 连接成功")
        
        else:
            return ConnectionTestResponse(
                success=False,
                message=f"暂不支持测试该类型的数据库: {data.type}"
            )
    
    except Exception as e:
        logger.error(f"Connection test failed: {str(e)}")
        return ConnectionTestResponse(
            success=False,
            message=f"连接失败: {str(e)}"
        )
