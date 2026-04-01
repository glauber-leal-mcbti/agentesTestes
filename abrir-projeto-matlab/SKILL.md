---
name: abrir-projeto-matlab
description: "Configura o ambiente MATLAB com um projeto .prj para uso por outras skills. Use este skill sempre que o usuário mencionar: 'abrir projeto matlab', 'configurar projeto matlab', ou como pré-requisito de outras skills MATLAB."
---

## Pré-requisitos
- MATLAB instalado com licença válida
- matlab-mcp-server instalado e conectado

## Workflow

### Passo 1: Coletar informações do usuário

Pegue as seguintes variáveis da chamada:

1. Versão do MATLAB → `{VERSAO_MATLAB}`
2. Caminho completo do projeto .prj → `{CAMINHO_PRJ}`

### Passo 2: Validar ambiente MATLAB

1. Use `detect_matlab_toolboxes` para verificar se o MATLAB está funcionando.
2. Verifique se a versão do MATLAB instalado é a mesma que `{VERSAO_MATLAB}`

Se retornar erro, informe o usuário e interrompa.

### Passo 3: Configurar contexto do projeto

Extraia o diretório a partir de `{CAMINHO_PRJ}`.

Use `set_project_context` com:
- `project_path`: diretório do arquivo .prj

### Passo 4: Retornar configuração

Disponibilize para quem chamou esta skill:

| Variável | Descrição |
|----------|-----------|
| `{VERSAO_MATLAB}` | Versão do MATLAB |
| `{CAMINHO_PRJ}` | Caminho do arquivo .prj |

## Error Handling

| Erro | Ação |
|------|------|
| MCP não conectado | Informar usuário |
| Caminho inválido | Verificar caminho informado |