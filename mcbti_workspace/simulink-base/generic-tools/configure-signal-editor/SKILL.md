---
name: configure-signal-editor
description: "Adds and builds scenarios and signals inside an existing Signal Editor block, using MATLAB commands. Use this skill whenever the user mentions: 'configure signal editor', 'add scenario', 'build signal', 'add signal to signal editor', or any reference to populating a Signal Editor with signal data. Requires the Signal Editor block to already exist (use create-signal-editor skill first)."
---


## Reference

- MathWorks: https://www.mathworks.com/help/simulink/create-signal-data-for-simulation.html
- Data class: `Simulink.SimulationData.Dataset`
- Signal class: `timeseries`

## Scope

This skill **only** populates signal data and scenarios inside an existing Signal Editor block.

**It does NOT:**
- Create the Signal Editor block (use `create-signal-editor` for that)
- Connect the block to other blocks in the model
- Run simulations

---

## Key Concepts

| Concept | MATLAB Representation | Notes |
|---------|-----------------------|-------|
| Scenario | Variable of type `Simulink.SimulationData.Dataset` in the MAT file | Variable name = scenario name |
| Signal | `timeseries` element inside a Dataset | `ts.Name` = signal name |
| MAT file | `.mat` file linked to the block via `FileName` parameter | All scenarios live here |

---

## Input Format

Collect the following from the user or calling skill:

| Variable | Description |
|----------|-------------|
| `{MODEL_NAME}` | Simulink model name (no extension) |
| `{BLOCK_PATH}` | Full path to the Signal Editor block (e.g., `ModelName/SignalEditor`) |
| `{MAT_FILE_PATH}` | Full path to the MAT file (e.g., `C:\project\signals.mat`) |
| `{ACTIVE_SCENARIO}` | Name of the scenario to activate on the block after configuration |
| `{SCENARIOS}` | List of scenarios, each with a name and a list of signals |

### Signal definition structure (per signal):

| Field | Description | Example |
|-------|-------------|---------|
| `name` | Signal name (must match model port label) | `Speed` |
| `time` | Time vector in seconds | `[0 1 2 3]` |
| `values` | Value vector (same length as time) | `[0 10 10 0]` |

---

## Workflow

### Step 1: Collect configuration

Use `AskUserQuestion` to collect interactively, or retrieve from the calling skill.

Required information:
1. Model name → `{MODEL_NAME}`
2. Full block path → `{BLOCK_PATH}` (e.g., `{MODEL_NAME}/SignalEditor`)
3. MAT file full path → `{MAT_FILE_PATH}`
4. Scenarios and their signals (name, time vector, value vector for each signal)
5. Active scenario name → `{ACTIVE_SCENARIO}`

---

### Step 2: Verify model is open and block exists

Use `evaluate_matlab_code` with:

```matlab
if ~bdIsLoaded('{MODEL_NAME}')
    error('Model %s is not open.', '{MODEL_NAME}');
end
existingBlock = find_system('{MODEL_NAME}', 'FindAll', 'on', 'Type', 'block', 'FullName', '{BLOCK_PATH}');
if isempty(existingBlock)
    error('Signal Editor block not found at path: %s', '{BLOCK_PATH}');
end
```

- If model not loaded → raise **| Model Not Open |** and stop.
- If block not found → raise **| Block Not Found |** and stop.

---

### Step 3: Check if MAT file exists (load or initialize)

Use `evaluate_matlab_code` with:

```matlab
if isfile('{MAT_FILE_PATH}')
    existingData = load('{MAT_FILE_PATH}');
    scenarioVars = fieldnames(existingData);
    fprintf('Existing MAT file found with %d scenario(s).\n', length(scenarioVars));
else
    existingData = struct();
    fprintf('No existing MAT file. A new one will be created.\n');
end
```

---

### Step 4: Build each scenario with its signals

Repeat this block for **each scenario** provided by the user. Replace `{SCENARIO_NAME}`, `{SIGNAL_NAME}`, `{TIME_VECTOR}`, and `{VALUE_VECTOR}` with actual values.

Use `evaluate_matlab_code` with:

```matlab
% AI Created — scenario: {SCENARIO_NAME}
{SCENARIO_NAME} = Simulink.SimulationData.Dataset;

% Signal: {SIGNAL_NAME}
t_{SIGNAL_NAME} = {TIME_VECTOR}';
v_{SIGNAL_NAME} = {VALUE_VECTOR}';
ts_{SIGNAL_NAME} = timeseries(v_{SIGNAL_NAME}, t_{SIGNAL_NAME});
ts_{SIGNAL_NAME}.Name = '{SIGNAL_NAME}';
{SCENARIO_NAME} = {SCENARIO_NAME}.addElement(ts_{SIGNAL_NAME}, '{SIGNAL_NAME}');

% (repeat addElement block for each additional signal in this scenario)
```

> **Important:** If the same scenario name already exists in the MAT file, the new definition will overwrite it.

---

### Step 5: Save all scenarios to the MAT file

Construct a single `save` call that includes all scenario variables.

Use `evaluate_matlab_code` with:

```matlab
% AI Created
% Save all scenarios (preserves existing ones not being modified)
existingFields = fieldnames(existingData);
for i = 1:length(existingFields)
    if ~exist(existingFields{i}, 'var')
        eval([existingFields{i} ' = existingData.(existingFields{i});']);
    end
end
save('{MAT_FILE_PATH}', '{SCENARIO_NAME_1}', '{SCENARIO_NAME_2}');
% Add all scenario variable names to the save command
fprintf('MAT file saved: %s\n', '{MAT_FILE_PATH}');
```

---

### Step 6: Link MAT file to block and set active scenario

Use `evaluate_matlab_code` with:

```matlab
% AI Created
set_param('{BLOCK_PATH}', 'FileName', '{MAT_FILE_PATH}');
set_param('{BLOCK_PATH}', 'ActiveScenario', '{ACTIVE_SCENARIO}');
fprintf('Block configured. Active scenario: %s\n', '{ACTIVE_SCENARIO}');
```

---

### Step 7: Save the model

Use `evaluate_matlab_code` with:

```matlab
% AI Created
save_system('{MODEL_NAME}');
disp('Model saved.');
```

---

## Error Handling

| Error | Action |
|-------|--------|
| **Model Not Open** | Notify caller to open the model first |
| **Block Not Found** | Notify caller that the block path is wrong or the block does not exist |
| **Time/Value Length Mismatch** | Before saving, verify `length(time) == length(values)` for each signal; report which signal failed |
| **Save Failed** | Report MATLAB error; model was not saved |

---

## Full Example (2 scenarios, 2 signals each)

```matlab
% AI Created — full example
% --- Scenario 1: Ramp Up ---
scenario_ramp = Simulink.SimulationData.Dataset;

ts_speed = timeseries([0 5 10 10]', [0 1 2 3]');
ts_speed.Name = 'Speed';
scenario_ramp = scenario_ramp.addElement(ts_speed, 'Speed');

ts_enable = timeseries([0 0 1 1]', [0 1 2 3]');
ts_enable.Name = 'Enable';
scenario_ramp = scenario_ramp.addElement(ts_enable, 'Enable');

% --- Scenario 2: Step Down ---
scenario_step = Simulink.SimulationData.Dataset;

ts_speed2 = timeseries([10 10 0 0]', [0 1 2 3]');
ts_speed2.Name = 'Speed';
scenario_step = scenario_step.addElement(ts_speed2, 'Speed');

ts_enable2 = timeseries([1 1 0 0]', [0 1 2 3]');
ts_enable2.Name = 'Enable';
scenario_step = scenario_step.addElement(ts_enable2, 'Enable');

% Save
save('C:\project\signals.mat', 'scenario_ramp', 'scenario_step');

% Link to block
set_param('MyModel/SignalEditor', 'FileName', 'C:\project\signals.mat');
set_param('MyModel/SignalEditor', 'ActiveScenario', 'scenario_ramp');
save_system('MyModel');
```
