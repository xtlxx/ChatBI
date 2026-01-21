"""
生产级日志配置
使用 structlog 实现结构化日志，支持 JSON 格式输出和上下文追踪
"""
import sys
import logging
from typing import Any
import structlog
from structlog.types import EventDict, Processor

from config import settings


def add_app_context(logger: Any, method_name: str, event_dict: EventDict) -> EventDict:
    """添加应用上下文信息到日志"""
    event_dict["app"] = "chatbi-agent"
    event_dict["environment"] = "production"
    return event_dict


def configure_logging() -> None:
    """配置结构化日志系统"""
    
    # 配置标准库 logging
    logging.basicConfig(
        format="%(message)s",
        stream=sys.stdout,
        level=getattr(logging, settings.LOG_LEVEL),
    )
    
    # 配置 structlog 处理器链
    processors: list[Processor] = [
        structlog.contextvars.merge_contextvars,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        add_app_context,
    ]
    
    # 根据环境选择渲染器
    if settings.LOG_LEVEL == "DEBUG":
        # 开发环境：使用彩色控制台输出
        processors.append(structlog.dev.ConsoleRenderer())
    else:
        # 生产环境：使用 JSON 格式
        processors.extend([
            structlog.processors.format_exc_info,
            structlog.processors.JSONRenderer()
        ])
    
    # 配置 structlog
    structlog.configure(
        processors=processors,
        wrapper_class=structlog.stdlib.BoundLogger,
        context_class=dict,
        logger_factory=structlog.stdlib.LoggerFactory(),
        cache_logger_on_first_use=True,
    )


def get_logger(name: str) -> structlog.stdlib.BoundLogger:
    """获取结构化日志记录器"""
    return structlog.get_logger(name)


# 初始化日志系统
configure_logging()
logger = get_logger(__name__)
