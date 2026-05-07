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
4. Use `view` on `{CONFIG_PATH}` and extract the following data:
   - MATLAB version → `{MATLAB_VERSION}`
   - Project file name (.prj) → `{PRJ_NAME}`
   - Simulink Test Manager file name (.mldatx) → `{TEST_MANAGER}`
   - Test Level (MiL or HiL) → `{TEST_LEVEL}`
   - Speedgoat target name → `{SPEEDGOAT_NAME}`
   - Report title → `{TEST_SPECIFICATION_DETAILS}`
5. Ask the user: Name of the author running the tests → save in `{TEST_FILE_AUTHOR}`
6. If `{TEST_LEVEL}` is HiL, ask the user: Controller repository path → save in `{CONTROL_PATH}`




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

### Step 3: Tests Executions

If the `{TEST_LEVEL}` is MiL, launch the agent run-mil-test with the parameters:
 - Porject directory → `{PROJECT_DIR}`
   - MATLAB version → `{MATLAB_VERSION}`
   - Project file name (.prj) → `{PRJ_NAME}`
   - Simulink Test Manager file name (.mldatx) → `{TEST_MANAGER}`
   - Report title → `{TEST_SPECIFICATION_DETAILS}`
   - Test autor → `{TEST_FILE_AUTHOR}`

If the `{TEST_LEVEL}` is HiL, launch the agent run-speedgoat-test with the parameters:
   - Porject directory → `{PROJECT_DIR}`
   - MATLAB version → `{MATLAB_VERSION}`
   - Project file name (.prj) → `{PRJ_NAME}`
   - Simulink Test Manager file name (.mldatx) → `{TEST_MANAGER}`
   - Speedgoat target name → `{SPEEDGOAT_NAME}`
   - Controller repository path → `{CONTROL_PATH}`
   - Report title → `{TEST_SPECIFICATION_DETAILS}`
   - Test autor → `{TEST_FILE_AUTHOR}`

### Step 4: Present results

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

### Step 5: Finalize MATLAB
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