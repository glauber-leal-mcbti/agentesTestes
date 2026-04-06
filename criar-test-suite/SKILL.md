---
name: criar-test-suite
description: "Cria um test suite para um Test Manager apontado . Use este skill sempre que o usuario mencionar: 'criar test suite', 'novo test suite', ou qualquer referencia a criar test suites."
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
| `evaluate_matlab_code` | Executa código MATLAB |
| `run_matlab_script` | Executa script .m |
| `check_matlab_code` | Analisa código |

## Workflow

### Passo 1: Variáveis de configuração

Use `ask_user_input_v0` para coletar de forma interativa, ou obtenha os dados da skill que chamou essa execução.

1. Nome do Test Manager → `{NOME_TEST_MANAGER}`
2. Nome do Test Suite → `{NOME_TEST_SUITE}`

Considere que o projeto já está configurado no ambiente MATLAB.

### Passo 2: Carregar Test Manager

Carregue o arquivo de Test Manager. Para tanto use `evaluate_matlab_code` com:
```matlab
tf = sltest.testmanager.load('`{NOME_TEST_MANAGER}`');  
```
Caso o matlab acuse que o arquivo não existe chame o erro | Test Manager inexistente |

### Passo 3: Criar Test Suite

Tente criar um test suite.  Para tanto use `evaluate_matlab_code` com:
```matlab
ts = createTestSuite(tf,'`{NOME_TEST_SUITE}`');   
```
Caso o matlab acuse que o test suite já existe chame o erro | Test Suite Existente |

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
| Test Suite Existente | Informar à chamada da skill que o Test Suite já existe e pode ser utilizado |
