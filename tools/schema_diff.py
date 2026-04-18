import json
import os
import sys

from typing import Any
sys.path.insert(0, os.path.dirname(__file__))

from rebuild_metadata import TableDef, parse_pdm_schema


def load_metadata_json(path: str) -> dict[str, Any]:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def diff_schema(pdm_tables: dict[str, TableDef], metadata: dict[str, Any]) -> dict[str, Any]:
    meta_tables: dict[str, Any] = metadata.get("tables", {}) or {}
    meta_names = {k.lower() for k in meta_tables.keys()}
    pdm_names = set(pdm_tables.keys())

    missing_in_metadata = sorted(pdm_names - meta_names)
    extra_in_metadata = sorted(meta_names - pdm_names)

    column_diff: dict[str, Any] = {}
    for name in sorted(pdm_names & meta_names):
        pdm_cols = {c.name.lower() for c in pdm_tables[name].columns}
        meta_cols = {c.get("name", "").lower() for c in (meta_tables.get(name) or {}).get("columns", [])}
        only_in_pdm = sorted(pdm_cols - meta_cols)
        only_in_meta = sorted(meta_cols - pdm_cols)
        if only_in_pdm or only_in_meta:
            column_diff[name] = {"missing_in_metadata": only_in_pdm, "extra_in_metadata": only_in_meta}

    return {
        "summary": {
            "pdm_table_count": len(pdm_names),
            "metadata_table_count": len(meta_names),
            "missing_table_count": len(missing_in_metadata),
            "extra_table_count": len(extra_in_metadata),
            "tables_with_column_diff_count": len(column_diff),
        },
        "missing_in_metadata": missing_in_metadata,
        "extra_in_metadata": extra_in_metadata,
        "column_diff": column_diff,
    }


def main() -> None:
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    pdm_path = os.path.join(repo_root, "PDMshema.sql")
    metadata_path = os.path.join(repo_root, "metadata.json")
    out_path = os.path.join(repo_root, "schema_diff_report.json")

    if not os.path.exists(pdm_path):
        raise SystemExit(f"Missing file: {pdm_path}")
    if not os.path.exists(metadata_path):
        raise SystemExit(f"Missing file: {metadata_path}")

    pdm_tables = parse_pdm_schema(pdm_path)
    metadata = load_metadata_json(metadata_path)
    report = diff_schema(pdm_tables, metadata)

    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(report, f, ensure_ascii=False, indent=2)

    s = report["summary"]
    print(json.dumps(s, ensure_ascii=False))
    print(f"report_written={out_path}")


if __name__ == "__main__":
    main()
