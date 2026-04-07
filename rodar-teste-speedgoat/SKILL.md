---
name: run-speedgoat-test
description: "Executes tests from a Simulink Test Manager .mldatx file on a Speedgoat target provided by the user. Use this skill whenever the user mentions: 'run speedgoat test', 'start speedgoat test', or any reference to running tests on a Speedgoat."
---

## Prerequisites
- MATLAB installed with a valid license
- matlab-mcp-server configured and connected

## Available MCP Tools

| Tool | Usage |
|------|-------|
| `evaluate_matlab_code` | Executes MATLAB code |
| `run_matlab_script` | Executes a .m script |
| `check_matlab_code` | Analyzes code |

## Workflow

### Step 1: Load configuration file

Use `AskUserQuestion` to collect interactively.

1. Ask the user: "Enter the path to the configuration file `.txt`"
2. Save in `{CONFIG_PATH}`
3. Extract the directory from `{CONFIG_PATH}` and save in `{PROJECT_DIR}`
   - Example: if `{CONFIG_PATH}` = `/home/user/project/config.txt`
   - Then `{PROJECT_DIR}` = `/home/user/project/`
4. Ask the user: Controller repository path → save in `{CONTROL_PATH}`
5. Ask the user: Name of the author running the tests → save in `{TEST_FILE_AUTHOR}`

6. Use `view` on `{CONFIG_PATH}` and extract the following data:
   - MATLAB version → `{MATLAB_VERSION}`
   - Project file name (.prj) → `{PRJ_NAME}`
   - Simulink Test Manager file name (.mldatx) → `{TEST_MANAGER}`
   - Speedgoat target name → `{SPEEDGOAT_NAME}`
   - Report title → `{TEST_SPECIFICATION_DETAILS}`

7. Build the full paths:
   - `{PRJ_PATH}` = `{PROJECT_DIR}` + `{PRJ_NAME}`

### Step 2: Configure MATLAB environment

Read and execute the `open-matlab-project/SKILL.md` skill using `view`. Pass the following parameters to that skill:
  - `{MATLAB_VERSION}`
  - `{PRJ_PATH}`

After execution, the following variables will be available:
- `{MATLAB_VERSION}`
- `{PRJ_PATH}`

The project context will already be configured in MATLAB.

### Step 3: Connect to Speedgoat

Use `evaluate_matlab_code` with:
```matlab
tg = slrealtime;
tg.connect
```
To establish the connection with the Speedgoat. Verify the connection was successful if the following function returns 1:
Use `evaluate_matlab_code` with:
```matlab
disp(tg.isConnected);
```

If the connection is unsuccessful, retry three times, then report back to the user. If still not connected, stop execution.

### Step 4: Upload controller code

Upload the controller code to the specified hardware. First navigate to the repository `{CONTROL_PATH}` and then perform the upload:
Execute via bash_tool:
```bash
cd {CONTROL_PATH}
pio run --target upload
```

Verify that the upload was successful. If not, stop the operation.

### Step 5: Load and analyze test file

Use `evaluate_matlab_code` with:
```matlab
% Load Test Manager
tf = sltest.testmanager.load('{TEST_MANAGER}');

% Get test information
testSuites = tf.getTestSuites;
numSuites = length(testSuites);

% Count total tests
totalTests = 0;
testInfo = {};

for i = 1:numSuites
    suite = testSuites(i);
    testCases = suite.getTestCases;
    numCases = length(testCases);
    totalTests = totalTests + numCases;

    for j = 1:numCases
        tc = testCases(j);
        testInfo{end+1} = struct('suite', suite.Name, 'test', tc.Name);
    end
end

disp(['TOTAL_SUITES: ', num2str(numSuites)]);
disp(['TOTAL_TESTS: ', num2str(totalTests)]);
```

Inform the user how many suites and tests were found.

### Step 6: Specific configurations
Perform the following configurations. The goal is to identify which model is being run in the test and change a parameter in it.
Use `evaluate_matlab_code` with:
```matlab
open_system("SystemHIL_Simscape")
set_param("SystemHIL_Simscape/IHM/setpointManual", "Value", "0");
```

### Step 7: Run tests

**Important**: Execute tests in smaller blocks to avoid timeout.

#### 7.1: Run tests and collect results

Use `evaluate_matlab_code` with:
```matlab
% Run all tests
testSuites = tf.getTestSuites;
results = {};

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
            results{end+1} = {suiteName, tcName, outcome, ''};
            disp(['TEST: ', tcName, ' -> ', outcome]);
        catch ME
            results{end+1} = {suiteName, tcName, 'ERROR', ME.message};
            disp(['TEST: ', tcName, ' -> ERROR: ', ME.message]);
        end
    end
end

% Save results in workspace for next step
disp('TESTS_COMPLETED');
```

#### 7.2: Generate report

Use `evaluate_matlab_code` with:
```matlab
% Collect test cases for the report
testSuites = tf.getTestSuites;
tcases = [];
for i = 1:length(testSuites)
    suite = testSuites(i);
    tcs = suite.getTestCases;
    tcases = [tcases, tcs];
end

% Generate report
sltest.testmanager.TestSpecReport(tcases, 'testReport.pdf', ...
    'Author', '{TEST_FILE_AUTHOR}', ...
    'Title', '{TEST_SPECIFICATION_DETAILS}', ...
    'IncludeCustomCriteria', false, ...
    'LaunchReport', true, ...
    'IncludeLoggedSignals', true, ...
    'IncludeTestFileOptions', true);

disp('REPORT_GENERATED');
```

#### 7.3: Display summary

Use `evaluate_matlab_code` with:
```matlab
% Calculate summary
passed = 0; failed = 0; errors = 0;
for k = 1:length(results)
    r = results{k};
    if strcmp(r{3}, 'Passed')
        passed = passed + 1;
    elseif strcmp(r{3}, 'Failed')
        failed = failed + 1;
    else
        errors = errors + 1;
    end
end

disp('=== SUMMARY ===');
disp(['Passed: ', num2str(passed)]);
disp(['Failed: ', num2str(failed)]);
disp(['Errors: ', num2str(errors)]);
```

### Step 8: Present results

Present the following to the user:
- Total tests executed
- How many passed
- How many failed
- How many had execution errors
- Detailed list of failures/errors (if any)

Display the summary in the following format:
```
┌──────────────────────┬────────────────────────────────┐
│        Item          │            Result              │
├──────────────────────┼────────────────────────────────┤
│ Project              │ {PRJ_NAME}                     │
├──────────────────────┼────────────────────────────────┤
│ Total tests          │ {TOTAL_TESTS}                  │
├──────────────────────┼────────────────────────────────┤
│ Passed               │ {PASSED} ✓                     │
├──────────────────────┼────────────────────────────────┤
│ Failed               │ {FAILED} ✗                     │
├──────────────────────┼────────────────────────────────┤
│ Execution errors     │ {ERRORS}                       │
├──────────────────────┼────────────────────────────────┤
│ Report               │ {REPORT_PATH}                  │
└──────────────────────┴────────────────────────────────┘
```

If there are failed tests, list them below:
```
┌─────────────────────────────────────────────────────────┐
│                     Failed Tests                        │
├──────────────────────┬──────────────────────────────────┤
│ Test Name            │ Reason                           │
├──────────────────────┼──────────────────────────────────┤
│ {TEST_NAME_1}        │ {REASON_1}                       │
├──────────────────────┼──────────────────────────────────┤
│ {TEST_NAME_2}        │ {REASON_2}                       │
└──────────────────────┴──────────────────────────────────┘
```

### Step 9: Finalize MATLAB
Finalize MATLAB operations, closing the Speedgoat connection and the Test Manager.
Use `evaluate_matlab_code` with:
```matlab
tg.disconnect
tf.saveToFile();
tf.close();
exit;
```
Close MATLAB.

## Error Handling

| Error | Action |
|-------|--------|
| Toolbox not installed | Report which one is missing |
| Speedgoat won't connect | Check IP/credentials |
| .mldatx file not found | Verify path |
| Test with error | Log and continue |