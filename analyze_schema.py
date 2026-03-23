"""
Parse the SQL dump file and extract table definitions, columns, PKs, FKs, and soft-delete info.
"""
import re
import json

def analyze_schema(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all CREATE TABLE blocks
    # Pattern: CREATE TABLE `tablename` ( ... ) ENGINE=...
    table_pattern = r"CREATE TABLE\s+`(\w+)`\s*\((.*?)\)\s*ENGINE="
    matches = list(re.finditer(table_pattern, content, re.DOTALL))
    
    print(f"Found {len(matches)} tables")
    
    tables = {}
    for m in matches:
        table_name = m.group(1)
        body = m.group(2)
        
        # Extract columns
        col_pattern = r"`(\w+)`\s+(\w+(?:\([^)]*\))?(?:\s+unsigned)?(?:\s+zerofill)?)\s*(.*?)(?:,\s*$|$)"
        cols = []
        pk = None
        soft_delete = None
        fk_refs = []
        
        for line in body.split('\n'):
            line = line.strip()
            if not line:
                continue
            
            # Primary key
            pk_match = re.search(r'PRIMARY KEY\s*\(`(\w+)`\)', line)
            if pk_match:
                pk = pk_match.group(1)
                continue
            
            # Skip index lines
            if line.startswith('UNIQUE KEY') or line.startswith('KEY '):
                continue
            
            # Column definition
            col_match = re.match(r'`(\w+)`\s+(\w+(?:\([^)]*\))?(?:\s+unsigned)?(?:\s+zerofill)?)', line)
            if col_match:
                col_name = col_match.group(1)
                col_type = col_match.group(2)
                
                # Extract comment
                comment_match = re.search(r"COMMENT\s+'(.*?)'", line)
                comment = comment_match.group(1) if comment_match else ''
                
                cols.append({
                    'name': col_name,
                    'type': col_type,
                    'comment': comment
                })
                
                # Check for FK references in comments
                ref_match = re.search(r'(\w+)\.(\w+)', comment)
                if ref_match and '_' in ref_match.group(1):
                    ref_table = ref_match.group(1)
                    ref_col = ref_match.group(2)
                    fk_refs.append({
                        'column': col_name,
                        'ref_table': ref_table,
                        'ref_column': ref_col,
                        'comment': comment
                    })
                
                # Check soft delete columns
                if col_name in ('del_flag', 'is_delete', 'is_deleted', 'deleted'):
                    default_match = re.search(r"DEFAULT\s+(?:'(\d+)'|(\d+))", line)
                    default_val = default_match.group(1) or default_match.group(2) if default_match else None
                    soft_delete = {
                        'column': col_name,
                        'type': col_type,
                        'default': default_val,
                        'active_value': default_val  # The value that means "not deleted"
                    }
        
        tables[table_name] = {
            'pk': pk,
            'columns': [c['name'] for c in cols],
            'column_details': cols,
            'soft_delete': soft_delete,
            'fk_refs': fk_refs
        }
    
    return tables


def print_summary(tables):
    # Group by prefix
    prefixes = {}
    for name in sorted(tables.keys()):
        parts = name.split('_')
        prefix = parts[0] if parts else name
        if prefix not in prefixes:
            prefixes[prefix] = []
        prefixes[prefix].append(name)
    
    print("\n=== TABLE GROUP SUMMARY ===")
    for prefix in sorted(prefixes.keys()):
        names = prefixes[prefix]
        print(f"\n--- {prefix}_ ({len(names)} tables) ---")
        for name in names:
            t = tables[name]
            sd = t['soft_delete']
            sd_str = f"  [soft_delete: {sd['column']}={sd['active_value']}]" if sd else ""
            pk_str = f"  PK={t['pk']}" if t['pk'] else ""
            print(f"  {name}{pk_str}{sd_str}")
    
    # Print FK references
    print("\n\n=== FOREIGN KEY REFERENCES (from comments) ===")
    for name in sorted(tables.keys()):
        t = tables[name]
        if t['fk_refs']:
            for ref in t['fk_refs']:
                print(f"  {name}.{ref['column']} -> {ref['ref_table']}.{ref['ref_column']}  # {ref['comment']}")
    
    # Print soft delete summary
    print("\n\n=== SOFT DELETE SUMMARY ===")
    sd_groups = {}
    for name in sorted(tables.keys()):
        t = tables[name]
        sd = t['soft_delete']
        if sd:
            key = f"{sd['column']}={sd['active_value']} ({sd['type']})"
            if key not in sd_groups:
                sd_groups[key] = []
            sd_groups[key].append(name)
    
    for key in sorted(sd_groups.keys()):
        names = sd_groups[key]
        print(f"\n  {key}:")
        for n in names:
            print(f"    - {n}")
    
    # Tables without soft delete
    no_sd = [name for name in sorted(tables.keys()) if not tables[name]['soft_delete']]
    print(f"\n  No soft delete column ({len(no_sd)} tables):")
    for n in no_sd:
        print(f"    - {n}")


if __name__ == '__main__':
    tables = analyze_schema(r'D:\Code\KY\Dump20251005.sql')
    print_summary(tables)
    
    # Save full analysis to JSON
    with open(r'D:\Code\KY\schema_analysis.json', 'w', encoding='utf-8') as f:
        json.dump(tables, f, ensure_ascii=False, indent=2)
    print(f"\nFull analysis saved to schema_analysis.json ({len(tables)} tables)")
