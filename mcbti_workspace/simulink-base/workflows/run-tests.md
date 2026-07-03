# run-tests Workflow

## What we are building

- This worflow instructs how to run MATLAB/Simulink tests
- This workflow coverage all types of tests
- This workflow uses another skills

## Notes

The user can ask to make just a single part of the workflow. Jump to it and don't run the prevoius steps.

## Steps 

Use the follow steps for run MATLAB/Simulink Tests. Manipulate inputs and outputs for each skill.

1. If the user ask for run Simulink test use the right Skill → Use the skill `run-simulink-test`
    - This skill has sub-agents for each type of Simulink Test
    - run-mil-test: MiL tests, that runs only on computer
    - run-hil-test: HiL tests, that runs only on Speedgoat machine
    - run-hil-controller-test: HiL tests, that rub on Speedgoat on communication with a embedded controller
2. If the user ask for run MATLAB test, this is not implementd yet. Warning the user about it