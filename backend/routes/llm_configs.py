"""
LLM 配置管理路由 (优化版 - 支持加密)
提供 LLM 配置的 CRUD 操作
"""
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel
from typing import List, Optional

from models.llm_config import LlmConfig
from utils.jwt_auth import get_current_user_id

router = APIRouter(prefix="/llm-configs", tags=["LLM Configurations"])


# === Pydantic 模型 ===

class LlmConfigForm(BaseModel):
    """LLM 配置表单"""
    provider: str  # openai, qwen, deepseek, anthropic
    model_name: str
    api_key: str
    base_url: Optional[str] = None


class LlmConfigResponse(BaseModel):
    """LLM 配置响应 (不包含 API key)"""
    id: int
    provider: str
    model_name: str
    base_url: Optional[str]


class LlmTestResponse(BaseModel):
    """LLM 测试响应"""
    success: bool
    message: str


# === 数据库依赖 ===

async def get_db():
    """获取数据库会话 (使用全局引擎)"""
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

@router.get("", response_model=List[LlmConfigResponse])
async def get_all_configs(
    current_user_id: int = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """
    获取当前用户的所有 LLM 配置
    
    Args:
        current_user_id: 从 JWT 提取的用户 ID
        db: 数据库会话
        
    Returns:
        LLM 配置列表 (不含 API key)
    """
    result = await db.execute(
        select(LlmConfig).where(LlmConfig.user_id == current_user_id)
    )
    configs = result.scalars().all()
    
    return [
        LlmConfigResponse(**config.to_dict(include_api_key=False))
        for config in configs
    ]


@router.get("/{config_id}", response_model=LlmConfigResponse)
async def get_config(
    config_id: int,
    current_user_id: int = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """
    获取指定 LLM 配置
    
    Args:
        config_id: 配置 ID
        current_user_id: 从 JWT 提取的用户 ID
        db: 数据库会话
        
    Returns:
        LLM 配置信息
        
    Raises:
        HTTPException: 配置不存在或无权访问
    """
    config = await db.get(LlmConfig, config_id)
    
    if not config or config.user_id != current_user_id:
        raise HTTPException(status_code=404, detail="LLM 配置不存在")
    
    return LlmConfigResponse(**config.to_dict(include_api_key=False))


@router.post("", response_model=LlmConfigResponse, status_code=201)
async def create_config(
    data: LlmConfigForm,
    current_user_id: int = Depends(get_current_user_id),  # ✅ 从 JWT 提取
    db: AsyncSession = Depends(get_db)
):
    """
    创建新的 LLM 配置
    
    注意: user_id 从 JWT token 提取,不在请求体中
    
    Args:
        data: LLM 配置
        current_user_id: 从 JWT 提取的用户 ID
        db: 数据库会话
        
    Returns:
        创建的配置信息
    """
    new_config = LlmConfig(
        user_id=current_user_id,  # ✅ 安全: 从 token 获取
        provider=data.provider,
        model_name=data.model_name,
        base_url=data.base_url
    )
    # ✅ 使用加密方法存储 API key
    new_config.set_api_key(data.api_key)
    
    db.add(new_config)
    await db.commit()
    await db.refresh(new_config)
    
    return LlmConfigResponse(**new_config.to_dict(include_api_key=False))


@router.put("/{config_id}", response_model=LlmConfigResponse)
async def update_config(
    config_id: int,
    data: LlmConfigForm,
    current_user_id: int = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """
    更新 LLM 配置
    
    Args:
        config_id: 配置 ID
        data: 新的配置
        current_user_id: 从 JWT 提取的用户 ID
        db: 数据库会话
        
    Returns:
        更新后的配置信息
        
    Raises:
        HTTPException: 配置不存在或无权访问
    """
    config = await db.get(LlmConfig, config_id)
    
    if not config or config.user_id != current_user_id:
        raise HTTPException(status_code=404, detail="LLM 配置不存在")
    
    # 更新字段
    config.provider = data.provider
    config.model_name = data.model_name
    if data.api_key:  # 只在提供新 API key 时更新
        config.set_api_key(data.api_key)  # ✅ 使用加密方法
    config.base_url = data.base_url
    
    await db.commit()
    await db.refresh(config)
    
    return LlmConfigResponse(**config.to_dict(include_api_key=False))


@router.delete("/{config_id}")
async def delete_config(
    config_id: int,
    current_user_id: int = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """
    删除 LLM 配置
    
    Args:
        config_id: 配置 ID
        current_user_id: 从 JWT 提取的用户 ID
        db: 数据库会话
        
    Returns:
        成功消息
        
    Raises:
        HTTPException: 配置不存在或无权访问
    """
    config = await db.get(LlmConfig, config_id)
    
    if not config or config.user_id != current_user_id:
        raise HTTPException(status_code=404, detail="LLM 配置不存在")
    
    await db.delete(config)
    await db.commit()
    
    return {"message": "LLM 配置已删除"}


@router.post("/test", response_model=LlmTestResponse)
async def test_config(data: LlmConfigForm):
    """
    测试 LLM 配置 (不需要认证,不保存到数据库)
    
    Args:
        data: LLM 配置
        
    Returns:
        测试结果
    """
    try:
        if data.provider == "openai":
            from openai import OpenAI
            client = OpenAI(
                api_key=data.api_key,
                base_url=data.base_url if data.base_url else None
            )
            # 测试简单调用
            response = client.chat.completions.create(
                model=data.model_name,
                messages=[{"role": "user", "content": "Hi"}],
                max_tokens=5
            )
            return LlmTestResponse(success=True, message="OpenAI 连接成功")
        
        elif data.provider == "anthropic":
            from anthropic import Anthropic
            client = Anthropic(api_key=data.api_key)
            # 测试简单调用
            response = client.messages.create(
                model=data.model_name,
                max_tokens=5,
                messages=[{"role": "user", "content": "Hi"}]
            )
            return LlmTestResponse(success=True, message="Anthropic 连接成功")
        
        else:
            # 其他 provider 使用通用 OpenAI 兼容接口
            from openai import OpenAI
            client = OpenAI(
                api_key=data.api_key,
                base_url=data.base_url if data.base_url else None
            )
            response = client.chat.completions.create(
                model=data.model_name,
                messages=[{"role": "user", "content": "Hi"}],
                max_tokens=5
            )
            return LlmTestResponse(success=True, message=f"{data.provider} 连接成功")
    
    except Exception as e:
        return LlmTestResponse(
            success=False,
            message=f"连接失败: {str(e)}"
        )
