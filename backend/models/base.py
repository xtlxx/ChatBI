# models/base.py
# 基础模型
# 包含所有表的公共字段（如创建时间、更新时间）
from datetime import UTC, datetime

from sqlalchemy import DateTime
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):

    # 自动生成 __tablename__ (可选，此处演示显式定义)
    pass

    # 抽取公共字段（Mixin模式）
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), sort_order=999
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(UTC),
        onupdate=lambda: datetime.now(UTC),
        sort_order=1000,
    )