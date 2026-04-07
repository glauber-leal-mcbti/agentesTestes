---
name: create-test-case
description: "Creates a test case for an Test Manager and Test Suite. Use this skill whenever the user mentions: 'create test case', 'new test case', or any reference to creating test cases."
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

### Step 1: Configuration variables

Use `AskUserQuestion` to collect interactively, or retrieve the data from the skill that triggered this execution.

1. Test Manager name → `{TEST_MANAGER_NAME}`
2. Test Suite name → `{TEST_SUITE_NAME}`
3. Test Case name → `{TEST_CASE_NAME}`
4. Model under test → `{MODEL_NAME}`
5. Harness under test → `{HARNESS_NAME}`
6. Test description → `{TEST_DESCRIPTION}`

Assume the project is already configured in the MATLAB environment.

### Step 2: Load Test Manager and Suite

Load the Test Manager file. Use `evaluate_matlab_code` with:
```matlab
tf = sltest.testmanager.load('{TEST_MANAGER_NAME}');
ts = getTestSuiteByName(tf, '{TEST_SUITE_NAME}');
```
If MATLAB reports that the Test Manager does not exist, raise the error | Non-existent Test Manager |
If MATLAB reports that the Test Suite does not exist, raise the error | Non-existent Test Suite |

### Step 3: Create Test Case

Attempt to create a test case. Use `evaluate_matlab_code` with:
```matlab
tc = createTestCase(ts, 'simulation', '{TEST_CASE_NAME}');
setProperty(tc, 'Model', '{MODEL_NAME}');
setProperty(tc, 'HarnessOwner', '{MODEL_NAME}', 'HarnessName', '{HARNESS_NAME}');
```
If MATLAB reports that the test case already exists, raise the error | Existing Test Case |

### Step 4: Set Test Description

Set the test description according to the test plan value, available in `{TEST_DESCRIPTION}`. Use `evaluate_matlab_code` with:
```matlab
setProperty(tc, 'Description', '{TEST_DESCRIPTION}');
```

### Step 5: Close the Test Manager

Close the Test Manager file. Use `evaluate_matlab_code` with:
```matlab
tf.saveToFile();
tf.close();
```

## Error Handling

| Error | Action |
|-------|--------|
| Non-existent Test Manager | Notify the skill caller that the file `{TEST_MANAGER_NAME}` does not exist in the project context |
| Non-existent Test Suite | Notify the skill caller that the instance `{TEST_SUITE_NAME}` does not exist in the project context |
| Existing Test Case | Notify the skill caller that the Test Case already exists and can be used |