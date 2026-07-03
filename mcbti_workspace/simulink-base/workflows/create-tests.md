# create-tests Workflow

## What we are building

- This worflow instructs how to create Simulink Tests
- This workflow coverage all the steps necessarys for the task
- This workflow uses another skills

## Notes

The user can ask to make just a single part of the workflow. Jump to it and don't run the prevoius steps.

## Steps 

Use the follow steps for create Simulink Tests. Manipulate inputs and outputs for each skill.

1. Define Simulink Model
2. Read this Model requeriments → Use the skill `verify-matlab-requirements`
3. Read the Test Plan file
4. Generate Harness file for the Model with requeriments and test plan → Use the skill `create-harness-mdl`
5. Test Manager:
    - Name the Test Manager file after the model name plus "Manager" at the end: `{TEST_MODEL}` + "Manager" → `{TEST_MANAGER_NAME}`
    - If the Test Manager alredy exist on project structure, use it
    - If don't exists create a new one → Use the skill `create-test-manager`
6. Test Suites:
    - Name the Test Suite after the CONT requirement that encompasses the implemented requirement `{REQUIREMENT_TO_IMPLEMENT}` → `{TEST_SUITE_NAME}`
    - For each CONT requirement, create a suite 
    - If the Test Suite alredy exist on Test Manager, use it
    - - For create Test Cases → Use the skill `create-test-suite`
7. Make Tests Cases:
    - Name the Test Case after the FUN requirement it verifies → `{TEST_CASE_NAME}`
    - For create Test Cases → Use the skill `create-test-case`
8. With the main structure create links betwen Test Cases, Assessments and the Requeriments Editor:
    - Use the skill `create-requirement-link`
    - Matlab variable with requirement set → `{REQQUIREMENTS_SET}`
    - Test Manager name → `{TEST_MANAGER_NAME}`
    - Tests Harness names → `{TOTAL_HARNESS}`
9. Present the main structure result for the user.
