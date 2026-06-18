# Simulink Test AI Agents

This project contains a skills set for integrate MATLAB/Simulink with the Claude Code AI. This skills has a focous on automating the Simulink Test Toolbox, covering all test process.

### 🔧 Setup

### 📋 Required Tools

You will need this softwares installed on your machine:
- Claude Code
- matlab-mcp-core-server

See *[Configuration](#-configuration)* to add MATLAB version to mcp.

### ⚙️ Configuration 

Adding MATLAB to mcp. Use the following commando for each MATLAB version.

On Windows:
```
claude mcp add matlab<VERSION> -- "\fullpath\to\matlab-mcp-core-server-win64.exe" --matlab-root="C:\Program Files\MATLAB\<VERSION>"
```
On Linux:
```
claude mcp add matlab<VERSION> -- ~/.claude/mcp_servers/matlab-mcp-core-server-glnxa64  --matlab-root=/usr/local/MATLAB/<VERSION>
```

Exemplo com R2026a:
| Placeholder | Exemplo      |
|-------------|--------------|
| `<VERSION>` | `R2026a`     |

Now, in Claude Code create the `commands` folder. Paste the skills unziped `simulin_test_ai_agents.zip` file into it.

Start a terminal and initialized Claude Code with:
```
claude
```
Log with your account and ask to see matlab-mcp-core-server instllaed versions.

## 📦 Avaiable Skills

To load a skill on Claude Code terminal is necessary call the activation command. Here are the avaiable skills and their activation commands:
| Skill | Description | Activation |
|-----------|-------------|----------|
| complete-test-process      | Manages the complete test creation process in Simulink | `complete test process`      |
| create-harness-mdl | Creates a test harness in .mdl format from a .slx model and a provided requirement. Uses a hybrid approach: MATLAB API for creation and simulation, direct Read/Grep/Edit on the .mdl for inspection and content configuration. Use Test Assertion verifiation | `create harness with assertion` |
| create-requirement-link   | Creates a requirement links between the correspondent requieremnt, test case, and test harness assessment block | `create requirement link`       |
| `create-test-assessment` | Creates a test assessment for an adopted Test Manager, Test Suite, and Test Case. The assessment is created from a template | create test assessment |
| create-test-case | Creates a test case for an Test Manager and Test Suite | `create test case` |
| create-test-manager | Creates a .mldatx Test Manager file | `create test manager` |
| create-test-suite | Creates a test suite for a specified Test Manager | `create test suite` |
| matlab-test | Create MATLAB Unit Testes | `create MATLAB test` |
| open-matlab-project | Configures a MATLAB environment with a .prj project for use by other skills | `open matlab projec` |
| run-simulink-test | Executes tests from a Simulink Test Manager .mldatx file on diffrent configurations, provided by the user | `run simulink test` |
| verify-matlab-requirements | Loads, checks, and lists all requirements present in a .slreqx requirements file, with their information and links to models | `verify matlab requirements` |

## 📌 Versions

Unvaliable

## ✒️ Autors



A MCBTI Product devoloped by:
- Gláuber Leal Silva - *Main Devoloper*
- Rodrigo Baker Botelho - *Project Manager*

## 📄 License

Unvaliable

