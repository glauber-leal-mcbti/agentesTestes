---
name: open-matlab-project
description: "Configures a MATLAB environment with a .prj project for use by other skills. Use this skill whenever the user mentions: 'open matlab project', 'configure matlab project', or as a prerequisite for other MATLAB skills."
---

## Prerequisites
- MATLAB installed with a valid license
- matlab-mcp-server installed and connected

## Available MCP Tools

| Tool | Usage |
|------|-------|
| `evaluate_matlab_code` | Executes MATLAB code |
| `run_matlab_script` | Executes a .m script |
| `check_matlab_code` | Analyzes code |

## Workflow

### Step 1: Collect user information

Retrieve the following variables from the call:

1. MATLAB version → `{MATLAB_VERSION}`
2. Full path to the .prj project → `{PRJ_PATH}`

### Step 2: Validate MATLAB environment

1. Check if the installed MATLAB version matches `{MATLAB_VERSION}`

If an error is returned, notify the user and stop.

### Step 3: Configure project context

Use the directory from `{PRJ_PATH}`.

1. Start MATLAB
2. Open the MATLAB project. Use `evaluate_matlab_code` with:
```matlab
openProject({PRJ_PATH});
```

### Step 4: Return configuration

Make the following available to the caller of this skill:

| Variable | Description |
|----------|-------------|
| `{MATLAB_VERSION}` | MATLAB version |
| `{PRJ_PATH}` | Path to the .prj file |

## Error Handling

| Error | Action |
|-------|--------|
| MCP not connected | Notify user |
| Invalid path | Verify the provided path |