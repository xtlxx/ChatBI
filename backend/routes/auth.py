# 文件位置: backend/routes/auth.py
# 角色: API 路由处理器 (API Route Handlers)
# 功能:
# FastAPI 路由定义 (/auth/register, /auth/login)
# 数据库操作 (使用 SQLAlchemy)
# HTTP 请求/响应处理
# 调用认证工具库函数
import logging
from typing import Annotated
from fastapi import APIRouter, HTTPException, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel, EmailStr, ConfigDict

from core.database import get_db  # ✅ 从 core 导入，解耦
from models.user import User
from utils.jwt_auth import create_access_token, get_current_user_id

# 配置日志
logger = logging.getLogger(__name__)
router = APIRouter(prefix="/auth", tags=["Authentication"])

# === Pydantic V2 模型 ===
class UserResponse(BaseModel):
    id: int
    username: str
    email: str
    token: str

    # 允许从 ORM 对象读取数据
    model_config = ConfigDict(from_attributes=True)

class LoginRequest(BaseModel):
    username: str
    password: str

class RegisterRequest(BaseModel):
    username: str
    email: EmailStr
    password: str

# 定义常用依赖类型
DbSession = Annotated[AsyncSession, Depends(get_db)]

@router.post("/register", response_model=UserResponse)
async def register(user_data: RegisterRequest, db: DbSession):
    # 检查用户名
    stmt = select(User).where(User.username == user_data.username)
    if (await db.execute(stmt)).scalar_one_or_none():
        raise HTTPException(status_code=400, detail="用户名已存在")

    # 创建用户
    new_user = User(
        username=user_data.username,
        email=user_data.email,
        hashed_password=User.hash_password(user_data.password)
    )

    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)

    token = create_access_token(data={"sub": str(new_user.id)})

    # 直接返回对象，Pydantic 会自动处理 to_dict
    # 但由于 UserResponse 需要 token 字段，这里手动构造一下
    return UserResponse(
        id=new_user.id,
        username=new_user.username,
        email=new_user.email,
        token=token
    )

@router.post("/login", response_model=UserResponse)
async def login(credentials: LoginRequest, db: DbSession):
    # 查询用户
    stmt = select(User).where(User.username == credentials.username)
    result = await db.execute(stmt)
    user = result.scalar_one_or_none()

    if not user or not user.verify_password(credentials.password):
        # 安全最佳实践：不要区分是用户不存在还是密码错误
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="用户名或密码错误",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = create_access_token(data={"sub": str(user.id)})

    return UserResponse(
        id=user.id,
        username=user.username,
        email=user.email,
        token=token
    )
