"""
认证路由
提供用户注册、登录、获取当前用户信息等功能
"""
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel, EmailStr
from typing import Optional

from models.user import User
from utils.jwt_auth import create_access_token, get_current_user_id

router = APIRouter(prefix="/auth", tags=["Authentication"])


# === Pydantic 模型 ===

class LoginRequest(BaseModel):
    """登录请求"""
    username: str
    password: str


class RegisterRequest(BaseModel):
    """注册请求"""
    username: str
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    """用户响应 (包含 JWT token)"""
    id: int
    username: str
    email: str
    token: str


class UserInfoResponse(BaseModel):
    """用户信息响应 (不包含 token)"""
    id: int
    username: str
    email: str


# === 数据库依赖 ===

async def get_db():
    """
    获取数据库会话
    使用全局数据库引擎
    """
    from sqlalchemy.ext.asyncio import AsyncSession
    from sqlalchemy.orm import sessionmaker
    
    # 从 app.py 导入全局数据库引擎
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

@router.post("/register", response_model=UserResponse)
async def register(
    user_data: RegisterRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    用户注册
    
    Args:
        user_data: 注册信息 (username, email, password)
        db: 数据库会话
        
    Returns:
        用户信息和 JWT token
        
    Raises:
        HTTPException: 用户名或邮箱已存在
    """
    # 检查用户名是否已存在
    result = await db.execute(
        select(User).where(User.username == user_data.username)
    )
    if result.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="用户名已存在")
    
    # 检查邮箱是否已存在
    result = await db.execute(
        select(User).where(User.email == user_data.email)
    )
    if result.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="邮箱已被注册")
    
    # 创建新用户
    new_user = User(
        username=user_data.username,
        email=user_data.email,
        hashed_password=User.hash_password(user_data.password)
    )
    
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)
    
    # 生成 JWT token (sub 必须是字符串)
    token = create_access_token(data={"sub": str(new_user.id)})
    
    return UserResponse(
        id=new_user.id,
        username=new_user.username,
        email=new_user.email,
        token=token
    )


@router.post("/login", response_model=UserResponse)
async def login(
    credentials: LoginRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    用户登录
    
    Args:
        credentials: 登录凭证 (username, password)
        db: 数据库会话
        
    Returns:
        用户信息和 JWT token
        
    Raises:
        HTTPException: 用户名或密码错误
    """
    # 查询用户
    result = await db.execute(
        select(User).where(User.username == credentials.username)
    )
    user = result.scalar_one_or_none()
    
    # 验证用户存在且密码正确
    if not user or not user.verify_password(credentials.password):
        raise HTTPException(
            status_code=401,
            detail="用户名或密码错误"
        )
    
    # 生成 JWT token (sub 必须是字符串)
    token = create_access_token(data={"sub": str(user.id)})
    
    return UserResponse(
        id=user.id,
        username=user.username,
        email=user.email,
        token=token
    )


@router.get("/me", response_model=UserInfoResponse)
async def get_current_user(
    user_id: int = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """
    获取当前登录用户信息
    
    Args:
        user_id: 从 JWT token 提取的用户 ID
        db: 数据库会话
        
    Returns:
        用户信息
        
    Raises:
        HTTPException: 用户不存在
    """
    user = await db.get(User, user_id)
    
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    
    return UserInfoResponse(
        id=user.id,
        username=user.username,
        email=user.email
    )


@router.post("/logout")
async def logout():
    """
    登出 (客户端需要删除本地 token)
    
    Returns:
        成功消息
    """
    return {"message": "登出成功,请删除客户端 token"}
