---
name: verify-matlab-requirements
description: "Loads, checks, and lists all requirements present in a .slreqx requirements file, with their information and links to models. Use this skill whenever the user mentions: 'verify matlab requirements', 'check matlab requirements', or any reference to reading requirements from MATLAB files."
---

## Prerequisites
- MATLAB installed with a valid license
- matlab-mcp-server installed
- matlab-mcp-server configured and connected

## Available MCP Tools

| Tool | Usage |
|------|-------|
| `evaluate_matlab_code` | Executes MATLAB code |
| `run_matlab_script` | Executes a .m script |
| `check_matlab_code` | Analyzes code |

## Requirements Structure
| Requirement Type | Abbreviation | Meaning |
|------------------|--------------|---------|
| Functional | FUN | What the system must do |
| Container | CONT | Group of functional requirements |
| Informational | INF | Information about the system |

Only FUN requirements are implemented in the harness and test manager for validation purposes. CONT requirements are used to create partitioning for better organization by functional affinity. Informational requirements are used only to provide information and are not implemented.

## Workflow

### Step 1: Load configuration file

Use `AskUserQuestion` to collect interactively.

1. Ask the user for the following information:
   - MATLAB version → `{MATLAB_VERSION}`
   - Project file path (.prj) → `{PRJ_PATH}`
   - Requirements file name (.slreqx) → `{REQUIREMENTS_FILE}`

2. Build the full paths:
   - `{PRJ_PATH}` = `{PROJECT_DIR}` + required files

### Step 2: Configure MATLAB environment

If MATLAB is not yet configured, read and execute the `open-matlab-project/SKILL.md` skill using `view`. Pass the following parameters to that skill:
  - `{MATLAB_VERSION}`
  - `{PRJ_PATH}`

After execution, the following variables will be available:
- `{MATLAB_VERSION}`
- `{PRJ_PATH}`

The project context will already be configured in MATLAB.

### Step 3: Load requirements file

Load the requirements file and display the implemented requirements to the user.
Use `evaluate_matlab_code` with:
```matlab
reqSet = slreq.load('{REQUIREMENTS_FILE}');
requirements = reqSet.find('Type', 'Requirement');
```

If the file is not found, call error | Requiriment file not existis |.

### Step 4: Describe requirements

Extract the requirements and display them to the user using the following script.
Before running the loop, add the skill's scripts directory to the MATLAB path. The base directory of this skill is known — use it to build the path.
Use `evaluate_matlab_code` with:
```matlab
addpath(fullfile('{SKILL_BASE_DIR}', 'scripts'));
for i = 1:length(requirements)
    r = requirements(i);
    description = cleanDescription(r.Description);
    fprintf('ID: %s\n', r.Id);
    fprintf('Summary: %s\n', r.Summary);
    fprintf('Description: %s\n\n', description);
    fprintf('Type: %s\n\n', r.Type);
end
```

### Step 5: Return

Return to the user or another skill a table with the data of the requirements read during this execution.

Finish by closing the requirements file. Use `evaluate_matlab_code` with:
```matlab
slreq.clear;
```

## Error Handling

| Error | Action |
|-------|--------|
| Requiriment file not existis | Stop execution and return error to the user |