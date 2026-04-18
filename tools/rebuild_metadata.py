import json
import os
import re
import shutil
from dataclasses import dataclass
from typing import Any


@dataclass(frozen=True)
class ColumnDef:
    name: str
    type: str
    nullable: bool
    default: str | None
    comment: str | None


@dataclass
class TableDef:
    name: str
    comment: str | None
    columns: list[ColumnDef]
    primary_key: list[str]
    indexes: list[dict[str, Any]]


_create_table_re = re.compile(r"^\s*CREATE\s+TABLE\s+`(?P<name>[^`]+)`", re.IGNORECASE)
_end_table_re = re.compile(r"^\s*\)\s*ENGINE\s*=", re.IGNORECASE)

_col_re = re.compile(
    r"^\s*`(?P<name>[^`]+)`\s+"
    r"(?P<type>.+?)\s+"
    r"(?P<nullability>NOT\s+NULL|NULL)\s+"
    r"DEFAULT\s+(?P<default>[^ ]+)"
    r"(?:\s+COMMENT\s+'(?P<comment>[^']*)')?"
    r"\s*,?\s*$",
    re.IGNORECASE,
)
_col_re_no_default = re.compile(
    r"^\s*`(?P<name>[^`]+)`\s+"
    r"(?P<type>.+?)\s+"
    r"(?P<nullability>NOT\s+NULL|NULL)"
    r"(?:\s+COMMENT\s+'(?P<comment>[^']*)')?"
    r"\s*,?\s*$",
    re.IGNORECASE,
)

_pk_re = re.compile(r"^\s*PRIMARY\s+KEY\s*\((?P<cols>[^)]+)\)", re.IGNORECASE)
_idx_re = re.compile(
    r"^\s*(?P<unique>UNIQUE\s+)?INDEX\s+`(?P<name>[^`]+)`\s*\((?P<cols>[^)]+)\)\s*(?:USING\s+(?P<type>\w+))?\s*,?\s*$",
    re.IGNORECASE,
)
_table_comment_re = re.compile(r"COMMENT\s*=\s*'(?P<comment>[^']*)'", re.IGNORECASE)


def _split_cols(cols_raw: str) -> list[str]:
    parts = []
    for part in cols_raw.split(","):
        p = part.strip()
        if p.startswith("`") and p.endswith("`"):
            p = p[1:-1]
        parts.append(p)
    return [p for p in parts if p]


def parse_pdm_schema(sql_path: str) -> dict[str, TableDef]:
    tables: dict[str, TableDef] = {}
    current: TableDef | None = None
    in_table = False

    with open(sql_path, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            if not in_table:
                m = _create_table_re.match(line)
                if not m:
                    continue
                name = m.group("name").strip()
                current = TableDef(
                    name=name,
                    comment=None,
                    columns=[],
                    primary_key=[],
                    indexes=[],
                )
                in_table = True
                continue

            if _end_table_re.match(line):
                if current:
                    mc = _table_comment_re.search(line)
                    if mc:
                        current.comment = mc.group("comment")
                    tables[current.name.lower()] = current
                current = None
                in_table = False
                continue

            if not current:
                continue

            mc = _col_re.match(line)
            if mc:
                col_name = mc.group("name").strip()
                col_type = mc.group("type").strip()
                nullability = mc.group("nullability").strip().upper()
                nullable = nullability == "NULL"
                default = mc.group("default")
                default = None if default is None else default.strip()
                comment = mc.group("comment")
                current.columns.append(
                    ColumnDef(
                        name=col_name,
                        type=col_type,
                        nullable=nullable,
                        default=default,
                        comment=comment,
                    )
                )
                continue

            mc2 = _col_re_no_default.match(line)
            if mc2:
                col_name = mc2.group("name").strip()
                col_type = mc2.group("type").strip()
                nullability = mc2.group("nullability").strip().upper()
                nullable = nullability == "NULL"
                comment = mc2.group("comment")
                current.columns.append(
                    ColumnDef(
                        name=col_name,
                        type=col_type,
                        nullable=nullable,
                        default=None,
                        comment=comment,
                    )
                )
                continue

            mpk = _pk_re.match(line)
            if mpk:
                current.primary_key = _split_cols(mpk.group("cols"))
                continue

            midx = _idx_re.match(line)
            if midx:
                current.indexes.append(
                    {
                        "name": midx.group("name"),
                        "unique": bool(midx.group("unique")),
                        "columns": _split_cols(midx.group("cols")),
                        "type": (midx.group("type") or "").upper() or None,
                    }
                )

    return tables


def build_metadata(pdm_tables: dict[str, TableDef]) -> dict[str, Any]:
    tables_out: dict[str, Any] = {}
    for table_name, t in sorted(pdm_tables.items(), key=lambda kv: kv[0]):
        tables_out[table_name] = {
            "name": t.name,
            "comment": t.comment,
            "columns": [
                {
                    "name": c.name,
                    "type": c.type,
                    "nullable": c.nullable,
                    "default": c.default,
                    "comment": c.comment,
                }
                for c in t.columns
            ],
            "constraints": [
                {
                    "type": "PRIMARY KEY",
                    "columns": t.primary_key,
                }
            ],
            "indexes": t.indexes,
        }
    return {"tables": tables_out}


def main() -> None:
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    pdm_path = os.path.join(repo_root, "PDMshema.sql")
    out_path = os.path.join(repo_root, "metadata.json")
    backup_path = os.path.join(repo_root, "metadata.json.bak")

    if not os.path.exists(pdm_path):
        raise SystemExit(f"Missing file: {pdm_path}")

    pdm_tables = parse_pdm_schema(pdm_path)
    metadata = build_metadata(pdm_tables)

    if os.path.exists(out_path):
        shutil.copyfile(out_path, backup_path)

    tmp_path = out_path + ".tmp"
    with open(tmp_path, "w", encoding="utf-8") as f:
        json.dump(metadata, f, ensure_ascii=False, indent=2)

    os.replace(tmp_path, out_path)
    print(json.dumps({"tables": len(metadata["tables"])}, ensure_ascii=False))
    print(f"written={out_path}")
    if os.path.exists(backup_path):
        print(f"backup={backup_path}")


if __name__ == "__main__":
    main()

