# routes/connections.py
import logging
from typing import List, Annotated, Optional
from fastapi import APIRouter, HTTPException, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel, ConfigDict, Field

# 确保你的项目中有这些模块
from core.database import get_db
from models.db_connection import DbConnection, DbType
from utils.jwt_auth import get_current_user_id

# 配置日志
logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/connections",
    tags=["Connections"]
)

# === 依赖注入定义 ===
DbSession = Annotated[AsyncSession, Depends(get_db)]
CurrentUserId = Annotated[int, Depends(get_current_user_id)]


# === Pydantic 模型 (Schema) ===

class DbConnectionBase(BaseModel):
    """基础字段模型"""
    name: str = Field(..., min_length=1, max_length=100)
    type: DbType  # Pydantic 会自动验证枚举值
    host: str = Field(..., min_length=1)
    port: int = Field(..., gt=0, lt=65536)
    username: str
    database_name: str


class DbConnectionCreate(DbConnectionBase):
    """创建请求 (包含密码)"""
    password: str = Field(..., min_length=1)


class DbConnectionUpdate(BaseModel):
    """更新请求 (所有字段可选)"""
    name: Optional[str] = None
    type: Optional[DbType] = None
    host: Optional[str] = None
    port: Optional[int] = Field(None, gt=0, lt=65536)
    username: Optional[str] = None
    password: Optional[str] = None
    database_name: Optional[str] = None


class DbConnectionResponse(DbConnectionBase):
    """响应模型 (不包含密码)"""
    id: int
    # created_at: Optional[datetime] # 如果需要在前端显示创建时间可取消注释

    # Pydantic V2 配置: 允许从 ORM 对象读取数据
    model_config = ConfigDict(from_attributes=True)

class DbConnectionEditResponse(DbConnectionBase):
    """编辑时响应模型 (包含密码)"""
    id: int
    password: str  # 编辑时返回密码

    # Pydantic V2 配置: 允许从 ORM 对象读取数据
    model_config = ConfigDict(from_attributes=True)


class ConnectionTestResponse(BaseModel):
    """测试结果响应"""
    success: bool
    message: str


# === API 端点 ===

@router.get("", response_model=List[DbConnectionResponse])
async def get_all_connections(
        user_id: CurrentUserId,
        db: DbSession
):
    """获取当前用户的所有数据库连接"""
    stmt = select(DbConnection).where(DbConnection.user_id == user_id)
    result = await db.execute(stmt)
    # 直接返回 ORM 对象列表，Pydantic 会自动序列化
    return result.scalars().all()


@router.get("/{connection_id}", response_model=DbConnectionResponse)
async def get_connection(
        connection_id: int,
        user_id: CurrentUserId,
        db: DbSession
):
    """获取指定数据库连接"""
    # 使用 await db.get 更高效
    connection = await db.get(DbConnection, connection_id)

    if not connection or connection.user_id != user_id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="数据库连接不存在"
        )

    return connection

@router.get("/{connection_id}/edit", response_model=DbConnectionEditResponse)
async def get_connection_for_edit(
        connection_id: int,
        user_id: CurrentUserId,
        db: DbSession
):
    """获取指定数据库连接用于编辑 (包含密码)"""
    connection = await db.get(DbConnection, connection_id)

    if not connection or connection.user_id != user_id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="数据库连接不存在"
        )

    return connection


@router.post("", response_model=DbConnectionResponse, status_code=status.HTTP_201_CREATED)
async def create_connection(
        data: DbConnectionCreate,
        user_id: CurrentUserId,
        db: DbSession
):
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
        raise HTTPException(status_code=500, detail="创建连接失败")

    return new_connection


@router.put("/{connection_id}", response_model=DbConnectionResponse)
async def update_connection(
        connection_id: int,
        data: DbConnectionUpdate,
        user_id: CurrentUserId,
        db: DbSession
):
    """更新数据库连接"""
    connection = await db.get(DbConnection, connection_id)

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
        raise HTTPException(status_code=500, detail="更新失败")

    return connection


@router.delete("/{connection_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_connection(
        connection_id: int,
        user_id: CurrentUserId,
        db: DbSession
):
    """
    删除数据库连接
    返回 204 No Content
    """
    connection = await db.get(DbConnection, connection_id)

    if not connection or connection.user_id != user_id:
        # 为了安全，这里也可以返回 404，不暴露资源是否存在
        raise HTTPException(status_code=404, detail="数据库连接不存在")

    await db.delete(connection)
    await db.commit()
    return None


@router.post("/test", response_model=ConnectionTestResponse)
async def test_connection(data: DbConnectionCreate):
    """
    测试数据库连接 (不需要保存到数据库)
    使用异步驱动防止阻塞 Event Loop
    """
    # 注意：这里接收 DbConnectionCreate 是为了获取明文密码进行测试
    try:
        if data.type == DbType.mysql:
            try:
                import aiomysql
            except ImportError:
                return ConnectionTestResponse(success=False, message="服务器未安装 aiomysql 驱动")

            # 尝试连接 MySQL
            conn = await aiomysql.connect(
                host=data.host,
                port=data.port,
                user=data.username,
                password=data.password,
                db=data.database_name,
                connect_timeout=5  # 设置超时防止挂起
            )
            conn.close()
            return ConnectionTestResponse(success=True, message="MySQL 连接成功")

        elif data.type == DbType.postgresql:
            try:
                import asyncpg
            except ImportError:
                return ConnectionTestResponse(success=False, message="服务器未安装 asyncpg 驱动")

            # 尝试连接 PostgreSQL
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
                message=f"暂不支持自动测试该类型的数据库: {data.type.value}"
            )

    except Exception as e:
        logger.warning(f"Connection test failed: {str(e)}")
        # 返回失败而不是抛出 500 异常，因为这是预期的业务逻辑
        return ConnectionTestResponse(
            success=False,
            message=f"连接失败: {str(e)}"
        )
