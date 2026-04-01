---
name: criar-harness-mdl
description: "Cria um test harness no formato .mdl a partir de um modelo .slx e um requisito fornecido. Usa abordagem híbrida: API MATLAB para criação e simulação, Read/Grep/Edit direto no .mdl para inspeção e configuração do conteúdo (Test Sequence steps, símbolos, limpeza de blocos residuais). Use este skill sempre que o usuário mencionar: 'criar harness mdl', 'harness em mdl', 'test harness formato mdl', ou qualquer referência a criar harness salvos como .mdl."
---

# Criar Test Harness em formato .mdl

Abordagem híbrida:
- **API MATLAB** → criação do harness, adição de símbolos Output, simulação
- **Read/Grep/Edit no .mdl** → inspeção da estrutura gerada, limpeza de residuais, edição de step actions

## Pré-requisitos
- MATLAB R2025a ou superior instalado
- Simulink Test Toolbox instalado
- matlab-mcp-server configurado e conectado

## Considerações
O ambiente matlab e o projeto com os paths já vai estar configurado.

## Variáveis de entrada

Coletar dos argumentos da chamada:

| Variável | Descrição |
|----------|-----------|
| `{MODELO_SLX}` | Caminho completo do modelo .slx |
| `{NOME_HARNESS}` | Nome do arquivo harness (sem extensão) |
| `{PASTA_DESTINO}` | Pasta onde salvar o .mdl (default: mesma pasta do modelo) |
| `{REQUISITO}` | Texto do requisito a ser testado |
| `{INPUTS}` | Mapa nome→valor das entradas do modelo |
| `{OUTPUT_ESPERADO}` | Nome do sinal de saída a verificar |

Derivar automaticamente se `{PASTA_DESTINO}` não fornecida:
```matlab
[PASTA_DESTINO, ~, ~] = fileparts(MODELO_SLX);
```

---

## Passo 1 — Carregar modelo e inspecionar portas (API)
Considere que o projeto foi configurado no ambiente matlab e que os paths estão configurados.
Use `evaluate_matlab_code` com:
```matlab

[~, mdlBase, ~] = fileparts(MODELO_SLX);
load_system(MODELO_SLX);

inports  = find_system(mdlBase, 'SearchDepth', 1, 'BlockType', 'Inport');
outports = find_system(mdlBase, 'SearchDepth', 1, 'BlockType', 'Outport');
fprintf('Inports:\n');  disp(inports);
fprintf('Outports:\n'); disp(outports);
```

Verificar que `{OUTPUT_ESPERADO}` está na lista de outports. Se não estiver, reportar erro e parar.

---

## Passo 2 — Criar o harness e salvar como .mdl (API)

```matlab
% Remover harness anterior se existir
try; sltest.harness.delete(mdlBase, NOME_HARNESS); catch; end

% Criar harness
result = sltest.harness.create(mdlBase, ...
    'Name',               NOME_HARNESS, ...
    'Description',        REQUISITO, ...
    'Source',             'Test Sequence', ...
    'SeparateAssessment', true, ...
    'SaveExternally',     true, ...
    'HarnessPath',        PASTA_DESTINO, ...
    'LogOutputs',         true);

% Abrir o harness
sltest.harness.open(mdlBase, NOME_HARNESS);

% Salvar IMEDIATAMENTE como .mdl antes de qualquer edição
MDL_PATH = fullfile(PASTA_DESTINO, [NOME_HARNESS '.mdl']);
save_system(NOME_HARNESS, MDL_PATH);
fprintf('Harness salvo como .mdl: %s\n', MDL_PATH);
```

---

## Passo 3 — Inspecionar o .mdl gerado (Read/Grep)

**Sem usar MATLAB**, usar Read e Grep no arquivo `.mdl` para extrair:

### 3.1 — Listar partes OPC do arquivo
Grep por `__MWOPC_PART_BEGIN__` para ver todos os XMLs embutidos.

### 3.2 — Identificar símbolos auto-gerados no Test Sequence
Grep por `BlockType="SubSystem" Name="Test Sequence"` para encontrar o bloco.
Depois ler o `system_NNN.xml` correspondente.

### 3.3 — Listar blocos From/Goto no harness raiz
Grep por `BlockType="From"` no `system_root.xml` do harness para inventariar
todos os tags Goto existentes — isso permite identificar quais são residuais
após deletar símbolos Input não utilizados.

### 3.4 — Ler step actions atuais no Stateflow
Grep por `<P Name="Actions">` ou `<act>` para localizar o conteúdo dos steps.
Identificar o padrão de codificação (XML entities, CDATA, texto plano).

> **Nota de execução:** Se o Stateflow estiver em formato binário/opaco no .mdl,
> usar a API para configurar os steps (Passo 4-API) e depois re-salvar como .mdl.
> Documentar qual seção foi editada via API vs. via texto.

---

## Passo 4 — Configurar Test Sequence (API + validação Read)

### 4a — Configurar step Run (API)
Configure o step Run de acordo com o requisito e os `{INPUTS}` esperados.
Use `evaluate_matlab_code` com:
```matlab
tsBlock = [NOME_HARNESS '/Test Sequence'];

% Construir action string a partir dos INPUTS fornecidos
% Exemplo para pwm_in1=5, cw_ccw1=uint8(0):
actionStr = ['%% Configurar entradas conforme requisito' newline];
% Para cada par nome=valor em INPUTS:
%   se tipo for uint8:  actionStr += 'nome = uint8(valor);'
%   caso contrário:     actionStr += 'nome = valor;'

sltest.testsequence.editStep(tsBlock, 'Run', 'Action', actionStr);
```

### 4b — Remover símbolos Input não usados (API + limpeza .mdl)
Use `evaluate_matlab_code` com:
```matlab
% Remover símbolo Input de saída (vout) do Test Sequence
allSyms = sltest.testsequence.findSymbol(tsBlock);
for i = 1:length(allSyms)
    sym = sltest.testsequence.readSymbol(tsBlock, allSyms{i});
    if strcmp(sym.Scope, 'Input')
        sltest.testsequence.deleteSymbol(tsBlock, allSyms{i});
        fprintf('Símbolo Input removido do TS: %s\n', allSyms{i});
    end
end
```

**Imediatamente após cada deleteSymbol**, salvar .mdl e usar Grep para
encontrar blocos `From` com tag `*_S` que se tornaram residuais:

```matlab
save_system(NOME_HARNESS, MDL_PATH);
```

Grep por `BlockType="From"` no .mdl salvo e filtrar tags `*_S`.
Para cada bloco residual encontrado:

```matlab
delete_block([NOME_HARNESS '/' NOME_BLOCO_RESIDUAL]);
```

---

## Passo 5 — Configurar Test Assessment (API + Read/Edit)

### 5a — Adicionar símbolos Output (API)


Use `evaluate_matlab_code` com:
```matlab
taBlock = [NOME_HARNESS '/Test Assessment Block'];

sltest.testsequence.addSymbol(taBlock, 'result', 'Data', 'Output');
sltest.testsequence.addSymbol(taBlock, 'flag',   'Data', 'Output');
sltest.testsequence.editSymbol(taBlock, 'result', 'DataType', 'boolean');
sltest.testsequence.editSymbol(taBlock, 'flag',   'DataType', 'boolean');
```
Para os sinais flag e result que saem do test assessment adicione uma conexão a um bloco terminator e nomeie os sinais com seus respectivos nomes.

### 5b — Configurar steps (API)

Descobrir a estrutura dos steps:
Use `evaluate_matlab_code` com:
```matlab
taSteps = sltest.testsequence.findStep(taBlock);
for i = 1:length(taSteps)
    st = sltest.testsequence.readStep(taBlock, taSteps{i});
    fprintf('%s | IsWhenSubStep=%d\n', st.Name, st.IsWhenSubStep);
    if st.IsWhenSubStep; fprintf('  WhenCondition: %s\n', st.WhenCondition); end
end
```

Configure o step de verificação de acordo com a descrição do requisito e o plano de teste. Utilize o seguinte exemplo para saber como alterar o bloco de Test asessement para adicionar condições de verificação.


Exemplo:
Configurar step de verificação (otherwise — último filho, sem WhenCondition):
```matlab
% Calcular limites a partir de VALOR_ESPERADO e TOLERANCIA_PCT
vMin = VALOR_ESPERADO * (1 - TOLERANCIA_PCT/100);
vMax = VALOR_ESPERADO * (1 + TOLERANCIA_PCT/100);

sltest.testsequence.editStep(taBlock, 'Run.step_1_2', 'Action', ...
    sprintf(['%%%% Verificar requisito: %s ~ %.4g V (+-%.0f%%)' newline ...
             'flag = true;' newline ...
             'result = boolean((%s >= %.6g) && (%s <= %.6g));'], ...
             OUTPUT_ESPERADO, VALOR_ESPERADO, TOLERANCIA_PCT, ...
             OUTPUT_ESPERADO, vMin, OUTPUT_ESPERADO, vMax));
```

> **Regra crítica:** O último `step_1_N` de um when-decomposition nunca aceita
> `WhenCondition` — ele é implicitamente o ramo "otherwise". Nunca tentar
> definir `WhenCondition` nele.

---

## Passo 6 — Salvar .mdl final e verificar via Read (API + Read/Grep)

```matlab
save_system(NOME_HARNESS, MDL_PATH);
```

Verificar no .mdl salvo (Read/Grep) as seguintes condições:

| Check | Grep pattern | Esperado |
|-------|-------------|---------|
| Símbolos Output existem | `result.*Output\|flag.*Output` | 2 matches |
| Step Run configurado | valor do input (ex: `pwm_in1 = 5`) | presente |
| Step step_1_2 configurado | valor min (ex: `319.2`) | presente |
| Nenhum From residual | `vout.*_S` | 0 matches |

---

## Passo 7 — Simular e validar compilação (API)

```matlab
try
    sim(NOME_HARNESS, 'StopTime', num2str(TEMPO_ESTABILIZACAO * 2));
    fprintf('Simulacao OK.\n');
catch ME
    fprintf('ERRO de compilacao: %s\n', ME.message);
    % Tentar diagnóstico: verificar símbolos não resolvidos
    % Corrigir e tentar novamente (máx 2 tentativas)
end
```

**Warnings esperados e aceitáveis:**
- `'pwm_in1' is defined, but never used in the Test Sequence block` — normal, são
  Input symbols no Test Assessment que não precisam ser referenciados nas actions.

**Erros que requerem correção:**
- `unresolved symbols` → variável local usada em step sem ser declarada como símbolo
- `compilation failures` → Data Dictionary não no path
- `Chart has unresolved symbols` → símbolo usado na action mas não declarado

---

## Passo 8 — Retorno

Reportar ao usuário:

```
Harness criado: {MDL_PATH}
Modelo testado: {MODELO_SLX}
Requisito: {REQUISITO}

Test Sequence — Run:
  {INPUTS formatados}

Test Assessment — step_1_1 (t < {TEMPO_ESTABILIZACAO}s):
  flag = false; result = false;

Test Assessment — step_1_2 (otherwise):
  flag = true;
  result = ({OUTPUT_ESPERADO} ∈ [{vMin:.4g}, {vMax:.4g}]);

Status da simulação: OK / ERRO
```

---

## Referência: Anatomia do .mdl OPC Text Package

```
__MWOPC_PART_BEGIN__ /simulink/systems/system_root.xml
  → blocos raiz do harness: Test Sequence, Test Assessment,
    Model Reference, From/Goto, Conversion Subsystems

__MWOPC_PART_BEGIN__ /simulink/systems/system_NNN.xml
  → interior de cada SubSystem (incluindo Test Seq / Assessment)

__MWOPC_PART_BEGIN__ /simulink/blockdiagram.xml
  → metadados do modelo: UUID, DataDictionary, SimulationMode

__MWOPC_PART_BEGIN__ /simulink/graphicalInterface.json
  → nomes de inports/outports raiz e signal names

__MWOPC_PART_BEGIN__ /simulink/bdmxdata/*.mxarray BASE64
  → dados binários (Simscape, etc.) — NÃO editar via texto
```

### O que é seguro editar diretamente no .mdl

| Elemento | Localização | Edição segura |
|----------|-------------|--------------|
| Posição de bloco | `system_NNN.xml` → `<P Name="Position">` | Sim |
| Parâmetros numéricos | `system_NNN.xml` → `<P Name="Value">` | Sim |
| Nome de bloco | `system_NNN.xml` → `Name="..."` no `<Block>` | Com cuidado (atualizar refs) |
| SIDHighWatermark | `system_root.xml` | Sim, ao adicionar blocos |
| Step actions (Stateflow) | Via API — não em XML direto | Somente via API |
| Símbolos TS/TA | Via API — não em XML direto | Somente via API |
| Linhas (connections) | `system_NNN.xml` → `<Line>` | Sim |
| Blocos atômicos | `system_NNN.xml` → `<Block>` | Sim |

---

## Error Handling

| Erro | Diagnóstico | Ação |
|------|-------------|------|
| `Unable to find data dictionary` | SLDD não no path | Buscar .sldd na árvore do projeto com `find_system` ou `dir` recursivo e adicionar ao path |
| `unresolved symbols` no Assessment | Variável usada na action sem ser símbolo | Usar valores literais inline em vez de variáveis locais |
| `WhenCondition not allowed in step` | Tentando definir condição no último filho do when-decomp | Remover o parâmetro `WhenCondition` da chamada `editStep` |
| From residual após `deleteSymbol` | Tag `*_S` presente no system_root | `delete_block` + re-salvar .mdl |
| Harness já existe | `sltest.harness.delete` lança erro | Usar `try/catch` no delete |
| Modelo não compila | Dependências externas | Verificar path completo e Data Dictionary |
