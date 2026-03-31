# App de exploração de base de dados

Este projeto inclui uma app em **Streamlit** para você montar e explorar sua base de dados SQL.

## O que a app faz

- Conecta em banco via URL SQLAlchemy (SQLite, PostgreSQL, MySQL etc.).
- Cria uma base SQLite de exemplo para testes.
- Executa arquivo `.sql` para criar/popular sua base.
- Importa `.csv` para uma tabela escolhida.
- Lista tabelas e mostra prévia dos dados com limite de linhas.
- Permite baixar a prévia em CSV.

## Requisitos

- Python 3.10+

## Instalação

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Executar app

```bash
streamlit run app.py
```

## Gerar resumo do dump SQL

Se você já tiver enviado/recebido um dump SQL no repositório, gere um resumo automático do modelo:

```bash
python scripts/analisar_dump.py  # usa ./pars_template.sql por padrão
# ou
python scripts/analisar_dump.py caminho/do/dump.sql
```

Esse comando cria o arquivo `ANALISE_DUMP.md` com tabelas, colunas, PKs e FKs detectadas.

> Observação: sem argumento, o script tenta `pars_template.sql`; se não existir e houver apenas um `.sql` no repo, ele usa esse arquivo automaticamente.

## Exemplos de URL

- SQLite local: `sqlite:///example.db`
- PostgreSQL: `postgresql+psycopg://usuario:senha@localhost:5432/meu_banco`
- MySQL: `mysql+pymysql://usuario:senha@localhost:3306/meu_banco`
