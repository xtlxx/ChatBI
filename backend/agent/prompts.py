import json
from typing import Any, List, Dict
from datetime import datetime
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder

# ============================================================
# 核心业务表定义（融合了关系、字段单位注释和必须字段）
# ============================================================

CORE_TABLES: Dict[str, Dict[str, Any]] = {
    # === 订单 ===
    'od_order_doc': {
        'pk': 'seq',
        'columns': ['seq', 'code', 'type', 'type_name', 'status', 'money_name', 'comp_name', 'order_date', 'custom_seq', 'custom_name',
                    'total_number《单位:双，订单总数量》', 'status_code', 'is_deleted', 'enable'],
        'relations': ['custom_seq -> bas_custom.id'],
    },
    'od_order_doc_article': {
        'pk': 'seq',
        'columns': ['seq', 'od_order_doc_seq', 'row_no', 'art_seq', 'sku', 'code', 'name', 'customer_code', 'product_class_name',
                    'customer_article_code', 'customer_article_name', 'color_name',
                    'total_number《单位:双，明细行数量》', 'manual_prod_code', 'is_deleted', 'enable'],
        'relations': ['od_order_doc_seq -> od_order_doc.seq', 'art_seq -> om_article.seq'],
    },
    'od_order_doc_aritcle_size': {
        'pk': 'seq',
        'columns': ['seq', 'od_order_doc_seq', 'order_doc_aritcle_seq', 'size_code', 'size_name', 'size_num《单位:双，尺码总数》', 'quotation_amount《单位:元，报价金额》', 'is_deleted'],
        'relations': ['order_doc_aritcle_seq -> od_order_doc_article.seq', 'od_order_doc_seq -> od_order_doc.seq'],
    },

    # === 产品资料 ===
    'om_article': {
        'pk': 'seq',
        'columns': ['seq', 'sku', 'code', 'name', 'customer_seq', 'customer_name', 'status', 'quarter_code', 'sex', 'brand',
                    'customer_article_code', 'customer_article_name', 'color_name',
                    'product_class_name', 'is_deleted', 'enable'],
        'relations': ['customer_seq -> bas_custom.id'],
    },

    # === 客户、公司与供应商 ===
    'bas_custom': {
        'pk': 'id',
        'columns': ['id', 'code', 'name', 'simple_name', 'company_type', 'is_delete', 'enable'],
        'relations': [],
    },
    'bas_company': {
        'pk': 'id',
        'columns': ['id', 'code', 'name', 'company_name', 'simple_name', 'legal_person', 'company_phone', 'is_delete', 'enable'],
        'relations': [],
    },
    'bas_supplier': {
        'pk': 'seq',
        'columns': ['seq', 'code', 'name', 'simple_name', 'legal_person', 'company_phone', 'business_state', 'is_delete', 'enable'],
        'relations': [],
    },

    # === 生产与品控 ===
    'od_product_order_doc': {
        'pk': 'seq',
        'columns': ['seq', 'code', 'art_seq', 'sku', 'art_code', 'art_name', 'manual_prod_code', 'customer_code', 'row_no', 'customer_name', 'product_class_name', 'status', 'od_order_doc_code', 'is_deleted', 'enable'],
        'relations': ['art_seq -> om_article.seq'],
    },
    'po_defective_product': {
        'pk': 'record_date',
        'columns': ['record_date', 'firm_name', 'department_name', 'group_name', 'process', 'check_num《单位:双，不良数量》', 'p_id'],
        'relations': [],
    },
    'proc_material_quality_spection': {
        'pk': 'seq',
        'columns': ['seq', 'code', 'test_by', 'test_department_name', 'test_date', 'inspection_results', 'is_deleted', 'enable'],
        'relations': [],
    },
    'proc_material_quality_spection_info': {
        'pk': 'seq',
        'columns': ['seq', 'proc_material_quality_spection_seq', 'sampling_quantity《单位:双，抽检数量》', 'qualified_quantity《单位:双，合格数量》', 'unqualified_quantity《单位:双，不合格数量》', 'qualified_rate', 'material_name', 'provider_name', 'purchase_order_number', 'is_deleted', 'enable'],
        'relations': ['proc_material_quality_spection_seq -> proc_material_quality_spection.seq'],
    },

    # === 成本、利润与 BOM ===
    't_standard_cost_budget': {
        'pk': 'seq',
        'columns': ['seq', 'art_seq', 'sku', 'quotation_number', 'customer_name', 'product_class_name', 'transaction_price《单位:元，成交价》', 'profit_margin《单位:%, 利润率》', 'cost_price《单位:元，成本价》', 'total_price_materials《单位:元，材料总价》', 'status', 'is_deleted'],
        'relations': ['art_seq -> om_article.seq'],
    },
    't_material_cost': {
        'pk': 'seq',
        'columns': ['seq', 'estimated_standard_cost_seq', 'estimated_order_number', 'estimated_unit_price《单位:元，预估单价》', 'estimated_unit_consumption', 'estimated_loss', 'estimated_amount《单位:元，预估金额》', 'is_effective'],
        'relations': [],
    },
    'anta_bom_detail_info': {
        'pk': 'seq',
        'columns': ['seq', 'bomno', 'partname', 'vendercode', 'vendername', 'materialname', 'forecastqty《单位:双，预估用量》', 'bomversionnumber', 'material_code', 'is_delete'],
        'relations': [],
    },
    'proc_material_procurement': {
        'pk': 'seq',
        'columns': ['seq', 'code', 'procurement_type', 'formal_order_seq', 'formal_order_code', 'company_name', 'row_no',
                    'product_order_code', 'sku', 'art_name', 'plan_date',
                    'status', 'order_quantity《单位:双，采购数量》', 'is_deleted'],
        'relations': ['formal_order_seq -> od_order_doc.seq'],
    },

    # === 库存与物料出入库 ===
    'store': {
        'pk': 'id',
        'columns': ['id', 'material_code', 'material_name', 'product_code', 'factory_name', 'supply_name', 'size', 'color_name',
                    'customer_name', 'warehouse_name', 'on_hand_qty《单位:双，在库数量》',
                    'total_qty《单位:双，总库存数量》', 'sku', 'manual_prod_code', 'is_deleted', 'enable'],
        'relations': [],
    },
    'material_inventory': {
        'pk': 'seq',
        'columns': ['seq', 'code', 'bath_no', 'mater_code', 'mater_name', 'storage《单位:双，入库数量》', 'out_storage《单位:双，出库数量》', 'price《单位:元，单价》', 'sum_price《单位:元，总金额》', 'supplier', 'create_date'],
        'relations': [],
    },

    # === 财务出货与对账 ===
    'acc_product_shipment': {
        'pk': 'seq',
        'columns': ['seq', 'po_no', 'customer_id', 'customer_name', 'order_seq', 'sku', 'art_code', 'shipment_code', 'basic_size_code', 'price《单位:元，单价》',
                    'art_name', 'shipment_quantity《单位:双，出货数量》', 'shipment_at', 'del_flag', 'is_available'],
        'relations': ['customer_id -> bas_custom.id', 'order_seq -> od_order_doc.seq'],
    },
    'acc_reconciliation': {
        'pk': 'seq',
        'columns': ['seq', 'bill_no', 'customer_id', 'customer_name', 'transaction_amount《单位:元，成交金额》',
                    'receivable_amount《单位:元，应收金额》', 'status', 'del_flag', 'is_available'],
        'relations': ['customer_id -> bas_custom.id'],
    },

    # === 质量定检分析 === 
    'shoe_qc_analysis': { 
        'pk': 'id', 
        'columns': [ 
            'id', 
            'defect_reason《业务含义:定检原因，如脱胶、线头等》', 
            'pair_count《单位:双，异常双数》', 
            'inspection_method《业务含义:巡检处理方法》', 
            'improvement_method《业务含义:现场改善方法》', 
            'is_confirmed' 
        ], 
        'relations': [], 
    }
}

# ============================================================
# 软删除与可用性规则（极其重要！）
# ============================================================

FILTER_RULES = {
    'default': "is_deleted = 0 AND enable = 1",
    'acc_': "del_flag = '0' AND is_available = '0'",
    'bas_': "is_delete = 0 AND enable = 1",
    'om_': "is_deleted = 0 AND enable = 1",
    'od_': "is_deleted = 0 AND enable = 1",
    'proc_': "is_deleted = 0 AND enable = 1",
    'po_': "1 = 1", # po_defective_product 没有通用软删字段
    't_': "is_deleted = 0", # t_standard_cost_budget
    'anta_': "is_delete = 0", # anta_bom_detail_info
    'shoe_': "1 = 1",  # ✅ 以 shoe_ 开头的表不需要软删除过滤
    'store': "is_deleted = '0' AND enable = '1'",
    'material_inventory': "1 = 1",
}

def generate_schema_info(current_time: str = None) -> str:
    if current_time is None:
        current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    lines = [
        f"当前系统时间：{current_time}",
        "### 数据库表关系说明 (Schema Context)",
        "这是一个鞋服制造行业的 MES/ERP 系统数据库。",
        "",
        "🚨 严格规则（必须遵守，否则 SQL 会失败）：",
        "1. 所有非核心业务字段（审计字段、创建/更新人、备注等）已被物理移除，你只看到业务必须的核心字段，禁止臆造任何其他字段。",
        "2. 优先使用名称/中文状态字段进行条件过滤，而不是使用 code 或 seq 字段猜测。",
        "3. 带有 (注释:xxx) 的字段说明，请严格遵循其含义进行统计，且在生成 SQL 时不要将注释部分写入列名中。",
        "4. JOIN 时只能使用 relations 中定义的外键关联。",
        "5. 聚合查询（如 GROUP BY）时，如果存在实体主键/关联键（如 custom_seq, art_seq 等），请优先使用键和名称一起分组（例如 GROUP BY custom_seq, custom_name），防止同名数据混淆。",
        "",
        "🗑️ 数据清洗规则（软删除与可用性强制执行！）",
        "本系统全部采用软删除逻辑。任何 SELECT 查询涉及的每一张表（包括 JOIN 的表）都必须加上正确的过滤条件，否则视为严重错误！"
    ]
    
    for prefix, rule in FILTER_RULES.items():
        if prefix == 'default':
            lines.append(f"- 其他表（未列出前缀）：必须包含条件 `{rule}`")
        else:
            lines.append(f"- 以 {prefix} 开头的表：必须包含条件 `{rule}`")
            
    lines.append("")
    lines.append("📖 业务字典说明：")
    lines.append("- acc_reconciliation 表的 status 字段取值说明: 0草稿，1待审校，2已审核待上传发票，3已完成")
    lines.append("")
    lines.append("📊 核心业务表与关键字段：")
    
    for table_name, info in sorted(CORE_TABLES.items()):
        lines.append(f"- 表 `{table_name}` (主键: {info['pk']})")
        
        formatted_columns = []
        for col in info['columns']:
            if "《" in col and "》" in col:
                col_name = col.split("《")[0]
                comment = col.split("《")[1].split("》")[0]
                formatted_columns.append(f"{col_name} (注释: {comment})")
            else:
                formatted_columns.append(col)
                
        lines.append(f"  字段: {', '.join(formatted_columns)}")
        if info.get('relations'):
            lines.append(f"  关联关系: {', '.join(info['relations'])}")
        lines.append("")
    
    return "\n".join(lines)

SCHEMA_CONTEXT = generate_schema_info()

# ============================================================
# Few-Shot 示例库（包含 JOIN 示例并保留纯 JSON 输出格式）
# ============================================================

FEW_SHOT_EXAMPLES = [
    {
        "mode": "sql",
        "intent": "aggregation",
        "query": "查询本月销售总额",
        "response": """{
    "thought": "1. 本月销售总额 → od_order_doc 表\\n2. 时间条件用 DATE_FORMAT\\n3. 必须加软删除 is_deleted=0 AND enable=1",
    "sql": "SELECT IFNULL(SUM(total_number), 0) AS total_qty FROM od_order_doc WHERE order_date >= DATE_FORMAT(NOW(), '%Y-%m-01') AND is_deleted = 0 AND enable = 1"
}"""
    },
    {
        "mode": "sql",
        "intent": "ranking",
        "query": "统计各客户出货量前5名",
        "response": """{
    "thought": "1. 按客户统计出货量并排名\\n2. 需要 acc_product_shipment 表\\n3. GROUP BY + SUM + ORDER BY + LIMIT\\n4. 过滤条件 del_flag='0' AND is_available='0'",
    "sql": "SELECT customer_name, SUM(shipment_quantity) AS order_count FROM acc_product_shipment WHERE del_flag = '0' AND is_available = '0' GROUP BY customer_name ORDER BY order_count DESC LIMIT 5"
}"""
    },
    {
        "mode": "sql",
        "intent": "join_detail",
        "query": "查询最近一个月每个订单的商品数量明细",
        "response": """{
    "thought": "1. 需要订单基本信息 + 商品明细 → JOIN od_order_doc 和 od_order_doc_article，通过 od_order_doc_seq 关联\\n2. 最近一个月时间范围\\n3. 两表都要加过滤条件",
    "sql": "SELECT d.od_order_doc_seq, d.sku, d.name, d.total_number, o.code AS order_code, o.order_date, o.custom_name FROM od_order_doc_article d INNER JOIN od_order_doc o ON d.od_order_doc_seq = o.seq WHERE o.order_date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND o.is_deleted = 0 AND o.enable = 1 AND d.is_deleted = 0 AND d.enable = 1 ORDER BY o.order_date DESC LIMIT 100"
}"""
    },
    {
        "mode": "sql",
        "intent": "inventory",
        "query": "查询某个SKU的当前库存",
        "response": """{
    "thought": "1. 查询库存表 store\\n2. 条件 sku='XXX'\\n3. 过滤条件 is_deleted='0' AND enable='1'",
    "sql": "SELECT sku, material_name, warehouse_name, on_hand_qty FROM store WHERE sku = 'XXX' AND is_deleted = '0' AND enable = '1' LIMIT 20"
}"""
    }
]

def select_few_shot_examples(query: str, max_examples: int = 4, mode: str = "sql") -> List[Dict[str, Any]]:
    candidates = [ex for ex in FEW_SHOT_EXAMPLES if ex.get("mode") == mode]
    q_lower = query.lower()
    if any(kw in q_lower for kw in ["前", "最多", "最高", "排名", "top"]):
        intent = "ranking"
    elif any(kw in q_lower for kw in ["明细", "详情", "哪些", "对应", "清单", "每个"]):
        intent = "join_detail"
    elif any(kw in q_lower for kw in ["库存", "在库", "剩余"]):
        intent = "inventory"
    else:
        intent = "aggregation"
    
    matched = [ex for ex in candidates if ex.get("intent") == intent]
    others = [ex for ex in candidates if ex.get("intent") != intent]
    return (matched + others)[:max_examples]

def format_few_shot_examples(examples: List[Dict[str, Any]]) -> str:
    if not examples:
        return ""
    parts = ["\n### Few-Shot 参考示例（严格参考格式）\n"]
    for i, ex in enumerate(examples, 1):
        parts.append(f"示例 {i}：{ex['query']}")
        parts.append(f"期望输出：\n```json\n{ex['response']}\n```")
        parts.append("")
    return "\n".join(parts)

# ============================================================
# 意图识别与思维链 (Thinking)
# ============================================================

THINKING_SYSTEM = """你是一位拥有 20 年经验的鞋服行业业务高管，同时也是精通企业数据的战略顾问。
当前系统时间：{current_time}

你的任务是：深度剖析用户的业务问题，将其转化为严谨的数据分析策略。

核心思维步骤（请严格按此顺序思考并输出）：
1. 业务意图解码：用户真正关心的业务价值是什么？（是关注营收增长、库存周转风险、还是供应链效率？）
2. 数据策略映射：为了回答这个业务问题，我们需要调取哪些核心数据资产？（请参考下方的 Schema Context）
3. 关键指标定义：如何精确定义分析维度？（时间窗口、业务状态、客户筛选等条件）
4. 数据完整性保障：必须强制应用数据清洗（软删除与可用性）规则，确保数据准确无误。（列出所有涉及表的过滤条件）
5. 关联逻辑构建：如何通过多表关联还原业务全貌？（说明表之间的 relations 业务关系）
6. 分析目标设定：最终交付的分析结果应包含什么？（总量统计、趋势分析、异常检测、排名分布？）

输出格式（请使用业务语言，但保持技术严谨）：
【业务意图】：...
【核心数据资产】：... (对应具体表名)
【关键指标与筛选】：...
【数据清洗规则】：... (过滤条件)
【业务关联逻辑】：...
【最终分析目标】：...

当前可用的完整 Schema 信息如下，请务必严格参考，禁止臆造表名或字段：
{schema_context}
"""

THINKING_PROMPT = ChatPromptTemplate.from_messages([
    ("system", THINKING_SYSTEM),
    MessagesPlaceholder(variable_name="messages"),
    ("human", "{query}"),
])

# ============================================================
# SQL 生成 (SQL Generation)
# ============================================================

SQL_GEN_SYSTEM = """你是一个严格的 MySQL SQL 专家。请根据用户需求和提供的 Schema Context 生成只读的 SELECT SQL。
当前系统时间：{current_time}

**强制要求（违反任何一条都视为严重错误）**：
1. 只返回纯 JSON 对象，不要任何解释文字！
2. 只生成 SELECT 查询，严禁出现 INSERT/UPDATE/DELETE/DROP 等。
3. 每张表必须原样加上过滤条件（参考 Schema 中的数据清洗规则，如 is_deleted=0 或 del_flag='0'，严格按定义复制。再次强调：涉及 JOIN 的每一张表都要加！漏加视为严重错误！）。
4. JOIN 只能使用 relations 中定义的关联。
5. 严格使用 Schema 中列出的表名和字段名，禁止臆造任何字段。优先使用带有中文描述的字段作条件。
6. 默认加上 LIMIT 100 防止返回过多数据。
7. 使用 MySQL 标准函数：DATE_FORMAT、NOW()、DATE_SUB 等。如果涉及时间范围，优先使用日期函数而非字符串比较。

返回格式必须是：
{{
    "thought": "思考过程：1. 需要的表... 2. 过滤条件... 3. 关联关系...",
    "sql": "SELECT ... FROM ... WHERE ..."
}}

{few_shot_examples}
"""

SQL_GEN_PROMPT = ChatPromptTemplate.from_messages([
    ("system", SQL_GEN_SYSTEM),
    MessagesPlaceholder(variable_name="messages"),
    ("human", """用户问题：{query}

Schema Context（必须严格遵守）：
{schema_context}

请直接输出 JSON。"""),
])

# ============================================================
# 最终报告生成 (Response Generation)
# ============================================================

RESPONSE_GEN_SYSTEM = """你是一位资深业务分析专家，正在向公司高管汇报。请根据用户问题和 SQL 执行结果，生成一份格式精美、层次分明、具有决策价值的 Markdown 格式分析报告。
当前系统时间：{current_time}

## 核心排版与视觉规范（严格遵守）
1. **层次解构**：必须使用标准的 Markdown 标题（`###` 或 `####`）将大段文字切分为独立模块，绝不允许出现超过 4 行的密集文本块。
2. **要点分离**：所有并列的观点、数据、建议，**必须**使用项目符号（`-`）或数字编号（`1.`）独立成行呈现。
3. **视觉聚焦**：
   - 核心数据指标必须使用 **加粗**。
   - 关键结论或警告信息使用 `>` 引用块突出。
4. **留白呼吸感**：在不同的标题和列表之间，必须保留一个空行（`\n\n`）作为视觉缓冲。

---

## 报告输出结构规范（按此顺序生成）

### 🎯 核心结论 (Executive Summary)
- 开门见山：用 1-2 句话总结最核心的业务发现，直击痛点或成绩。
- 核心指标：将最关键的 1-3 个数据提取出来，使用 **加粗** 呈现（如：总异常数 **250双**）。

### 📊 数据详情 (Data Evidence)
- 简要说明数据来源或概况。
- 呈现标准 Markdown 表格：
  - 确保列名转换为易读的业务词汇（而非原始英文字段名）。
  - 数字类列建议右对齐。
  - **强制过滤**：在表格中绝对禁止出现 `is_deleted`, `enable`, `del_flag`, `is_available` 等无业务意义的技术性字段。

### 🔍 深度洞察 (Trends & Anomalies)
*（将洞察按主题拆分为带有小标题的子项，例如：）*
#### 1. [洞察主题 A]（如：高度依赖人工操作规范）
- **现象描述**：基于数据看到了什么事实。
- **业务推论**：这说明了什么业务问题。

#### 2. [洞察主题 B]（如：改善维度较为单一）
- **现象描述**：...
- **业务推论**：...

### 💡 行动建议 (Actionable Insights)
*（针对上述洞察，给出具体、可执行的管理建议，每条建议独立成段）*
1. **[建议方向 A]（如：强化现场作业标准化与培训）**
   - **具体行动**：建议相关工位立即开展...
   - **预期收益**：以期达到...效果。
2. **[建议方向 B]（如：引入防呆机制 Poka-Yoke）**
   - **具体行动**：建议工艺工程部评估...
   - **预期收益**：彻底降低人为失误...

---

## 🚫 绝对红线约束
- 严禁将所有文字揉成一段。
- 只能使用提供的 `sql_result` 数据，禁止任何形式的数值虚构或脑补。
- 数据单位必须严格遵循字段含义（如“双”、“元”），不可捏造。
"""

RESPONSE_GEN_PROMPT = ChatPromptTemplate.from_messages([
    ("system", RESPONSE_GEN_SYSTEM),
    MessagesPlaceholder(variable_name="messages"),
    ("human", """用户问题：{query}

SQL 查询结果（JSON 格式）：{sql_result}

请生成完整的分析报告。"""),
])

# ============================================================
# 图表配置生成 (Chart Config Generation)
# ============================================================

CHART_GEN_SYSTEM = """你是一位数据可视化专家。
根据用户问题和 SQL 结果，决定是否生成 ECharts 配置。
如果数据不适合图表（单个数字、空结果等），请返回 null。
否则返回符合 EChartsConfig Pydantic 模型的 JSON 配置。"""

CHART_GEN_PROMPT = ChatPromptTemplate.from_messages([
    ("system", CHART_GEN_SYSTEM),
    ("human", """用户问题：{query}
SQL 结果：{sql_result}"""),
])

# ============================================================
# 导出
# ============================================================

__all__ = [
    "SCHEMA_CONTEXT",
    "select_few_shot_examples",
    "format_few_shot_examples",
    "THINKING_PROMPT",
    "SQL_GEN_PROMPT",
    "RESPONSE_GEN_PROMPT",
    "CHART_GEN_PROMPT",
]