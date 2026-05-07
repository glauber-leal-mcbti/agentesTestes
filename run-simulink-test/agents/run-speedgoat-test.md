# Test Creator Agent
This Agent runs a test file with a HiL configuration for the skill ________________

## Workflow

### Step 1: Load Inputs

Read the inputs from the caller skill:
   - Porject directory → `{PROJECT_DIR}`
   - MATLAB version → `{MATLAB_VERSION}`
   - Project file name (.prj) → `{PRJ_NAME}`
   - Simulink Test Manager file name (.mldatx) → `{TEST_MANAGER}`
   - Speedgoat target name → `{SPEEDGOAT_NAME}`
   - Controller repository path → `{CONTROL_PATH}`
   - Report title → `{TEST_SPECIFICATION_DETAILS}`
   - Test autor → `{TEST_FILE_AUTHOR}`


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

resultSet = sltest.testmanager.run;

% Save results in workspace for next step
disp('TESTS_COMPLETED');
```

#### 7.2: Generate report

Use `evaluate_matlab_code` with:
```matlab
% Collect test cases for the report

testFilePath = tf.FilePath;
[testFolder,~,~] = fileparts(testFilePath);
reportPath = fullfile(testFolder, 'testReport.pdf');

% Generate report

    sltest.testmanager.report(resultSet, reportPath, ...
    'Author', '{TEST_FILE_AUTHOR}', ...
    'Title', '{TEST_SPECIFICATION_DETAILS}', ...
    'IncludeSimulationSignalPlots', true, ...
    'IncludeErrorMessages', true, ...
    'IncludeTestResults', true, ...
    'IncludeSimulationMetadata', true, ...
    'LaunchReport', true);

disp('REPORT_GENERATED');
```

#### 7.3: Display summary

Use `evaluate_matlab_code` with:
```matlab

disp('=== SUMMARY ===');
disp(['Passed: ', resultSet.NumPassed]);
disp(['Failed: ', resultSet.NFailde]);
```

## Error Handling

| Error | Action |
|-------|--------|
| Toolbox not installed | Report which one is missing |
| Speedgoat won't connect | Check IP/credentials |
| .mldatx file not found | Verify path |
| Test with error | Log and continue |