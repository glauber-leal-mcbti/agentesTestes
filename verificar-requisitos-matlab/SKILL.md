---
name: verificar-requisitos-matlab
description: "Carrega, checa, lista quantos requisitos estão presentes em um arquivo de requisitos do tipo .slreqx, bem como suas informações e links com modelos. Use este skill sempre que o usuario mencionar: 'verificar requisitos matlab', 'olhar requisitos matlab', ou qualquer referencia a ler requisitos de arquivos matlab."
---
## Pre-requisitos
- MATLAB instalado com licença valida
- matlab-mcp-server instalado
- matlab-mcp-server configurado e conectado

## Ferramentas MCP Disponíveis

| Ferramenta | Uso |
|------------|-----|
| `evaluate_matlab_code` | Executa código MATLAB |
| `run_matlab_script` | Executa script .m |
| `check_matlab_code` | Analisa código |

## Estrutura de Requisitos
| Tipo do Requisito| Abreviação | Significado |
|------------------|------------|-------------|
| Funcional | FUN | O que o sistema deve fazer |
| Container | CONT | Conjunto de funcionais |
| Informational | INF | Informações sobre o sistema |

Apenas requisitos FUN são implementados no harness e no test manager para fins de validação. Requisitos CONT servem para criar um particionamento com fim de melhor organização por afinidade de função. Requisitos informacionais são usados apenas para fornecer informações, e não são implementados.

## Workflow

### Passo 1: Carregar arquivo de configuração

Use `AskUserQuestion` para coletar de forma interativa.

1. Pergunte ao usuário as seguintes informações:
   - Versão do MATLAB → `{VERSAO_MATLAB}`
   - Caminho do arquivo de projeto (.prj) → `{CAMINHO_PRJ}`
   - Nome do arquivo de requisito .slreqx → `{ARQ_REQUISITOS}`

2. Construa os caminhos completos:
   - `{CAMINHO_PRJ}` = `{PROJECT_DIR}` + arquivos necessários

### Passo 2: Configuração ambiente matlab

Caso o MATLAB não esteja configurado, leia e execute a skill `abrir-projeto-matlab/SKILL.md` usando `view`. Passe como parâmetro para essa skill:
    - `{VERSAO_MATLAB}`
    - `{CAMINHO_PRJ}`

Após execução, as variáveis estarão disponíveis:
- `{VERSAO_MATLAB}`
- `{CAMINHO_PRJ}`

O contexto do projeto já estará configurado no MATLAB.


### Passo 3: Carregar arquivo de requisitos

Carregue o arquivo de requisitos e motre ao usuário quais requisitos implementados
Use `evaluate_matlab_code` com:
```matlab
reqSet = slreq.load('{ARQ_REQUISITOS}');
requisitos = reqSet.find('Type', 'Requirement');
```

Se o arquivo não for encontrado cancele a operação.

### Passo 4: Descrever requisitos

Extraia os requisitos e motre ao usuário utilizando o seguinte script. 
Antes de executar o loop, adicione o diretório de scripts da skill ao path do MATLAB. O diretório base desta skill é conhecido — use-o para construir o caminho.
Use `evaluate_matlab_code` com:
```matlab
addpath(fullfile('{SKILL_BASE_DIR}', 'scripts'));
for i = 1:length(requisitos)
    r = requisitos(i);
    descricao = descricaoLimpa(r.Description);
    fprintf('ID: %s\n', r.Id);
    fprintf('Sumário: %s\n', r.Summary);
    fprintf('Descrição: %s\n\n', descricao);
    fprintf('Tipo: %s\n\n', r.Type);
end
```

### Passo 5: Retorno da chamada

Retorne para o usuario ou outra skill os uma tabela com os dados dos requisitos que foram lidos nessa execução.

Termine fechando o arquivo de requisito. Use `evaluate_matlab_code` com:
```matlab
slreq.clear;
```

## Error Handling

| Erro | Ação |
|------|------|
