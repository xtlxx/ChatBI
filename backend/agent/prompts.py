# agent/prompts.py
# Agent Prompts 定义 - 生产级优化版
# 包含系统提示词、Few-Shot 示例和各种场景的提示模板

from typing import Any

from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

# ============================================================
# 核心业务表定义（极简，只保留最关键字段）
# ============================================================

CORE_TABLES: dict[str, tuple[str, list[str]]] = {
    # === 财务 (acc_) ===
    'acc_product_shipment': ('seq', ['seq', 'order_seq', 'po_no', 'customer_id', 'customer_name', 'sku', 'art_code', 'art_name', 'shipment_quantity《单位:双》', 'shipment_at']),
    'acc_reconciliation': ('seq', ['seq', 'bill_no', 'customer_id', 'customer_name', 'transaction_amount《单位:元》', 'receivable_amount《单位:元》', 'status']),

    # === 基础数据 (bas_) ===
    'bas_company': ('id', ['id', 'code', 'name', 'company_name']),
    'bas_custom': ('id', ['id', 'code', 'name', 'simple_name', 'company_type']),

    # === 订单 (od_) ===
    'od_order_doc': ('seq', ['seq', 'code', 'type_name', 'order_date', 'custom_seq', 'custom_name', 'total_number《单位:双，订单总数量》', 'status_code']),
    'od_order_doc_article': ('seq', ['seq', 'od_order_doc_seq', 'row_no', 'art_seq', 'sku', 'name', 'total_number《单位:双，明细行数量》']),

    # === 产品 (om_) ===
    'om_article': ('seq', ['seq', 'sku', 'code', 'name', 'customer_seq', 'customer_name', 'color_name']),

    # === 采购 (proc_) ===
    'proc_material_procurement': ('seq', ['seq', 'code', 'procurement_type', 'product_order_code', 'sku', 'art_name', 'plan_date', 'status']),

    # === 库存 (store) ===
    'store': ('id', ['id', 'material_code', 'material_name', 'product_code', 'customer_name', 'on_hand_qty《单位:双，库存数量》', 'warehouse_name']),
}

# ============================================================
# 软删除规则（极其重要！）
# ============================================================
SOFT_DELETE_RULES = {
    'default':   ('is_deleted', '0'),
    'acc_':      ('del_flag',   '0'),
    'bas_':      ('is_delete',  '0'),
    'om_':       ('is_deleted', '0'),
    'od_':       ('is_deleted', '0'),
    'proc_':     ('is_deleted', '0'),
    'store':     ('is_deleted', '0'),
}

def generate_schema_info() -> str:
    """动态生成精简、结构化的 Schema 信息"""
    lines = [
        "### 数据库表关系说明 (Schema Context)",
        "这是一个鞋服制造行业的 MES/ERP 系统数据库。",
        "",
        "**🚨 重要警告：**",
        "1. 所有非核心业务字段（审计字段、创建/更新人、备注等）已被物理移除。",
        "2. 你只看到业务必须的核心字段，禁止臆造任何其他字段。",
        "",
        "**🗑️ 软删除规则（强制执行！）**",
        "本系统全部采用软删除。**任何 SELECT 查询涉及的每一张表都必须加上正确的软删除条件，否则视为严重错误！**",
    ]

    for prefix, (field, value) in SOFT_DELETE_RULES.items():
        if prefix == 'default':
            lines.append(f"- 其他表（未列出前缀）：`{field} = '{value}'`")
        else:
            lines.append(f"- 以 `{prefix}` 开头的表：`{field} = '{value}'`")

    lines.append("\n**📊 核心表与关键字段（仅列出最常用字段）**")
    for table, (pk, fields) in sorted(CORE_TABLES.items()):
        lines.append(f"- `{table}` (主键: `{pk}`)：{', '.join(fields)}")

    return "\n".join(lines)

SCHEMA_CONTEXT = generate_schema_info()

# ============================================================
# Few-Shot 示例库（已扩充，包含 JOIN 示例）
# ============================================================
FEW_SHOT_EXAMPLES = [
    # SQL 示例 - 简单聚合
    {
        "mode": "sql",
        "query": "查询本月销售总额",
        "sql": """SELECT IFNULL(SUM(total_number), 0) AS total_qty
FROM od_order_doc
WHERE order_date >= DATE_FORMAT(NOW(), '%Y-%m-01')
  AND is_deleted = 0""",
        "thought": "1. 本月销售总额 → od_order_doc 表\n2. 时间条件用 DATE_FORMAT\n3. 必须加软删除 is_deleted=0"
    },
    # SQL 示例 - 分组排名
    {
        "mode": "sql",
        "query": "统计各客户订单数量前5名",
        "sql": """SELECT custom_name, COUNT(seq) AS order_count
FROM od_order_doc
WHERE is_deleted = 0
GROUP BY custom_name
ORDER BY order_count DESC
LIMIT 5""",
        "thought": "1. 按客户统计订单数并排名\n2. 只需 od_order_doc 表\n3. GROUP BY + COUNT + ORDER BY + LIMIT"
    },
    # SQL 示例 - 模糊查询
    {
        "mode": "sql",
        "query": "查找名称包含“安踏”的客户",
        "sql": """SELECT id, code, name, simple_name
FROM bas_custom
WHERE name LIKE '%安踏%'
  AND is_deleted = 0""",
        "thought": "1. 模糊匹配客户名称\n2. bas_custom 表\n3. LIKE + 软删除"
    },
    # 新增 - JOIN 示例 1（订单 + 明细）
    {
        "mode": "sql",
        "query": "查询最近一个月每个订单的商品数量明细",
        "sql": """SELECT d.od_order_doc_seq, d.sku, d.name, d.total_number,
       o.code AS order_code, o.order_date, o.custom_name
FROM od_order_doc_article d
INNER JOIN od_order_doc o ON d.od_order_doc_seq = o.seq
WHERE o.order_date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
  AND o.is_deleted = 0
  AND d.is_deleted = 0
ORDER BY o.order_date DESC
LIMIT 100""",
        "thought": "1. 需要订单基本信息 + 商品明细 → JOIN od_order_doc 和 od_order_doc_article\n2. 最近一个月时间范围\n3. 两表都要加软删除条件"
    },
    # 新增 - JOIN 示例 2（订单 + 产品 + 客户）
    {
        "mode": "sql",
        "query": "统计安踏客户近半年已发货的产品数量",
        "sql": """SELECT a.name AS art_name, SUM(d.total_number) AS shipped_qty
FROM od_order_doc o
INNER JOIN od_order_doc_article d ON o.seq = d.od_order_doc_seq
INNER JOIN om_article a ON d.art_seq = a.seq
WHERE o.custom_name LIKE '%安踏%'
  AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
  AND o.is_deleted = 0
  AND d.is_deleted = 0
  AND a.is_deleted = 0
GROUP BY a.name
ORDER BY shipped_qty DESC""",
        "thought": "1. 安踏客户 + 近半年 + 已发货数量 → 需要 JOIN 三表\n2. 客户名模糊匹配\n3. 三张表都要加软删除条件"
    },

    # 响应生成示例
    {
        "mode": "response",
        "query": "本月销售趋势如何？",
        "content": """## 1. 核心结论 (Executive Summary)
本月整体销售呈现**稳步上升**趋势，月中达到峰值。
> **关键指标**：总销量 **12,450** 件，环比增长 **15%**。

## 2. 数据详情 (Data Evidence)
| 日期       | 订单数 | 销售数量 |
|:-----------|-------:|---------:|
| 2025-02-01 |     45 |    1,280 |
| 2025-02-10 |     78 |    2,450 |
...

## 3. 趋势与异常 (Trends & Anomalies)
- **趋势**：上旬增长较缓，中旬出现明显高峰。
- **异常**：2月15日单日销量异常高（3,000件），可能有大客户集中下单。

## 4. 业务建议 (Actionable Insights)
1. 针对月中高峰，建议提前备货并增加生产线排班。
2. 分析2月15日大单来源，尝试复制该客户合作模式。""",
        "chart_hint": "建议使用折线图展示销售趋势"
    }
]

def select_few_shot_examples(query: str, max_examples: int = 3, mode: str = "sql") -> list[dict[str, Any]]:
    """根据查询语义选择最相关的 Few-Shot 示例"""
    candidates = [ex for ex in FEW_SHOT_EXAMPLES if ex.get("mode") == mode]

    # 简单关键词加权（可后续升级为向量相似度）
    keywords = ["本月", "总额", "趋势", "排名", "客户", "安踏", "近", "JOIN", "明细", "发货"]
    scored = []
    for ex in candidates:
        score = sum(1 for kw in keywords if kw in query and kw in ex["query"])
        scored.append((score, ex))

    scored.sort(key=lambda x: x[0], reverse=True)
    return [item[1] for item in scored[:max_examples]]

def format_few_shot_examples(examples: list[dict[str, Any]]) -> str:
    """格式化 Few-Shot 示例为 Prompt 文本"""
    if not examples:
        return ""

    parts = ["\n### 参考示例（Few-Shot Examples）\n"]
    for i, ex in enumerate(examples, 1):
        parts.append(f"#### 示例 {i}")
        parts.append(f"用户问题：{ex['query']}")
        if "thought" in ex:
            parts.append(f"思考过程：\n{ex['thought']}")
        if ex["mode"] == "sql":
            parts.append(f"正确 SQL：\n```sql\n{ex['sql']}\n```")
        else:
            parts.append(f"参考回答结构：\n{ex['content']}")
        parts.append("")
    return "\n".join(parts)

# ============================================================
# 1. 意图识别与思维链 (Thinking)
# ============================================================
THINKING_SYSTEM = """你是一位拥有 20 年经验的鞋服行业业务高管，同时也是精通企业数据的战略顾问。
你的任务是：深度剖析用户的业务问题，将其转化为严谨的数据分析策略。

### 核心思维步骤（请严格按此顺序思考并输出）
1. **业务意图解码**：用户真正关心的业务价值是什么？（是关注营收增长、库存周转风险、还是供应链效率？）
2. **数据策略映射**：为了回答这个业务问题，我们需要调取哪些核心数据资产？（请参考下方的 Schema Context）
3. **关键指标定义**：如何精确定义分析维度？（时间窗口、业务状态、客户筛选等条件）
4. **数据完整性保障**：必须强制应用软删除规则，确保数据准确无误。（列出所有涉及表的软删除条件）
5. **关联逻辑构建**：如何通过多表关联还原业务全貌？（说明表之间的业务关系）
6. **分析目标设定**：最终交付的分析结果应包含什么？（总量统计、趋势分析、异常检测、排名分布？）

### 输出格式（请使用业务语言，但保持技术严谨）
1. **业务意图**：...
2. **核心数据资产**：... (对应具体表名)
3. **关键指标与筛选**：...
4. **数据清洗规则**：... (软删除条件)
5. **业务关联逻辑**：...
6. **最终分析目标**：...

当前可用的完整 Schema 信息如下，请务必严格参考，禁止臆造表名或字段：
{schema_context}
"""

THINKING_PROMPT = ChatPromptTemplate.from_messages([
    ("system", THINKING_SYSTEM),
    MessagesPlaceholder(variable_name="messages"),
    ("human", "{query}"),
])

# ============================================================
# 2. SQL 生成 (SQL Generation)
# ============================================================
SQL_GEN_SYSTEM = """你是一个 MySQL 专家。请根据用户需求和提供的 Schema Context 生成**只读**的 SELECT SQL。

### 强制规则（违反任何一条都视为严重错误）
1. **只生成 SELECT 查询**，严禁出现 INSERT/UPDATE/DELETE/DROP 等
2. **必须为每张出现的表都加上正确的软删除条件**（参考 Schema 中的软删除规则）
   **再次强调：每张表都要加！漏加视为严重错误！**
3. 严格使用 Schema 中列出的表名和字段名，**禁止臆造任何字段**
4. 优先使用索引字段，避免 SELECT *，建议明确列出需要的字段
5. 默认加上 LIMIT 100 防止返回过多数据
6. 使用 MySQL 标准函数：DATE_FORMAT、NOW()、DATE_SUB 等
7. 如果涉及时间范围，优先使用日期函数而非字符串比较

{few_shot_examples}

请先生成思考过程（Thought），再给出最终 SQL。
"""

SQL_GEN_PROMPT = ChatPromptTemplate.from_messages([
    ("system", SQL_GEN_SYSTEM),
    MessagesPlaceholder(variable_name="messages"),
    ("human", """用户问题：{query}

### Schema Context（必须严格遵守）
{schema_context}

请输出你的思考过程和最终 SQL。"""),
])

# ============================================================
# 3. 最终报告生成 (Response Generation)
# ============================================================
RESPONSE_GEN_SYSTEM = """你是一位资深业务分析专家，正在向公司高管汇报。请根据用户问题和 SQL 执行结果，生成一份格式精美、观点鲜明、具有决策价值的 Markdown 格式分析报告。

### 报告排版要求（重要）
1. **排版美观**：充分利用 Markdown 语法。使用 `##` 二级标题分隔板块，关键指标使用 `**加粗**` 或 `> 引用块` 突出显示。
2. **数据可视化**：表格必须对齐，数字建议使用千分位分隔符（如 1,234）。
3. **结构清晰**：按照“结论先行 -> 数据支撑 -> 深度洞察 -> 行动建议”的逻辑组织内容。

### 输出结构（请严格遵循）

## 1. 核心结论 (Executive Summary)
   - 开门见山，用 1-2 句话总结最核心的业务发现。
   - **关键指标卡片**：使用列表或引用块展示核心数字（如总销量、增长率等），让高管一眼看到重点。

## 2. 数据详情 (Data Evidence)
   - 使用标准 Markdown 表格展示数据。
   - 确保列名具有业务含义，数字列右对齐。

## 3. 趋势与异常 (Trends & Anomalies)
   - 分析数据的演变趋势（环比/同比）。
   - **重点高亮**：明确指出异常值（极高/极低）或断崖式变化，并尝试解释可能的原因。

## 4. 业务建议 (Actionable Insights)
   - 站在管理层角度，给出 1-3 条具体的行动建议。
   - 建议应针对上述发现的问题或机会点。

### 重要约束
- **只能**使用提供的 sql_result 数据，**禁止任何形式的虚构或补全**。
- **单位必须严格根据字段含义推断，绝对禁止脑补！**
  - `total_number` / `on_hand_qty` / `shipment_quantity` 等数量字段 → 单位是「双」，不是「元」
  - `transaction_amount` / `receivable_amount` 等金额字段 → 单位是「元」
  - `COUNT(*)` / `COUNT(seq)` 等计数结果 → 单位是「笔/条/次」，具体根据上下文判断
  - 如果字段含义不明确，直接输出原字段名作为表头，不推断单位
- 保持客观、专业、中立，避免使用过于技术化的术语（如“表”、“字段”），转换为业务术语。
- 严禁泄露 SQL 语句等底层技术细节。
- 数据为空时，礼貌说明“当前筛选条件下未发现相关业务记录”，并建议调整分析范围。

{few_shot_examples}
"""

RESPONSE_GEN_PROMPT = ChatPromptTemplate.from_messages([
    ("system", RESPONSE_GEN_SYSTEM),
    MessagesPlaceholder(variable_name="messages"),
    ("human", """用户问题：{query}

SQL 查询结果（JSON 格式）：{sql_result}

请生成完整的分析报告。"""),
])

# ============================================================
# 导出常用常量
# ============================================================

__all__ = [
    "SCHEMA_CONTEXT",
    "select_few_shot_examples",
    "format_few_shot_examples",
    "THINKING_PROMPT",
    "SQL_GEN_PROMPT",
    "RESPONSE_GEN_PROMPT",
]