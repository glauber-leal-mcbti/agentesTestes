---
name: close-matlab
description: "Close MATLAB enviroment. Use this skill whenever the user mentions: 'close matlab', or as a prerequisite for other MATLAB skills."
---

## Workflow

### Step 3: Configure project context

Use the directory from `{PRJ_PATH}`.

1. Save all opend MATLAB windows. Use `evaluate_matlab_code` with:
```matlab
save all;
```
2. Close the MATLAB. Use `evaluate_matlab_code` with:
```matlab
bdclose('all');
close all force
exit;
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