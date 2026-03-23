import re

# Define file paths
SQL_DUMP_PATH = r"d:\Code\KY\Dump20251005.sql"
OUTPUT_PATH = r"d:\Code\KY\backend\agent\prompts.py"

# Table Exclusion Patterns (Regex)
TABLE_EXCLUDE_PATTERNS = [
    r'^act_', r'^flw_', r'^hi_', r'^ru_', r'^re_',  # Workflow
    r'^sys_', r'^dict_', r'^qrtz_', r'^job_',       # System/Quartz
    r'^andy_', r'^demo_', r'^tb_', r'^test_',       # Test/Temp
    r'^anta_bom_',                                  # Anta BOM (Explicitly excluded by user)
    r'^mac',                                        # Machine logs/stats
    r'^api_',                                       # API logs
    r'_copy\d*$', r'_bak\d*$', r'_tmp$',            # Backup/Temp suffixes
    r'_\d{4}$', r'_\d{8}$',                         # Date suffixes
    r'^v_',                                         # Views
    r'^log_',                                       # Logs
    r'^rep_',                                       # Reports (maybe?)
    r'^file', r'^business_file',                    # File storage
    r'^rabbitmq',                                   # Message Queue
]

# Column Inclusion Keywords (Keep if matches these)
CORE_COLUMN_KEYWORDS = [
    'id', 'seq', 'code', 'no', 'number', 'uuid',    # Identifiers
    'name', 'title', 'desc', 'content',             # Text
    'status', 'state', 'type', 'kind',              # Enum/Status
    'amount', 'price', 'cost', 'total', 'sum',      # Money
    'qty', 'quantity', 'num', 'count',              # Numbers
    'date', 'time', 'at', 'day', 'year', 'month',   # Time
    'custom', 'supplier', 'provider', 'user',       # Entities
    'material', 'product', 'article', 'sku',        # Items
    'warehouse', 'store', 'location',               # Places
    'remark', 'memo',                               # Notes
    'is_delete', 'is_deleted', 'del_flag', 'enable' # Flags
]

# Column Exclusion Patterns (Remove even if matches keywords, unless PK/SoftDelete)
COLUMN_EXCLUDE_PATTERNS = [
    r'password', r'pwd', r'salt',                   # Security
    r'^rev_', r'_rev$',                             # Revision
    r'blob', r'bytes',                              # Binary
    r'tenant_id',                                   # Multi-tenant
    r'create_by', r'update_by', r'delete_by',       # Audit User
    r'created_by', r'updated_by', r'deleted_by',
    r'version',                                     # Optimistic Locking
    r'signature',                                   # Signatures
    r'token',                                       # Tokens
]

# Soft Delete Config
SOFT_DELETE_MAPPING = {
    'is_delete': '0',
    'is_deleted': '0',
    'del_flag': '0',
}

def should_exclude_table(table_name):
    return any(re.search(pattern, table_name, re.IGNORECASE) for pattern in TABLE_EXCLUDE_PATTERNS)

def should_include_column(col_name, is_pk, is_soft_delete):
    if is_pk or is_soft_delete:
        return True

    col_lower = col_name.lower()

    # Check exclusion patterns first
    for pattern in COLUMN_EXCLUDE_PATTERNS:
        if re.search(pattern, col_lower):
            return False

    # Check inclusion keywords
    return any(keyword in col_lower for keyword in CORE_COLUMN_KEYWORDS)

def parse_sql_dump(file_path):
    with open(file_path, encoding='utf-8') as f:
        content = f.read()

    tables = {}

    # Regex to find CREATE TABLE statements
    # CREATE TABLE `table_name` ( ... ) ... ;
    table_pattern = re.compile(r"CREATE TABLE `(\w+)` \((.*?)\) ENGINE=.*?;", re.DOTALL)

    matches = table_pattern.findall(content)

    for table_name, body in matches:
        if should_exclude_table(table_name):
            continue

        lines = body.split('\n')
        columns = []
        pk = None
        soft_delete_col = None
        soft_delete_val = '0'

        # First pass to find PK and Soft Delete
        for line in lines:
            line = line.strip()
            if line.startswith('PRIMARY KEY'):
                # PRIMARY KEY (`seq`)
                pk_match = re.search(r"PRIMARY KEY \(`(\w+)`\)", line)
                if pk_match:
                    pk = pk_match.group(1)
            elif line.startswith('`'):
                # `col_name` type ...
                col_match = re.search(r"`(\w+)`", line)
                if col_match:
                    col_name = col_match.group(1)
                    if col_name in SOFT_DELETE_MAPPING:
                        soft_delete_col = col_name
                        soft_delete_val = SOFT_DELETE_MAPPING[col_name]

        # Default PK if not found (usually 'seq' or 'id')
        if not pk:
            if 'seq' in body:
                pk = 'seq'
            elif 'id' in body:
                pk = 'id'

        # Second pass to collect columns
        for line in lines:
            line = line.strip()
            if not line.startswith('`'):
                continue

            col_match = re.search(r"`(\w+)`", line)
            if not col_match:
                continue

            col_name = col_match.group(1)
            is_pk = (col_name == pk)
            is_soft_delete = (col_name == soft_delete_col)

            if should_include_column(col_name, is_pk, is_soft_delete):
                columns.append(col_name)

        if columns:
            tables[table_name] = (pk, columns, soft_delete_col, soft_delete_val)

    return tables

def generate_core_tables_code(tables):
    lines = []
    lines.append("# ============================================================")
    lines.append("# 业务表定义（经过优化的核心表结构）")
    lines.append("# ============================================================")
    lines.append("")
    lines.append("# 核心业务表及其关键字段")
    lines.append("# 格式: 表名 -> (主键, 核心字段列表, 软删除字段, 软删除值)")
    lines.append("CORE_TABLES: Dict[str, Tuple[str, List[str], str, str]] = {")

    # Sort tables by category for readability
    sorted_tables = sorted(tables.items(), key=lambda x: x[0])

    # Helper to determine category
    def get_category(name):
        if name.startswith('bas_'):
            return '基础数据 (bas_)'
        if name.startswith('od_'):
            return '订单 (od_)'
        if name.startswith('proc_'):
            return '生产与采购 (proc_)'
        if name.startswith('acc_'):
            return '财务 (acc_)'
        if name.startswith('om_'):
            return '产品 (om_)'
        if name.startswith('mx_'):
            return '物料 (mx_)'
        if name.startswith('store'):
            return '库存 (store)'
        if name.startswith('sop_'):
            return 'SOP'
        return '其他'

    current_category = None

    for table_name, (pk, cols, sd_col, sd_val) in sorted_tables:
        category = get_category(table_name)
        if category != current_category:
            lines.append(f"    # === {category} ===")
            current_category = category

        # Format columns list nicely
        cols_str = "[" + ", ".join([f"'{c}'" for c in cols]) + "]"
        # Wrap long lines
        if len(cols_str) > 80:
            # Simple wrapping logic
            cols_formatted = "[\n"
            chunk = "        "
            for c in cols:
                chunk += f"'{c}', "
                if len(chunk) > 70:
                    cols_formatted += chunk + "\n"
                    chunk = "        "
            cols_formatted += chunk.rstrip(", ") + "]"
        else:
            cols_formatted = cols_str

        sd_col_repr = f"'{sd_col}'" if sd_col else "None"
        sd_val_repr = f"'{sd_val}'" if sd_val else "None"

        lines.append(f"    '{table_name}': ('{pk}', {cols_formatted}, {sd_col_repr}, {sd_val_repr}),")
        lines.append("")

    lines.append("}")
    return "\n".join(lines)

def update_prompts_file(new_core_tables_code):
    with open(OUTPUT_PATH, encoding='utf-8') as f:
        content = f.read()

    # Regex to replace existing CORE_TABLES definition
    # Match from CORE_TABLES ... = { to the closing } at the end of the dict
    # This is tricky with nested braces, but CORE_TABLES structure is predictable.
    # It starts with `CORE_TABLES: Dict... = {` and ends with `}` followed by `\n\n` or similar.

    # We'll look for the start marker and the next major section marker.
    start_marker = "# ============================================================\n# 业务表定义（经过优化的核心表结构）"
    end_marker = "# ============================================================\n# 软删除规则（补充覆盖）"

    # If markers not found, try looser match
    if start_marker not in content:
        print("Start marker not found, trying regex...")
        # Fallback regex
        # This regex is risky if `}` appears inside.
        # But our `CORE_TABLES` uses indent.
        pass

    # Safe replacement: Split by markers
    parts = content.split(start_marker)
    if len(parts) < 2:
        print("Could not find CORE_TABLES start marker.")
        return False

    pre_content = parts[0]
    remainder = parts[1]

    parts2 = remainder.split(end_marker)
    if len(parts2) < 2:
        print("Could not find CORE_TABLES end marker.")
        return False

    post_content = parts2[1]

    new_content = pre_content + new_core_tables_code + "\n\n\n" + end_marker + post_content

    with open(OUTPUT_PATH, 'w', encoding='utf-8') as f:
        f.write(new_content)

    return True

if __name__ == "__main__":
    print(f"Parsing {SQL_DUMP_PATH}...")
    tables = parse_sql_dump(SQL_DUMP_PATH)
    print(f"Found {len(tables)} tables after filtering.")

    code = generate_core_tables_code(tables)
    print("Generated CORE_TABLES code.")

    if update_prompts_file(code):
        print(f"Successfully updated {OUTPUT_PATH}")
    else:
        print("Failed to update file.")
