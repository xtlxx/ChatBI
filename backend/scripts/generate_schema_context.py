import json
import os
import re


def load_metadata(path):
    with open(path, encoding='utf-8') as f:
        return json.load(f)

def should_ignore_table(table_name):
    # Ignore patterns for backup, temp, and system tables
    ignore_patterns = [
        r"_copy\d*$", r"_bak\d*$", r"_tmp\d*$", r"_temp\d*$",
        r"_\d{8}$", r"_\d{4}$", r"_dna$", r"_snapshot$", r"_old$", r"_new$",
        r"_zqs\d*$", r"_lz\d*$", r"_wyl\d*$",
        # Ignore SZ specific temp/task tables
        r"^sz_dwfl_tmp", r"^sz_t_",
        # Ignore other potential temp prefixes if found
        r"^tmp_", r"^temp_"
    ]
    return any(re.search(pattern, table_name, re.IGNORECASE) for pattern in ignore_patterns)

def generate_schema_context_str(metadata_path):
    data = load_metadata(metadata_path)
    tables = data.get('tables', {})

    # 1. Analyze Soft Delete Rules Global Summary
    soft_delete_rules = set()
    filtered_tables = {}

    for t_name, t_info in tables.items():
        if should_ignore_table(t_name):
            continue
        filtered_tables[t_name] = t_info

        cols = {c['name']: c.get('type', '') for c in t_info.get('columns', [])}

        if 'del_flag' in cols:
            if t_name.startswith('acc_'):
                soft_delete_rules.add("- `acc_` tables: `del_flag` = '0' (Char)")
            else:
                soft_delete_rules.add(f"- `{t_name}`: `del_flag` = '0'")
        elif 'is_delete' in cols:
            if t_name.startswith('bas_'):
                 soft_delete_rules.add("- `bas_` tables: `is_delete` = 0 (Int)")
            else:
                 soft_delete_rules.add(f"- `{t_name}`: `is_delete` = 0")
        elif 'is_deleted' in cols:
             if t_name.startswith('od_') or t_name.startswith('proc_'):
                 soft_delete_rules.add("- `od_`/`proc_` tables: `is_deleted` = 0 (Int)")
             elif t_name == 'store':
                 soft_delete_rules.add("- `store`: `is_deleted` = '0' (Char)")
             else:
                 soft_delete_rules.add(f"- `{t_name}`: `is_deleted` = 0")

    # 2. Group Tables
    groups = {
        "Base Data (bas_)": [],
        "Order (od_)": [],
        "Production & Proc (proc_)": [],
        "Accounting & Shipment (acc_)": [],
        "System & Others": []
    }

    for t_name in filtered_tables:
        if t_name.startswith('bas_') or t_name == 'om_article':
            groups["Base Data (bas_)"].append(t_name)
        elif t_name.startswith('od_'):
             groups["Order (od_)"].append(t_name)
        elif t_name.startswith('proc_'):
             groups["Production & Proc (proc_)"].append(t_name)
        elif t_name.startswith('acc_'):
             groups["Accounting & Shipment (acc_)"].append(t_name)
        else:
            groups["System & Others"].append(t_name)

    # 3. Generate String
    lines = []
    lines.append("### 数据库表关系说明 (Schema Context) [Auto-Generated]")
    lines.append("这是一个鞋服制造行业的 MES/ERP 系统数据库。")
    lines.append("**软删除规则 (Detected):**")
    for rule in sorted(soft_delete_rules):
        lines.append(rule)

    lines.append("\n**核心表结构:**")

    for group_name, table_list in groups.items():
        if not table_list:
            continue
        lines.append(f"\n#### {group_name}")
        for t_name in sorted(table_list):
            t = filtered_tables[t_name]
            # Find PK
            pk = "Unknown"
            if t.get('constraints'):
                for c in t['constraints']:
                    if c['type'] == 'PRIMARY KEY':
                        pk = ", ".join(c['columns'])

            # Key Columns (filter out boring ones)
            cols = []
            for c in t['columns']:
                cname = c['name']
                # Skip standard audit columns to save space
                if cname in ['created_at', 'updated_at', 'created_by', 'updated_by', 'version', 'remark', 'create_by', 'update_by', 'create_time', 'update_time']:
                    continue

                # Format: name (comment)
                desc = cname
                if c.get('comment'):
                    # Clean comment
                    comment = c['comment'].replace('\n', ' ').strip()
                    if comment and comment != cname:
                        desc += f" ({comment})"
                cols.append(desc)

            col_str = ", ".join(cols)
            lines.append(f"- `{t_name}`: PK=`{pk}`. Cols: {col_str}")

    return "\n".join(lines)

def update_prompts_file(prompts_path, schema_content):
    with open(prompts_path, encoding='utf-8') as f:
        content = f.read()

    # Target SCHEMA_INFO = """..."""
    # Use non-greedy match for the content inside triple quotes
    pattern = r'(SCHEMA_INFO\s*=\s*""")([\s\S]*?)"""'

    match = re.search(pattern, content)
    if not match:
        print("Error: Could not find SCHEMA_INFO pattern in prompts.py.")
        return False

    # Replace content inside SCHEMA_INFO
    # We need to escape backslashes in schema_content to avoid regex issues during replacement,
    # but since we are constructing the replacement string directly, we should be careful.
    # Better to use string slicing or a safe replacement method.

    start, end = match.span(2)
    new_content = content[:start] + f'\n{schema_content}\n' + content[end:]

    with open(prompts_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

    print(f"Updated {prompts_path} successfully. Size: {len(new_content)} chars.")
    return True

if __name__ == "__main__":
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    metadata_path = os.path.join(base_dir, "metadata.json")
    prompts_path = os.path.join(base_dir, "agent", "prompts.py")

    if not os.path.exists(metadata_path):
        print(f"Error: {metadata_path} not found")
    else:
        schema_str = generate_schema_context_str(metadata_path)
        print(f"Generated schema length: {len(schema_str)} chars")

        if os.path.exists(prompts_path):
            update_prompts_file(prompts_path, schema_str)
        else:
            print(f"Error: {prompts_path} not found")
