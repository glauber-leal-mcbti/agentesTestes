---
name: matlab-teste
description: "Inicia o procedimento de abrir um .prj no matlab, abrir um script .m, abrir o arquivo de requisitos desse script, criar um teste pelo matlab test, criar e executar os testes desse .m. Use este skill sempre que o usuario mencionar: 'criar teste matlab', 'testar script matlab', 'matlab test', 'teste unitario matlab', verificar requisitos matlab', 'gerar relatorio de teste', ou qualquer referencia a testes automatizados em ambiente matlab."
---
## Pre-requisitos
- MATLAB instalado com licença valida
- MATLAB Test toolbox disponível

## Ferramentas MCP Disponíveis

| Ferramenta | Uso |
|------------|-----|
| `evaluate_matlab_code` | Executa código MATLAB |
| `run_matlab_script` | Executa script .m |
| `check_matlab_code` | Analisa código |

## Workflow

### Passo 1: Variaveis iniciais
1. Pergunte ao usuario qual a versao do MATLAB. Versoes disponiveis: R2024b, R2025a, R2025b
2. Pergunte ao usuario qual o camiho do projeto .prj e salve em '{CAMINHO_PRJ}'
3. Pergunte ao usuario qual script .m sera testado e salve em '{CAMINHO_SCRIPT}'
4. Pergunte ao usuario qual o arquivo de requisitos desse script e salve em '{CAMINHO_REQUISITOS}'
5. Pergunte ao usuario qual o caminho para salvar os arquivos de teste e salve em '{CAMINHO_TESTE}'
6. Guarde essas informacoes

### Passo 2: Inicializacao do MATLAB
1. Inicie o MATLAB, conforme a versao solicitada via 'bash_tool'

### Passo 3: Analise projeto MATLAB
1. Use 'view' no arquivo '{CAMINHO_PRJ}' para identificar 
	- Arquivos que fazem parte do projeto
	- Paths configurados
	- Dependencias
2. Use 'view' no arquivo '{CAMINHO_REQUISITOS}' para identificar
	- Quantidade de requisitos a serem testado
	- Nome de cada requisito
	- Caracteristicas de cada requisito
	- Inputs esperados para cada requisito
	- Outputs esperados para cada requisito
3. Use 'view' no arquivo '{CAMINHO_SCRIPT}' para identificar
	- Inputs do script
	- Outputs do script

### Passo 4: Criação dos arquivos de teste (paralelo)

Crie múltiplos agentes para gerar os testes simultaneamente.

Para cada requisito identificado no Passo 3, faça spawn de um agente independente:

Spawne agentes passando os resultados da análise do Passo 3:
- `script_path`: `{CAMINHO_SCRIPT}`
- `script_functions`: funções identificadas no Passo 3
- `script_inputs`: inputs identificados no Passo 3
- `script_outputs`: outputs identificados no Passo 3
- `requirement_name`: nome do requisito
- `requirement_inputs`: inputs esperados do requisito
- `requirement_outputs`: outputs esperados do requisito

**Importante**: Inicie todos os agentes simultaneamente em uma única chamada para permitir execução paralela. Não espere um agente terminar para iniciar o próximo.

Aguarde todos os agentes concluírem antes de prosseguir para o Passo 5.

### Passo 5: Validar execução dos testes

Para cada arquivo de teste criado no Passo 4, spawne um agente test-runner.

Leia o arquivo `agents/test-runner.md` usando `view` e inicie os agentes simultaneamente, passando:

- `test_file`: caminho do arquivo de teste criado
- `project_path`: `{CAMINHO_PRJ}`
- `matlab_version`: `{VERSAO_MATLAB}`

Aguarde todos os agentes concluírem.

Se algum teste retornar `erro`:
1. Apresente o erro ao usuário
2. Pergunte se deseja corrigir o arquivo de teste e tentar novamente
```

## Fluxo Simplificado
```
test-creator ──► test_req1.m ──► test-runner ──► ok / erro
3. Utilize o Passo 5 para verificar se o erro foi corrigido
