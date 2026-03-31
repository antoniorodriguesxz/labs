#!/usr/bin/env python3
"""Gera um resumo do modelo de dados a partir de um dump SQL.

Uso:
  python scripts/analisar_dump.py [caminho/do/dump.sql]

Sem argumento:
- usa `pars_template.sql` na raiz, se existir;
- senão tenta descobrir automaticamente `.sql` no repositório.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

DEFAULT_DUMP = Path("pars_template.sql")

TABLE_RE = re.compile(
    r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?[`\"]?([\w\.]+)[`\"]?\s*\((.*?)\);",
    flags=re.IGNORECASE | re.DOTALL,
)

FK_RE = re.compile(
    r"FOREIGN\s+KEY\s*\(([^\)]+)\)\s+REFERENCES\s+[`\"]?([\w\.]+)[`\"]?\s*\(([^\)]+)\)",
    flags=re.IGNORECASE,
)


def split_columns(block: str) -> list[str]:
    items: list[str] = []
    current: list[str] = []
    depth = 0
    for ch in block:
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth = max(0, depth - 1)
        if ch == "," and depth == 0:
            piece = "".join(current).strip()
            if piece:
                items.append(piece)
            current = []
        else:
            current.append(ch)
    tail = "".join(current).strip()
    if tail:
        items.append(tail)
    return items


def parse_dump(sql: str) -> dict[str, dict]:
    tables: dict[str, dict] = {}
    for match in TABLE_RE.finditer(sql):
        table_name = match.group(1)
        block = match.group(2)
        entries = split_columns(block)

        columns: list[dict[str, str]] = []
        pks: list[str] = []
        fks: list[dict[str, str]] = []

        for entry in entries:
            normalized = entry.strip()
            upper = normalized.upper()

            if upper.startswith("PRIMARY KEY"):
                cols = re.findall(r"\((.*?)\)", normalized)
                if cols:
                    pks.extend([c.strip().strip('`"') for c in cols[0].split(",")])
                continue

            fk_match = FK_RE.search(normalized)
            if fk_match:
                fk_cols = fk_match.group(1).strip().replace("`", "").replace('"', "")
                ref_table = fk_match.group(2)
                ref_cols = fk_match.group(3).strip().replace("`", "").replace('"', "")
                fks.append({"columns": fk_cols, "ref_table": ref_table, "ref_columns": ref_cols})
                continue

            token = normalized.split()
            if len(token) >= 2 and upper.split()[0] not in {"CONSTRAINT", "UNIQUE", "CHECK", "KEY", "INDEX"}:
                col_name = token[0].strip('`"')
                col_type = token[1]
                columns.append({"name": col_name, "type": col_type})
                if "PRIMARY KEY" in upper:
                    pks.append(col_name)

        tables[table_name] = {"columns": columns, "primary_keys": sorted(set(pks)), "foreign_keys": fks}

    return tables


def render_markdown(tables: dict[str, dict], source: Path) -> str:
    lines: list[str] = []
    lines.append("# Resumo do modelo de dados")
    lines.append("")
    lines.append(f"Arquivo analisado: `{source}`")
    lines.append("")
    lines.append(f"Total de tabelas detectadas: **{len(tables)}**")
    lines.append("")

    for table, info in sorted(tables.items()):
        lines.append(f"## `{table}`")
        lines.append("")
        lines.append("### Colunas")
        for col in info["columns"]:
            lines.append(f"- `{col['name']}` ({col['type']})")
        if not info["columns"]:
            lines.append("- _Nenhuma coluna identificada._")

        lines.append("")
        lines.append("### Chave primária")
        if info["primary_keys"]:
            for pk in info["primary_keys"]:
                lines.append(f"- `{pk}`")
        else:
            lines.append("- _Não identificada._")

        lines.append("")
        lines.append("### Chaves estrangeiras")
        if info["foreign_keys"]:
            for fk in info["foreign_keys"]:
                lines.append(
                    f"- (`{fk['columns']}`) -> `{fk['ref_table']}` (`{fk['ref_columns']}`)"
                )
        else:
            lines.append("- _Nenhuma FK detectada._")
        lines.append("")

    return "\n".join(lines)


def find_sql_candidates() -> list[Path]:
    return sorted(
        p for p in Path(".").rglob("*.sql") if ".git" not in p.parts and p.is_file()
    )


def resolve_source_from_default() -> Path | None:
    if DEFAULT_DUMP.exists():
        return DEFAULT_DUMP

    candidates = find_sql_candidates()
    if len(candidates) == 1:
        print(f"`pars_template.sql` não encontrado. Usando dump detectado automaticamente: {candidates[0]}")
        return candidates[0]

    if len(candidates) > 1:
        print("`pars_template.sql` não encontrado e há múltiplos dumps SQL no repositório:")
        for candidate in candidates:
            print(f"- {candidate}")
        print("Passe o caminho desejado explicitamente: python scripts/analisar_dump.py caminho/do/arquivo.sql")
        return None

    print("Arquivo não encontrado: pars_template.sql")
    print("Nenhum arquivo .sql foi detectado no repositório.")
    print("Dica: adicione o dump ou passe o caminho no comando.")
    return None


def main() -> int:
    source = Path(sys.argv[1]) if len(sys.argv) > 1 else resolve_source_from_default()

    if source is None:
        return 2

    if not source.exists():
        print(f"Arquivo não encontrado: {source}")
        return 2

    sql = source.read_text(encoding="utf-8", errors="ignore")
    tables = parse_dump(sql)
    out = Path("ANALISE_DUMP.md")
    out.write_text(render_markdown(tables, source), encoding="utf-8")

    print(f"Resumo gerado em: {out}")
    print(f"Tabelas detectadas: {len(tables)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
