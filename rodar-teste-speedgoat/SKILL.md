---
name: rodar-teste-speedgoat
description: "Executa os testes presentes em um arquivo .mldatx do Simulink Test Manager, para um target speedgoat disponibilizado pelo usuário. Use este skill sempre que o usuario mencionar: 'rodar teste speedgoat', 'iniciar teste speedgoat', ou qualquer referencia a executar testes em uma speedgoat."
---
## Pre-requisitos
- MATLAB instalado com licença valida
- matlab-mcp-server instalado
- Speedgoat Support Package instalado
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

### Passo 1: Carregar arquivo de configuração

Use `ask_user_input_v0` para coletar de forma interativa.

1. Pergunte ao usuário: "Informe o caminho do arquivo de configurações `.txt`"
2. Salve em `{CONFIG_PATH}`
3. Extraia o diretório de `{CONFIG_PATH}` e salve em `{PROJECT_DIR}`
   - Exemplo: se `{CONFIG_PATH}` = `/home/user/projeto/config.txt`
   - Então `{PROJECT_DIR}` = `/home/user/projeto/`
4. Pergunte ao usuário: Caminho repositório controlador → salve em `{CONTROL_PATH}`
5. Pergunte ao usuário: Nome do autor que executa os testes → salve em `{Test_File_Author}`

4. Utilize `view` em `{CONFIG_PATH}` e extraia os dados:
   - Versão do MATLAB → `{VERSAO_MATLAB}`
   - Nome do arquivo de projeto (.prj) → `{NOME_PRJ}`
   - Nome do arquivo Simulink Test Manager (.mldatx) → `{TEST_MANAGER}`
   - Nome do target Speedgoat → `{NOME_SPEEDGOAT}`
   - Título Relatórios → `{Test_Specification_Details}`

5. Construa os caminhos completos:
   - `{CAMINHO_PRJ}` = `{PROJECT_DIR}` + `{NOME_PRJ}`

### Passo 2: Configuração ambiente matlab

Leia e execute a skill `abrir-projeto-matlab/SKILL.md` usando `view`. Passe como parâmetro para essa skill:
    - `{VERSAO_MATLAB}`
    - `{CAMINHO_PRJ}`

Após execução, as variáveis estarão disponíveis:
- `{VERSAO_MATLAB}`
- `{CAMINHO_PRJ}`

O contexto do projeto já estará configurado no MATLAB.

### Passo 3: Verificar toolboxes necessários

Use `detect_matlab_toolboxes` para confirmar que estão instalados:
- Simulink Test
- Speedgoat Support Package

Se algum estiver faltando, informe o usuário e interrompa.

## Passo 4: Conectar na Speedgoat

Use `evaluate_matlab_code` com:
```matlab
    tg=slrealtime;
    tg.connect
```
Para realizar a conexão com a speedgoat. Verifique se a conexão foi realizada se o retorno da função abixo for 1:
Use `evaluate_matlab_code` com:
```matlab
    disp(tg.isConnected);
```

Se a conexão não for bem sucedida, tente novamente três vezes, e retorne ao usuário. Caso não esteja conectado, finalizar execução.

## Passo 5: Fazer upload código controlador
Faça upload do código do controlador no hardware especificado no arquivo disponibilizado. Primeiro navegue até o repositório `{CONTROL_PATH}` e então faça o upload:
Execute via bash_tool:
```bash
cd {CONTROL_PATH}
pio run --target upload
```

Verifique se o upload foi executado. Se não termine a operação.

### Passo 6: Carregar e analisar arquivo de testes

Use `evaluate_matlab_code` com:
```matlab
% Carregar Test Manager
tf = sltest.testmanager.load('{TEST_MANAGER}');

% Obter informações dos testes
testSuites = tf.getTestSuites;
numSuites = length(testSuites);

% Contar total de testes
totalTestes = 0;
infoTestes = {};

for i = 1:numSuites
    suite = testSuites(i);
    testCases = suite.getTestCases;
    numCases = length(testCases);
    totalTestes = totalTestes + numCases;
    
    for j = 1:numCases
        tc = testCases(j);
        infoTestes{end+1} = struct('suite', suite.Name, 'teste', tc.Name);
    end
end

disp(['TOTAL_SUITES: ', num2str(numSuites)]);
disp(['TOTAL_TESTES: ', num2str(totalTestes)]);
```

Informe ao usuário quantos suites e testes foram encontrados.

### Passo 7: Configurações Específicas
Realize as seguintes configurações a seguir. A ideia é pegar qual o modelo sendo executado no teste, e mudar um parmetro no mesmo
Use `evaluate_matlab_code` com:
```matlab
open_system("SystemHIL_Simscape")
set_param("SystemHIL_Simscape/IHM/setpointManual", "Value","0");
```

### Passo 8: Executar testes

**Importante**: Execute os testes em blocos menores para evitar timeout.

#### 8.1: Executar testes e coletar resultados

Use `evaluate_matlab_code` com:
```matlab
% Executar todos os testes
testSuites = tf.getTestSuites;
resultados = {};

for i = 1:length(testSuites)
    suite = testSuites(i);
    suiteName = suite.Name;
    testCases = suite.getTestCases;
    
    for j = 1:length(testCases)
        tc = testCases(j);
        tcName = tc.Name;
        
        try
            result = tc.run;
            outcome = char(result.Outcome);
            resultados{end+1} = {suiteName, tcName, outcome, ''};
            disp(['TESTE: ', tcName, ' -> ', outcome]);
        catch ME
            resultados{end+1} = {suiteName, tcName, 'ERRO', ME.message};
            disp(['TESTE: ', tcName, ' -> ERRO: ', ME.message]);
        end
    end
end

% Salvar resultados no workspace para próximo passo
disp('TESTES_CONCLUIDOS');
```

#### 8.2: Gerar relatório

Use `evaluate_matlab_code` com:
```matlab
% Coletar test cases para o relatório
testSuites = tf.getTestSuites;
tcases = [];
for i = 1:length(testSuites)
    suite = testSuites(i);
    tcs = suite.getTestCases;
    tcases = [tcases, tcs];
end

% Gerar relatório
sltest.testmanager.TestSpecReport(tcases, 'testReport.pdf',...
    'Author', '{Test_File_Author}',...
    'Title', '{Test_Specification_Details}',...
    'IncludeCustomCriteria', false,...
    'LaunchReport', true,...
    'IncludeLoggedSignals', true,...
    'IncludeTestFileOptions', true);

disp('RELATORIO_GERADO');
```

#### 8.3: Exibir sumário

Use `evaluate_matlab_code` com:
```matlab
% Calcular sumário
passaram = 0; falharam = 0; erros = 0;
for k = 1:length(resultados)
    r = resultados{k};
    if strcmp(r{3}, 'Passed')
        passaram = passaram + 1;
    elseif strcmp(r{3}, 'Failed')
        falharam = falharam + 1;
    else
        erros = erros + 1;
    end
end

disp('=== SUMARIO ===');
disp(['Passaram: ', num2str(passaram)]);
disp(['Falharam: ', num2str(falharam)]);
disp(['Erros: ', num2str(erros)]);
```
### Passo 9: Apresentar resultados

Apresente ao usuário:
- Total de testes executados
- Quantos passaram
- Quantos falharam
- Quantos tiveram erro de execução
- Lista detalhada de falhas/erros (se houver)

Utilize o modelo:
Exiba o sumário no formato:
```
┌──────────────────────┬────────────────────────────────┐
│        Item          │           Resultado            │
├──────────────────────┼────────────────────────────────┤
│ Projeto              │ {NOME_PRJ}                     │
├──────────────────────┼────────────────────────────────┤
│ Total de testes      │ {TOTAL_TESTES}                 │
├──────────────────────┼────────────────────────────────┤
│ Passaram             │ {PASSARAM} ✓                   │
├──────────────────────┼────────────────────────────────┤
│ Falharam             │ {FALHARAM} ✗                   │
├──────────────────────┼────────────────────────────────┤
│ Erros de execução    │ {ERROS}                        │
├──────────────────────┼────────────────────────────────┤
│ Relatório            │ {CAMINHO_RELATORIO}            │
└──────────────────────┴────────────────────────────────┘
```

Se houver testes que falharam, liste-os abaixo:
```
┌─────────────────────────────────────────────────────────┐
│                   Testes com Falha                      │
├──────────────────────┬──────────────────────────────────┤
│ Nome do Teste        │ Motivo                           │
├──────────────────────┼──────────────────────────────────┤
│ {NOME_TESTE_1}       │ {MOTIVO_1}                       │
├──────────────────────┼──────────────────────────────────┤
│ {NOME_TESTE_2}       │ {MOTIVO_2}                       │
└──────────────────────┴──────────────────────────────────┘
```


### Passo 10: Finalizar MATLAB
Finalize as operações do MATLAB, fechando a conexão com a speedgoat e fechando o TestManager.
Use `evaluate_matlab_code` com:
```matlab
tg.diconnect
tf.saveToFile();
tf.close();
exit;
```
Feche o MATLAB.

## Error Handling

| Erro | Ação |
|------|------|
| Toolbox não instalado | Informar qual está faltando |
| Speedgoat não conecta | Verificar IP/credenciais |
| Arquivo .mldatx não encontrado | Verificar caminho |
| Teste com erro | Registrar e continuar |