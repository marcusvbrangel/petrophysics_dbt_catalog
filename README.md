# Petrophysics Data Catalog com dbt + DuckDB

Este projeto transforma logs sintéticos de 28 poços em um pequeno catálogo de dados petrofísico usando:

- CSV como entrada
- DuckDB como engine analítica
- dbt como pipeline, documentação, testes e lineage
- Parquet como saída particionada por poço e zona

## 1. Instalação

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## 2. Configurar profile do dbt

Copie o exemplo:

```bash
mkdir -p ~/.dbt
cp profiles.yml.example ~/.dbt/profiles.yml
```

## 3. Gerar dados sintéticos e carregar DuckDB

```bash
python src/01_generate_synthetic_logs.py
python src/02_load_raw_to_duckdb.py
```

## 4. Rodar dbt

```bash
dbt debug
dbt run
dbt test
```

## 5. Gerar documentação para humanos

```bash
dbt docs generate
dbt docs serve
```

Acesse o endereço exibido pelo comando. Você verá:

- modelos/tabelas
- descrições em linguagem humana
- colunas
- tipos de dados
- testes de qualidade
- lineage entre staging, intermediate, marts e quality

## 6. Exportar Parquet particionado

Depois do `dbt run`, execute:

```bash
python src/03_export_mart_to_parquet.py
```

Saída:

```text
data/parquet/petrophysics/well_id=.../zone=.../*.parquet
```

## Modelos principais

| Modelo | Função |
|---|---|
| `stg_raw_logs` | Padroniza os logs crus |
| `int_petrophysics` | Calcula propriedades petrofísicas, elásticas e hidráulicas |
| `mart_zone_quality` | Agrega indicadores por zona |
| `mart_well_zone_quality` | Agrega indicadores por poço e zona |
| `qc_invalid_petrophysics` | Lista registros suspeitos ou inválidos |

## Ideia central

Este projeto não é apenas SQL. Ele transforma regras físicas e conhecimento petrofísico em documentação, testes e rastreabilidade.

O `dbt docs` vira um catálogo navegável para humanos, enquanto `dbt test` protege o pipeline contra erros como valores fora de faixa, unidades erradas, saturações inválidas e propriedades elásticas não físicas.
# petrophysics_dbt_catalog
