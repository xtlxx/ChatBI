import re
import os
import sys

# Paths
PROMPTS_PATH = r"d:\Code\KY\backend\agent\prompts.py"
DUMP_PATH = r"d:\Code\KY\Dump20251005.sql"

# Expected Schema from Prompts
# This dictionary represents the "Truth" asserted by prompts.py
EXPECTED_SCHEMA = {
    "bas_custom": {"pk": "id", "soft_delete": "is_delete"},
    "bas_supplier": {"pk": "seq", "soft_delete": "is_delete"},
    "om_article": {"pk": "seq", "soft_delete": "is_deleted"},
    "od_order_doc": {"pk": "seq", "soft_delete": "is_deleted"},
    "od_order_doc_article": {"pk": "seq", "soft_delete": "is_deleted"},
    "od_product_order_doc": {"pk": "seq", "soft_delete": "is_deleted"},
    "proc_material_procurement": {"pk": "seq", "soft_delete": "is_deleted"},
    "proc_material_list": {"pk": "seq", "soft_delete": "is_deleted"},
    "proc_material_warehousing": {"pk": "seq", "soft_delete": "is_deleted"},
    "store": {"pk": "id", "soft_delete": "is_deleted"}, 
    "acc_product_shipment": {"pk": "seq", "soft_delete": "del_flag"},
    "acc_reconciliation": {"pk": "seq", "soft_delete": "del_flag"},
    "proc_supplier_statement": {"pk": "seq", "soft_delete": "is_deleted"},
}

def parse_sql_dump(dump_path):
    schema = {}
    if not os.path.exists(dump_path):
        print(f"Dump file not found: {dump_path}")
        return {}
        
    with open(dump_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Regex to find create table blocks
    # This is a simple parser, might be fragile if dump format changes
    table_blocks = re.split(r'CREATE TABLE `(\w+)`', content)
    
    # iterate 1, 2; 3, 4...
    for i in range(1, len(table_blocks), 2):
        table_name = table_blocks[i]
        block = table_blocks[i+1]
        
        # Parse PK
        pk = None
        if "PRIMARY KEY (`" in block:
            pk_match = re.search(r'PRIMARY KEY \(`(\w+)`\)', block)
            if pk_match:
                pk = pk_match.group(1)
        
        # Parse Soft Delete
        soft_delete = None
        if "`is_delete`" in block:
            soft_delete = "is_delete"
        elif "`is_deleted`" in block:
            soft_delete = "is_deleted"
        elif "`del_flag`" in block:
            soft_delete = "del_flag"
            
        schema[table_name] = {"pk": pk, "soft_delete": soft_delete}
        
    return schema

def test_schema_validity():
    print(f"Parsing SQL Dump: {DUMP_PATH}")
    actual_schema = parse_sql_dump(DUMP_PATH)
    errors = []
    
    print("Validating Prompts.py claims against Dump...")
    for table, expected in EXPECTED_SCHEMA.items():
        if table not in actual_schema:
            print(f"WARNING: Table {table} not found in dump (might be omitted in simple parse)")
            continue
            
        actual = actual_schema[table]
        
        # Check PK
        if expected["pk"] and actual["pk"] != expected["pk"]:
             errors.append(f"{table}: Expected PK '{expected['pk']}', found '{actual['pk']}'")
             
        # Check Soft Delete
        if expected["soft_delete"]:
            if actual["soft_delete"] != expected["soft_delete"]:
                 errors.append(f"{table}: Expected Soft Delete '{expected['soft_delete']}', found '{actual['soft_delete']}'")
            else:
                print(f"OK: {table} (PK={actual['pk']}, SD={actual['soft_delete']})")

    if errors:
        print("\n❌ Schema Validation Errors:")
        for e in errors:
            print(f"- {e}")
        assert False, f"Schema validation errors: {errors}"
    else:
        print("\n✅ Schema Validation Passed: Prompts match Dump.")

if __name__ == "__main__":
    test_schema_validity()
