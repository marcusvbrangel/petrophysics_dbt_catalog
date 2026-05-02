# dbt Flow

## Objetivo

Este arquivo resume um fluxo completo e pratico de comandos para trabalhar com `dbt Core`.

O foco aqui e responder:

- quando usar `dbt init`;
- onde entra `dbt compile`;
- qual e o fluxo de um projeto novo;
- qual e o fluxo de um projeto ja existente;
- como pensar desenvolvimento, validacao e producao.

## Regra principal

`dbt init` so entra quando voce ainda vai criar um projeto novo.

Se o projeto ja existe, o fluxo nao comeca com `dbt init`.

Ele normalmente comeca com:

```bash
source .venv/bin/activate
dbt debug
dbt deps
```

## Visao geral do fluxo

Em alto nivel, o fluxo mental de `dbt Core` e este:

```text
ambiente -> projeto -> profile -> debug -> dependencias -> dado bruto -> seed opcional -> compile opcional -> run/build -> test -> docs
```

## Fluxo 1 - Projeto novo do zero

### 1. Criar e ativar ambiente Python

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install dbt-core dbt-duckdb
```

Se usar outro banco, troque o adapter correspondente.

Exemplos:

- `dbt-postgres`
- `dbt-bigquery`
- `dbt-snowflake`

### 2. Criar o projeto

```bash
dbt init meu_projeto
```

Aqui o `dbt init`:

- cria a estrutura inicial;
- gera o esqueleto de pastas;
- ajuda a iniciar o `profiles.yml`.

### 3. Entrar na pasta do projeto

```bash
cd meu_projeto
```

### 4. Configurar o `profiles.yml`

Esse arquivo define:

- qual banco sera usado;
- onde esta esse banco;
- credenciais;
- target ativo;
- numero de threads.

Sem `profiles.yml`, o projeto existe, mas nao consegue se conectar corretamente.

### 5. Validar ambiente e conexao

```bash
dbt debug
```

Esse e o primeiro comando realmente obrigatorio apos configurar ambiente e profile.

Ele verifica:

- se o projeto esta valido;
- se o profile foi encontrado;
- se o adapter esta instalado;
- se a conexao funciona.

### 6. Baixar dependencias do projeto, se houver

```bash
dbt deps
```

Use isso quando houver `packages.yml`.

### 7. Colocar o dado bruto no banco

Esse passo normalmente acontece fora do dbt.

Exemplos:

- script Python;
- carga CSV;
- ingestao por ferramenta externa;
- tabela ja existente no warehouse.

### 8. Rodar `dbt seed`, se usar `seeds/`

```bash
dbt seed
```

Use apenas se o projeto tiver arquivos CSV versionados em `seeds/`.

### 9. Criar `sources`, `models`, `tests`, `macros` e documentacao

Aqui comeca o trabalho real de modelagem:

- declarar `sources`;
- criar `staging`;
- criar `intermediate`;
- criar `marts`;
- documentar colunas;
- criar testes.

### 10. Compilar, se quiser inspecionar o SQL final

```bash
dbt compile
```

Esse passo e opcional.

Use quando quiser:

- ver o SQL final compilado;
- inspecionar `ref()`, `source()`, macros e Jinja;
- depurar antes de executar.

Importante:

- `dbt compile` nao substitui `dbt run`;
- `dbt run` ja compila internamente antes de executar.

### 11. Construir os models

```bash
dbt run
```

Ou rodar so parte do projeto:

```bash
dbt run --select stg_orders
dbt run --select +mart_customer_sales
dbt run --select stg_orders+
dbt run --select +mart_customer_sales+
```

### 12. Rodar os testes

```bash
dbt test
```

### 13. Gerar documentacao

```bash
dbt docs generate
dbt docs serve
```

## Fluxo 2 - Projeto ja existente

Se o projeto ja existe, o fluxo mais comum e este:

### 1. Ativar ambiente

```bash
source .venv/bin/activate
```

### 2. Validar conexao e setup

```bash
dbt debug
```

### 3. Baixar ou atualizar packages, se houver

```bash
dbt deps
```

### 4. Atualizar `seed`, se o projeto usar

```bash
dbt seed
```

### 5. Compilar, se estiver depurando

```bash
dbt compile
```

### 6. Rodar transformacoes

```bash
dbt run
```

Ou:

```bash
dbt run --select nome_do_model
```

### 7. Rodar testes

```bash
dbt test
```

### 8. Atualizar docs

```bash
dbt docs generate
```

## Fluxo 3 - Desenvolvimento diario

No dia a dia, o fluxo costuma ser menor e mais focado no escopo alterado.

### Sequencia recomendada

```bash
source .venv/bin/activate
dbt debug
dbt deps
dbt compile --select nome_do_model
dbt run --select +nome_do_model+
dbt test --select +nome_do_model+
```

### Logica desse fluxo

- `dbt debug`: confirma que o ambiente esta sano;
- `dbt deps`: garante dependencias do projeto;
- `dbt compile --select ...`: ajuda a inspecionar o SQL do escopo alterado;
- `dbt run --select +model+`: constroi o trecho relevante do grafo;
- `dbt test --select +model+`: valida o mesmo trecho.

## Fluxo 4 - Fluxo integrado com `dbt build`

Se o projeto esta mais maduro, voce pode usar:

```bash
dbt build
```

Esse comando integra, conforme o projeto:

- `seed`
- `snapshot`
- `run`
- `test`

Use quando:

- faz sentido ter um fluxo mais integrado;
- a expectativa e falhar cedo se algo quebrar;
- o projeto esta com comportamento mais previsivel.

Nao use automaticamente so porque parece mais completo. Em contexto exploratorio, `run` e `test` separados podem ser melhores.

## Fluxo 5 - Producao ou CI

Um fluxo tipico de CI com `dbt Core` pode ser:

```bash
source .venv/bin/activate
dbt debug
dbt deps
dbt build
dbt docs generate
```

Dependendo do projeto, tambem pode haver:

- validacao de estilo SQL;
- checagem de artefatos;
- publicacao de docs;
- passos externos de carga antes do dbt.

## Onde entra `dbt compile`

`dbt compile` entra como ferramenta de inspecao e debug.

Ele e especialmente util quando voce quer:

- ver o SQL final em `target/compiled/`;
- conferir se o Jinja expandiu como esperado;
- validar `ref()` e `source()`;
- depurar macros;
- checar um model antes de rodar.

### Exemplos

Compilar tudo:

```bash
dbt compile
```

Compilar um model especifico:

```bash
dbt compile --select mart_customer_sales
```

Compilar um trecho inline:

```bash
dbt compile --inline "select * from {{ ref('stg_orders') }}"
```

## Onde `dbt compile` nao entra

Ele nao e:

- substituto de `dbt run`;
- substituto de `dbt test`;
- obrigatorio em toda execucao;
- o primeiro comando do projeto.

## Sequencia completa recomendada

### Projeto novo

```text
python/venv -> instalar dbt -> dbt init -> configurar profiles.yml -> dbt debug -> dbt deps -> carregar bruto -> dbt seed opcional -> dbt compile opcional -> dbt run -> dbt test -> dbt docs generate
```

### Projeto existente

```text
ativar venv -> dbt debug -> dbt deps -> dbt seed opcional -> dbt compile opcional -> dbt run -> dbt test -> dbt docs generate
```

### Fluxo integrado

```text
ativar venv -> dbt debug -> dbt deps -> dbt build -> dbt docs generate
```

## Resumo final

Se o projeto ainda nao existe:

```bash
dbt init
```

Se o projeto ja existe:

```bash
dbt debug
```

Se voce quer inspecionar o SQL:

```bash
dbt compile
```

Se voce quer construir os models:

```bash
dbt run
```

Se voce quer validar os dados:

```bash
dbt test
```

Se voce quer um fluxo mais integrado:

```bash
dbt build
```
