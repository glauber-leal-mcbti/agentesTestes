---
name: create-test-manager
description: "Creates a .mldatx Test Manager file. Use this skill whenever the user mentions: 'create test manager', 'new test manager', or any reference to creating test managers."
---

## Workflow

### Step 1: Configuration variables

Use `AskUserQuestion` to collect interactively, or retrieve the data from the skill that triggered this execution.

1. Test Manager name → `{TEST_MANAGER_NAME}`
2. Test Manager file directory → `{TEST_MANAGER_DIRECTORY}`

Assume the project is already configured in the MATLAB environment.

### Step 2: Check if Test Manager already exists

Check whether the file `{TEST_MANAGER_NAME}`, with extension .mldatx, already exists in the directory `{TEST_MANAGER_DIRECTORY}`.
    - If it already exists, raise the error | Existing File | and stop execution.
    - If the file does not exist, continue the skill execution.

### Step 3: Create Test Manager file

Create a Test Manager file in the directory `{TEST_MANAGER_DIRECTORY}`. Use `evaluate_matlab_code` with:
```matlab
tf = sltest.testmanager.TestFile('{TEST_MANAGER_DIRECTORY}\{TEST_MANAGER_NAME}.mldatx');
```
### Step 4: Close Test Manager file

Close the Test Manager file. Use `evaluate_matlab_code` with:
```matlab
tf.saveToFile();
tf.close();
```

## Error Handling

| Error | Action |
|-------|--------|
| Existing File | Notify the skill caller that the file already exists with the name `{TEST_MANAGER_NAME}` |