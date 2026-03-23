
import asyncio
import json
import os
import sys

# Ensure backend project root is in path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from sqlalchemy import text

from core.database import engine


def map_type(type_str):
    type_str = type_str.upper()
    if type_str.startswith("UINT"):
        # Helper for UINT(18) -> BIGINT UNSIGNED or INT(18) UNSIGNED
        # Assuming BIGINT UNSIGNED is safe for all UINT
        return "BIGINT UNSIGNED"
    if type_str.startswith("UBIGINT"):
        return "BIGINT UNSIGNED"
    if "TIMESTAMPTZ" in type_str:
        return "DATETIME"
    if "JSONB" in type_str:
        return "JSON"
    return type_str

async def restore_tables():
    try:
        print("Loading metadata...")
        meta_path = os.path.join(os.path.dirname(__file__), "..", "metadata.json")
        with open(meta_path, encoding="utf-8") as f:
            metadata = json.load(f)
            tables = metadata.get("tables", {})

        print(f"Loaded {len(tables)} tables from metadata.")

        tables_to_restore = [
            "bas_custom",
            "od_order_doc",
            "od_order_doc_article",
            "om_article",
            "acc_product_shipment",
            "acc_reconciliation",
            "acc_reconciliation_deduction",
            "acc_reconciliation_deduction_attachment",
            "acc_reconciliation_detail"
        ]

        async with engine.begin() as conn:
            for table_name in tables_to_restore:
                if table_name not in tables:
                    print(f"SKIPPING: Table {table_name} not found in metadata keys.")
                    continue

                # Check if table exists
                exists_check = await conn.execute(text(f"SHOW TABLES LIKE '{table_name}'"))
                if exists_check.scalar():
                    print(f"EXISTS: Table {table_name} already exists.")
                    continue

                print(f"Processing {table_name}...")

                table_def = tables[table_name]
                columns_sql = []
                pk_cols = []

                for col in table_def["columns"]:
                    col_name = f"`{col['name']}`"
                    col_type = map_type(col['type'])

                    col_def = f"{col_name} {col_type}"

                    if not col.get("nullable", True):
                        col_def += " NOT NULL"

                    default_val = col.get("default")
                    if default_val is not None:
                        if isinstance(default_val, str) and default_val.upper() == "NULL":
                            if col.get("nullable", True):
                                col_def += " DEFAULT NULL"
                        elif isinstance(default_val, str) and (default_val.startswith("'") or default_val.upper() in ['CURRENT_TIMESTAMP', 'NOW()']) or isinstance(default_val, int | float):
                             col_def += f" DEFAULT {default_val}"
                        else:
                             col_def += f" DEFAULT '{default_val}'"
                    elif col.get("nullable", True):
                        col_def += " DEFAULT NULL"

                    if col.get("comment"):
                        safe_comment = col['comment'].replace("'", "''")
                        col_def += f" COMMENT '{safe_comment}'"

                    columns_sql.append(col_def)

                if "constraints" in table_def:
                    for cons in table_def["constraints"]:
                        if cons.get("type") == "PRIMARY KEY":
                            pk_cols = cons.get("columns", [])
                            break

                create_stmt = f"CREATE TABLE IF NOT EXISTS `{table_name}` (\n"
                create_stmt += ",\n".join(columns_sql)

                if pk_cols:
                    pk_str = ", ".join([f"`{c}`" for c in pk_cols])
                    create_stmt += f",\nPRIMARY KEY ({pk_str})"

                create_stmt += "\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"

                print(f"Creating table {table_name}...")
                try:
                    await conn.execute(text(create_stmt))
                    print(f"CREATED: Table {table_name} created successfully.")
                except Exception as e:
                    print(f"ERROR creating {table_name}: {e}")

            # Insert dummy data check
            print("Checking bas_custom data...")
            try:
                result = await conn.execute(text("SHOW TABLES LIKE 'bas_custom'"))
                if result.scalar():
                    result = await conn.execute(text("SELECT COUNT(*) FROM bas_custom"))
                    count = result.scalar()
                    if count == 0:
                        print("Inserting dummy data into bas_custom...")
                        await conn.execute(text("""
                            INSERT INTO bas_custom (name, code, email, legal_person, company_phone, business_state, payment_type)
                            VALUES
                            ('Admin User', 'ADMIN001', 'admin@example.com', 'Admin Person', '13800138000', 'Active', 'Credit'),
                            ('Demo User', 'DEMO001', 'demo@example.com', 'Demo Person', '13900139000', 'Active', 'Cash')
                        """))
                        print("Dummy data inserted.")
            except Exception as e:
                print(f"Error inserting dummy data: {e}")

    except Exception as e:
        print(f"Script crash: {e}")
    finally:
        await engine.dispose()

if __name__ == "__main__":
    if sys.platform == 'win32':
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
    asyncio.run(restore_tables())
