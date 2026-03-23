# agent/schemas.py
# 定义了用于 SQL 生成和响应生成的 Pydantic 模型。
# 包含了 SQL 生成的逐步思考过程和最终的 SQL 查询，以及响应生成的主要内容和可选的 ECharts 配置。
import re
from typing import Any

from pydantic import BaseModel, Field, field_validator


class GenerateSQLOutput(BaseModel):
    """SQL 生成输出的模式"""

    thought: str | None = Field(
        default=None,
        description="业务分析策略。请使用业务化语言描述：1.业务意图解读 2.所需数据资产定位 3.关键指标与筛选条件 4.数据完整性规则。禁止出现纯技术术语，请转换为业务语言（如用'订单数据'代替'od_order_doc 表'）。请使用中文。",
    )

    sql: str = Field(
        description="最终的 SQL 查询语句。必须以 SELECT 开头，严禁使用 markdown 代码块包裹。",
    )

    # === 新增：自动清洗和校验器 ===
    @field_validator('sql')
    @classmethod
    def clean_and_validate_sql(cls, v: str) -> str:
        # 1. 自动移除可能残留的 Markdown 标记
        if "```" in v:
            pattern = r"```(?:sql)?\s*(.*?)\s*```"
            match = re.search(pattern, v, re.DOTALL | re.IGNORECASE)
            v = match.group(1) if match else v.replace("```sql", "").replace("```", "")

        # 2. 去除首尾空白
        v = v.strip()

        # 3. 强制校验是否为 SELECT 语句 (安全网)
        # 使用正则匹配，允许开头有注释或空白
        match_query = re.match(r"^(?:--.*?\n|/\*.*?\*/|\s+)*(SELECT|WITH)\b", v, re.IGNORECASE | re.DOTALL)
        if not match_query and (not v.upper().startswith("SELECT") and not v.upper().startswith("WITH")):
            # 兜底检查：如果正则匹配失败但看起来安全（例如严格以 SELECT 开头）
            raise ValueError("生成的 SQL 必须以 SELECT 或 WITH 开头，禁止执行非查询操作。")

        return v

class EChartsConfig(BaseModel):
    """
    生产级 ECharts 配置模型
    宽松模式：允许额外字段，核心字段设为可选，防止 Pydantic 校验过于严格导致死循环。
    """
    model_config = {
        "extra": "ignore"  # 关键修改：忽略多余字段，而不是报错
    }

    title: dict[str, Any] | None = Field(
        default=None,
        description="图表标题配置"
    )
    tooltip: dict[str, Any] | None = Field(
        default=None,
        description="提示框配置"
    )
    legend: dict[str, Any] | None = Field(
        default=None,
        description="图例配置"
    )
    grid: dict[str, Any] | None = Field(
        default=None,
        description="网格配置"
    )
    xAxis: list[dict[str, Any]] | dict[str, Any] | None = Field(
        default=None,
        description="X 轴配置"
    )
    yAxis: list[dict[str, Any]] | dict[str, Any] | None = Field(
        default=None,
        description="Y 轴配置"
    )
    series: list[dict[str, Any]] | None = Field(
        default=None,
        description="数据系列配置"
    )
    color: list[str] | None = Field(
        default=None,
        description="自定义调色板"
    )
    # 允许其他任意字段兜底
    option: dict[str, Any] | None = Field(
        default=None,
        description="其他未定义的 ECharts 配置项"
    )


class GenerateResponseOutput(BaseModel):
    """最终响应生成的结构化输出模式"""
    content: str = Field(
        description="主要响应内容，采用 Markdown 格式。必须包含：1.核心结论 2.数据详情(表格) 3.趋势分析 4.业务建议。"
    )
    chart_option: EChartsConfig | None = Field(
        default=None,
        description="ECharts 可视化配置对象。仅在数据适合可视化时提供，否则为 None。"
    )
    