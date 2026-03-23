# scripts/analyze_sql.py
# SQL 分析工具 。用于解析 SQL Dump 文件，提取表结构、血缘关系等元数据（生成 metadata.json 的核心工具）。
# 功能：
# 解析 SQL Dump 文件，提取表结构、视图、触发器、函数等元数据。
# 识别表之间的血缘关系（如 JOIN、子查询等）。
# 提取列级别的血缘关系（如视图中使用的列）。
# 生成 JSON 格式的元数据文件（metadata.json），用于后续分析和可视化。
import json
import os
import re
import sys
from typing import Any

import sqlglot
from sqlglot import exp

# Increase recursion depth for deep ASTs
sys.setrecursionlimit(10000)


class SQLAnalyzer:
    REGEX_CREATE_TABLE = re.compile(r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?[`']?(\w+)[`']?", re.IGNORECASE)
    REGEX_COLUMN_COMMENT = re.compile(r"^\s*[`']?(\w+)[`']?\s+.*COMMENT\s+['\"](.*?)['\"]", re.IGNORECASE | re.MULTILINE)

    def __init__(self, dump_file: str = r"d:\Code\KY\Dump20251005.sql"):
        self.dump_file = dump_file
        self.metadata: dict[str, Any] = {}
        self.lineage_edges: list[dict[str, str]] = []
        self.implicit_edges: list[dict[str, str]] = []
        self.column_lineage: list[dict[str, str]] = []
        self.views: dict[str, Any] = {}
        self.triggers: list[dict[str, Any]] = []
        self.functions: list[dict[str, Any]] = []
        self.create_table_pattern = re.compile(
            r"CREATE TABLE\s+(?:IF NOT EXISTS\s+)?" r"(?:`?(\w+)`?\.)?`?(\w+)`?\s*\(", re.IGNORECASE
        )

    def run(self):
        print(f"Analyzing {self.dump_file}...")
        self.parse_dump()
        self.analyze_relationships()
        self.generate_artifacts()
        print("Analysis complete.")

    def parse_dump(self):
        """
        Reads the dump file and parses CREATE TABLE/VIEW/TRIGGER statements.
        """
        if not os.path.exists(self.dump_file):
            print(f"File not found: {self.dump_file}")
            return

        with open(self.dump_file, encoding="utf-8") as f:
            content = f.read()

        # Split by semicolon followed by newline/EOF to get raw statements
        raw_statements = re.split(r";\s*\n", content)

        for i, raw in enumerate(raw_statements):
            raw = raw.strip()
            if not raw:
                continue

            # 1. Check for CREATE TABLE
            if not re.match(r"(?i)^\s*CREATE\s+", raw):
                continue

            # 2. Parse with sqlglot
            try:
                # Use MySQL dialect for better parsing of comments
                # and specific syntax
                parsed = sqlglot.parse_one(raw, read="mysql")
            except Exception as e:
                # print(f"Error parsing statement {i}: {e}")
                # Fallback to Regex for Tables if sqlglot fails
                if "CREATE TABLE" in raw.upper():
                    print(
                        f"Warning: sqlglot failed for statement {i} "
                        f"(possible Table). Error: {e}. Attempting fallback..."
                    )
                    self.fallback_parse_table(raw)
                continue

            if isinstance(parsed, exp.Create):
                self.process_statement(parsed, raw)

    def process_statement(self, stmt, raw_sql):
        if isinstance(stmt, exp.Create):
            if stmt.kind == "TABLE":
                self.extract_table_metadata(stmt)
            elif stmt.kind == "VIEW":
                self.extract_view_metadata(stmt)
            elif stmt.kind == "TRIGGER":
                self.extract_trigger_metadata(stmt, raw_sql)
            elif stmt.kind == "FUNCTION":
                self.extract_function_metadata(stmt, raw_sql)
        elif isinstance(stmt, exp.Insert):
            self.extract_insert_lineage(stmt)
        elif isinstance(stmt, exp.Update):
            self.extract_update_lineage(stmt)

    def extract_insert_lineage(self, stmt):
        """
        Extract lineage from INSERT INTO ... SELECT ...
        """
        try:
            target_table = stmt.this.name if stmt.this else "unknown"

            # Get target columns if specified: INSERT INTO t (c1, c2)
            target_cols = []
            if isinstance(stmt.this, exp.Schema):
                target_table = stmt.this.this.name
                target_cols = [e.name for e in stmt.this.expressions]

            # Check source: SELECT ...
            source_select = stmt.expression
            if isinstance(source_select, exp.Select):
                # Map select expressions to target columns by position
                for i, expression in enumerate(source_select.expressions):
                    if i < len(target_cols):
                        target_col = target_cols[i]

                        # Find source columns in expression
                        for source_col_exp in expression.find_all(exp.Column):
                            source_table = (
                                source_col_exp.table or "unknown"
                            )  # Might need alias resolution
                            source_col = source_col_exp.name

                            self.column_lineage.append(
                                {
                                    "source_table": source_table,
                                    "source_col": source_col,
                                    "target_table": target_table,
                                    "target_col": target_col,
                                    "type": "insert_select",
                                }
                            )

                            # Also add table level dependency
                            self.lineage_edges.append(
                                {
                                    "source": target_table,
                                    "target": source_table,
                                    "type": "dml",
                                    "label": "insert_select",
                                }
                            )
        except Exception:
            pass

    def extract_update_lineage(self, stmt):
        """
        Extract lineage from UPDATE t SET c1=exp ...
        """
        try:
            target_table = stmt.this.name if stmt.this else "unknown"

            # UPDATE joins are complex, let's look at SET expressions
            for expression in stmt.expressions:
                if isinstance(expression, exp.EQ):
                    target_col = expression.this.name  # Left side
                    source_exp = expression.expression  # Right side

                    for source_col_exp in source_exp.find_all(exp.Column):
                        # Default to same table
                        source_table = source_col_exp.table or target_table
                        source_col = source_col_exp.name

                        self.column_lineage.append(
                            {
                                "source_table": source_table,
                                "source_col": source_col,
                                "target_table": target_table,
                                "target_col": target_col,
                                "type": "update_set",
                            }
                        )
        except Exception:
            pass

    def fallback_parse_table(self, raw_sql: str) -> None:
        """
        Regex fallback to extract table name and columns if sqlglot fails.
        """
        match = self.REGEX_CREATE_TABLE.search(raw_sql)
        if match:
            table_name = match.group(1)
            print(f"Fallback: Identified table '{table_name}' via regex.")

            columns = []
            for line in raw_sql.split('\n'):
                col_match = self.REGEX_COLUMN_COMMENT.search(line)
                if col_match:
                    col_name = col_match.group(1)
                    comment = col_match.group(2)
                    columns.append({
                        "name": col_name,
                        "type": "UNKNOWN", # Regex doesn't parse type easily without complexity
                        "comment": comment
                    })

            self.metadata[table_name] = {
                "columns": columns,
                "comment": "Fallback extraction"
            }

    def fallback_parse(self, raw_sql):
        # Basic Regex extraction for Function/Trigger if sqlglot fails
        if re.match(r"(?i)^\s*CREATE\s+TRIGGER", raw_sql):
            name_match = re.search(r"TRIGGER\s+`?(\w+)`?", raw_sql, re.IGNORECASE)
            if name_match:
                self.triggers.append({"name": name_match.group(1), "sql": raw_sql[:100] + "..."})
        elif re.match(r"(?i)^\s*CREATE\s+FUNCTION", raw_sql):
            name_match = re.search(r"FUNCTION\s+`?(\w+)`?", raw_sql, re.IGNORECASE)
            if name_match:
                self.functions.append({"name": name_match.group(1), "sql": raw_sql[:100] + "..."})

    def extract_table_metadata(self, table_exp: exp.Create):
        if isinstance(table_exp.this, exp.Schema):
            table_ident = table_exp.this.this
        else:
            table_ident = table_exp.this

        table_name = (
            table_ident.name
            if isinstance(table_ident, exp.Table | exp.Identifier)
            else str(table_ident)
        )

        columns = []
        constraints = []
        indexes = []

        expressions = table_exp.this.expressions if isinstance(table_exp.this, exp.Schema) else []

        if expressions:
            for item in expressions:
                if isinstance(item, exp.ColumnDef):
                    col_name = item.this.name
                    col_type = item.kind.sql()
                    is_nullable = True
                    default_val = None
                    comment = None

                    for const in item.args.get("constraints", []):
                        constraint_kind = const.kind if hasattr(const, "kind") else const
                        kind_name = type(constraint_kind).__name__
                        const_sql = const.sql().upper()

                        if "NOTNULL" in kind_name.upper() or "NOT NULL" in const_sql:
                            is_nullable = False
                        elif "DEFAULT" in kind_name.upper() or "DEFAULT" in const_sql:
                            if hasattr(constraint_kind, "this"):
                                default_val = constraint_kind.this.sql()
                        elif ("COMMENT" in kind_name.upper() or "COMMENT" in const_sql) and hasattr(constraint_kind, "this"):
                            comment = constraint_kind.this.name

                    columns.append(
                        {
                            "name": col_name,
                            "type": col_type,
                            "nullable": is_nullable,
                            "default": default_val,
                            "comment": comment,
                        }
                    )

                elif isinstance(item, exp.PrimaryKey):
                    pk_cols = [c.name for c in item.this.expressions] if item.this else []
                    constraints.append({"type": "PRIMARY KEY", "columns": pk_cols})

                elif isinstance(item, exp.ForeignKey):
                    cols = [c.name for c in item.this.expressions]
                    ref = item.args.get("reference")
                    ref_table = ref.this.name
                    ref_cols = [c.name for c in ref.expressions]

                    constraints.append(
                        {
                            "type": "FOREIGN KEY",
                            "columns": cols,
                            "ref_table": ref_table,
                            "ref_columns": ref_cols,
                        }
                    )

                    self.lineage_edges.append(
                        {
                            "source": table_name,
                            "target": ref_table,
                            "type": "explicit",
                            "label": f"{','.join(cols)}->{','.join(ref_cols)}",
                        }
                    )

                # Indexes can be separate expressions in CREATE TABLE
                elif type(item).__name__ in (
                    "Index",
                    "Unique",
                    "UniqueColumnConstraint",
                    "IndexColumnConstraint",
                ):
                    is_unique = "Unique" in type(item).__name__
                    idx_name = item.this.name if item.this else f"idx_{table_name}_{len(indexes)}"
                    # Handle different sqlglot index structures
                    # Sometimes item.args['columns'] or item.expressions
                    idx_cols = []
                    if hasattr(item, "expressions") and item.expressions:
                        idx_cols = [
                            c.name for c in item.expressions if isinstance(c, exp.Identifier)
                        ]

                    # If empty, try checking params/args
                    if not idx_cols and hasattr(item, "args") and "columns" in item.args:
                        # item.args['columns'] might be a list of identifiers
                        cols_list = item.args["columns"]
                        if isinstance(cols_list, list):
                            idx_cols = [c.name for c in cols_list if hasattr(c, "name")]

                    indexes.append(
                        {
                            "name": idx_name,
                            "unique": is_unique,
                            "columns": idx_cols,
                            "type": "BTREE",  # Default for MySQL
                        }
                    )

        self.metadata[table_name] = {
            "name": table_name,
            "columns": columns,
            "constraints": constraints,
            "indexes": indexes,
        }

    def extract_view_metadata(self, view_exp: exp.Create):
        view_name = view_exp.this.name
        # Extract SELECT statement
        select_stmt = view_exp.expression

        dependencies = []
        if select_stmt:
            # Find all tables referenced
            for table in select_stmt.find_all(exp.Table):
                dependencies.append(table.name)
                self.lineage_edges.append(
                    {
                        "source": view_name,
                        "target": table.name,
                        "type": "view_dep",
                        "label": "selects_from",
                    }
                )

            # Column Lineage: Try to map output columns to source columns
            # Simple projection mapping
            if isinstance(select_stmt, exp.Select):
                for expression in select_stmt.expressions:
                    if isinstance(expression, exp.Alias):
                        target_col = expression.alias
                        source_col_exp = expression.this
                    else:
                        target_col = expression.name
                        source_col_exp = expression

                    # If source is a Column
                    if isinstance(source_col_exp, exp.Column):
                        source_table = source_col_exp.table
                        source_col = source_col_exp.name
                        if source_table:
                            self.column_lineage.append(
                                {
                                    "source_table": source_table,
                                    "source_col": source_col,
                                    "target_table": view_name,
                                    "target_col": target_col,
                                }
                            )
                    # If source is a Function (e.g. SUM(col))
                    elif isinstance(source_col_exp, exp.Func):
                        # Find columns inside function
                        for col in source_col_exp.find_all(exp.Column):
                            self.column_lineage.append(
                                {
                                    "source_table": col.table or "unknown",
                                    "source_col": col.name,
                                    "target_table": view_name,
                                    "target_col": target_col,
                                    "transform": source_col_exp.sql(),
                                }
                            )

        self.views[view_name] = {"name": view_name, "dependencies": list(set(dependencies))}

    def extract_trigger_metadata(self, stmt, raw_sql):
        # Basic extraction
        trigger_name = stmt.this.name
        self.triggers.append({"name": trigger_name})
        # Try to find table
        table_match = re.search(r"ON\s+`?(\w+)`?", raw_sql, re.IGNORECASE)
        if table_match:
            table_name = table_match.group(1)
            self.lineage_edges.append(
                {
                    "source": trigger_name,
                    "target": table_name,
                    "type": "trigger_on",
                    "label": "triggers_on",
                }
            )

    def extract_function_metadata(self, stmt, raw_sql):
        func_name = stmt.this.name
        self.functions.append({"name": func_name})

    def analyze_relationships(self):
        """
        Infer implicit relationships from comments.
        Pattern: "field_name" COMMENT '... table.field ...'
        """
        for table, meta in self.metadata.items():
            for col in meta["columns"]:
                comment = col.get("comment")
                if comment:
                    # Regex to find table.field patterns in comments
                    matches = re.findall(r"([a-zA-Z0-9_]+)\.([a-zA-Z0-9_]+)", comment)
                    for match in matches:
                        ref_table, ref_col = match
                        if ref_table in self.metadata:
                            self.implicit_edges.append(
                                {
                                    "source": table,
                                    "target": ref_table,
                                    "type": "implicit",
                                    "label": (f"{col['name']}->{ref_table}.{ref_col}"),
                                }
                            )
                            # Add to column lineage
                            self.column_lineage.append(
                                {
                                    "source_table": ref_table,
                                    "source_col": ref_col,
                                    "target_table": table,
                                    "target_col": col["name"],
                                    "type": "implicit_ref",
                                }
                            )

    def generate_artifacts(self):
        # 1. Metadata JSON
        full_metadata = {
            "tables": self.metadata,
            "views": self.views,
            "triggers": self.triggers,
            "functions": self.functions,
            "column_lineage": self.column_lineage,
        }
        with open("metadata.json", "w", encoding="utf-8") as f:
            json.dump(full_metadata, f, indent=2, ensure_ascii=False)

        # 2. Lineage Graphs
        self.generate_dot()
        self.generate_mermaid()

        # 3. Impact Analysis Report
        self.generate_impact_report()

    def generate_dot(self):
        dot_content = (
            "digraph DataLineage {\n"
            "  rankdir=LR;\n"
            "  node [shape=box, style=filled, fillcolor=lightblue];\n"
        )

        # Nodes
        for table in self.metadata:
            dot_content += f'  "{table}" [label="{table}", shape=box];\n'
        for view in self.views:
            dot_content += (
                f'  "{view}" [label="{view} (View)", ' "shape=ellipse, fillcolor=lightyellow];\n"
            )

        # Edges
        seen_edges = set()
        for edge in self.lineage_edges:
            key = f"{edge['source']}-{edge['target']}"
            if key not in seen_edges:
                style = "solid" if edge["type"] == "explicit" else "dashed"
                color = "black" if edge["type"] == "explicit" else "blue"
                dot_content += (
                    f'  "{edge["source"]}" -> "{edge["target"]}" '
                    f'[label="{edge["label"]}", style={style}, '
                    f"color={color}];\n"
                )
                seen_edges.add(key)

        for edge in self.implicit_edges:
            key = f"{edge['source']}-{edge['target']}"
            if key not in seen_edges:
                dot_content += (
                    f'  "{edge["source"]}" -> "{edge["target"]}" '
                    f'[label="{edge["label"]}", style=dotted, color=gray];\n'
                )
                seen_edges.add(key)

        dot_content += "}\n"

        with open("lineage.dot", "w", encoding="utf-8") as f:
            f.write(dot_content)

    def generate_mermaid(self):
        mermaid_content = "erDiagram\n"

        # Entities (Tables only to avoid clutter, or maybe Views too)
        for table, meta in self.metadata.items():
            mermaid_content += f"  {table} {{\n"
            # Limit columns to 10 for display
            for col in meta["columns"][:10]:
                col_type = col["type"].replace(" ", "_").replace(",", "_")
                mermaid_content += f"    {col_type} {col['name']}\n"
            if len(meta["columns"]) > 10:
                mermaid_content += "    ... ...\n"
            mermaid_content += "  }\n"

        # Relationships
        # Mermaid doesn't support labelled edges nicely in ER diagrams
        # without strict cardinality
        # We'll approximate
        for edge in self.lineage_edges + self.implicit_edges:
            # |o--|| or }o--||
            mermaid_content += (
                f"  {edge['target']} ||--o{{ {edge['source']} : " f"\"{edge['label']}\"\n"
            )

        with open("lineage.mmd", "w", encoding="utf-8") as f:
            f.write(mermaid_content)

    def generate_impact_report(self):
        report = "# Data Lineage & Impact Analysis Report\n\n"

        # 1. Summary
        report += "## 1. Schema Summary\n"
        report += f"- Total Tables: {len(self.metadata)}\n"
        report += f"- Total Views: {len(self.views)}\n"
        report += f"- Explicit Relationships: {len(self.lineage_edges)}\n"
        report += (
            f"- Implicit Relationships (inferred from comments): " f"{len(self.implicit_edges)}\n\n"
        )

        report += "## 2. High Risk Impact Analysis\n"
        report += (
            "The following fields are critical integration points. "
            "Modifications here require synchronized updates downstream.\n\n"
        )

        # Identify High Risk Tables (referenced by many)
        downstream_deps = {}  # Table -> [Downstream Tables]
        for edge in self.lineage_edges + self.implicit_edges:
            upstream = edge["target"]  # The referenced table
            downstream = edge["source"]  # The table having FK
            if upstream not in downstream_deps:
                downstream_deps[upstream] = []
            downstream_deps[upstream].append(f"{downstream} ({edge['label']})")

        # 2. Column Level Dependencies
        col_deps = {}  # Table.Col -> [Downstream Table.Col]
        for lineage in self.column_lineage:
            src_key = f"{lineage['source_table']}.{lineage['source_col']}"
            target_key = f"{lineage['target_table']}.{lineage['target_col']}"
            if src_key not in col_deps:
                col_deps[src_key] = []
            col_deps[src_key].append(target_key)

        # Report High Risk Tables (Many dependencies)
        sorted_tables = sorted(downstream_deps.items(), key=lambda x: len(x[1]), reverse=True)
        for table, deps in sorted_tables[:10]:  # Top 10
            report += f"### 🔴 Table: {table}\n"
            report += f"**Impact Score**: {len(deps)} downstream dependencies.\n"
            report += "**Affected Downstream Objects**:\n"
            for dep in deps[:5]:
                report += f"- {dep}\n"
            if len(deps) > 5:
                report += f"- ... and {len(deps)-5} more.\n"

            # Check for critical columns in this table
            table_meta = self.metadata.get(table)
            if table_meta:
                report += "\n**Critical Columns (High Lineage Impact)**:\n"
                for col in table_meta["columns"]:
                    col_key = f"{table}.{col['name']}"
                    if col_key in col_deps:
                        report += (
                            f"- `{col['name']}` ({col['type']}): "
                            f"Affects {len(col_deps[col_key])} "
                            f"downstream fields.\n"
                        )
                        # High risk warning
                        if "char" in col["type"].lower() or "decimal" in col["type"].lower():
                            report += (
                                f"  - ⚠️ **RISK**: Type modification "
                                f"(e.g. shortening length/precision) will "
                                f"truncate data in: "
                                f"{', '.join(col_deps[col_key][:3])}...\n"
                            )
            report += "\n---\n"

        with open("impact_analysis.md", "w", encoding="utf-8") as f:
            f.write(report)


if __name__ == "__main__":
    analyzer = SQLAnalyzer(r"d:\Code\KY\Dump20251005.sql")
    analyzer.run()
