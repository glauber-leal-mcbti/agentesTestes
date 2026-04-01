---
name: criar-test-case
description: "Cria um test case para um Test Manager e um Test Suite adotados . Use este skill sempre que o usuario mencionar: 'criar test case', 'novo test case', ou qualquer referencia a criar test suites."
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

## Workflow

### Passo 1: Variáveis de configuração

Use `ask_user_input_v0` para coletar de forma interativa, ou obtenha os dados da skill que chamou essa execução.

1. Nome do Test Manager → `{NOME_TEST_MANAGER}`
2. Nome do Test Suite → `{NOME_TEST_SUITE}`
3. Nome do Test Suite → `{NOME_TEST_CASE}`
4. Modelo testado → `{NOME_MODELO}`
5. Harness testado → `{NOME_HARNESS}`
6. Descrição do teste -> `{DESCRICAO_TESTE}`

Considere que o projeto já está configurado no ambiente MATLAB.

### Passo 2: Carregar Test Manager e Suite

Carregue o arquivo de Test Manager. Para tanto use `evaluate_matlab_code` com:
```matlab
tf = sltest.testmanager.load('`{NOME_TEST_MANAGER}`');  
ts = getTestSuiteByName(tf,'`{NOME_TEST_SUITE}`'); 
```
Caso o matlab acuse que o Test Manager não existe chame o erro | Test Manager inexistente |
Caso o matlab acuse que o Test MSuite não existe chame o erro | Test Suite inexistente |

### Passo 3: Criar Test Case

Tente criar um test case.  Para tanto use `evaluate_matlab_code` com:
```matlab
tc = createTestCase(ts,'simulation','nome_do_case');
setProperty(tc,'Model','`{NOME_MODELO}`'); 
setProperty(tc,'HarnessOwner','`{NOME_MODELO}`','HarnessName','`{NOME_HARNESS}`');  
```
Caso o matlab acuse que o test case já existe chame o erro | Test Case Existente |

### Passo 4: Criar Test Case

Sete a descrição do teste de acordo com o valor do Plano de teste, disponível em `{DESCRICAO_TESTE}`.  Para tanto use `evaluate_matlab_code` com:
```matlab
setProperty(tc, 'Description', '`{DESCRICAO_TESTE}`');
```

### Passo 5: Fechar o Test Manager

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
| Test Case Existente | Informar à chamada da skill que o Test Case já existe e pode ser utilizado |
