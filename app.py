from __future__ import annotations

import re
from pathlib import Path

import pandas as pd
import streamlit as st
from sqlalchemy import create_engine, inspect, text
from sqlalchemy.exc import SQLAlchemyError

st.set_page_config(page_title="Explorador de Base de Dados", page_icon="🗄️", layout="wide")

st.title("🗄️ App para a sua base de dados")
st.caption(
    "Conecte em qualquer banco SQL (via SQLAlchemy), crie sua base com script SQL e explore os dados em poucos cliques."
)

with st.sidebar:
    st.header("Conexão")
    db_url = st.text_input(
        "URL do banco",
        value="sqlite:///example.db",
        help="Ex.: postgresql+psycopg://usuario:senha@host:5432/db",
    )
    row_limit = st.slider("Limite de linhas", min_value=10, max_value=500, value=100, step=10)


def bootstrap_example_database(engine) -> None:
    with engine.begin() as conn:
        conn.execute(
            text(
                """
                CREATE TABLE IF NOT EXISTS clientes (
                    id INTEGER PRIMARY KEY,
                    nome TEXT NOT NULL,
                    email TEXT NOT NULL,
                    cidade TEXT NOT NULL
                )
                """
            )
        )
        conn.execute(
            text(
                """
                CREATE TABLE IF NOT EXISTS pedidos (
                    id INTEGER PRIMARY KEY,
                    cliente_id INTEGER NOT NULL,
                    produto TEXT NOT NULL,
                    valor NUMERIC NOT NULL,
                    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
                )
                """
            )
        )
        conn.execute(text("DELETE FROM pedidos"))
        conn.execute(text("DELETE FROM clientes"))
        conn.execute(
            text(
                """
                INSERT INTO clientes (id, nome, email, cidade) VALUES
                (1, 'Ana', 'ana@empresa.com', 'São Paulo'),
                (2, 'Bruno', 'bruno@empresa.com', 'Rio de Janeiro'),
                (3, 'Carla', 'carla@empresa.com', 'Curitiba')
                """
            )
        )
        conn.execute(
            text(
                """
                INSERT INTO pedidos (id, cliente_id, produto, valor) VALUES
                (1, 1, 'Plano Pro', 99.90),
                (2, 1, 'Suporte Premium', 49.90),
                (3, 2, 'Plano Starter', 39.90)
                """
            )
        )


def run_sql_script(engine, sql_script: str) -> None:
    with engine.begin() as conn:
        conn.connection.executescript(sql_script)


def safe_table_name(raw_name: str) -> str | None:
    cleaned = raw_name.strip().lower()
    if not cleaned:
        return None
    if not re.match(r"^[a-zA-Z_][a-zA-Z0-9_]*$", cleaned):
        return None
    return cleaned


def import_csv_to_table(engine, csv_file, table_name: str) -> int:
    dataframe = pd.read_csv(csv_file)
    dataframe.to_sql(table_name, engine, if_exists="replace", index=False)
    return len(dataframe)


setup_tab, explore_tab = st.tabs(["Configurar base", "Explorar dados"])

with setup_tab:
    st.subheader("1) Criar base de exemplo")
    if st.button("Criar base SQLite de exemplo", use_container_width=True):
        try:
            bootstrap_example_database(create_engine("sqlite:///example.db"))
            st.success("Base de exemplo criada/atualizada com sucesso em example.db")
        except SQLAlchemyError as exc:
            st.error(f"Não foi possível criar a base de exemplo: {exc}")

    st.divider()
    st.subheader("2) Criar sua base via script SQL")
    uploaded_sql = st.file_uploader("Envie um arquivo .sql", type=["sql"])

    if uploaded_sql is not None:
        if st.button("Executar script SQL neste banco", type="primary", use_container_width=True):
            try:
                engine = create_engine(db_url)
                script_text = uploaded_sql.getvalue().decode("utf-8")
                run_sql_script(engine, script_text)
                st.success("Script SQL executado com sucesso.")
            except (UnicodeDecodeError, SQLAlchemyError) as exc:
                st.error(f"Falha ao executar script SQL: {exc}")

    st.divider()
    st.subheader("3) Importar CSV para uma tabela")
    uploaded_csv = st.file_uploader("Envie um arquivo .csv", type=["csv"])
    table_name_input = st.text_input("Nome da tabela de destino", value="minha_tabela")

    if uploaded_csv is not None:
        if st.button("Importar CSV", use_container_width=True):
            safe_name = safe_table_name(table_name_input)
            if safe_name is None:
                st.error("Nome de tabela inválido. Use apenas letras, números e underscore.")
            else:
                try:
                    engine = create_engine(db_url)
                    rows = import_csv_to_table(engine, uploaded_csv, safe_name)
                    st.success(f"CSV importado para a tabela '{safe_name}' ({rows} linhas).")
                except SQLAlchemyError as exc:
                    st.error(f"Falha ao importar CSV: {exc}")

with explore_tab:
    st.subheader("Exploração")
    try:
        engine = create_engine(db_url)
        inspector = inspect(engine)
        tables = inspector.get_table_names()
    except SQLAlchemyError as exc:
        st.error(f"Falha ao conectar ao banco: {exc}")
        st.stop()

    if not tables:
        st.info("Nenhuma tabela encontrada nessa conexão. Use a aba 'Configurar base'.")
        st.stop()

    selected_table = st.selectbox("Selecione uma tabela", tables)

    try:
        query = text(f'SELECT * FROM "{selected_table}" LIMIT :limit')
        dataframe = pd.read_sql(query, engine, params={"limit": row_limit})

        st.dataframe(dataframe, use_container_width=True)

        col1, col2 = st.columns(2)
        with col1:
            st.metric("Colunas", len(dataframe.columns))
        with col2:
            st.metric("Linhas exibidas", len(dataframe))

        csv_preview = dataframe.to_csv(index=False).encode("utf-8")
        st.download_button(
            "Baixar prévia em CSV",
            data=csv_preview,
            file_name=f"preview_{selected_table}.csv",
            mime="text/csv",
        )
    except SQLAlchemyError as exc:
        st.error(f"Erro ao consultar a tabela {selected_table}: {exc}")

st.caption(
    "Dica: se você já tiver o esquema da sua base, envie um .sql na aba 'Configurar base' para gerar as tabelas automaticamente."
)

if Path("example.db").exists():
    st.caption("Arquivo local detectado: example.db")
