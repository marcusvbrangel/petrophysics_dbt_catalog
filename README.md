# Petrophysics Data Catalog com dbt + DuckDB

Este projeto transforma logs sintéticos de 28 poços em um catálogo analítico petrofísico usando:

- CSV como entrada bruta
- DuckDB como engine analítica local
- dbt como camada de transformação, testes, documentação e lineage
- Parquet como saída particionada para consumo analítico

## Objetivo

O objetivo deste repositório não é apenas calcular métricas petrofísicas. Ele serve para:

- organizar um fluxo lógico de transformação de dados de poço;
- documentar as regras físicas e analíticas usadas no modelo;
- permitir exploração e pesquisa sem esconder inconsistências;
- separar claramente dado bruto, dado tratado, enriquecimento, saída analítica e auditoria de qualidade.

## Modelo Mental

Pense no pipeline em cinco camadas:

1. gerar ou receber o dado bruto;
2. carregar o bruto para uma base analítica local;
3. padronizar e enriquecer o dado com regras físicas;
4. produzir visões analíticas agregadas;
5. auditar inconsistências sem bloquear a exploração.

O fluxo lógico atual é este:

```text
src/01_generate_synthetic_logs.py
    -> data/raw/synthetic_logs_28_wells.csv
    -> src/02_load_raw_to_duckdb.py
    -> raw_logs
    -> models/staging/stg_raw_logs.sql
    -> models/intermediate/int_petrophysics.sql
       -> models/marts/mart_zone_quality.sql
       -> models/marts/mart_well_zone_quality.sql
       -> models/quality/qc_invalid_petrophysics.sql
    -> src/03_export_mart_to_parquet.py
    -> data/parquet/petrophysics/...
```

O ponto importante é este:

- `staging` prepara o dado;
- `intermediate` concentra a lógica de domínio;
- `marts` entrega visões finais para análise;
- `quality` não vem "antes" dos marts; ela audita o mesmo insumo base;
- nesta fase de pesquisa, `dbt test` serve para sinalizar problema, não para impedir exploração.

## Filosofia de Trabalho

Este projeto está em fase de pesquisa e desenvolvimento de modelos. Por isso, a estratégia operacional é:

- rodar `dbt run` para seguir o fluxo e materializar os modelos;
- rodar `dbt test` separadamente para inspecionar anomalias e hipóteses ruins;
- não usar `dbt build` como fluxo principal;
- não mascarar erro só para teste passar;
- não alterar os dados brutos para "forçar" consistência.

Em outras palavras:

- teste falhando aqui é sinal analítico;
- teste falhando não significa que o pipeline de exploração deva parar;
- inconsistências ajudam a entender se o range, a coleta sintética ou a regra física precisam ser revisados;
- o bruto deve continuar preservado.

## O Que Nunca Deve Ser Alterado

Nesta abordagem, há uma regra importante:

- os dados brutos são observados, carregados e analisados;
- os dados brutos não devem ser corrigidos manualmente para fazer o teste passar.

No contexto atual, isso significa:

- `data/raw/synthetic_logs_28_wells.csv` é a fonte bruta;
- `raw_logs` é uma carga dessa fonte para o DuckDB;
- qualquer inconsistência encontrada deve aparecer no modelo ou nos testes;
- se houver revisão, ela deve ocorrer por decisão explícita de modelagem, não por maquiagem do dado.

## Ordem Lógica do Trabalho

A ordem lógica do trabalho, independentemente do nome das pastas, é esta:

1. fonte bruta
2. padronização
3. enriquecimento de domínio
4. consumo analítico
5. auditoria

No projeto, isso corresponde a:

| Etapa lógica | Artefato | Papel |
|---|---|---|
| Fonte bruta | `data/raw/synthetic_logs_28_wells.csv` | Logs sintéticos originais |
| Carga local | `raw_logs` | Tabela inicial no DuckDB |
| Padronização | `stg_raw_logs` | Tipagem e normalização mínima |
| Enriquecimento | `int_petrophysics` | Cálculos petrofísicos, elásticos e hidráulicos |
| Saída analítica | `mart_zone_quality`, `mart_well_zone_quality` | Agregações para análise |
| Auditoria | `qc_invalid_petrophysics` | Lista registros com comportamento fora do esperado |

## Detalhamento de Cada Step

### 1. Geração do Bruto

Arquivo:

- `src/01_generate_synthetic_logs.py`

Entrada:

- nenhuma fonte externa; o script gera os dados sintéticos

Saída:

- `data/raw/synthetic_logs_28_wells.csv`

Objetivo:

- criar uma base sintética controlada de logs para estudo de petrofísica;
- simular curvas de gamma ray, densidade, porosidade neutrônica, sônico compressional, sônico shear e resistividade.

### 2. Carga para DuckDB

Arquivo:

- `src/02_load_raw_to_duckdb.py`

Entrada:

- `data/raw/synthetic_logs_28_wells.csv`

Saída:

- tabela `raw_logs` em `data/reservoir.duckdb`

Objetivo:

- mover o bruto do CSV para o DuckDB;
- preparar uma base local simples para o dbt consumir.

### 3. Staging

Arquivo:

- `models/staging/stg_raw_logs.sql`

Entrada:

- tabela `raw_logs`

Saída:

- modelo `stg_raw_logs`

O que acontece aqui:

- casting explícito de colunas;
- padronização de tipos;
- preservação da estrutura básica do bruto.

Objetivo:

- criar uma camada estável e previsível para os cálculos seguintes;
- separar problemas de tipagem de problemas de lógica física.

### 4. Intermediate

Arquivo:

- `models/intermediate/int_petrophysics.sql`

Entrada:

- modelo `stg_raw_logs`

Saída:

- modelo `int_petrophysics`

O que entra:

- `well_id`, `md_m`, `zone`, `gr_api`, `rhob_gcc`, `nphi_vv`, `dt_usft`, `dts_usft`, `rt_ohmm`

O que sai:

- velocidades `vp_ms` e `vs_ms`
- densidade `rho_kgm3`
- porosidade `phi`
- volume de shale `vsh`
- saturações `sw` e `so`
- permeabilidade `perm_md` e `perm_m2`
- módulos elásticos e impedâncias
- `poisson_ratio`, `vpvs_ratio`, `biot_alpha`, `hydraulic_diffusivity_m2s`

Objetivo:

- concentrar a lógica de domínio do projeto;
- transformar logs em propriedades petrofísicas utilizáveis;
- deixar visível onde as hipóteses físicas e as simplificações estão sendo aplicadas.

Esta é a camada central do modelo mental. Se algo parecer fisicamente estranho, normalmente o primeiro lugar a investigar é `int_petrophysics`.

### 5. Marts

Arquivos:

- `models/marts/mart_zone_quality.sql`
- `models/marts/mart_well_zone_quality.sql`

Entrada:

- modelo `int_petrophysics`

Saídas:

- `mart_zone_quality`
- `mart_well_zone_quality`

Objetivo:

- transformar o dado enriquecido em visões analíticas simples de consumir;
- resumir o comportamento médio por zona e por poço/zona;
- permitir ranking, comparação e interpretação mais rápida.

#### `mart_zone_quality`

O que entra:

- todos os registros de `int_petrophysics`

O que sai:

- uma linha por `zone`
- médias de porosidade, saturações, permeabilidade, Vsh, velocidades, módulo de Young, Biot e difusividade

Pergunta que responde:

- quais zonas, em média, parecem melhores ou piores do ponto de vista petrofísico?

#### `mart_well_zone_quality`

O que entra:

- todos os registros de `int_petrophysics`

O que sai:

- uma linha por combinação `well_id` + `zone`
- médias e intervalos por poço/zona

Pergunta que responde:

- em quais poços cada zona se comporta melhor ou pior?

### 6. Quality

Arquivo:

- `models/quality/qc_invalid_petrophysics.sql`

Entrada:

- modelo `int_petrophysics`

Saída:

- `qc_invalid_petrophysics`

O que acontece aqui:

- o modelo procura registros fora de faixas físicas ou operacionais esperadas;
- cada linha inválida recebe um `quality_issue`.

Exemplos de checagem:

- porosidade fora do range esperado
- Vsh fora de `0` a `1`
- saturações inválidas
- permeabilidade não positiva
- `poisson_ratio` fora de `0.0` a `0.5`
- `biot_alpha` fora de faixa
- curvas sônicas inválidas

Objetivo:

- auditar o comportamento do modelo;
- mostrar onde a física simplificada ou o dado sintético entram em conflito;
- apoiar pesquisa e revisão das hipóteses.

### 7. Exportação

Arquivo:

- `src/03_export_mart_to_parquet.py`

Entrada:

- modelo `int_petrophysics` materializado no DuckDB

Saída:

- `data/parquet/petrophysics/well_id=.../zone=.../*.parquet`

Objetivo:

- disponibilizar o dado enriquecido em formato particionado;
- facilitar consumo posterior em notebooks, engines locais ou camadas analíticas externas.

Observação:

- apesar do nome do script mencionar `mart`, a exportação atual parte de `int_petrophysics`.

## Por Que `quality` Não Bloqueia `marts`

No estado atual do projeto, isso é intencional.

Se `quality` viesse antes e barrasse tudo, o pipeline deixaria de ser útil para exploração. Em pesquisa, muitas vezes é necessário:

- gerar o modelo mesmo com algumas anomalias;
- observar os resultados analíticos;
- comparar o que parece plausível com o que parece inconsistente;
- usar os próprios testes como instrumento de aprendizado.

Portanto, a arquitetura atual é:

- `marts` para consumo e interpretação;
- `quality` para auditoria e crítica do resultado.

Isso é adequado para P&D. Em produção, o fluxo provavelmente seria mais restritivo.

## Como Rodar

### 1. Instalação

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2. Configurar profile do dbt

```bash
mkdir -p ~/.dbt
cp profiles.yml.example ~/.dbt/profiles.yml
```

### 3. Gerar e carregar a base

```bash
python src/01_generate_synthetic_logs.py
python src/02_load_raw_to_duckdb.py
```

### 4. Materializar os modelos

```bash
dbt debug
dbt run
```

### 5. Inspecionar qualidade

```bash
dbt test
```

Interpretação recomendada nesta fase:

- `dbt run` materializa o pipeline;
- `dbt test` revela inconsistências;
- falha de teste não obriga interrupção do estudo;
- `dbt test` deve orientar revisão de hipóteses, ranges e fórmulas.

### 6. Gerar documentação do dbt

```bash
dbt docs generate
dbt docs serve
```

O `dbt docs` ajuda a visualizar:

- modelos
- colunas
- descrições
- testes
- lineage

### 7. Exportar Parquet

```bash
python src/03_export_mart_to_parquet.py
```

Saída esperada:

```text
data/parquet/petrophysics/well_id=.../zone=.../*.parquet
```

## Resumo Curto

Se precisar explicar o projeto em poucas linhas, esta é a versão curta:

- o CSV bruto entra sem maquiagem;
- o DuckDB recebe o bruto como `raw_logs`;
- o `staging` padroniza;
- o `intermediate` aplica a lógica petrofísica;
- os `marts` resumem para análise;
- o `quality` denuncia onde o modelo ou o dado se comportam mal;
- `dbt run` constrói;
- `dbt test` questiona;
- a fase atual privilegia entendimento do modelo, não bloqueio do fluxo.
