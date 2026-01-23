# routes/llm_configs.py
import logging
import httpx # 用于通用的 HTTP 异步请求 (如 Gemini)
from typing import List, Annotated, Optional
from fastapi import APIRouter, HTTPException, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel, ConfigDict, Field

# 项目模块依赖
from core.database import get_db
from models.llm_config import LlmConfig, LlmProvider
from utils.jwt_auth import get_current_user_id

# 配置日志
logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/llm-configs",
    tags=["LLM Configurations"]
)

# === 依赖注入定义 ===
DbSession = Annotated[AsyncSession, Depends(get_db)]
CurrentUserId = Annotated[int, Depends(get_current_user_id)]

# === Pydantic V2 模型 ===

class LlmConfigBase(BaseModel):
    """LLM 基础配置"""
    provider: LlmProvider # 自动验证枚举
    model_name: str = Field(..., min_length=1)
    base_url: Optional[str] = None

class LlmConfigCreate(LlmConfigBase):
    """创建请求 (含 Key)"""
    api_key: str = Field(..., min_length=1)

class LlmConfigUpdate(BaseModel):
    """更新请求"""
    provider: Optional[LlmProvider] = None
    model_name: Optional[str] = None
    api_key: Optional[str] = None
    base_url: Optional[str] = None

class LlmConfigResponse(LlmConfigBase):
    """响应 (不含 Key)"""
    id: int

    # Pydantic V2 ORM 模式
    model_config = ConfigDict(from_attributes=True)

class LlmConfigEditResponse(LlmConfigBase):
    """编辑时响应模型 (含 Key)"""
    id: int
    api_key: str  # 编辑时返回API密钥

    # Pydantic V2 ORM 模式
    model_config = ConfigDict(from_attributes=True)

class LlmTestRequest(LlmConfigCreate):
    """测试请求 (结构同 Create，因为需要明文 Key)"""
    pass

class LlmTestResponse(BaseModel):
    success: bool
    message: str

# === API 端点 ===

@router.get("", response_model=List[LlmConfigResponse])
async def get_all_configs(user_id: CurrentUserId, db: DbSession):
    """获取所有配置"""
    stmt = select(LlmConfig).where(LlmConfig.user_id == user_id)
    result = await db.execute(stmt)
    return result.scalars().all()

@router.get("/{config_id}", response_model=LlmConfigResponse)
async def get_config(config_id: int, user_id: CurrentUserId, db: DbSession):
    """获取单个配置"""
    config = await db.get(LlmConfig, config_id)
    if not config or config.user_id != user_id:
        raise HTTPException(status_code=404, detail="配置不存在")
    return config

@router.get("/{config_id}/edit", response_model=LlmConfigEditResponse)
async def get_config_for_edit(config_id: int, user_id: CurrentUserId, db: DbSession):
    """获取单个配置用于编辑 (包含API密钥)"""
    config = await db.get(LlmConfig, config_id)
    if not config or config.user_id != user_id:
        raise HTTPException(status_code=404, detail="配置不存在")
    return config

@router.post("", response_model=LlmConfigResponse, status_code=status.HTTP_201_CREATED)
async def create_config(data: LlmConfigCreate, user_id: CurrentUserId, db: DbSession):
    """创建配置"""
    # 排除 api_key，通过 setter 处理
    config_data = data.model_dump(exclude={"api_key"})

    new_config = LlmConfig(**config_data, user_id=user_id)
    new_config.api_key = data.api_key # 自动加密

    db.add(new_config)
    await db.commit()
    await db.refresh(new_config)
    return new_config

@router.put("/{config_id}", response_model=LlmConfigResponse)
async def update_config(
    config_id: int,
    data: LlmConfigUpdate,
    user_id: CurrentUserId,
    db: DbSession
):
    """更新配置"""
    config = await db.get(LlmConfig, config_id)
    if not config or config.user_id != user_id:
        raise HTTPException(status_code=404, detail="配置不存在")

    update_data = data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if field == "api_key":
            config.api_key = value # 自动加密
        else:
            setattr(config, field, value)

    await db.commit()
    await db.refresh(config)
    return config

@router.delete("/{config_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_config(config_id: int, user_id: CurrentUserId, db: DbSession):
    """删除配置"""
    config = await db.get(LlmConfig, config_id)
    if not config or config.user_id != user_id:
        raise HTTPException(status_code=404, detail="配置不存在")

    await db.delete(config)
    await db.commit()
    return None

# === 核心：异步多模型测试逻辑 ===

@router.post("/test", response_model=LlmTestResponse)
async def test_llm_connection(data: LlmTestRequest):
    """
    测试 LLM 连接 (全异步、非阻塞)
    支持: OpenAI, Anthropic, Gemini, DeepSeek, Qwen, Ollama
    """
    try:
        # 1. 处理 OpenAI 兼容协议 (OpenAI, DeepSeek, Qwen, Moonshot, Ollama)
        if data.provider in [
            LlmProvider.openai,
            LlmProvider.deepseek,
            LlmProvider.qwen,
            LlmProvider.moonshot,
            LlmProvider.ollama,
            "other" # 假设"other"也是兼容 OpenAI 协议的
        ]:
            try:
                from openai import AsyncOpenAI, APIConnectionError, AuthenticationError
            except ImportError:
                return LlmTestResponse(success=False, message="未安装 openai 库")

            # 智能推断 Base URL
            base_url = data.base_url
            if not base_url:
                if data.provider == LlmProvider.ollama:
                    base_url = "http://localhost:11434/v1"
                elif data.provider == LlmProvider.deepseek:
                    base_url = "https://api.deepseek.com"
                elif data.provider == LlmProvider.qwen:
                    base_url = "https://dashscope.aliyuncs.com/compatible-mode/v1"
                elif data.provider == LlmProvider.moonshot:
                    base_url = "https://api.moonshot.cn/v1"

            client = AsyncOpenAI(
                api_key=data.api_key,
                base_url=base_url
            )

            # 发起极简请求
            await client.chat.completions.create(
                model=data.model_name,
                messages=[{"role": "user", "content": "Hi"}],
                max_tokens=1,
                timeout=10.0 # 10秒超时
            )
            return LlmTestResponse(success=True, message=f"{data.provider} 连接成功")

        # 2. 处理 Anthropic (Claude)
        elif data.provider == LlmProvider.anthropic:
            try:
                from anthropic import AsyncAnthropic, APIConnectionError, AuthenticationError
            except ImportError:
                return LlmTestResponse(success=False, message="未安装 anthropic 库")

            client = AsyncAnthropic(api_key=data.api_key)

            await client.messages.create(
                model=data.model_name,
                max_tokens=1,
                messages=[{"role": "user", "content": "Hi"}],
                timeout=10.0
            )
            return LlmTestResponse(success=True, message="Anthropic 连接成功")

        # 3. 处理 Google Gemini (使用 HTTPX 异步调用 REST API)
        # Google 的 SDK 有时较重，REST API 更加轻量且标准
        elif data.provider == LlmProvider.gemini:
            api_key = data.api_key
            model = data.model_name if data.model_name else "gemini-pro"
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"

            payload = {
                "contents": [{"parts": [{"text": "Hi"}]}],
                "generationConfig": {"maxOutputTokens": 1}
            }

            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.post(url, json=payload)

                if resp.status_code != 200:
                    error_msg = resp.json().get('error', {}).get('message', 'Unknown Error')
                    raise Exception(f"Google API Error: {error_msg}")

            return LlmTestResponse(success=True, message="Gemini 连接成功")

        else:
            return LlmTestResponse(success=False, message=f"暂不支持测试该提供商: {data.provider}")

    except Exception as e:
        logger.warning(f"LLM Test Failed for {data.provider}: {str(e)}")
        # 友好的错误信息处理
        msg = str(e)
        if "401" in msg or "Incorrect API key" in msg:
            msg = "API Key 错误或无效"
        elif "ConnectError" in msg:
            msg = "无法连接到 API 服务器，请检查网络或 Base URL"

        return LlmTestResponse(success=False, message=f"连接失败: {msg}")
