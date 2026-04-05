# models/system_prompt.py
import logging

from sqlalchemy import Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base

logger = logging.getLogger(__name__)

class SystemPrompt(Base):
    __tablename__ = "system_prompts"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, comment="主键")
    prompt_key: Mapped[str] = mapped_column(String(50), unique=True, nullable=False, comment="Prompt唯一键")
    content: Mapped[str] = mapped_column(Text, nullable=False, comment="Prompt内容")
    description: Mapped[str | None] = mapped_column(String(255), nullable=True, comment="Prompt描述")
