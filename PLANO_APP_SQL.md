# Plano de implementação — App orientada ao modelo SQL

> Objetivo: criar **apenas o plano** para uma aplicação que responda ao modelo de dados SQL enviado pelo usuário.

## 1) Escopo funcional (MVP)

- Conectar em banco SQL existente (PostgreSQL/MySQL/SQLite).
- Ler metadados do schema (`information_schema` / introspecção SQLAlchemy).
- Expor interface com:
  - consulta por entidades (tabelas e relacionamentos);
  - filtros por campos-chave;
  - listagem e detalhamento de registros;
  - exportação CSV/Excel.
- Camada de “resposta ao modelo de dados”:
  - cada tela/refinamento é derivado do schema real;
  - validações e joins seguem FKs detectadas.

## 2) Requisitos de entrada

Para iniciar a implementação, precisamos de **um** destes artefatos:

1. Dump SQL (`schema.sql`) com `CREATE TABLE` e FKs; ou
2. Acesso read-only ao banco; ou
3. Dicionário de dados (tabelas, colunas, tipos, PK/FK).

## 3) Arquitetura proposta

### 3.1 Backend
- **FastAPI** para API REST.
- **SQLAlchemy 2.x** para conexão e introspecção.
- Módulo `schema_service` para:
  - mapear tabelas/colunas/FKs;
  - gerar metamodelo interno;
  - cachear metadados.

### 3.2 Frontend
- **React + TypeScript** (ou Streamlit no MVP rápido).
- UI dinâmica baseada no metamodelo:
  - menu por entidades;
  - formulário de filtro com base no tipo da coluna;
  - tabela com paginação e ordenação.

### 3.3 Segurança
- Usuário técnico com permissão de leitura para exploração.
- Segredos via `.env` (nunca hardcode).
- Query builder parametrizado (sem SQL concatenado em input livre).
- Auditoria de consultas críticas.

## 4) Modelo de domínio derivado do SQL

Pipeline de geração do modelo:

1. Introspecção do schema.
2. Normalização de tipos SQL para tipos da app (string, number, date, boolean).
3. Identificação de:
   - chaves primárias,
   - estrangeiras,
   - colunas de busca (nome, código, status, data).
4. Geração de configuração por entidade:
   - campos listáveis,
   - campos filtráveis,
   - relacionamentos navegáveis.

## 5) Endpoints (proposta)

- `GET /meta/entities` → lista entidades e relações.
- `GET /meta/entities/{entity}` → colunas, tipos, PK/FK.
- `POST /query/{entity}` → filtros, paginação, ordenação.
- `GET /record/{entity}/{id}` → detalhe por PK.
- `POST /export/{entity}` → exportação CSV/Excel.

## 6) Plano em fases

### Fase 0 — Descoberta (0,5–1 dia)
- Validar artefato de entrada (dump, acesso ou dicionário).
- Confirmar regras de negócio mínimas e entidades prioritárias.

### Fase 1 — Fundação técnica (1–2 dias)
- Setup do projeto (API + UI).
- Configuração de conexão segura com o banco.
- Introspecção do schema e endpoint `/meta/entities`.

### Fase 2 — Consulta dinâmica (2–3 dias)
- Query builder parametrizado por metamodelo.
- Listagem por entidade com paginação, filtro e ordenação.
- Tela de detalhe com relacionamento básico (FK).

### Fase 3 — Usabilidade e exportação (1–2 dias)
- Filtros avançados por tipo (intervalo de datas, enum, texto).
- Download CSV/Excel.
- Tratamento de erros amigável.

### Fase 4 — Qualidade e entrega (1 dia)
- Testes automatizados essenciais.
- Documentação de uso e operação.
- Checklist de segurança.

## 7) Critérios de aceite

- A app reflete automaticamente mudanças simples no schema (nova tabela/coluna).
- Usuário consegue consultar pelo menos 3 entidades principais com filtros.
- Relações FK aparecem na navegação (detalhe com referência).
- Exportação de resultados funciona.
- Tempo de resposta p95 aceitável com paginação (definir meta após volume real).

## 8) Riscos e mitigação

- **Schema inconsistente**: criar camada de mapeamento manual opcional.
- **Volume alto de dados**: paginação server-side + índices.
- **Permissões limitadas**: alinhar usuário read-only e grants antecipadamente.
- **Tipos não padronizados**: fallback para render genérico e ajustes por entidade.

## 9) Entregáveis

- Documento de arquitetura.
- API de metadados + consulta dinâmica.
- Interface de exploração orientada ao schema.
- Guia de operação (conexão, variáveis e troubleshooting).

## 10) Próximo passo imediato

Assim que você reenviar o **modelo SQL** (ou dump), eu transformo este plano em backlog técnico com:
- histórias priorizadas,
- estimativas por tarefa,
- e definição exata das telas com base nas suas tabelas reais.
