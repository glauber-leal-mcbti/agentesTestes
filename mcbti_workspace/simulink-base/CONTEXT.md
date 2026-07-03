# simulink-base Project

## What we are building

- This project helps MBCTI to manipulate Simulink projects.
- This project could use MATLAB instructions too
- This project support several workflows

## Available MCP Tools

| Tool | Usage |
|------|-------|
| `evaluate_matlab_code` | Executes MATLAB code |
| `run_matlab_script` | Executes a .m script |
| `check_matlab_code` | Analyzes code |

## Harness Model manipulation

- **MATLAB API** → harness creation, Output symbol addition, simulation
- **Read/Grep/Edit on .mdl** → inspection of generated structure, residual cleanup, step action editing

## Folder Structure
```
simulink-base/              ← Simulink base skills and workflows
├── CONTEXT.md              ← Simulink context
├── generic-tools/          ← Generic simulink skills
│   ├── configure-signal-editor/   ← Configure Signal Editor block structure
├── starting-enviroment/    ← Simulink Enviroment workflow
│   ├── close-matlab/               ← Close MATLAB enviroment
│   ├── open-matlab-project/        ← Open MATLAB enviroment
├── test-process/                   ← Simulink test skills
│   ├── create-harness-mdl/         ← 
│   │   └── SKILL.md
│   ├── create-requirement-link/    ← 
│   │   └── SKILL.md
│   ├── create-test-case/           ← 
│   │   └── SKILL.md
│   ├── create-test-manager/        ← 
│   │   └── SKILL.md
│   ├── create-test-suite/          ←
│   │   └── SKILL.md
│   ├── run-simulink-test           ←
│   │   ├── SKILL.md
│   │   └── agents
│   │       ├── run-hil-controller-test.md
│   │       ├── run-hil-test.md
│   │       └── run-mil-test.md
│   ├── verify-matlab-requirements/     ← 
│   │   └── SKILL.md
├── workflows/              ← Simulink wrokflows
│   ├── create-tests.md     ← Simulink test create worflow
│   ├── run-tests.md        ← Simulink test run workflow
│   ├── start-project.md    ← Start Simulink project workflow
```

## Workspace Summary
| Wrokspace | Propose | Skills & Tolls |
|-----------|---------|----------------|
| "generic-tools/" | Simulink skills by Mathworks | "matlab-mcp-core-server", "simulink-agentic-toolkit" |
| "starting-enviroment/" | Simulink enviroment setup |  |
| "test-process/" | Simulink test devolopment |  |
| "workflows/" | Simulink worflows descriptions | "create-tests", "run-tests" |

## Note

Always execute the `start-project` workflow before and after work with Simulink models.

## Where to Go

| You Want To.. | Go Here |
|---------------|---------|
| **Create Simulink test** | `workflows/create-tests.md` |
| **Run Simulink test** | `workflows/run-tests.md` |
| **Starts Simulink projects** | `workflows/start-project.md` |

**Don't read everything.** Identify your task, load only what you need.


## Definitions
- Project: Simulink ".prj" structure file
- Model: Main models (.slx or .mdl), that was devoloped by MCBTI devolopers
- Harnnes: Simulink files (.slx or .mdl) that implement tests on Models
- Test Manager: Simulink Test Manager Tool (.mldatx)
- Requeriments Editor: Simulink Requeriments Editor Tool (.slqrex)
- MiL: is a simulation testing phase in Model-Based Design (MBD) where control algorithms are tested against a virtual model of the physical system
- HiL: is a simulation testing phase in Model-Based Design (MBD) where physical controller hardware is connected to a computer-based, real-time simulation of the physical system (the "plant") it is designed to control
- Speedgoat: HiL machine

## What good looks like
- **Don't read everything.** Identify your task, load only what you need.
- Modify Models
- Work with Harnnes on ".mdl" format

## What to avoid
- Work with Simulink test files on ".slx" format


