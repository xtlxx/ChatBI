import json
import re
from typing import Any, List, Dict
from datetime import datetime
from pathlib import Path
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
        'columns': ['seq', 'od_order_doc_seq', 'row_no', 'art_seq', 'sku', 'code', 'name', 'customer_article_code', 'product_class_name',
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
        'columns': ['id', 'code', 'name', 'simple_name', 'legal_person', 'company_phone', 'business_state', 'payment_type',
                    'province_address', 'city_address', 'detail_address', 'is_delete', 'enable'],
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
    'mes_product_shipment': {
        'pk': 'seq',
        'columns': ['seq', 'firm_name', 'shipment_code', 'po', 'color_name', 'basic_size_code', 'out_date《业务含义:出货日期/出库日期，用于查询成品出货情况》', 
                    'shipment_quantity《单位:双，成品出库数量》', 'sku', 'od_order_doc_seq', 'customer_id', 'customer_name', 
                    'quotation_amount《单位:元，单价/金额》', 'order_code', 'out_type', 'warehouse_name'],
        'relations': ['customer_id -> bas_custom.id', 'od_order_doc_seq -> od_order_doc.seq'],
    },    
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
        'columns': ['seq', 'art_seq', 'sku', 'quotation_number', 'customer_name', 'product_class_name', 'transaction_price', 'profit_margin', 'cost_price', 'total_price_materials', 'status', 'is_deleted'],
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
        'columns': ['id', 'material_code', 'material_name', 'material_seq', 'product_code', 'factory_name', 'supply_name', 'size', 'color_name',
                    'customer_name', 'warehouse_name', 'on_hand_qty《单位:双，在库数量》',
                    'total_qty《单位:双，总库存数量》', 'sku', 'manual_prod_code', 'is_deleted', 'enable'],
        'relations': [],
    },
    'material_inventory': {
        'pk': 'seq',
        'columns': ['seq', 'code', 'bath_no', 'mater_code', 'mater_name', 'storage《单位:双，入库数量》', 'out_storage《单位:双，出库数量》', 'price《单位:元，单价》', 'sum_price《单位:元，总金额》', 'supplier', 'create_date'],
        'relations': [],
    },
    'proc_material_warehousing': {
        'pk': 'seq',
        'columns': ['seq', 'warehouse_entry_number', 'warehouse_entry_date《业务含义:入库日期，单据的业务发生时间》', 'supplier', 'supplier_seq', 'is_deleted', 'status'],
        'relations': ['supplier_seq -> bas_supplier.seq'],
    },
    'proc_material_warehousing_info': {
        'pk': 'seq',
        'columns': ['seq', 'proc_material_warehousing_seq', 'in_code《业务含义:入库单号》', 'this_time_inventory_quantity《业务含义:材料入库数量、本次入库量，针对材料维度的采购入库》', 'inventory_quantity_purchase《单位:双，采购单位的入库数量》', 'store_unit_price《单位:元，入库单价》', 'is_deleted', 'business_type《业务含义:60为入库》'],
        'relations': ['proc_material_warehousing_seq -> proc_material_warehousing.seq'],
    },

    # === 财务出货与对账 ===
    'acc_product_shipment': {
        'pk': 'seq',
        'columns': ['seq', 'po_no', 'customer_id', 'customer_name', 'order_seq', 'sku', 'art_code', 'shipment_code', 'basic_size_code', 'price《单位:元，单价》',
                    'art_name', 'shipment_quantity《业务含义:成品订单入库与出货数量，针对订单维度》', 'shipment_at', 'del_flag', 'is_available'],
        'relations': ['customer_id -> bas_custom.id'],
    },
    'acc_reconciliation': {
        'pk': 'seq',
        'columns': ['seq', 'bill_no', 'customer_id', 'customer_name', 'transaction_amount《单位:元，成交金额》',
                    'receivable_amount《单位:元，应收金额》', 'status', 'del_flag', 'is_available'],
        'relations': ['customer_id -> bas_custom.id'],
    },
    'acc_reconciliation_detail': {
        'pk': 'seq',
        'columns': ['seq', 'acc_reconciliation_seq', 'acc_product_shipment_seq', 'order_seq', 'po_no', 'sku', 'customer_id', 'customer_name',
                    'art_code', 'art_name', 'basic_size_code', 'shipment_quantity', 'shipment_at', 'shipment_code',
                    'reconciliation_quantity', 'reconciliation_price', 'settlement_quantity', 'settlement_price', 'settlement_amount',
                    'del_flag', 'is_available'],
        'relations': ['acc_reconciliation_seq -> acc_reconciliation.seq', 'acc_product_shipment_seq -> acc_product_shipment.seq'],
    },
    'acc_reconciliation_deduction': {
        'pk': 'seq',
        'columns': ['seq', 'acc_reconciliation_seq', 'parent_bill_no', 'deduction_item', 'deduction_amount', 'remark', 'del_flag', 'is_available'],
        'relations': ['acc_reconciliation_seq -> acc_reconciliation.seq'],
    },
    'acc_reconciliation_payment': {
        'pk': 'seq',
        'columns': ['seq', 'acc_reconciliation_seq', 'payment_date', 'amount_received', 'discount_amount', 'remark', 'created_by', 'created_at'],
        'relations': ['acc_reconciliation_seq -> acc_reconciliation.seq'],
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


import logging
logger = logging.getLogger(__name__)

def _load_metadata() -> dict[str, Any]:
    # __file__ is e:\Code\KY\backend\agent\prompts.py
    # parents[0] is agent
    # parents[1] is backend
    # parents[2] is KY (project root)
    project_root = Path(__file__).resolve().parents[2]
    
    target_path = project_root / "metadata.json"
    
    if target_path.exists() and target_path.is_file():
        try:
            with target_path.open("r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.error(f"解析 metadata.json 失败，路径：{target_path}，错误：{e}")
            return {}
            
    logger.warning(f"在 {target_path} 未找到 metadata.json")
    return {}


_METADATA: dict[str, Any] = _load_metadata()
_METADATA_TABLES: dict[str, Any] = (_METADATA.get("tables") or {}) if isinstance(_METADATA, dict) else {}
_AUDIT_COLUMNS = {
    "create_by",
    "create_time",
    "update_by",
    "update_time",
    "delete_by",
    "delete_time",
}
_SCHEMA_DISPLAY_EXCLUDE_COLUMNS = _AUDIT_COLUMNS | {
    "is_deleted",
    "enable",
    "is_delete",
    "del_flag",
    "is_available",
    "is_effective",
}
_NON_RELATION_COLUMNS = {
    "is_deleted",
    "enable",
    "is_effective",
    "is_delete",
    "del_flag",
    "is_available",
}
_REF_RE = re.compile(r"([a-zA-Z][a-zA-Z0-9_]+)\.([a-zA-Z][a-zA-Z0-9_]+)")


def _format_columns_from_metadata(meta_columns: list[dict[str, Any]]) -> list[str]:
    out: list[str] = []
    for c in meta_columns:
        name = (c.get("name") or "").strip()
        if not name:
            continue
        if name.lower() in _SCHEMA_DISPLAY_EXCLUDE_COLUMNS:
            continue
        comment = (c.get("comment") or "").strip()
        if comment:
            out.append(f"{name}《{comment}》")
        else:
            out.append(name)
    return out


def _hydrate_core_tables_from_metadata() -> None:
    if not _METADATA_TABLES:
        return
    for table_name, info in CORE_TABLES.items():
        meta = _METADATA_TABLES.get(table_name.lower())
        if not isinstance(meta, dict):
            continue
        meta_cols = meta.get("columns") or []
        if isinstance(meta_cols, list) and meta_cols:
            info["columns"] = _format_columns_from_metadata(meta_cols)

        pk_cols: list[str] = []
        for cons in (meta.get("constraints") or []):
            if not isinstance(cons, dict):
                continue
            if str(cons.get("type") or "").upper() == "PRIMARY KEY":
                cols = cons.get("columns") or []
                if isinstance(cols, list):
                    pk_cols = [str(x) for x in cols if x]
                break
        if pk_cols:
            info["pk"] = pk_cols[0]


def _find_matching_table(base: str, available_tables: set[str]) -> str | None:
    if base in available_tables:
        return base
    prefixes = ["bas_", "od_", "om_", "proc_", "acc_", "t_", "po_"]
    for p in prefixes:
        if f"{p}{base}" in available_tables:
            return f"{p}{base}"
    # Special mappings
    if base in ("custom", "customer") and "bas_custom" in available_tables: return "bas_custom"
    if base in ("art", "article") and "om_article" in available_tables: return "om_article"
    if base == "order" and "od_order_doc" in available_tables: return "od_order_doc"
    if base == "supplier" and "bas_supplier" in available_tables: return "bas_supplier"
    if base == "material" and "store" in available_tables: return "store" # just in case
    return None

def _infer_relations_from_metadata() -> None:
    if not _METADATA_TABLES:
        return

    meta_cols_map: dict[str, set[str]] = {}
    for tname, tmeta in _METADATA_TABLES.items():
        cols: set[str] = set()
        if isinstance(tmeta, dict):
            for c in (tmeta.get("columns") or []):
                if isinstance(c, dict) and c.get("name"):
                    cols.add(str(c["name"]).lower())
        meta_cols_map[str(tname).lower()] = cols

    core_table_set = set(CORE_TABLES.keys())

    for table_name, info in CORE_TABLES.items():
        meta = _METADATA_TABLES.get(table_name.lower())
        if not isinstance(meta, dict):
            continue

        relations = set(info.get("relations") or [])
        for c in (meta.get("columns") or []):
            if not isinstance(c, dict):
                continue

            col_name = (c.get("name") or "").strip()
            if not col_name:
                continue

            col_name_l = col_name.lower()
            if col_name_l in _AUDIT_COLUMNS or col_name_l in _NON_RELATION_COLUMNS:
                continue

            comment = (c.get("comment") or "").strip()
            if comment:
                for m in _REF_RE.finditer(comment):
                    ref_table = m.group(1).lower()
                    ref_col = m.group(2)
                    if ref_table in CORE_TABLES and ref_table in meta_cols_map and ref_col.lower() in meta_cols_map[ref_table]:
                        relations.add(f"{col_name} -> {ref_table}.{ref_col}")

            if col_name_l.endswith("_seq"):
                base = col_name_l[:-4]
                target_table = _find_matching_table(base, core_table_set)
                if target_table and target_table in meta_cols_map and "seq" in meta_cols_map[target_table]:
                    relations.add(f"{col_name} -> {target_table}.seq")
            elif col_name_l.endswith("_id"):
                base = col_name_l[:-3]
                target_table = _find_matching_table(base, core_table_set)
                if target_table and target_table in meta_cols_map:
                    if "id" in meta_cols_map[target_table]:
                        relations.add(f"{col_name} -> {target_table}.id")
                    elif "seq" in meta_cols_map[target_table]:
                        relations.add(f"{col_name} -> {target_table}.seq")
            elif col_name_l.endswith("_code"):
                base = col_name_l[:-5]
                target_table = _find_matching_table(base, core_table_set)
                if target_table and target_table in meta_cols_map:
                    if "code" in meta_cols_map[target_table]:
                        relations.add(f"{col_name} -> {target_table}.code")

        info["relations"] = sorted(relations)


def infer_filter_rule_for_table(table_name: str) -> str:
    cols: set[str] = set()
    meta = _METADATA_TABLES.get(table_name.lower())
    if isinstance(meta, dict):
        for c in (meta.get("columns") or []):
            if isinstance(c, dict) and c.get("name"):
                cols.add(str(c["name"]).lower())
    else:
        for c in CORE_TABLES.get(table_name, {}).get("columns", []):
            if isinstance(c, str) and c:
                cols.add(c.split("《")[0].strip().lower())

    parts: list[str] = []

    if "del_flag" in cols:
        parts.append("del_flag = '0'")

    if "is_available" in cols:
        parts.append("is_available = '0'")

    if "is_delete" in cols:
        parts.append("is_delete = 0")

    if "is_deleted" in cols:
        parts.append("is_deleted = 0")

    if "enable" in cols:
        parts.append("enable = 1")

    if table_name.startswith("proc_") and "is_effective" in cols:
        parts.append("is_effective = 1")

    return " AND ".join(parts) if parts else "1 = 1"


_hydrate_core_tables_from_metadata()
_infer_relations_from_metadata()

# ============================================================
# 软删除与可用性规则（极其重要！）
# ============================================================

FILTER_RULES = {
    'default': "is_deleted = 0 AND enable = 1",
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
        "1. 字段列表中已隐藏审计字段与软删除/可用性字段（如 is_deleted/enable/del_flag 等），但你在 WHERE 中仍必须按规则补齐这些过滤条件。",
        "2. 优先使用名称/中文状态字段进行条件过滤，而不是使用 code 或 seq 字段猜测。",
        "3. 带有 (注释:xxx) 的字段说明，请严格遵循其含义进行统计，且在生成 SQL 时不要将注释部分写入列名中。",
        "4. JOIN 时只能使用 relations 中定义的外键关联。若无必要请勿关联明细表，如果关联明细表（如订单关联订单明细），强烈建议使用 LEFT JOIN，避免主表数据被过滤！",
        "5. 聚合查询（如 GROUP BY）时，如果存在实体主键/关联键（如 custom_seq, art_seq 等），请优先使用键和名称一起分组（例如 GROUP BY custom_seq, custom_name），防止同名数据混淆。",
        "6. 对于模糊查询（如“xx情况”、“xx分析”），请优先输出按日期、按状态、或按客户的 GROUP BY 聚合统计结果，而非直接 SELECT 原始明细。",
        "7. 对于以 proc_ 开头的表，如果表中存在 is_effective 字段，查询时优先额外添加 is_effective = 1 过滤。",
        "",
        "🗑️ 数据清洗规则（软删除与可用性强制执行！）",
        "本系统全部采用软删除逻辑。任何 SELECT 查询涉及的每一张表（包括 JOIN 的表）都必须加上正确的过滤条件，否则视为严重错误！",
        "⚠️ 特别注意：部分表（如 acc_ 开头的表）的 is_available 字段，0 代表可用，1 代表不可用！请严格原样复制以下过滤条件，绝不要自作主张修改值（例如绝不要把 0 擅自改成 1）！"
    ]
    
    for table_name in sorted(CORE_TABLES.keys()):
        rule = infer_filter_rule_for_table(table_name)
        lines.append(f"- 表 {table_name}：必须包含条件 `{rule}`")
            
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


_QUERY_STOPWORDS = {
    "查询",
    "统计",
    "分析",
    "查看",
    "获取",
    "最近",
    "近",
    "本月",
    "本周",
    "本年",
    "今年",
    "今天",
    "昨日",
    "昨天",
    "今天的",
    "的",
    "了",
    "和",
    "与",
    "及",
    "或",
    "对",
    "按",
    "每个",
    "各",
    "多少",
    "数量",
    "总数",
    "总量",
    "明细",
    "详情",
    "列表",
    "top",
    "排名",
}

_TERM_TABLE_HINTS: dict[str, list[str]] = {
    "订单": ["od_order_doc", "od_order_doc_article", "proc_material_procurement", "acc_product_shipment"],
    "正式订单": ["od_order_doc", "od_order_doc_article"],
    "采购": ["proc_material_procurement"],
    "入库": ["proc_material_warehousing", "proc_material_warehousing_info", "material_inventory"],
    "出库": ["mes_product_shipment"],
    "出货": ["acc_product_shipment"],
    "库存": ["store", "material_inventory"],
    "质检": ["proc_material_quality_spection", "proc_material_quality_spection_info", "shoe_qc_analysis"],
    "定检": ["shoe_qc_analysis"],
    "巡检": ["shoe_qc_analysis"],
    "成本": ["t_standard_cost_budget", "t_material_cost"],
    "bom": ["anta_bom_detail_info"],
}


def _extract_query_terms(query: str) -> list[str]:
    q = (query or "").strip().lower()
    if not q:
        return []
    raw = re.findall(r"[a-zA-Z0-9_]+|[\u4e00-\u9fff]{2,}", q)
    out: list[str] = []
    for t in raw:
        tt = t.strip().lower()
        if not tt:
            continue
        if tt in _QUERY_STOPWORDS:
            continue
        if len(tt) < 2:
            continue
        out.append(tt)
    seen = set()
    deduped: list[str] = []
    for t in out:
        if t in seen:
            continue
        seen.add(t)
        deduped.append(t)
    return deduped[:24]


def _get_table_text(tname: str, meta: dict[str, Any]) -> str:
    parts = [tname.lower(), str(meta.get("comment") or "").lower()]
    for c in (meta.get("columns") or []):
        if not isinstance(c, dict):
            continue
        n = str(c.get("name") or "").lower()
        cm = str(c.get("comment") or "").lower()
        if n:
            parts.append(n)
        if cm:
            parts.append(cm)
    return "\n".join([p for p in parts if p])


def _score_table_for_query(tname: str, meta: dict[str, Any], terms: list[str]) -> int:
    if not terms:
        return 0
    name_l = tname.lower()
    comment_l = str(meta.get("comment") or "").lower()
    text_l = None
    score = 0
    for term in terms:
        if term in name_l:
            score += 10
        if term in comment_l:
            score += 6
        if score and score >= 30:
            continue
        if text_l is None:
            text_l = _get_table_text(tname, meta)
        if term in text_l:
            score += 2
    return score


def _infer_relations_from_table_metadata(table_name: str) -> list[str]:
    t = _METADATA_TABLES.get(table_name.lower())
    if not isinstance(t, dict):
        return []

    meta_cols_map: dict[str, set[str]] = {}
    for tname, tmeta in _METADATA_TABLES.items():
        cols: set[str] = set()
        if isinstance(tmeta, dict):
            for c in (tmeta.get("columns") or []):
                if isinstance(c, dict) and c.get("name"):
                    cols.add(str(c["name"]).lower())
        meta_cols_map[str(tname).lower()] = cols

    relations: set[str] = set()
    for c in (t.get("columns") or []):
        if not isinstance(c, dict):
            continue
        col_name = (c.get("name") or "").strip()
        if not col_name:
            continue
        col_name_l = col_name.lower()
        if col_name_l in _AUDIT_COLUMNS or col_name_l in _NON_RELATION_COLUMNS:
            continue

        comment = (c.get("comment") or "").strip()
        if comment:
            for m in _REF_RE.finditer(comment):
                ref_table = m.group(1).lower()
                ref_col = m.group(2)
                if ref_table in meta_cols_map and ref_col.lower() in meta_cols_map[ref_table]:
                    relations.add(f"{col_name} -> {ref_table}.{ref_col}")

        if col_name_l.endswith("_seq"):
            base = col_name_l[:-4]
            target_table = _find_matching_table(base, set(meta_cols_map.keys()))
            if target_table and target_table in meta_cols_map and "seq" in meta_cols_map[target_table]:
                relations.add(f"{col_name} -> {target_table}.seq")
        elif col_name_l.endswith("_id"):
            base = col_name_l[:-3]
            target_table = _find_matching_table(base, set(meta_cols_map.keys()))
            if target_table and target_table in meta_cols_map:
                if "id" in meta_cols_map[target_table]:
                    relations.add(f"{col_name} -> {target_table}.id")
                elif "seq" in meta_cols_map[target_table]:
                    relations.add(f"{col_name} -> {target_table}.seq")
        elif col_name_l.endswith("_code"):
            base = col_name_l[:-5]
            target_table = _find_matching_table(base, set(meta_cols_map.keys()))
            if target_table and target_table in meta_cols_map:
                if "code" in meta_cols_map[target_table]:
                    relations.add(f"{col_name} -> {target_table}.code")

    return sorted(relations)


_REL_TARGET_RE = re.compile(r"->\s*([a-zA-Z][a-zA-Z0-9_]+)\.")


def _extract_relation_target_tables(relations: list[str]) -> set[str]:
    out: set[str] = set()
    for r in relations or []:
        if not isinstance(r, str):
            continue
        m = _REL_TARGET_RE.search(r)
        if not m:
            continue
        out.add(m.group(1).lower())
    return out


def _get_pk_from_metadata(table_name: str) -> str:
    meta = _METADATA_TABLES.get(table_name.lower())
    if not isinstance(meta, dict):
        return CORE_TABLES.get(table_name, {}).get("pk") or "id"
    for cons in (meta.get("constraints") or []):
        if not isinstance(cons, dict):
            continue
        if str(cons.get("type") or "").upper() == "PRIMARY KEY":
            cols = cons.get("columns") or []
            if isinstance(cols, list) and cols:
                return str(cols[0])
            break
    cols = {str(c.get("name") or "").lower() for c in (meta.get("columns") or []) if isinstance(c, dict)}
    if "seq" in cols:
        return "seq"
    if "id" in cols:
        return "id"
    return "id"


def generate_schema_info_for_query(query: str, current_time: str | None = None, max_tables: int = 18) -> str:
    if current_time is None:
        current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    if not _METADATA_TABLES:
        return generate_schema_info(current_time=current_time)

    terms = _extract_query_terms(query)
    selected: set[str] = set()

    q_l = (query or "").lower()
    for k, hints in _TERM_TABLE_HINTS.items():
        if k.lower() in q_l:
            selected.update([h.lower() for h in hints])

    scored: list[tuple[int, str]] = []
    for tname, meta in _METADATA_TABLES.items():
        if not isinstance(meta, dict):
            continue
        s = _score_table_for_query(str(tname), meta, terms)
        if s > 0:
            scored.append((s, str(tname).lower()))
    scored.sort(key=lambda x: (-x[0], x[1]))
    for _, t in scored:
        selected.add(t)
        if len(selected) >= max_tables:
            break

    if not selected:
        selected.update([t.lower() for t in list(CORE_TABLES.keys())[:max_tables]])

    expanded = True
    while expanded and len(selected) < max_tables:
        expanded = False
        for t in list(selected):
            rels = _infer_relations_from_table_metadata(t)
            if not rels:
                rels = list(CORE_TABLES.get(t, {}).get("relations") or [])
            for rt in _extract_relation_target_tables(rels):
                if rt in _METADATA_TABLES and rt not in selected:
                    selected.add(rt)
                    expanded = True
                    if len(selected) >= max_tables:
                        break
            if len(selected) >= max_tables:
                break

    lines = [
        f"当前系统时间：{current_time}",
        "### 数据库表关系说明 (Schema Context)",
        "这是一个鞋服制造行业的 MES/ERP 系统数据库。",
        "",
        "🚨 严格规则（必须遵守，否则 SQL 会失败）：",
        "1. 字段列表中已隐藏审计字段与软删除/可用性字段（如 is_deleted/enable/del_flag 等），但你在 WHERE 中仍必须按规则补齐这些过滤条件。",
        "2. 优先使用名称/中文状态字段进行条件过滤，而不是使用 code 或 seq 字段猜测。",
        "3. 带有 (注释:xxx) 的字段说明，请严格遵循其含义进行统计，且在生成 SQL 时不要将注释部分写入列名中。",
        "4. JOIN 时只能使用 relations 中定义的外键关联。若无必要请勿关联明细表，如果关联明细表（如订单关联订单明细），强烈建议使用 LEFT JOIN，避免主表数据被过滤！",
        "5. 聚合查询（如 GROUP BY）时，如果存在实体主键/关联键（如 custom_seq, art_seq 等），请优先使用键和名称一起分组（例如 GROUP BY custom_seq, custom_name），防止同名数据混淆。",
        "6. 对于模糊查询（如“xx情况”、“xx分析”），请优先输出按日期、按状态、或按客户的 GROUP BY 聚合统计结果，而非直接 SELECT 原始明细。",
        "7. 对于以 proc_ 开头的表，如果表中存在 is_effective 字段，查询时优先额外添加 is_effective = 1 过滤。",
        "",
        "🗑️ 数据清洗规则（软删除与可用性强制执行！）",
        "任何 SELECT 查询涉及的每一张表（包括 JOIN 的表）都必须加上正确的过滤条件，否则视为严重错误！",
        "⚠️ 特别注意：部分表（如 acc_ 开头的表）的 is_available 字段，0 代表可用，1 代表不可用！请严格原样复制以下过滤条件，绝不要自作主张修改值（例如绝不要把 0 擅自改成 1）！",
        "",
        "本次问题相关表的过滤条件：",
    ]

    for table_name in sorted(selected):
        rule = infer_filter_rule_for_table(table_name)
        lines.append(f"- 表 {table_name}：必须包含条件 `{rule}`")

    lines.append("")
    lines.append("📊 本次问题相关表与关键字段：")

    for table_name in sorted(selected):
        meta = _METADATA_TABLES.get(table_name.lower())
        if not isinstance(meta, dict):
            continue
        pk = _get_pk_from_metadata(table_name)
        cols = _format_columns_from_metadata(meta.get("columns") or [])
        relations = _infer_relations_from_table_metadata(table_name)
        if not relations:
            relations = list(CORE_TABLES.get(table_name, {}).get("relations") or [])

        lines.append(f"- 表 `{table_name}` (主键: {pk})")
        formatted_columns = []
        for col in cols:
            if "《" in col and "》" in col:
                col_name = col.split("《")[0]
                comment = col.split("《")[1].split("》")[0]
                formatted_columns.append(f"{col_name} (注释: {comment})")
            else:
                formatted_columns.append(col)
        if formatted_columns:
            lines.append(f"  字段: {', '.join(formatted_columns)}")
        if relations:
            lines.append(f"  关联关系: {', '.join(relations)}")
        lines.append("")

    return "\n".join(lines)

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
    "sql": "SELECT d.od_order_doc_seq, d.sku, d.name, d.total_number, o.code AS order_code, o.order_date, o.custom_name FROM od_order_doc_article d INNER JOIN od_order_doc o ON d.od_order_doc_seq = o.seq WHERE o.order_date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND o.is_deleted = 0 AND o.enable = 1 AND d.is_deleted = 0 AND d.enable = 1 ORDER BY o.order_date DESC LIMIT 1000"
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
    },
    {
        "mode": "sql",
        "intent": "qc_analysis",
        "query": "你说说脱胶定检原因",
        "response": """{
    "thought": "1. 查询定检异常原因分析\\n2. 需要 shoe_qc_analysis 表\\n3. 过滤条件 defect_reason 包含 '脱胶'\\n4. shoe_qc_analysis 表不需要软删除过滤",
    "sql": "SELECT defect_reason, pair_count, inspection_method, improvement_method FROM shoe_qc_analysis WHERE defect_reason LIKE '%脱胶%' LIMIT 1000"
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
    elif any(kw in q_lower for kw in ["定检", "巡检", "质检", "脱胶", "原因", "异常"]):
        intent = "qc_analysis"
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
5. 关联逻辑构建：如何通过多表关联还原业务全貌？（若只需查主表情况，明确指出不需要关联明细表，如果需要关联明细表说明理由并使用 LEFT JOIN）
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
6. 默认加上 LIMIT 1000 防止返回过多数据。
7. 使用 MySQL 标准函数：DATE_FORMAT、NOW()、DATE_SUB 等。如果涉及时间范围，强烈建议使用 `DATE_FORMAT(col, '%Y-%m') = '2026-04'` 或 `< '2026-05-01'`，避免 `<=` 导致 datetime 精度丢失最后一天的数据。
8. 关联查询时：如果只是查询主表“情况/统计”而未明确要求明细，优先只查主表；若必须关联明细表（如订单关联订单商品），强制使用 **LEFT JOIN**，防止因缺失明细数据导致主表数据被错误过滤！
9. 对于模糊的“情况/概况”查询，优先生成 GROUP BY 聚合统计（如按天、按状态统计数量和金额），而不是只 SELECT 原始明细行。

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
    "generate_schema_info_for_query",
    "select_few_shot_examples",
    "format_few_shot_examples",
    "THINKING_PROMPT",
    "SQL_GEN_PROMPT",
    "RESPONSE_GEN_PROMPT",
    "CHART_GEN_PROMPT",
]
