---
name: processo-test-wip
description: "Gerencia o processo completo de criação de um test no simulink, não está finalizado - Working in progress. Use este skill sempre que o usuario mencionar: 'processo testes completo', 'gerar testes completo', ou qualquer referencia a criar um ambiente de teste completo."
---
## Pre-requisitos
- MATLAB instalado com licença valida
- matlab-mcp-server instalado
- Speedgoat Support Package instalado
- Simulink Test API instalado
- matlab-mcp-server configurado e conectado

## Ferramentas MCP Disponíveis

| Ferramenta | Uso |
|------------|-----|
| `set_project_context` | Define diretório de trabalho |
| `evaluate_matlab_code` | Executa código MATLAB |
| `run_matlab_script` | Executa script .m |
| `detect_matlab_toolboxes` | Verifica toolboxes |
| `check_matlab_code` | Analisa código |

## Estrutura de Requisitos
Os requisitos são estruturados da seuinte maneira:

| Tipo do Requisito| Abreviação | Significado |
|------------------|------------|-------------|
| Funcional | FUN | O que o sistema deve fazer |
| Container | CONT | Conjunto de funcionais |
| Informational | INF | Informações sobre o sistema |

Apenas requisitos FUN são implementados no harness e no test manager para fins de validação. Requisitos CONT servem para criar um particionamento com fim de melhor organização por afinidade de função. Requisitos informacionais são usados apenas para fornecer informações, e não são implementados.

Os requisitos são nomeados com a seguinte estrutura:
[Sistema]-[Subsistema]-[Tipo]-[Número]

Sendo:
 - Sistema: sistema que ele verifica
 - Subsistema: subsistema que ele verifica
 - Tipo: FUN, CONT, INF
 - Número: numeração do requisito

## Workflow

### Passo 1: Variáveis de configuração

Use `AskUserQuestion` para coletar de forma interativa, ou obtenha os dados da skill que chamou essa execução.

  - Versão do MATLAB → `{VERSAO_MATLAB}`
  - Caminho do arquivo de projeto (.prj) → `{CAMINHO_PRJ}`
  - Nome do arquivo de requisito .slreqx → `{ARQ_REQUISITOS}`
  - Nome do arquivo de plano de teste → `{ARQ_PLANO}`
  - Modelo em que sera criado o harness → `{MODELO_TESTE}`

Considere que o projeto já está configurado no ambiente MATLAB.

### Passo 2: Configuração ambiente matlab

Leia e execute a skill `abrir-projeto-matlab/SKILL.md` usando `view`. Passe como parâmetro para essa skill:
  - `{VERSAO_MATLAB}`
  - `{CAMINHO_PRJ}`

Após execução, as variáveis estarão disponíveis:
- `{VERSAO_MATLAB}`
- `{CAMINHO_PRJ}`

### Passo 3: Ler requisitos

Leia e execute a skill `verificar-requisitos-matlab/SKILL.md` usando `view`. Passe como parâmetro para essa skill:
  - Versão do MATLAB → `{VERSAO_MATLAB}`
  - Caminho do arquivo de projeto (.prj) → `{CAMINHO_PRJ}`
  - Nome do arquivo de requisito .slreqx → `{ARQ_REQUISITOS}`

Salve as informações dos requisitos, como nome.

### Passo 4: Ler requisitos

Leia o arquivo `{ARQ_PLANO}` e associe o plano de teste para cada requisito identificado. Passe como parâmetro para essa skill:


### Passo 5: Gerar test harness WIP

Os testes harness devem ser salvos no melhor diretório disponível na arquitetura do projeto, de acordo com a parte de testes e o modelo em teste. Salve esse caminho em `{PASTA_TESTES}`.

Lance um agente para cada requisito a ser testado

Utilize a skill criar-harness-mdl para gerar o test harness que verificada requisito. De acordo com o requisito e com o plano de teste gere os inputs necessarios `{INPUTS}` e os valores de output do modelo esperados para que o teste seja considerado aprovado `{OUTPUTS_ESPERADOS}`. Execute a skill criar-harness-mdl passando os valores:
  - Modelo .slx → `{MODELO_TESTE}`
  - Nome do harness → número do requisito mais o nome do modelo `{MODELO_TESTE}`
  - Pasta de destino → `{PASTA_TESTES}`
  - Requisto a ser testado
  - Inputs → `{INPUTS}`
  - Outputs esperados → `{OUTPUTS_ESPERADOS}`

Salve os nomes dos harness gerados para a execução a seguir


### Passo 6: Criar estrutura de teste

Nomeie o arquivo de Test Manager com o nome do mdelo mais a palavra "Manager" no final `{MODELO_TESTE}`+"Manager" → `{NOME_TEST_MANAGER}`
Nomeie o Test Suite conforme o requisito CONT que engloba o requisito implementado `{REQUISITO_A_IMPLEMENTAR}` → `{NOME_TEST_SUITE}`
Nomeie o Test Case com o nome do requisito FUN que ele verifica → `{NOME_TEST_CASE}`

Crie ou indentifique o arquivo do teste manager. Leia a estrutura do projeto para salvar esse arquivo no local condizente aos testes, como uma pasta salva como o nome de teste, com o nome do modelo. Isso não é regra para todos os projetos. Para realizar essa tarefa, leia e execute a skill `criar-test-manager/SKILL.md` usando `view`. Passe como parâmetro para essa skill:
1. Nome do Test Manager → `{NOME_TEST_MANAGER}`
2. Dieretório do arquivo de testes → `{DIRETORIO_TEST_MANAGER}`

Leia e execute a skill `criar-test-suite/SKILL.md` usando `view`. Passe como parâmetro para essa skill:
1. Nome do Test Manager → `{NOME_TEST_MANAGER}`
2. Nome do Test Suite → `{NOME_TEST_SUITE}`

Leia e execute a skill `criar-test-case/SKILL.md` usando `view`. Passe como parâmetro para essa skill:
1. Nome do Test Manager → `{NOME_TEST_MANAGER}`
2. Nome do Test Suite → `{NOME_TEST_SUITE}`
3. Nome do Test Suite → `{NOME_TEST_CASE}`
4. Modelo testado → `{MODELO_TEST}`
5. Harness testado → `{NOME_HARNESS}`
6. Passe uma descrição de como o teste foi implementado de acordo com as instruções de `{ARQ_PLANO}`. Considere a descrição dos requisitos relacionados, com tipo CONT

Leia e execute a skill `criar-test-assessment/SKILL.md` usando `view`. Passe como parâmetro para essa skill:
1. Nome do Test Manager → `{NOME_TEST_MANAGER}`
2. Nome do Test Suite → `{NOME_TEST_SUITE}`
3. Nome do Test Case → `{NOME_TEST_CASE}`
4. Nome do Test Assessment → `{NOME_TEST_ASS}`
5. Nivel do Test Assessment (MIL ou HIL) → `{NIVEL_ASS}`
6. Tipo do Test Assessment (verificação) → `{TIPO_ASS}`


### Passo 7: Criar estrutura de teste

Finalize o matlab para tanto use `evaluate_matlab_code` com:
```matlab
exit;
```

Instrua o usuário a alterar as variáveis do test assessment, para tanto aponte qual a estrutura foi criada


## Error Handling

| Erro | Ação |
|------|------|
| Test Manager inexistente | Informar à chamada da skill que o arquivo `{NOME_TEST_MANAGER}` não existe no contexto do projeto|
| Test Suite inexistente | Informar à chamada da skill que a instância `{NOME_TEST_SUITE}` não existe no contexto do projeto|
| Test Case Existente | Informar à chamada da skill que o Test Case já existe e pode ser utilizado |
