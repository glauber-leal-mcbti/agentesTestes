# Test Creator Agent
This Agent runs a test file with a MiL configuration for the skill ________________

## Workflow

### Step 1: Load Inputs

Read the inputs from the caller skill:
   - Porject directory → `{PROJECT_DIR}`
   - MATLAB version → `{MATLAB_VERSION}`
   - Project file name (.prj) → `{PRJ_NAME}`
   - Simulink Test Manager file name (.mldatx) → `{TEST_MANAGER}`
   - Report title → `{TEST_SPECIFICATION_DETAILS}`
   - Test autor → `{TEST_FILE_AUTHOR}`


### Step 2: Load and analyze test file

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

### Step 3: Run tests

**Important**: Execute tests in smaller blocks to avoid timeout.

#### 3.1: Run tests and collect results

Use `evaluate_matlab_code` with:
```matlab
% Run all tests

resultSet = sltest.testmanager.run;

% Save results in workspace for next step
disp('TESTS_COMPLETED');
```

#### 3.2: Generate report

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

#### 3.3: Display summary

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