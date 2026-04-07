---
name: create-test-suite
description: "Creates a test suite for a specified Test Manager. Use this skill whenever the user mentions: 'create test suite', 'new test suite', or any reference to creating test suites."
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

Assume the project is already configured in the MATLAB environment.

### Step 2: Load Test Manager

Load the Test Manager file. Use `evaluate_matlab_code` with:
```matlab
tf = sltest.testmanager.load('{TEST_MANAGER_NAME}');
```
If MATLAB reports that the file does not exist, raise the error | Non-existent Test Manager |

### Step 3: Create Test Suite

Attempt to create a test suite. Use `evaluate_matlab_code` with:
```matlab
ts = createTestSuite(tf, '{TEST_SUITE_NAME}');
```
If MATLAB reports that the test suite already exists, raise the error | Existing Test Suite |

### Step 4: Close the Test Manager

Close the Test Manager file. Use `evaluate_matlab_code` with:
```matlab
tf.saveToFile();
tf.close();
```

## Error Handling

| Error | Action |
|-------|--------|
| Non-existent Test Manager | Notify the skill caller that the file `{TEST_MANAGER_NAME}` does not exist in the project context |
| Existing Test Suite | Notify the skill caller that the Test Suite already exists and can be used |