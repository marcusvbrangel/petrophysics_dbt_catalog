# Anexo Opcional - Projeto Petrophysics com dbt Core

## Objetivo deste anexo

Este anexo nao faz parte da trilha principal do treinamento.

Ele existe apenas como referencia opcional para aplicar os conceitos do curso em um projeto real que ja esta neste repositorio.

Se voce ainda estiver aprendendo o basico de `dbt Core`, faca primeiro o treinamento principal em [TREINAMENTO_DBT_CORE_COMPLETO.md](TREINAMENTO_DBT_CORE_COMPLETO.md).

## O que este projeto faz

Resumo do objetivo:

- gerar logs sinteticos de 28 pocos;
- carregar esses dados em DuckDB;
- transformar logs em propriedades petrofisicas;
- produzir tabelas analiticas;
- auditar comportamentos fisicamente suspeitos;
- exportar o resultado para Parquet particionado.

## Pipeline logico do projeto

```text
src/01_generate_synthetic_logs.py
  -> data/raw/synthetic_logs_28_wells.csv
  -> src/02_load_raw_to_duckdb.py
  -> tabela raw_logs
  -> models/staging/stg_raw_logs.sql
  -> models/intermediate/int_petrophysics.sql
  -> models/marts/mart_zone_quality.sql
  -> models/marts/mart_well_zone_quality.sql
  -> models/quality/qc_invalid_petrophysics.sql
  -> src/03_export_mart_to_parquet.py
  -> data/parquet/petrophysics/...
```

## Estrutura central

Arquivos principais:

- `dbt_project.yml`
- `profiles.yml.example`
- `models/staging/stg_raw_logs.sql`
- `models/intermediate/int_petrophysics.sql`
- `models/marts/mart_zone_quality.sql`
- `models/marts/mart_well_zone_quality.sql`
- `models/quality/qc_invalid_petrophysics.sql`
- `models/schema.yml`
- `macros/range_between.sql`
- `src/01_generate_synthetic_logs.py`
- `src/02_load_raw_to_duckdb.py`
- `src/03_export_mart_to_parquet.py`
- `analyses/best_zones_by_reservoir_quality.sql`
- `analyses/best_wells_res_a.sql`

## O que o `dbt_project.yml` mostra

O projeto define:

- nome do projeto: `petrophysics_catalog`
- profile: `petrophysics_catalog`
- caminhos de `models`, `analyses`, `tests` e `macros`
- materializacao:
- `staging` como `view`
- `intermediate` como `table`
- `marts` como `table`
- `quality` como `table`

Interpretacao:

- staging e leve e pode ficar como view;
- a parte petrofisica central ja merece materializacao fisica em tabela;
- marts e auditoria tambem ficam materializados para consulta simples.

## O que o `profiles.yml.example` mostra

Ele aponta para:

```yaml
petrophysics_catalog:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: data/reservoir.duckdb
      threads: 4
```

Traducao:

- o banco e local;
- o arquivo do banco fica em `data/reservoir.duckdb`;
- o projeto nao depende de cloud para funcionar.

## Como preparar o ambiente deste repositorio

No terminal do VS Code, dentro deste projeto:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
mkdir -p ~/.dbt
cp profiles.yml.example ~/.dbt/profiles.yml
dbt debug
```

Explicacao:

- o `requirements.txt` ja traz `dbt-core`, `dbt-duckdb`, `duckdb`, `pandas`, `numpy` e `pyarrow`;
- o `profiles.yml.example` e a base do profile real;
- `dbt debug` confirma que tudo esta pronto.

## Gerando o dado bruto

Execute:

```bash
python src/01_generate_synthetic_logs.py
```

O que esse script faz:

- fixa uma semente aleatoria com `np.random.seed(42)`, para repetibilidade;
- gera 28 pocos;
- cobre profundidades de `2500.0` ate `3100.0` com passo `0.5`;
- classifica cada profundidade em zonas geologicas;
- gera curvas sinteticas como `gr_api`, `nphi_vv`, `rhob_gcc`, `dt_usft`, `dts_usft` e `rt_ohmm`;
- grava o CSV em `data/raw/synthetic_logs_28_wells.csv`.

Observacao importante:

- o passo e `0.5` metro;
- o intervalo total e de 600 metros;
- isso produz `1201` amostras por poco;
- com 28 pocos, o bruto esperado e `33628` linhas.

## Entendendo a logica das zonas no gerador

O script separa quatro zonas:

- `SEAL_TOP`
- `RES_A`
- `SEAL_MID`
- `RES_B`

Essas zonas orientam a simulacao:

- zonas de selo usam `gr` maior e `phi` menor;
- zonas reservatorio usam `gr` menor e `phi` maior;
- a resistividade de base tambem muda por zona.

Ou seja:

- o dado sintetico ja nasce com um comportamento geologico plausivel para estudo.

## Carregando o bruto no DuckDB

Execute:

```bash
python src/02_load_raw_to_duckdb.py
```

O que esse script faz:

- conecta em `data/reservoir.duckdb`;
- le `data/raw/synthetic_logs_28_wells.csv`;
- cria ou substitui a tabela `raw_logs`.

Detalhe didatico:

- este projeto nao usa `source()` para `raw_logs`;
- o model de staging le diretamente a tabela `raw_logs`.

Isso funciona. Em um projeto mais formal, uma boa evolucao seria declarar essa origem em `sources.yml`.

## Lendo o staging

Arquivo:

- `models/staging/stg_raw_logs.sql`

Conteudo essencial:

```sql
select
    cast(well_id as varchar) as well_id,
    cast(md_m as double) as md_m,
    cast(zone as varchar) as zone,
    cast(gr_api as double) as gr_api,
    cast(rhob_gcc as double) as rhob_gcc,
    cast(nphi_vv as double) as nphi_vv,
    cast(dt_usft as double) as dt_usft,
    cast(dts_usft as double) as dts_usft,
    cast(rt_ohmm as double) as rt_ohmm
from raw_logs
```

Interpretacao:

- esse staging e enxuto;
- faz tipagem e estabiliza a entrada;
- prepara a camada seguinte sem esconder a origem.

## Lendo o model central

Arquivo:

- `models/intermediate/int_petrophysics.sql`

Esse e o coracao do projeto.

Ele usa varias CTEs:

`base`

- le `stg_raw_logs`;
- calcula `vp_ms`, `vs_ms`, `rho_kgm3`, `phi_nphi` e `vsh_raw`.

`clean`

- limita `vsh` entre `0` e `1`;
- limita `phi` entre `0.01` e `0.35`.

`elastic`

- calcula modulo de cisalhamento;
- calcula modulo volumetrico;
- calcula `vpvs_ratio`.

`elastic2`

- calcula `young_modulus_pa`;
- calcula `poisson_ratio`;
- calcula compressibilidade proxy;
- calcula impedancias.

`fluid`

- estima `sw_raw`;
- estima `perm_md_raw`.

`final`

- limita saturacoes;
- deriva `so = 1 - sw`;
- garante permeabilidade minima positiva;
- converte permeabilidade para `m2`;
- calcula `biot_alpha_raw`;
- calcula difusividade hidraulica.

Licao central:

- um model bom nao e so uma consulta que roda;
- ele organiza o raciocinio em etapas legiveis.

## Rodando o projeto por partes

Rodar apenas o staging:

```bash
dbt run --select stg_raw_logs
```

Rodar o model central e seus dependentes:

```bash
dbt run --select int_petrophysics+
```

Esse comando pega:

- `int_petrophysics`
- `mart_zone_quality`
- `mart_well_zone_quality`
- `qc_invalid_petrophysics`

## Lendo os marts

`mart_zone_quality.sql`

- agrega por zona;
- calcula medias de porosidade, saturacoes, permeabilidade, Vsh e propriedades elasticas;
- ordena por `avg_phi desc, avg_perm_md desc`.

`mart_well_zone_quality.sql`

- agrega por poco e zona;
- calcula topo e base em profundidade;
- calcula medias por combinacao `well_id + zone`.

Em linguagem de negocio:

- o primeiro mart responde qual zona parece melhor em media;
- o segundo responde em qual poco e em qual zona o comportamento foi melhor.

## Lendo o model de auditoria

Arquivo:

- `models/quality/qc_invalid_petrophysics.sql`

Ele marca problemas como:

- `PHI_OUT_OF_RANGE`
- `VSH_OUT_OF_RANGE`
- `SW_OUT_OF_RANGE`
- `SO_OUT_OF_RANGE`
- `PERM_NOT_POSITIVE`
- `POISSON_OUT_OF_RANGE`
- `BIOT_OUT_OF_RANGE`
- `SONIC_INVALID`
- `RHOB_OUT_OF_RANGE`
- `GR_OUT_OF_RANGE`

Licao importante:

- nem todo problema precisa impedir a analise;
- em alguns contextos, materializar a anomalia e melhor do que escondela.

## Lendo os testes

O projeto usa testes como:

- `not_null`
- `accepted_values`
- `unique`
- `range_between`

O teste `range_between` e customizado e vive em `macros/range_between.sql`.

Conteudo resumido:

```sql
{% test range_between(model, column_name, min_value, max_value) %}

select *
from {{ model }}
where {{ column_name }} < {{ min_value }}
   or {{ column_name }} > {{ max_value }}
   or {{ column_name }} is null

{% endtest %}
```

Isso mostra bem a ideia de teste generico reutilizavel.

## Rodando os testes

```bash
dbt test
```

Nuance importante deste projeto:

- o `README.md` deixa claro que o fluxo principal e `dbt run` e `dbt test` separados;
- a ideia e nao travar a exploracao por causa de um teste que aponta uma hipotese ruim;
- nesse contexto, teste falhando pode ser sinal analitico, nao apenas erro operacional.

## Gerando documentacao local

```bash
dbt docs generate
dbt docs serve
```

Observe:

- a cadeia `stg_raw_logs -> int_petrophysics -> marts/quality`;
- as descricoes das colunas em `models/schema.yml`;
- os testes associados a cada campo.

## Exportando o resultado para Parquet

Execute:

```bash
python src/03_export_mart_to_parquet.py
```

O que esse script faz:

1. localiza o executavel `dbt` no mesmo ambiente Python ativo;
2. roda `dbt run --select +int_petrophysics`;
3. conecta no DuckDB;
4. exporta `int_petrophysics` para `data/parquet/petrophysics`;
5. particiona por `well_id` e `zone`.

## O papel das consultas em `analyses/`

Arquivos:

- `analyses/best_zones_by_reservoir_quality.sql`
- `analyses/best_wells_res_a.sql`

Esses arquivos servem para:

- consultas exploratorias;
- perguntas analiticas ad hoc;
- apoio a estudo e interpretacao.

Em outras palavras:

- `models/` cria a estrutura reutilizavel;
- `analyses/` responde perguntas especificas sobre essa estrutura.

## Sequencia opcional de execucao

Se voce quiser percorrer este projeto do inicio ao fim:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
mkdir -p ~/.dbt
cp profiles.yml.example ~/.dbt/profiles.yml
python src/01_generate_synthetic_logs.py
python src/02_load_raw_to_duckdb.py
dbt debug
dbt run --select stg_raw_logs
dbt run --select int_petrophysics+
dbt test
dbt docs generate
python src/03_export_mart_to_parquet.py
```

## Como usar este anexo corretamente

Use este anexo apenas quando:

- voce ja tiver entendido `source()`, `ref()`, camadas, testes e materializacao;
- quiser ver esses conceitos em um dominio mais tecnico;
- quiser praticar leitura de um projeto dbt real local.

Nao use este anexo como substituto da trilha principal.
