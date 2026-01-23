#utils/jwt_auth.py
"""
JWT 认证工具
提供 JWT token 生成和验证功能
"""
import os
from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from fastapi import HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from datetime import datetime, timedelta, timezone

# JWT 配置 - 延迟加载以确保 .env 文件已被读取
def get_secret_key() -> str:
    """获取 JWT 密钥 (延迟加载)"""
    from config import settings
    return getattr(settings, 'JWT_SECRET_KEY', 'your-secret-key-change-this-in-production')

ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24  # 24小时

security = HTTPBearer()


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    创建 JWT access token
    
    Args:
        data: 要编码的数据 (通常包含 user_id)
        expires_delta: 过期时间增量
        
    Returns:
        JWT token 字符串
    """
    to_encode = data.copy()
    
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, get_secret_key(), algorithm=ALGORITHM)
    
    return encoded_jwt


def decode_token(token: str) -> dict:
    """
    解码 JWT token
    
    Args:
        token: JWT token 字符串
        
    Returns:
        解码后的 payload
        
    Raises:
        HTTPException: token 无效或过期
    """
    try:
        payload = jwt.decode(token, get_secret_key(), algorithms=[ALGORITHM])
        return payload
    except JWTError as e:
        raise HTTPException(
            status_code=401,
            detail=f"Invalid authentication credentials: {str(e)}"
        )


async def get_current_user_id(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> int:
    """
    从 JWT token 中提取当前用户 ID
    
    这是一个 FastAPI 依赖项,用于保护需要认证的端点
    
    Args:
        credentials: HTTP Bearer token
        
    Returns:
        用户 ID
        
    Raises:
        HTTPException: token 无效或缺失 user_id
    """
    token = credentials.credentials
    payload = decode_token(token)
    
    user_id_raw = payload.get("sub")
    if user_id_raw is None:
        raise HTTPException(status_code=401, detail="Invalid token: missing user_id")
    
    # 转换为整数 (JWT 的 sub 可能是字符串或整数)
    try:
        user_id = int(user_id_raw)
    except (ValueError, TypeError):
        raise HTTPException(status_code=401, detail="Invalid token: user_id must be an integer")
    
    return user_id


async def get_optional_user_id(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(HTTPBearer(auto_error=False))
) -> Optional[int]:
    """
    可选的用户认证 (用于同时支持认证和非认证访问的端点)
    
    Returns:
        用户 ID 或 None
    """
    if not credentials:
        return None
    
    try:
        token = credentials.credentials
        payload = decode_token(token)
        user_id_raw = payload.get("sub")

        if user_id_raw is None:
            return None

        return int(user_id_raw)
    except HTTPException:
        return None
