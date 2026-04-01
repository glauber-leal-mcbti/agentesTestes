---
name: criar-test-manager
description: "Cria um arquivo .mldatx de Test Manager. Use este skill sempre que o usuario mencionar: 'criar test manager', 'novo test manager', ou qualquer referencia a criar test managers."
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
2. Dieretório do arquivo de testes → `{DIRETORIO_TEST_MANAGER}`

Considere que o projeto já está configurado no ambiente MATLAB.

### Passo 2: Verificacar se Test Manager já existe

Verifique se o arquivo `{NOME_TEST_MANAGER}`, com extensão .mldatx, já existe no diretório `{DIRETORIO_TEST_MANAGER}`. 
    - Caso já exista lance o erro |Aquivo existente| e termine a execução. 
    - Se o arquivo não existir continue a execução da skill.

### Passo 3: Criar arquivo Test Manager

Crie um arquivo Test Manager no diretório `{DIRETORIO_TEST_MANAGER}`. Para tanto use `evaluate_matlab_code` com:
```matlab
tf = sltest.testmanager.TestFile('{DIRETORIO_TEST_MANAGER}\{NOME_TEST_MANAGER}.mldatx'); 
```


## Error Handling

| Erro | Ação |
|------|------|
| Aquivo existente | Informar à chamada da skill que o arquivo já existe e possui o nome `{NOME_TEST_MANAGER}`|
