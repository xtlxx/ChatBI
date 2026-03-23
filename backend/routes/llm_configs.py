# routes/llm_configs.py
import logging
import time
from datetime import datetime
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, ConfigDict, Field
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

# 项目模块依赖
from core.database import get_db
from models.llm_config import LlmConfig, LlmProvider
from utils.jwt_auth import get_current_user_id

# 配置日志
logger = logging.getLogger(__name__)

router = APIRouter(prefix="/llm-configs", tags=["LLM Configurations"])

# === 依赖注入定义 ===
DbSession = Annotated[AsyncSession, Depends(get_db)]
CurrentUserId = Annotated[int, Depends(get_current_user_id)]

# === Pydantic V2 模型 ===


class LlmConfigBase(BaseModel):
    """LLM 基础配置"""

    provider: LlmProvider  # 自动验证枚举
    model_name: str = Field(..., min_length=1)
    base_url: str | None = None
    temperature: float = Field(default=0.7, ge=0.0, le=1.0)


class LlmConfigCreate(LlmConfigBase):
    """创建请求 (含 Key)"""

    api_key: str = Field(..., min_length=1)


class LlmConfigUpdate(BaseModel):
    """更新请求"""

    provider: LlmProvider | None = None
    model_name: str | None = None
    api_key: str | None = None
    base_url: str | None = None
    temperature: float | None = Field(default=None, ge=0.0, le=1.0)


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
    """测试响应"""
    success: bool
    message: str
    duration_ms: float = 0
    status_code: int = None
    error_detail: str = None
    timestamp: str = None


# === API 端点 ===


@router.get("", response_model=list[LlmConfigResponse])
async def get_all_configs(user_id: CurrentUserId, db: DbSession):
    """获取所有配置"""
    stmt = select(LlmConfig).where(LlmConfig.user_id == user_id)
    result = await db.execute(stmt)
    return result.scalars().all()


@router.get("/{config_id}", response_model=LlmConfigResponse)
async def get_config(config_id: int, user_id: CurrentUserId, db: DbSession):
    """获取单个配置"""
    stmt = select(LlmConfig).where(LlmConfig.id == config_id)
    result = await db.execute(stmt)
    config = result.scalar_one_or_none()
    if not config or config.user_id != user_id:
        raise HTTPException(status_code=404, detail="配置不存在")
    return config


@router.get("/{config_id}/edit", response_model=LlmConfigEditResponse)
async def get_config_for_edit(config_id: int, user_id: CurrentUserId, db: DbSession):
    """获取单个配置用于编辑 (包含API密钥)"""
    stmt = select(LlmConfig).where(LlmConfig.id == config_id)
    result = await db.execute(stmt)
    config = result.scalar_one_or_none()
    if not config or config.user_id != user_id:
        raise HTTPException(status_code=404, detail="配置不存在")
    return config


@router.post("", response_model=LlmConfigResponse, status_code=status.HTTP_201_CREATED)
async def create_config(data: LlmConfigCreate, user_id: CurrentUserId, db: DbSession):
    """创建配置"""
    # 排除 api_key，通过 setter 处理
    config_data = data.model_dump(exclude={"api_key"})

    new_config = LlmConfig(**config_data, user_id=user_id)
    new_config.api_key = data.api_key  # 自动加密

    db.add(new_config)
    await db.commit()
    await db.refresh(new_config)
    return new_config


@router.put("/{config_id}", response_model=LlmConfigResponse)
async def update_config(
    config_id: int, data: LlmConfigUpdate, user_id: CurrentUserId, db: DbSession
):
    """更新配置"""
    stmt = select(LlmConfig).where(LlmConfig.id == config_id)
    result = await db.execute(stmt)
    config = result.scalar_one_or_none()
    if not config or config.user_id != user_id:
        raise HTTPException(status_code=404, detail="配置不存在")

    update_data = data.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        if field == "api_key":
            config.api_key = value  # 自动加密
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
async def test_llm_connection(data: LlmTestRequest, user_id: CurrentUserId):
    """
    测试 LLM 连接 (全异步、非阻塞)
    支持: OpenAI, Anthropic, Gemini, DeepSeek, Qwen, Ollama
    """
    start_time = time.perf_counter()
    timestamp = datetime.now().isoformat()

    try:
        # 1. 处理 OpenAI 兼容协议 (OpenAI, DeepSeek, Qwen, Moonshot, Ollama, Gemini)
        if data.provider in [
            LlmProvider.openai,
            LlmProvider.deepseek,
            LlmProvider.qwen,
            LlmProvider.moonshot,
            LlmProvider.ollama,
            LlmProvider.gemini,
            "other",  # 假设"other"也是兼容 OpenAI 协议的
        ]:
            try:
                from openai import (
                    APIConnectionError,
                    APITimeoutError,
                    AsyncOpenAI,
                    AuthenticationError,
                    NotFoundError,
                    RateLimitError,
                )
            except ImportError:
                return LlmTestResponse(
                    success=False, message="未安装 openai 库", timestamp=timestamp
                )

            # 智能推断 Base URL
            base_url = data.base_url
            if not base_url:
                base_url = LlmProvider.get_default_base_url(data.provider)

            client = AsyncOpenAI(api_key=data.api_key, base_url=base_url)

            try:
                # 发起极简请求
                await client.chat.completions.create(
                    model=data.model_name,
                    messages=[{"role": "user", "content": "Hi"}],
                    max_tokens=1,
                    timeout=10.0,  # 10秒超时
                )
                duration = (time.perf_counter() - start_time) * 1000
                logger.info(
                    f"LLM Test Success | User: {user_id} | Provider: {data.provider} | Duration: {duration:.2f}ms"
                )
                return LlmTestResponse(
                    success=True,
                    message="LLM配置验证成功",
                    duration_ms=round(duration, 2),
                    status_code=200,
                    timestamp=timestamp,
                )
            except AuthenticationError as e:
                duration = (time.perf_counter() - start_time) * 1000
                logger.warning(
                    f"LLM Test Auth Failed | User: {user_id} | Provider: {data.provider} | Error: {e}"
                )
                return LlmTestResponse(
                    success=False,
                    message="配置验证失败：认证无效 (Invalid API Key)",
                    error_detail=str(e),
                    status_code=401,
                    duration_ms=round(duration, 2),
                    timestamp=timestamp,
                )
            except RateLimitError as e:
                duration = (time.perf_counter() - start_time) * 1000
                logger.warning(
                    f"LLM Test RateLimit | User: {user_id} | Provider: {data.provider} | Error: {e}"
                )
                return LlmTestResponse(
                    success=False,
                    message="配置验证失败：额度耗尽或请求过快",
                    error_detail=str(e),
                    status_code=429,
                    duration_ms=round(duration, 2),
                    timestamp=timestamp,
                )
            except NotFoundError as e:
                duration = (time.perf_counter() - start_time) * 1000
                logger.warning(
                    f"LLM Test NotFound | User: {user_id} | Provider: {data.provider} | Error: {e}"
                )
                return LlmTestResponse(
                    success=False,
                    message=f"配置验证失败：模型不存在 ({data.model_name})",
                    error_detail=str(e),
                    status_code=404,
                    duration_ms=round(duration, 2),
                    timestamp=timestamp,
                )
            except APITimeoutError as e:
                duration = (time.perf_counter() - start_time) * 1000
                logger.error(
                    f"LLM Test Timeout | User: {user_id} | Provider: {data.provider} | Error: {e}"
                )
                return LlmTestResponse(
                    success=False,
                    message="配置验证失败：网络连接超时",
                    error_detail=str(e),
                    status_code=408,
                    duration_ms=round(duration, 2),
                    timestamp=timestamp,
                )
            except APIConnectionError as e:
                duration = (time.perf_counter() - start_time) * 1000
                logger.error(
                    f"LLM Test Connection Error | User: {user_id} | Provider: {data.provider} | Error: {e}"
                )
                return LlmTestResponse(
                    success=False,
                    message="配置验证失败：网络连接错误",
                    error_detail=str(e),
                    status_code=503,
                    duration_ms=round(duration, 2),
                    timestamp=timestamp,
                )
            except Exception as e:
                duration = (time.perf_counter() - start_time) * 1000
                logger.error(
                    f"LLM Test Error | User: {user_id} | Provider: {data.provider} | Error: {e}"
                )
                return LlmTestResponse(
                    success=False,
                    message="配置验证失败：未知错误",
                    error_detail=str(e),
                    duration_ms=round(duration, 2),
                    timestamp=timestamp,
                )

        # 2. 处理 Anthropic (Claude)
        elif data.provider == LlmProvider.anthropic:
            try:
                from anthropic import (
                    APIConnectionError,
                    APITimeoutError,
                    AsyncAnthropic,
                    AuthenticationError,
                    NotFoundError,
                    RateLimitError,
                )
            except ImportError:
                return LlmTestResponse(
                    success=False, message="未安装 anthropic 库", timestamp=timestamp
                )

            client = AsyncAnthropic(api_key=data.api_key)

            try:
                await client.messages.create(
                    model=data.model_name,
                    max_tokens=1,
                    messages=[{"role": "user", "content": "Hi"}],
                    timeout=10.0,
                )
                duration = (time.perf_counter() - start_time) * 1000
                logger.info(
                    f"LLM Test Success | User: {user_id} | Provider: {data.provider} | Duration: {duration:.2f}ms"
                )
                return LlmTestResponse(
                    success=True,
                    message="LLM配置验证成功",
                    duration_ms=round(duration, 2),
                    status_code=200,
                    timestamp=timestamp,
                )
            except AuthenticationError as e:
                duration = (time.perf_counter() - start_time) * 1000
                logger.warning(
                    f"LLM Test Auth Failed | User: {user_id} | Provider: {data.provider} | Error: {e}"
                )
                return LlmTestResponse(
                    success=False,
                    message="配置验证失败：认证无效 (Invalid API Key)",
                    error_detail=str(e),
                    status_code=401,
                    duration_ms=round(duration, 2),
                    timestamp=timestamp,
                )
            except RateLimitError as e:
                duration = (time.perf_counter() - start_time) * 1000
                logger.warning(
                    f"LLM Test RateLimit | User: {user_id} | Provider: {data.provider} | Error: {e}"
                )
                return LlmTestResponse(
                    success=False,
                    message="配置验证失败：额度耗尽或请求过快",
                    error_detail=str(e),
                    status_code=429,
                    duration_ms=round(duration, 2),
                    timestamp=timestamp,
                )
            except NotFoundError as e:
                duration = (time.perf_counter() - start_time) * 1000
                logger.warning(
                    f"LLM Test NotFound | User: {user_id} | Provider: {data.provider} | Error: {e}"
                )
                return LlmTestResponse(
                    success=False,
                    message=f"配置验证失败：模型不存在 ({data.model_name})",
                    error_detail=str(e),
                    status_code=404,
                    duration_ms=round(duration, 2),
                    timestamp=timestamp,
                )
            except APITimeoutError as e:
                duration = (time.perf_counter() - start_time) * 1000
                logger.error(
                    f"LLM Test Timeout | User: {user_id} | Provider: {data.provider} | Error: {e}"
                )
                return LlmTestResponse(
                    success=False,
                    message="配置验证失败：网络连接超时",
                    error_detail=str(e),
                    status_code=408,
                    duration_ms=round(duration, 2),
                    timestamp=timestamp,
                )
            except Exception as e:
                duration = (time.perf_counter() - start_time) * 1000
                logger.error(
                    f"LLM Test Error | User: {user_id} | Provider: {data.provider} | Error: {e}"
                )
                return LlmTestResponse(
                    success=False,
                    message="配置验证失败：未知错误",
                    error_detail=str(e),
                    duration_ms=round(duration, 2),
                    timestamp=timestamp,
                )

        else:
            duration = (time.perf_counter() - start_time) * 1000
            logger.warning(f"LLM Test Unsupported | User: {user_id} | Provider: {data.provider}")
            return LlmTestResponse(
                success=False,
                message=f"暂不支持测试该提供商: {data.provider}",
                duration_ms=round(duration, 2),
                timestamp=timestamp,
            )

    except Exception as e:
        logger.error(f"LLM Test System Error | User: {user_id} | Error: {str(e)}")
        duration = (time.perf_counter() - start_time) * 1000
        return LlmTestResponse(
            success=False,
            message="测试过程发生未知错误",
            error_detail=str(e),
            duration_ms=round(duration, 2),
            timestamp=timestamp,
        )