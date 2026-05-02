# Treinamento Completo e Amplo de dbt Core

## Objetivo

Este material foi escrito para ser um treinamento completo, conceitual e pratico sobre `dbt Core`, sem depender de `dbt Cloud`.

O foco aqui e:

- entender o que o dbt faz e o que ele nao faz;
- aprender o vocabulario do dbt sem jogar termos soltos;
- montar um projeto pequeno do zero;
- cobrir os principais recursos do `dbt Core` para trabalho real;
- entender como pensar arquitetura, testes, reuso, depuracao e evolucao de projeto;
- praticar com um primeiro estudo de caso simples;
- trabalhar tudo localmente no VS Code, com `Python`, `DuckDB` e `dbt Core`.

Sempre que aparecer um termo novo, eu explico antes ou imediatamente depois.

Este treinamento nao foi pensado para girar em torno deste repositorio. A trilha principal continua geral e independente. Ainda assim, perto do final ha um unico capitulo pratico usando este projeto como aplicacao concreta dos conceitos aprendidos.

## Mapa do treinamento

O material esta organizado em quatro blocos:

1. fundamentos: o que e dbt, como ele pensa, como ele se conecta ao banco e como um projeto e organizado;
2. pratica guiada inicial: um projeto pequeno do zero para aprender sem ruido;
3. amplitude de `dbt Core`: comandos, seletores, testes, macros, `vars`, `packages`, `seed`, `snapshot`, `incremental`, documentacao, debug e workflow;
4. consolidacao: exercicios, um capitulo pratico com este repositorio e criterios de maturidade.

## Como estudar este material

Use a seguinte ordem:

1. Leia as Partes 1, 2 e 3 para formar o modelo mental correto.
2. Execute o Estudo de Caso 1 do inicio ao fim.
3. Estude com calma as partes amplas de `dbt Core` sobre comandos, modelagem, testes, macros, snapshots e incremental.
4. Faca os exercicios propostos.
5. Execute o capitulo pratico com este repositorio como consolidacao aplicada.
6. Depois disso, monte ou analise um estudo de caso proprio, se quiser aprofundar.

Se voce tentar pular direto para macros, testes e lineage sem entender o basico, o dbt vira um monte de sintaxe decorada. Esse e exatamente o erro que este material tenta evitar.

## Parte 1 - O que e dbt, de verdade

### 1.1 O que e dbt

`dbt` significa `data build tool`.

Em termos simples:

- voce ja tem dados em algum banco analitico;
- voce escreve SQL para transformar esses dados;
- o dbt organiza, executa, testa, documenta e conecta essas transformacoes.

O dbt nao "substitui SQL". Ele organiza SQL.

### 1.2 O que o dbt nao faz

O dbt nao e, por padrao:

- ferramenta de extracao de API;
- ferramenta de orquestracao geral de todo o ecossistema;
- banco de dados;
- servico de dashboard;
- servico de armazenamento bruto.

Entao pense assim:

- `Python`, `Airflow`, `scripts`, `Fivetran`, `Meltano`, `bash`, `ingestao manual` podem trazer dados;
- `DuckDB`, `Postgres`, `BigQuery`, `Snowflake`, `Redshift` guardam e processam dados;
- `dbt` transforma e organiza a camada analitica dentro desse banco.

### 1.3 O papel central do dbt

O papel central do dbt e este:

1. ler tabelas ja existentes no banco;
2. transformar essas tabelas em modelos mais limpos;
3. encadear modelos em uma sequencia logica;
4. testar regras importantes;
5. gerar documentacao e lineage.

### 1.4 O modelo mental correto

Pense no dbt como uma fabrica de modelos SQL.

Fluxo mental:

```text
fonte bruta -> staging -> intermediate -> marts -> testes -> documentacao
```

Traduzindo:

- `fonte bruta`: dado como chegou;
- `staging`: limpeza leve, tipagem, padronizacao;
- `intermediate`: regras de negocio e enriquecimento;
- `marts`: tabelas prontas para consumo analitico;
- `testes`: validacoes sobre os dados;
- `documentacao`: descricoes, colunas, dependencias e lineage.

### 1.5 Glossario essencial

Antes de seguir, estes termos precisam ficar claros.

`adapter`

- e o conector do dbt para um banco especifico;
- exemplo: `dbt-duckdb` e o adapter para DuckDB.

`profile`

- e o arquivo que diz para qual banco o dbt vai se conectar;
- no caso deste treinamento, vamos usar DuckDB local.

`model`

- e, na pratica, um arquivo `.sql` dentro da pasta `models/`;
- cada model gera uma relacao no banco, como uma `view` ou `table`.

`materialization`

- e a forma como o model sera persistido;
- os tipos mais comuns sao `view`, `table`, `ephemeral` e `incremental`.

`ref()`

- e uma funcao do dbt usada para apontar para outro model;
- ela faz duas coisas ao mesmo tempo:
- cria a dependencia logica;
- resolve o nome correto da tabela ou view no banco.

`source()`

- e parecido com `ref()`, mas serve para tabelas de origem externa ao dbt;
- exemplo: uma tabela bruta carregada no banco por um script.

`lineage`

- e o mapa de dependencias entre os modelos;
- mostra quem depende de quem.

`DAG`

- significa `Directed Acyclic Graph`;
- em termos simples, e o grafo de dependencia do projeto;
- o dbt usa esse grafo para saber a ordem certa de execucao.

`macro`

- e um trecho reutilizavel escrito com `Jinja`;
- pense em macro como uma funcao reutilizavel para gerar SQL.

`Jinja`

- e a linguagem de template usada dentro do dbt;
- ela aparece entre `{{ ... }}` ou `{% ... %}`.

## Parte 2 - Preparando o ambiente local

### 2.1 O que vamos usar

Tudo local:

- `Python`
- `venv` para ambiente virtual
- `dbt-core`
- `dbt-duckdb`
- `DuckDB`
- `VS Code`

### 2.2 O que e um ambiente virtual

Ambiente virtual e uma pasta isolada com pacotes Python do projeto.

Por que isso importa:

- evita conflito entre projetos;
- garante que `dbt`, `duckdb` e outras dependencias fiquem versionadas localmente;
- faz o terminal do VS Code apontar para o Python certo.

### 2.3 Criando o ambiente

No terminal do VS Code:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install dbt-core dbt-duckdb duckdb pandas
```

Explicacao:

- `python3 -m venv .venv`: cria o ambiente virtual na pasta `.venv`;
- `source .venv/bin/activate`: ativa esse ambiente no terminal atual;
- `pip install --upgrade pip`: atualiza o instalador de pacotes;
- `pip install ...`: instala o dbt e dependencias locais.

### 2.4 Verificando a instalacao

```bash
dbt --version
```

Se esse comando funcionar, o dbt esta disponivel no ambiente.

### 2.5 Onde fica o `profiles.yml`

O dbt normalmente procura o arquivo de conexao em:

```text
~/.dbt/profiles.yml
```

Ou seja:

- `~` significa sua pasta de usuario;
- `.dbt` e uma pasta oculta;
- `profiles.yml` e o arquivo que diz como conectar no banco.

### 2.6 Exemplo minimo de profile para DuckDB

```yaml
mini_loja_dbt:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: loja.duckdb
      threads: 4
```

Explicacao linha por linha:

- `mini_loja_dbt`: nome do profile;
- `target: dev`: nome do ambiente ativo;
- `outputs`: bloco com as configuracoes disponiveis;
- `dev`: configuracao do ambiente de desenvolvimento;
- `type: duckdb`: adapter usado;
- `path: loja.duckdb`: arquivo do banco local;
- `threads: 4`: numero de threads para execucao paralela.

### 2.7 Testando a conexao

Dentro da pasta do projeto dbt:

```bash
dbt debug
```

Esse comando verifica:

- se o `profiles.yml` foi encontrado;
- se o `dbt_project.yml` e valido;
- se a conexao com o banco funciona.

## Parte 3 - Anatomia de um projeto dbt

### 3.1 Estrutura tipica

```text
meu_projeto_dbt/
  dbt_project.yml
  models/
    staging/
    intermediate/
    marts/
    schema.yml
  macros/
  analyses/
  tests/
  snapshots/
  seeds/
  target/
```

O que cada parte significa:

- `dbt_project.yml`: arquivo principal do projeto;
- `models/`: onde ficam os modelos SQL;
- `macros/`: funcoes reutilizaveis em Jinja;
- `analyses/`: consultas analiticas avulsas;
- `tests/`: testes SQL singulares;
- `snapshots/`: historizacao de mudancas ao longo do tempo;
- `seeds/`: CSVs versionados e carregados pelo dbt;
- `target/`: artefatos gerados automaticamente pelo dbt.

### 3.2 O arquivo `dbt_project.yml`

Exemplo:

```yaml
name: 'mini_loja_dbt'
version: '1.0.0'
config-version: 2

profile: 'mini_loja_dbt'

model-paths: ['models']
analysis-paths: ['analyses']
test-paths: ['tests']
macro-paths: ['macros']
seed-paths: ['seeds']
snapshot-paths: ['snapshots']

models:
  mini_loja_dbt:
    staging:
      +materialized: view
    intermediate:
      +materialized: view
    marts:
      +materialized: table
```

Explicacao:

- `name`: nome do projeto dbt;
- `version`: versao do projeto;
- `config-version: 2`: formato moderno de configuracao;
- `profile`: qual profile do `profiles.yml` este projeto usa;
- `model-paths`, `analysis-paths` etc.: em quais pastas o dbt deve procurar arquivos;
- `+materialized`: define como os modelos daquela pasta serao persistidos.

### 3.3 O que e `view` e o que e `table`

`view`

- guarda a consulta;
- normalmente nao guarda os dados fisicamente do mesmo jeito que uma tabela;
- boa para staging e transformacoes leves;
- toda vez que alguem consulta, a logica da view pode ser recalculada pelo banco.

`table`

- guarda o resultado materializado;
- boa para marts e modelos pesados;
- ocupa armazenamento, mas tende a facilitar consumo repetido.

## Parte 4 - Estudo de Caso 1: mini projeto comercial do zero

Aqui vamos construir um projeto pequeno para aprender o fluxo inteiro, sem pular etapas.

### 4.1 Cenario

Imagine uma pequena operacao de vendas com tres tabelas brutas:

- clientes
- pedidos
- itens de pedido

Nosso objetivo sera produzir uma tabela final com vendas por cliente.

### 4.2 Estrutura do projeto

```text
mini_loja_dbt/
  dbt_project.yml
  models/
    staging/
      stg_customers.sql
      stg_orders.sql
      stg_order_items.sql
    intermediate/
      int_order_items_enriched.sql
    marts/
      mart_customer_sales.sql
    schema.yml
    sources.yml
  macros/
    non_negative.sql
  analyses/
  tests/
  data/
    raw/
      customers.csv
      orders.csv
      order_items.csv
  scripts/
    load_raw_to_duckdb.py
```

### 4.3 Dados brutos minimos

Exemplo de `customers.csv`:

```csv
customer_id,customer_name,customer_city
1,Ana,Sao Paulo
2,Bruno,Rio de Janeiro
3,Carla,Belo Horizonte
```

Exemplo de `orders.csv`:

```csv
order_id,customer_id,order_date,status
1001,1,2026-01-10,completed
1002,2,2026-01-11,cancelled
1003,1,2026-01-12,completed
```

Exemplo de `order_items.csv`:

```csv
order_id,product_id,quantity,unit_price
1001,501,2,100.00
1001,777,1,50.00
1002,901,3,30.00
1003,777,4,50.00
```

### 4.4 Carregando o bruto para DuckDB

Crie `scripts/load_raw_to_duckdb.py`:

```python
from pathlib import Path
import duckdb

project_root = Path(__file__).resolve().parents[1]
db_path = project_root / "loja.duckdb"

con = duckdb.connect(str(db_path))
con.execute("create schema if not exists raw;")

con.execute("""
create or replace table raw.customers as
select *
from read_csv_auto('data/raw/customers.csv');
""")

con.execute("""
create or replace table raw.orders as
select *
from read_csv_auto('data/raw/orders.csv');
""")

con.execute("""
create or replace table raw.order_items as
select *
from read_csv_auto('data/raw/order_items.csv');
""")

print("Tabelas brutas carregadas em loja.duckdb")
```

O que esse script faz:

- abre o banco `loja.duckdb`;
- cria o schema `raw` se ele ainda nao existir;
- le os CSVs;
- grava tres tabelas brutas no banco.

Execute:

```bash
python scripts/load_raw_to_duckdb.py
```

### 4.5 Definindo o profile

Em `~/.dbt/profiles.yml`:

```yaml
mini_loja_dbt:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: loja.duckdb
      threads: 4
```

### 4.6 Criando o `dbt_project.yml`

```yaml
name: 'mini_loja_dbt'
version: '1.0.0'
config-version: 2

profile: 'mini_loja_dbt'

model-paths: ['models']
analysis-paths: ['analyses']
test-paths: ['tests']
macro-paths: ['macros']

models:
  mini_loja_dbt:
    staging:
      +materialized: view
    intermediate:
      +materialized: view
    marts:
      +materialized: table
```

### 4.7 Declarando as fontes com `source()`

Crie `models/sources.yml`:

```yaml
version: 2

sources:
  - name: raw
    description: Tabelas brutas carregadas localmente em DuckDB.
    schema: raw
    tables:
      - name: customers
      - name: orders
      - name: order_items
```

Por que isso importa:

- deixa explicito que essas tabelas nao sao produzidas pelo dbt;
- permite documentar a origem;
- torna o lineage mais claro;
- evita escrever nome de tabela bruta na mao em todo lugar.

### 4.8 Modelos de staging

#### `models/staging/stg_customers.sql`

```sql
-- Staging = limpeza minima e tipagem previsivel.
select
    cast(customer_id as integer) as customer_id,
    cast(customer_name as varchar) as customer_name,
    cast(customer_city as varchar) as customer_city
from {{ source('raw', 'customers') }}
```

Explicacao:

- `cast(...)`: converte para o tipo esperado;
- `as customer_id`: define o nome final da coluna;
- `{{ source('raw', 'customers') }}`: aponta para a tabela bruta `raw.customers`.

#### `models/staging/stg_orders.sql`

```sql
select
    cast(order_id as integer) as order_id,
    cast(customer_id as integer) as customer_id,
    cast(order_date as date) as order_date,
    cast(status as varchar) as status
from {{ source('raw', 'orders') }}
```

#### `models/staging/stg_order_items.sql`

```sql
select
    cast(order_id as integer) as order_id,
    cast(product_id as integer) as product_id,
    cast(quantity as integer) as quantity,
    cast(unit_price as double) as unit_price
from {{ source('raw', 'order_items') }}
```

Por que staging quase sempre e simples:

- staging nao e o lugar ideal para regra de negocio complexa;
- staging deve preparar o terreno;
- se voce mistura tudo aqui, o projeto fica opaco e dificil de manter.

### 4.9 Modelo intermediate

Crie `models/intermediate/int_order_items_enriched.sql`:

```sql
with
order_items as (
    select * from {{ ref('stg_order_items') }}
),
orders as (
    select * from {{ ref('stg_orders') }}
),
customers as (
    select * from {{ ref('stg_customers') }}
)

select
    oi.order_id,
    o.order_date,
    o.status,
    o.customer_id,
    c.customer_name,
    c.customer_city,
    oi.product_id,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price as line_total
from order_items oi
inner join orders o
    on oi.order_id = o.order_id
inner join customers c
    on o.customer_id = c.customer_id
```

Explicacao do que esta acontecendo:

- o bloco `with` cria subconjuntos nomeados para leitura mais clara;
- `ref('stg_order_items')` aponta para o model de staging correspondente;
- juntamos itens, pedidos e clientes;
- calculamos `line_total`, que e o valor da linha do pedido.

### 4.10 Modelo mart

Crie `models/marts/mart_customer_sales.sql`:

```sql
select
    customer_id,
    customer_name,
    customer_city,
    count(distinct order_id) as completed_orders,
    sum(quantity) as total_items,
    sum(line_total) as total_revenue,
    avg(line_total) as avg_ticket_per_line
from {{ ref('int_order_items_enriched') }}
where status = 'completed'
group by
    customer_id,
    customer_name,
    customer_city
order by total_revenue desc
```

Logica de negocio:

- estamos considerando apenas `status = 'completed'`;
- pedidos cancelados nao entram na receita;
- agregamos por cliente;
- esse modelo ja fica pronto para analise.

### 4.11 Testes e documentacao

Crie `models/schema.yml`:

```yaml
version: 2

models:
  - name: stg_customers
    description: Clientes apos limpeza e tipagem minima.
    columns:
      - name: customer_id
        description: Identificador do cliente.
        data_tests: [not_null, unique]
      - name: customer_name
        description: Nome do cliente.
        data_tests: [not_null]

  - name: stg_orders
    description: Pedidos apos padronizacao basica.
    columns:
      - name: order_id
        description: Identificador do pedido.
        data_tests: [not_null, unique]
      - name: customer_id
        description: Chave do cliente no pedido.
        data_tests:
          - not_null
          - relationships:
              to: ref('stg_customers')
              field: customer_id
      - name: status
        description: Status operacional do pedido.
        data_tests:
          - accepted_values:
              values: ['completed', 'cancelled']

  - name: stg_order_items
    description: Itens de pedido com tipagem correta.
    columns:
      - name: order_id
        description: Chave do pedido.
        data_tests:
          - not_null
          - relationships:
              to: ref('stg_orders')
              field: order_id
      - name: quantity
        description: Quantidade do item.
        data_tests:
          - not_null
          - non_negative
      - name: unit_price
        description: Preco unitario.
        data_tests:
          - not_null
          - non_negative

  - name: mart_customer_sales
    description: Receita agregada por cliente considerando apenas pedidos concluidos.
    columns:
      - name: customer_id
        description: Identificador do cliente.
        data_tests: [not_null, unique]
      - name: total_revenue
        description: Receita total por cliente.
        data_tests:
          - non_negative
```

### 4.12 Criando um teste customizado com macro

Crie `macros/non_negative.sql`:

```sql
{% test non_negative(model, column_name) %}

select *
from {{ model }}
where {{ column_name }} < 0
   or {{ column_name }} is null

{% endtest %}
```

Como ler isso:

- `test non_negative(...)`: define um teste reutilizavel;
- `model`: o model que esta sendo testado;
- `column_name`: a coluna recebida no YAML;
- se a consulta retornar linhas, o teste falha;
- se retornar zero linhas, o teste passa.

Esse e um ponto muito importante no dbt:

- teste em dbt e, no fundo, SQL;
- um teste passa quando a consulta retorna zero linhas invalidas.

### 4.13 Executando o projeto

Dentro da pasta `mini_loja_dbt`:

```bash
dbt debug
dbt run
dbt test
dbt docs generate
dbt docs serve
```

O que cada comando faz:

- `dbt debug`: valida ambiente e conexao;
- `dbt run`: constroi os models;
- `dbt test`: executa os testes;
- `dbt docs generate`: gera artefatos de documentacao;
- `dbt docs serve`: sobe um servidor local para navegar nos docs.

### 4.14 O que observar nos docs

Nos docs do dbt, observe:

- os modelos e colunas documentadas;
- o grafo de dependencias;
- o lineage de `stg_*` para `int_*` e depois `mart_*`.

### 4.15 O que voce aprendeu nesse primeiro estudo

Se tudo fez sentido, voce ja aprendeu:

- a diferenca entre dado bruto e model dbt;
- o papel de `source()` e `ref()`;
- como organizar `staging`, `intermediate` e `marts`;
- como criar testes genericos;
- como documentar modelos e colunas;
- como o dbt monta o DAG.

## Parte 5 - Conceitos que mais confundem iniciantes

### 5.1 `ref()` nao e so "um alias bonito"

Muita gente acha que `ref()` so evita escrever nome de tabela. Nao e so isso.

`ref()` faz duas coisas:

1. diz ao dbt que existe dependencia entre dois modelos;
2. resolve o nome correto da relacao no banco.

Sem `ref()`, o dbt perde parte do entendimento do grafo.

### 5.2 `source()` nao e a mesma coisa que `ref()`

`source()` aponta para dado externo ao dbt.

`ref()` aponta para dado produzido pelo proprio dbt.

Em termos praticos:

- `source('raw', 'orders')` = tabela bruta carregada por fora;
- `ref('stg_orders')` = model criado dentro do projeto dbt.

### 5.3 O que sao `{{ ... }}` e `{% ... %}`

Ambos sao Jinja, mas com papeis diferentes.

`{{ ... }}`

- imprime ou injeta um valor na SQL final.

Exemplo:

```sql
select * from {{ ref('stg_orders') }}
```

`{% ... %}`

- controla logica de template;
- muito usado em macros, loops e condicionais.

Exemplo:

```sql
{% test non_negative(model, column_name) %}
...
{% endtest %}
```

### 5.4 `dbt run` nao e igual a `dbt test`

`dbt run`

- constroi modelos.

`dbt test`

- valida regras.

`dbt build`

- roda seeds, snapshots, run e tests em fluxo integrado.

Na pratica:

- em projetos maduros, `dbt build` pode ser otimo;
- em projetos exploratorios, rodar `run` e `test` separadamente pode ser melhor para nao confundir materializacao com auditoria.

### 5.5 O que vai para `target/`

A pasta `target/` e gerada pelo dbt e normalmente contem:

- SQL compilado;
- `manifest.json`;
- `catalog.json`;
- `run_results.json`;
- arquivos usados pela documentacao.

Isso e util porque permite inspecionar:

- qual SQL final o dbt realmente executou;
- quais modelos foram processados;
- quais testes passaram ou falharam.

### 5.6 O que significa "SQL compilado"

Seu arquivo dbt pode ter:

- `ref()`
- `source()`
- macros
- Jinja

O dbt transforma isso em SQL puro antes de enviar ao banco. Esse resultado final compilado fica em `target/compiled/`.

Se algo estiver estranho, olhar o SQL compilado costuma ajudar muito.

## Parte 6 - Assuntos importantes depois do basico

Esta parte e para quando o fluxo principal ja estiver claro.

### 6.1 `seed`

`seed` e um CSV versionado dentro do projeto, carregado pelo proprio dbt.

Bom para:

- tabelas pequenas;
- dicionarios;
- tabelas de apoio;
- mapeamentos controlados.

### 6.2 `snapshot`

`snapshot` serve para guardar historico de mudancas ao longo do tempo.

Exemplo:

- hoje um cliente esta com status `silver`;
- amanha ele vira `gold`;
- o snapshot guarda o historico das mudancas.

### 6.3 `incremental`

`incremental` evita reconstruir tudo toda vez.

Em vez disso:

- processa apenas registros novos ou alterados;
- e util quando a tabela cresce muito.

Mas cuidado:

- incremental exige criterio;
- se a regra de negocio muda, talvez seja necessario `full refresh`.

### 6.4 `ephemeral`

`ephemeral` nao cria tabela nem view.

Ele:

- funciona como um bloco logico;
- e embutido no SQL final de outro model.

Pode ser bom para:

- pequenas transformacoes reutilizaveis;
- reducao de lixo no banco.

Pode ser ruim quando:

- o SQL final fica gigante;
- voce precisa inspecionar a etapa separadamente.

## Parte 7 - Comandos fundamentais do dbt Core

Antes de qualquer projeto real maior, voce precisa dominar os comandos. Sem isso, a pessoa fica dependente de copiar comandos prontos sem entender o que esta pedindo ao dbt.

### 7.1 `dbt init`

Esse comando cria a estrutura inicial de um projeto.

Exemplo:

```bash
dbt init meu_projeto
```

Quando usar:

- quando voce quer que o dbt gere um esqueleto inicial;
- quando esta aprendendo e quer ver a estrutura padrao.

Quando nao e obrigatorio:

- quando voce prefere criar os arquivos manualmente;
- quando ja existe um repositorio montado.

### 7.2 `dbt debug`

Esse e um dos comandos mais importantes para inicio de trabalho.

Ele verifica:

- se o `profiles.yml` foi encontrado;
- se o `dbt_project.yml` esta valido;
- se o adapter esta instalado;
- se a conexao com o banco funciona.

Use sempre que:

- montar ambiente novo;
- trocar de banco;
- copiar projeto para outra maquina.

### 7.3 `dbt run`

`dbt run` constroi models.

Ele:

- le os arquivos em `models/`;
- respeita dependencias entre eles;
- gera `view`, `table` ou outro tipo configurado;
- executa na ordem certa.

Exemplo:

```bash
dbt run
```

Exemplo filtrando:

```bash
dbt run --select mart_customer_sales
```

### 7.4 `dbt test`

`dbt test` executa os testes definidos no projeto.

Isso inclui:

- testes genericos no YAML;
- testes singulares em arquivos SQL.

Exemplo:

```bash
dbt test
```

Importante:

- ele nao constroi modelos novos;
- ele verifica se os dados materializados respeitam as regras declaradas.

### 7.5 `dbt build`

`dbt build` e um comando composto.

Em termos simples, ele integra:

- `seed`
- `snapshot`
- `run`
- `test`

Use quando:

- voce quer um fluxo mais integrado;
- faz sentido falhar cedo se teste quebrar;
- o projeto esta com comportamento mais previsivel.

Nao use sem criterio so porque parece mais completo. Em contexto exploratorio, separar `run` e `test` pode ser mais inteligente.

### 7.6 `dbt compile`

Esse comando compila o projeto sem necessariamente executar tudo no banco do mesmo jeito que `run`.

O valor dele e:

- mostrar o SQL final gerado;
- ajudar a inspecionar Jinja, `ref()`, `source()` e macros;
- facilitar debug.

Se voce tem duvida do que o dbt realmente vai mandar para o banco, `dbt compile` ajuda.

### 7.7 `dbt ls`

`dbt ls` lista recursos reconhecidos pelo projeto.

Exemplo:

```bash
dbt ls
```

Exemplo filtrando models:

```bash
dbt ls --select path:models/marts
```

Isso e util para:

- entender o que o seletor realmente esta pegando;
- depurar escopo de execucao;
- navegar no projeto.

### 7.8 `dbt docs generate` e `dbt docs serve`

Esses comandos cuidam da documentacao navegavel.

`dbt docs generate`

- gera os artefatos.

`dbt docs serve`

- sobe um servidor local para navegar pelos docs.

Isso ajuda a ver:

- lineage;
- descricoes;
- testes;
- relacoes entre modelos.

### 7.9 `dbt seed`

`dbt seed` carrega arquivos CSV da pasta `seeds/` para o banco.

Bom para:

- tabelas pequenas e controladas;
- tabelas de parametros;
- mapeamentos.

Nao e a melhor escolha para:

- arquivos gigantes;
- ingestao operacional pesada;
- dados brutos instaveis de grande volume.

### 7.10 `dbt snapshot`

`dbt snapshot` historiza mudancas ao longo do tempo.

Ele e importante quando voce quer responder perguntas como:

- quando um registro mudou;
- qual era o valor antes;
- qual versao estava vigente em uma data passada.

### 7.11 `dbt deps`

`dbt deps` baixa `packages` declarados no `packages.yml`.

Pense em `packages` como bibliotecas reutilizaveis da comunidade ou do seu time.

Exemplo de uso:

- macros prontas;
- testes reutilizaveis;
- utilitarios SQL.

### 7.12 `dbt clean`

`dbt clean` remove diretorios gerados pelo dbt, como `target/` e outros configurados em `clean-targets`.

Use quando:

- o projeto ficou com artefatos antigos;
- voce quer recomecar a geracao local de maneira limpa.

### 7.13 `dbt run-operation`

Esse comando executa uma macro como operacao.

Exemplo:

```bash
dbt run-operation minha_macro
```

Quando isso e util:

- tarefas administrativas;
- geracao de SQL utilitario;
- operacoes repetitivas controladas por macro.

### 7.14 Seletores: como o dbt entende o que voce quer rodar

Seletores sao filtros do que sera executado.

O mais comum e:

```bash
dbt run --select alguma_coisa
```

Essa `alguma_coisa` pode ser:

- nome de model;
- pasta;
- tag;
- source;
- teste;
- combinacao de dependencias.

### 7.15 Seletores mais importantes no dia a dia

Rodar um model especifico:

```bash
dbt run --select stg_orders
```

Rodar um model e seus filhos:

```bash
dbt run --select stg_orders+
```

O `+` a direita quer dizer:

- inclua os descendentes;
- ou seja, os modelos que dependem dele.

Rodar um model e seus pais:

```bash
dbt run --select +mart_customer_sales
```

O `+` a esquerda quer dizer:

- inclua os ancestrais;
- ou seja, tudo de que ele depende.

Rodar pais, model e filhos:

```bash
dbt run --select +mart_customer_sales+
```

Rodar por pasta:

```bash
dbt run --select path:models/staging
```

Rodar por tag:

```bash
dbt run --select tag:daily
```

### 7.16 Regra pratica para seletores

Se voce ainda esta aprendendo, pense assim:

- `modelo` = so aquele recurso;
- `+modelo` = o que vem antes dele;
- `modelo+` = o que vem depois dele;
- `+modelo+` = o trecho inteiro conectado.

## Parte 8 - Arquitetura e modelagem analitica com dbt

`dbt Core` nao ensina sozinho a modelar bem. Ele organiza a execucao. A qualidade da modelagem ainda depende de criterio.

### 8.1 Granularidade: a pergunta mais importante antes de escrever SQL

Granularidade, ou `grain`, e o nivel de detalhe de uma tabela.

Exemplos:

- uma linha por cliente;
- uma linha por pedido;
- uma linha por item de pedido;
- uma linha por poco e profundidade;
- uma linha por poco e zona.

Antes de criar um model, pergunte:

- qual entidade cada linha representa;
- se existe repeticao indevida;
- se vou agregar ou detalhar;
- se as chaves continuam coerentes.

Muitos erros de modelagem nao comecam no `join`. Eles comecam em uma granularidade mal pensada.

### 8.2 O papel real de cada camada

`source`

- descreve o dado externo;
- nao e transformacao do dbt;
- e a porta de entrada documentada.

`staging`

- limpa pouco;
- tipa;
- renomeia;
- padroniza;
- evita inteligencia demais.

`intermediate`

- junta tabelas;
- aplica regras de negocio;
- organiza calculos;
- prepara entidades de trabalho.

`mart`

- entrega resposta para consumo;
- consolida metricas;
- reflete perguntas de negocio.

### 8.3 O que nunca fazer com staging

Evite no staging:

- agregacoes de negocio complexas;
- dezenas de regras misturadas;
- joins pesados entre muitas tabelas;
- logica que so faz sentido para um dashboard especifico.

Se staging fica pesado demais, ele deixa de ser staging.

### 8.4 Fatos e dimensoes, em linguagem simples

`fato`

- tabela de eventos, transacoes ou observacoes;
- normalmente cresce bastante;
- exemplos: vendas, cliques, leituras de sensor, logs de poco por profundidade.

`dimensao`

- tabela descritiva;
- contextualiza fatos;
- exemplos: cliente, produto, poco, zona, calendario.

Um bom projeto dbt costuma deixar claro:

- onde estao os eventos;
- onde estao os atributos descritivos;
- onde estao as agregacoes finais.

### 8.5 O perigo dos `joins` que multiplicam linhas

Um dos erros mais comuns e este:

- voce acha que esta so enriquecendo um dado;
- mas na pratica esta duplicando ou multiplicando linhas.

Exemplo classico:

- uma tabela por pedido;
- outra tabela por item;
- ao juntar sem pensar, o pedido passa a aparecer varias vezes.

A pergunta certa e:

- a granularidade final continua a mesma de antes?

Se a resposta for nao, essa mudanca precisa ser intencional.

### 8.6 Nome de model deve explicar o papel

Nomes ruins:

- `dados_final`
- `tabela_nova`
- `base_ok`

Nomes melhores:

- `stg_orders`
- `int_order_items_enriched`
- `mart_customer_sales`

O nome deve dizer:

- camada;
- entidade;
- papel.

### 8.7 Quando quebrar um model em varios modelos

Quebre um model quando:

- ele mistura muitas responsabilidades;
- a leitura ficou opaca;
- o mesmo bloco logico sera reutilizado;
- o debug esta dificil;
- uma etapa merece ser inspecionada sozinha.

Nao quebre so por mania. Modelo demais tambem pode fragmentar sem ganho.

### 8.8 Boas perguntas antes de criar um mart

Pergunte:

- qual decisao esse mart ajuda a tomar;
- quem vai consumir;
- em qual granularidade;
- quais filtros serao comuns;
- quais metricas sao indispensaveis;
- se o mart e reutilizavel ou apenas uma consulta ad hoc.

### 8.9 Quando um model deveria virar `analysis` em vez de `mart`

Se o arquivo:

- responde uma pergunta muito especifica;
- nao precisa ser base reutilizavel;
- nao precisa entrar no pipeline principal;
- serve mais para exploracao do que para produto de dados;

entao ele talvez seja melhor em `analyses/` do que em `models/`.

## Parte 9 - Testes, documentacao e confiabilidade

Sem confiabilidade, dbt vira apenas um organizador de SQL. O ganho real aparece quando voce comeca a explicitar e verificar expectativas.

### 9.1 O que significa "testar dados" no contexto do dbt

Testar dados nao significa provar que o mundo esta perfeito.

Significa declarar coisas como:

- esta chave nao deveria ser nula;
- este id deveria ser unico;
- esta coluna deveria ter apenas certos valores;
- esta relacao deveria existir entre duas tabelas;
- este range deveria fazer sentido.

### 9.2 Testes genericos nativos

Os mais conhecidos sao:

- `not_null`
- `unique`
- `relationships`
- `accepted_values`

Esses testes normalmente vao no YAML.

Exemplo:

```yaml
columns:
  - name: customer_id
    data_tests: [not_null, unique]
```

### 9.3 O que faz cada teste nativo

`not_null`

- falha se houver valor nulo.

`unique`

- falha se um valor aparecer repetido onde deveria ser unico.

`relationships`

- falha se a chave apontar para um registro inexistente na tabela relacionada.

`accepted_values`

- falha se a coluna tiver um valor fora da lista autorizada.

### 9.4 Teste generico e teste singular

`teste generico`

- e reutilizavel;
- recebe parametros;
- normalmente nasce em macro;
- e chamado no YAML.

`teste singular`

- e um arquivo SQL escrito para uma regra especifica;
- vive normalmente na pasta `tests/`.

Exemplo de teste singular:

```sql
select *
from {{ ref('mart_customer_sales') }}
where total_revenue < 0
```

Se essa consulta retornar linhas, o teste falha.

### 9.5 Como pensar uma boa regra de teste

Uma boa regra e:

- clara;
- explicavel;
- importante;
- barata o suficiente para executar;
- alinhada com o negocio ou com a fisica do dado.

Um teste ruim e:

- decorativo;
- arbitrario;
- impossivel de explicar;
- excessivamente caro;
- ou tao generico que nao protege nada importante.

### 9.6 Documentacao nao e perfumaria

Documentacao em dbt ajuda a responder:

- o que esta tabela representa;
- o que cada coluna significa;
- qual a regra por tras do calculo;
- quem depende de quem;
- quais suposicoes o time esta fazendo.

Uma coluna sem descricao em area critica costuma cobrar caro depois.

### 9.7 `source freshness`

`freshness` e a verificacao de recencia da fonte.

Ela ajuda a responder:

- os dados chegaram recentemente;
- a carga atrasou;
- a fonte parece parada.

Exemplo simplificado:

```yaml
sources:
  - name: raw
    schema: raw
    tables:
      - name: orders
        loaded_at_field: loaded_at
        freshness:
          warn_after: {count: 12, period: hour}
          error_after: {count: 24, period: hour}
```

Interpretacao:

- com 12 horas, gera alerta;
- com 24 horas, vira erro.

### 9.8 Contratos de modelo

Contrato de modelo e uma forma de deixar mais rigida a expectativa sobre a estrutura de um model.

Em linguagem simples, ele ajuda a afirmar:

- estas colunas devem existir;
- estes tipos sao esperados;
- o model nao deveria mudar silenciosamente de formato.

Nem todo projeto precisa disso cedo. Mas em ambientes mais maduros, contratos ajudam a reduzir surpresa.

### 9.9 Qualidade nao e so teste

Qualidade tambem inclui:

- modelagem clara;
- nomenclatura consistente;
- regras bem documentadas;
- logs e artefatos legiveis;
- estrategia de tratamento de anomalias.

Em alguns casos, faz sentido:

- falhar o pipeline;
- ou materializar uma tabela de auditoria para estudo.

O criterio depende do contexto.

## Parte 10 - Jinja, macros, `vars`, `env_var` e `packages`

Essa e a parte que costuma assustar iniciantes. O erro comum e tentar usar Jinja demais cedo demais.

### 10.1 O que e Jinja no dbt

Jinja e uma camada de template.

Ela nao substitui SQL. Ela ajuda a:

- injetar nomes e valores;
- repetir estruturas;
- parametrizar comportamento;
- chamar macros.

### 10.2 Exemplo simples de Jinja

```sql
select *
from {{ ref('stg_orders') }}
```

Aqui a Jinja nao esta fazendo um loop nem uma condicao. Ela esta so pedindo ao dbt:

- resolva corretamente esse model de referencia.

### 10.3 Exemplo de loop com Jinja

Suponha que voce queira selecionar varias colunas de forma repetitiva:

```sql
select
    order_id,
    {% for col in ['quantity', 'unit_price'] %}
    {{ col }}{% if not loop.last %},{% endif %}
    {% endfor %}
from {{ ref('stg_order_items') }}
```

Isso compila para SQL normal. Mas cuidado:

- so porque da para fazer, nao significa que sempre fica mais legivel.

### 10.4 O que e uma macro

Macro e uma funcao reutilizavel escrita em Jinja.

Ela serve para:

- reduzir repeticao;
- encapsular padrao;
- gerar SQL dinamico;
- criar testes customizados;
- executar utilitarios com `run-operation`.

### 10.5 Estrutura mental de uma macro

Pense assim:

- entrada: argumentos;
- processamento: template Jinja;
- saida: SQL ou comportamento utilitario.

Exemplo simples:

```sql
{% macro cents_to_currency(column_name) %}
    {{ column_name }} / 100.0
{% endmacro %}
```

Uso:

```sql
select
    order_id,
    {{ cents_to_currency('amount_cents') }} as amount_currency
from {{ ref('stg_orders') }}
```

### 10.6 `var()`

`var()` le variaveis do projeto ou da linha de comando.

Exemplo:

```sql
where order_date >= '{{ var("start_date", "2026-01-01") }}'
```

Interpretacao:

- use a variavel `start_date` se ela existir;
- caso contrario, use `2026-01-01`.

Rodando:

```bash
dbt run --vars '{"start_date": "2026-02-01"}'
```

### 10.7 `env_var()`

`env_var()` le variaveis de ambiente do sistema operacional.

Exemplo:

```yaml
user: "{{ env_var('DB_USER') }}"
password: "{{ env_var('DB_PASSWORD') }}"
```

Isso e util para:

- credenciais;
- configuracoes sensiveis;
- variacao por ambiente.

### 10.8 `packages`

`packages` sao dependencias externas do projeto dbt.

Exemplo de `packages.yml`:

```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.3.0
```

Depois:

```bash
dbt deps
```

Por que isso importa:

- evita reinventar macro basica;
- reaproveita testes e utilitarios padronizados;
- acelera projeto.

### 10.9 Quando um `package` ajuda de verdade

Use `package` quando ele:

- resolve um problema recorrente;
- e confiavel;
- e entendido pelo time;
- reduz codigo proprio sem criar dependencia opaca.

Nao use so porque existe. Dependencia demais tambem confunde.

### 10.10 `run-operation` na pratica

Se voce tem uma macro utilitaria, pode roda-la assim:

```bash
dbt run-operation minha_macro --args '{"schema_name": "analytics"}'
```

Isso e bom para:

- automacoes pequenas;
- tarefas administrativas;
- operacoes parametrizadas.

### 10.11 Quando nao exagerar em Jinja

Evite macro ou Jinja excessiva quando:

- o SQL puro ja esta claro;
- a abstracao esconde a logica;
- o ganho de reuso e pequeno;
- o time vai sofrer para entender.

Regra pratica:

- se a macro torna o SQL mais legivel, bom;
- se a macro transforma tudo em metaprogramacao opaca, ruim.

## Parte 11 - Evolucao do projeto: `seed`, `snapshot`, `incremental`, debug e workflow

Agora entramos no bloco que diferencia um projeto pequeno de um projeto que consegue crescer.

### 11.1 `seed` com criterio

Ja vimos que `seed` carrega CSVs do proprio repositorio. Agora a pergunta correta e: quando isso e boa ideia?

Boa ideia:

- tabela pequena;
- lista controlada pelo time;
- baixa frequencia de mudanca;
- alto valor de versionamento.

Ma ideia:

- bruto volumoso;
- arquivo mudando o tempo todo fora do Git;
- dependencia operacional pesada.

### 11.2 `snapshot` em linguagem pratica

Use `snapshot` quando o valor atual nao basta. Voce precisa da historia.

Exemplo mental:

- cliente muda de segmento;
- produto muda de categoria;
- contrato muda de status;
- poco muda de classificacao operacional.

Exemplo simplificado de snapshot:

```sql
{% snapshot snap_customers %}

{{
    config(
      target_schema='snapshots',
      unique_key='customer_id',
      strategy='check',
      check_cols=['customer_name', 'customer_city']
    )
}}

select *
from {{ ref('stg_customers') }}

{% endsnapshot %}
```

Interpretacao:

- `unique_key`: identifica o registro;
- `strategy='check'`: compara colunas observadas;
- `check_cols`: colunas cuja mudanca gera nova versao historica.

### 11.3 `incremental` em linguagem pratica

Use `incremental` quando reconstruir tudo toda vez ficou caro demais.

Exemplo simplificado:

```sql
{{
    config(
      materialized='incremental',
      unique_key='order_id'
    )
}}

select
    order_id,
    customer_id,
    order_date,
    status
from {{ source('raw', 'orders') }}
{% if is_incremental() %}
where order_date >= (
    select coalesce(max(order_date), date '1900-01-01')
    from {{ this }}
)
{% endif %}
```

Como ler isso sem susto:

- `materialized='incremental'`: este model nao sera reconstruido sempre do zero;
- `unique_key='order_id'`: chave usada para reconciliar registro;
- `is_incremental()`: condicao verdadeira apenas em execucao incremental;
- `{{ this }}`: referencia ao proprio model ja materializado.

### 11.4 O que pode dar errado com incremental

Problemas comuns:

- criterio de filtro errado;
- dado atrasado chegando depois;
- mudanca de regra antiga sem reprocessamento;
- dependencia de deduplicacao mal pensada.

Por isso, incremental exige mais cuidado do que `table` ou `view`.

### 11.5 `full-refresh`

Quando um incremental precisa ser reconstruido do zero:

```bash
dbt run --full-refresh --select meu_model_incremental
```

Use quando:

- a regra mudou fortemente;
- houve correcao historica;
- o acumulado esta inconsistente.

### 11.6 Como depurar um projeto dbt

Sequencia pratica de debug:

1. rode `dbt debug`;
2. isole um model com `--select`;
3. use `dbt compile`;
4. abra o SQL compilado em `target/compiled/`;
5. leia `logs/dbt.log` se necessario;
6. confira se o problema e de conexao, SQL, dados ou Jinja.

### 11.7 Como ler erro de dbt com calma

Pergunte:

- o erro e do dbt ou do banco;
- o problema aconteceu em compilacao ou execucao;
- qual model exato falhou;
- o SQL compilado faz sentido;
- algum `ref()` ou `source()` esta errado;
- ha problema de tipo, range, nulo ou relacionamento.

### 11.8 Performance: por onde comecar

Antes de tentar "otimizar tudo", verifique:

- materializacao certa;
- filtros cedo o suficiente;
- granularidade correta;
- joins necessarios;
- modelos pesados demais em cadeia;
- agregacoes repetidas sem necessidade.

Em muitos casos, o maior ganho nao vem de SQL exotica. Vem de modelagem melhor.

### 11.9 Workflow local profissional sem depender de cloud

Um fluxo simples e maduro pode ser:

1. atualizar branch;
2. ativar ambiente virtual;
3. rodar `dbt debug`;
4. rodar so o escopo alterado com `--select`;
5. rodar testes relevantes;
6. gerar docs se a mudanca afetar contrato ou descricao;
7. revisar diff e SQL compilado quando necessario.

### 11.10 Um fluxo de CI possivel com `dbt Core`

Mesmo sem cloud, voce pode ter CI com:

- instalacao de dependencias;
- `dbt deps`;
- `dbt build` ou `dbt run` + `dbt test`;
- checagens de estilo SQL;
- validacao de artefatos.

Ou seja:

- `dbt Core` nao depende de `dbt Cloud` para ser profissional;
- ele so precisa de um ambiente de execucao bem montado.

### 11.11 Sinais de maturidade de um projeto dbt

Niveis de maturidade, de forma simples:

Nivel 1:

- alguns models funcionando.

Nivel 2:

- camadas claras;
- `ref()` correto;
- documentacao minima.

Nivel 3:

- testes consistentes;
- nomenclatura previsivel;
- seletores bem usados.

Nivel 4:

- incremental e snapshot com criterio;
- reuso por macros e packages;
- CI confiavel;
- debug e operacao previsiveis.

### 11.12 Como escolher um estudo de caso proprio

Em vez de usar um repositorio especifico como trilha oficial, o melhor e escolher um estudo de caso pequeno, controlado e explicavel.

Um bom estudo de caso para treinar `dbt Core` deve ter:

- entre 2 e 5 tabelas de origem;
- uma granularidade clara;
- pelo menos um `join` importante;
- pelo menos um mart final;
- pelo menos um teste nativo;
- pelo menos um teste customizado ou uma macro pequena;
- perguntas analiticas simples, mas reais.

Exemplos bons para estudo:

- vendas de loja;
- pedidos e entregas;
- RH com funcionarios, departamentos e cargos;
- sensores industriais;
- eventos de aplicacao;
- marketing com campanhas, leads e conversoes.

Exemplos ruins para estudo inicial:

- dezenas de fontes ao mesmo tempo;
- regras cheias de excecao;
- dependencia de API, cloud e infraestrutura externa;
- volume enorme antes de dominar o basico.

Neste treinamento, alem do estudo de caso pequeno criado no inicio, ha um capitulo pratico especifico com este repositorio na Parte 13. O anexo [ANEXO_OPCIONAL_PROJETO_PETROPHYSICS_DBT.md](ANEXO_OPCIONAL_PROJETO_PETROPHYSICS_DBT.md) fica como aprofundamento complementar.

## Parte 12 - Exercicios praticos

Todos os exercicios desta parte sao gerais. Se quiser, voce pode resolvelos em um projeto novo, pequeno e independente.

### 12.1 Exercicio 1: explicar `source()` e `ref()` com um mini exemplo proprio

Objetivo:

- provar que voce entendeu a diferenca entre origem externa e model interno.

Tarefa:

1. imagine uma tabela bruta `raw.orders`;
2. escreva um `sources.yml` minimo para essa origem;
3. escreva um model `stg_orders.sql` usando `source()`;
4. escreva um model `mart_orders.sql` usando `ref('stg_orders')`;
5. explique com suas palavras por que um usa `source()` e o outro usa `ref()`.

O que voce aprende:

- diferenca conceitual entre origem e transformacao;
- dependencia explicita no DAG.

### 12.2 Exercicio 2: praticar seletores

Objetivo:

- ganhar fluidez com `--select`.

Tarefa:

- escreva os comandos para:
- rodar apenas `stg_orders`;
- rodar `stg_orders` e seus filhos;
- rodar `mart_customer_sales` e tudo de que ele depende;
- rodar tudo da pasta `models/marts`;
- rodar apenas modelos com tag `daily`.

O que voce aprende:

- navegacao operacional do projeto;
- leitura correta de ancestrais e descendentes.

### 12.3 Exercicio 3: desenhar uma estrategia de testes para um projeto simples

Objetivo:

- pensar qualidade antes da sintaxe.

Cenario:

- voce tem `customers`, `orders` e `order_items`.

Tarefa:

- diga quais colunas deveriam receber:
- `not_null`;
- `unique`;
- `relationships`;
- `accepted_values`;
- um teste customizado.

O que voce aprende:

- como transformar expectativa de negocio em regra verificavel.

### 12.4 Exercicio 4: criar uma macro pequena e legivel

Objetivo:

- usar Jinja com controle.

Tarefa:

- crie uma macro chamada `percent_to_fraction(column_name)`;
- mostre como ela seria usada em um model;
- explique por que essa macro ajuda e em que ponto ela passaria a ser exagero.

O que voce aprende:

- reuso com clareza;
- limite saudavel de abstracao.

### 12.5 Exercicio 5: desenhar um pequeno projeto em camadas

Objetivo:

- praticar a separacao entre `staging`, `intermediate` e `marts`.

Tarefa:

1. escolha um dominio pequeno, como vendas, RH, sensores ou marketing;
2. descreva 3 tabelas brutas;
3. defina a granularidade de cada uma;
4. proponha pelo menos 2 models de `staging`;
5. proponha 1 model `intermediate`;
6. proponha 1 `mart` final;
7. explique o papel de cada camada.

O que voce aprende:

- arquitetura minima de projeto;
- clareza de responsabilidade por camada.

### 12.6 Exercicio 6: criar um teste singular

Objetivo:

- validar uma regra de negocio especifica que nao cabe bem em um teste nativo.

Exemplos de regras possiveis:

- `data_fim` nao pode ser menor que `data_inicio`;
- `desconto_percentual` nao pode passar de `100`;
- `receita_total` nao pode ser negativa;
- `status_cancelado` nao deveria coexistir com `data_entrega_preenchida`.

Escreva um arquivo de teste singular em `tests/` para uma dessas regras.

Estrutura esperada:

```sql
select *
from {{ ref('nome_do_model') }}
where ...
```

Como interpretar:

- se retornar linha, o teste falha;
- isso verifica uma regra especifica que voce escolheu conscientemente.

### 12.7 Exercicio 7: desenhar um caso de `snapshot`

Objetivo:

- entender quando historizacao faz sentido.

Tarefa:

1. escolha uma entidade que muda com o tempo, como cliente, contrato, produto ou colaborador;
2. diga qual seria a `unique_key`;
3. diga quais colunas deveriam ser monitoradas;
4. explique se voce usaria `strategy='check'` ou `strategy='timestamp'`;
5. escreva um exemplo simplificado de snapshot.

O que voce aprende:

- historizacao;
- criterio de mudanca temporal;
- diferenca entre valor atual e historico.

### 12.8 Exercicio 8: desenhar um caso de `incremental`

Objetivo:

- entender quando vale a pena nao reconstruir tudo.

Tarefa:

1. escolha uma tabela de eventos grande, como pedidos, acessos ou leituras;
2. diga qual campo usaria para recorte incremental;
3. explique qual e o risco de dado atrasado;
4. escreva um exemplo simplificado com `is_incremental()`;
5. diga em que situacao voce faria `full-refresh`.

O que voce aprende:

- trade-off de performance;
- risco operacional de incremental.

### 12.9 Exercicio 9: comparar `view` e `table`

Objetivo:

- sentir na pratica o efeito de materializacao.

Passos:

1. pegue um model de `staging` do seu projeto;
2. rode com `view`;
3. depois rode com `table`;
4. compare legibilidade, persistencia, custo conceitual e experiencia de debug.

## Parte 13 - Capitulo pratico com este repositorio

Este capitulo existe para uma finalidade muito especifica:

- pegar os conceitos gerais do treinamento;
- enxergar esses conceitos em um projeto real local;
- praticar leitura de estrutura, camadas, testes e fluxo de execucao.

Importante:

- este repositorio nao define a trilha do curso;
- ele entra apenas aqui, como um capitulo pratico de consolidacao.

### 13.1 O que observar neste projeto

Use este repositorio para localizar, na pratica:

- `dbt_project.yml`
- `profiles.yml.example`
- `models/staging/`
- `models/intermediate/`
- `models/marts/`
- `models/schema.yml`
- `macros/`
- `analyses/`

A pergunta central nao e "como aprender petrofisica". A pergunta central e:

- onde estao, neste projeto, os conceitos de `dbt Core` que eu aprendi?

### 13.2 O que este projeto faz, em alto nivel

Em alto nivel, o projeto:

- gera dados sinteticos;
- carrega esses dados em DuckDB;
- aplica transformacoes com `dbt Core`;
- produz tabelas analiticas;
- executa validacoes de qualidade;
- exporta resultado para Parquet.

Isso e suficiente para ele virar um bom laboratorio de `dbt Core` sem virar o centro do curso.

### 13.3 Como mapear as camadas

Ao ler o projeto, tente responder:

- qual e a entrada bruta;
- o que o `staging` apenas tipa ou padroniza;
- onde mora a logica principal de negocio;
- quais models viram saida analitica;
- onde a qualidade foi tratada por testes;
- onde existe auditoria complementar fora dos testes.

Se voce conseguir responder isso com clareza, entendeu a arquitetura dbt do projeto.

### 13.4 Sequencia pratica recomendada

Use esta ordem:

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
```

O que observar durante a execucao:

- o que vem de script Python e o que vem do dbt;
- em que momento o dado bruto vira model;
- onde entram `ref()`, materializacao e testes;
- como o grafo fica organizado nos docs.

### 13.5 Perguntas que este capitulo deve responder

Ao terminar este capitulo, voce deveria conseguir explicar:

1. por que `staging` deste projeto e simples;
2. onde esta a regra principal do dominio;
3. por que existem `marts` separados;
4. qual a diferenca entre teste e tabela de auditoria neste projeto;
5. por que esse fluxo funciona inteiramente com `dbt Core` local.

### 13.6 Aprofundamento opcional

Se quiser um walkthrough mais detalhado deste repositorio, use o anexo:

[ANEXO_OPCIONAL_PROJETO_PETROPHYSICS_DBT.md](ANEXO_OPCIONAL_PROJETO_PETROPHYSICS_DBT.md)

Esse anexo existe para aprofundar o projeto sem deixar o treinamento principal refem dele.

## Parte 14 - Erros comuns de quem esta aprendendo dbt

### 14.1 Misturar tudo no staging

Erro:

- colocar regra pesada de negocio logo no staging.

Problema:

- a camada deixa de ser previsivel;
- a manutencao piora;
- o raciocinio fica escondido.

### 14.2 Usar nome de tabela bruto na mao por toda parte

Erro:

- escrever `raw.minha_tabela` diretamente em muitos arquivos.

Problema:

- origem fica mal documentada;
- renomear depois fica chato;
- o lineage perde clareza.

### 14.3 Decorar `ref()` sem entender dependencia

Erro:

- tratar `ref()` apenas como "atalho de nome".

Problema:

- a pessoa nao entende o DAG;
- quando o projeto cresce, ela se perde.

### 14.4 Achar que teste dbt e so burocracia

Erro:

- criar testes so para marcar caixa.

Problema:

- os testes deixam de representar regra real de negocio ou qualidade.

### 14.5 Criar marts sem criterio de consumo

Erro:

- materializar tabelas finais sem saber qual pergunta elas respondem.

Problema:

- o projeto vira acumulo de tabelas bonitas e pouco uteis.

## Parte 15 - Checklist de dominio

Voce esta no caminho certo se consegue explicar, com suas palavras:

1. o que e a diferenca entre `source()` e `ref()`;
2. por que staging deve ser simples;
3. onde mora a regra de negocio principal;
4. quando usar `view` e quando usar `table`;
5. por que um teste dbt falha quando retorna linhas;
6. o que significa olhar o SQL compilado;
7. como o lineage ajuda a entender impacto de mudanca;
8. como usar `--select`, `+modelo`, `modelo+` e `+modelo+`;
9. quando uma regra deveria virar teste generico, teste singular ou tabela de auditoria;
10. em que situacoes `seed`, `snapshot` e `incremental` fazem sentido;
11. quando Jinja e macro ajudam e quando atrapalham;
12. como analisar qualquer projeto dbt existente sem depender de conhecer o dominio antes.

## Parte 16 - Roteiro de estudo em 2 semanas

### Semana 1

Dia 1:

- leia Partes 1, 2 e 3;
- monte o ambiente local.

Dia 2:

- execute o carregamento bruto do Estudo de Caso 1;
- crie `sources.yml` e os models de staging.

Dia 3:

- crie o model intermediate;
- entenda cada join e cada calculo.

Dia 4:

- crie o mart final;
- rode `dbt run`.

Dia 5:

- crie `schema.yml`;
- rode `dbt test`.

Dia 6:

- gere docs;
- navegue no lineage.

Dia 7:

- revise `ref()`, `source()`, `view`, `table`, `macro`, `test`.

### Semana 2

Dia 8:

- estude a Parte 7 sobre comandos e seletores;
- pratique `dbt run`, `dbt test`, `dbt compile` e `dbt ls`.

Dia 9:

- estude a Parte 8 sobre modelagem;
- revise granularidade, joins e criterios de marts.

Dia 10:

- estude a Parte 9 sobre testes e documentacao;
- escreva uma estrategia de testes para o mini projeto.

Dia 11:

- estude as Partes 10 e 11;
- pratique `var()`, macro, `seed`, `snapshot` e `incremental` em nivel conceitual.

Dia 12:

- faca pelo menos 3 exercicios da Parte 12;
- revise o que observar no Capitulo 13.

Dia 13:

- execute o Capitulo 13 com este repositorio;
- rode a sequencia pratica e anote onde estao staging, regra principal, marts e testes.

Dia 14:

- escreva com suas palavras o fluxo completo deste projeto e compare com o mini projeto do inicio;
- se quiser aprofundar, monte ou analise um estudo de caso proprio adicional.

## Parte 17 - Fechamento

Se voce absorver bem este material, o dbt deixa de ser "uma ferramenta que roda SQL" e passa a virar o que ele realmente e:

- um sistema de organizacao de transformacoes;
- uma disciplina de modelagem analitica;
- uma forma de tornar SQL testavel, documentado e navegavel.

O principal e isto:

- nao comece por sintaxe;
- comece pelo fluxo;
- entenda a camada;
- entenda a dependencia;
- entenda a regra de negocio;
- so depois se preocupe com refinamentos avancados.

Depois que essa base estiver firme, voce consegue entrar em qualquer projeto `dbt Core` com muito mais criterio, inclusive projetos reais ja existentes, sem depender de decorar comandos ou copiar estruturas sem entender.
