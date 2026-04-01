---
name: criar-test-assessment
description: "Cria um test assessment para um Test Manager, um Test Suite e um Test Case adotados. Esse assessment é criado a partir da copia de um template. Use este skill sempre que o usuario mencionar: 'criar test case', 'novo test case', ou qualquer referencia a criar test suites."
---
## Pre-requisitos
- MATLAB instalado com licença valida
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

## Template

O template nomeado `{Assesstment_template}` localizado em `assets/Assesstment_template.mldatx` (relativo a esta skill). Nunca edite o template.

## Workflow

### Passo 1: Variáveis de configuração

Use `ask_user_input_v0` para coletar de forma interativa, ou obtenha os dados da skill que chamou essa execução.

1. Nome do Test Manager → `{NOME_TEST_MANAGER}`
2. Nome do Test Suite → `{NOME_TEST_SUITE}`
3. Nome do Test Case → `{NOME_TEST_CASE}`
4. Nome do Test Assessment → `{NOME_TEST_ASS}`
5. Nivel do Test Assessment (MIL ou HIL) → `{NIVEL_ASS}`
6. Tipo do Test Assessment (verificação) → `{TIPO_ASS}`

Considere que o projeto já está configurado no ambiente MATLAB.

### Passo 2: Carregar Test Manager e Suite principais

Carregue o arquivo de Test Manager. Para tanto use `evaluate_matlab_code` com:
```matlab
tf = sltest.testmanager.load('`{NOME_TEST_MANAGER}`');  
ts = getTestSuiteByName(tf,'`{NOME_TEST_SUITE}`');
tc = getTestCaseByName(ts, '`{NOME_TEST_CASE}`');
```
Caso o matlab acuse que o Test Manager não existe chame o erro | Test Manager inexistente |
Caso o matlab acuse que o Test Suite não existe chame o erro | Test Suite inexistente |
Caso o matlab acuse que o Test Case não existe chame o erro | Test Case inexistente |

### Passo 3: Copiar Assessment template WORKING IN PROGRESS $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

Copie o Assessment template do arquivo de template `{Assesstment_template}`, indicado no início dessa skill. Para tanto use `evaluate_matlab_code` com:
```matlab
tftemp = sltest.testmanager.load('`{Assesstment_template}`'); 
tstemp = getTestSuiteByName(tf,'`{NIVEL_ASS}`');
tctemp = getTestCaseByName(ts, '`{TIPO_ASS}`');
asstemp = getAssessments(tctemp);
ass=addAssessment(tc,assT); 

```
Caso o matlab acuse que o test case já existe chame o erro | Test Case Existente |

### Passo 4: Fechar o Test Manager

Feche o arquivo do Test Manager. Para tanto use `evaluate_matlab_code` com:
```matlab
tf.saveToFile(); 
tf.close(); 
```


## Error Handling

| Erro | Ação |
|------|------|
| Test Manager inexistente | Informar à chamada da skill que o arquivo `{NOME_TEST_MANAGER}` não existe no contexto do projeto|
| Test Suite inexistente | Informar à chamada da skill que a instância `{NOME_TEST_SUITE}` não existe no contexto do projeto|
| Test Case inexistente | Informar à chamada da skill que a instância `{NOME_TEST_CASE}` não existe no contexto do projeto|

