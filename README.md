# OpenCode + Orca: Two-Tier Multi-Agent Orchestration Architecture

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![OpenCode](https://img.shields.io/badge/OpenCode-Configured-8A2BE2)](https://opencode.ai)
[![Orca](https://img.shields.io/badge/Orca-Orchestration-orange)](https://orca.dev)

A battle-tested, high-throughput multi-agent development architecture for **[OpenCode](https://opencode.ai)** and **[Orca](https://orca.dev)**. 

This setup decouples high-level task intake and dispatch from project-level architecture, enforces **mandatory subagent delegation**, prevents regressions with **Zero-Redundancy Verification Rules**, and slashes token consumption by pairing **Ponytail** (anti-over-engineering) with **Caveman** (ultra-compressed communication).

---

## Architecture Overview

```
                      +------------------------------------------+
                      |                 TIER 1                   |
                      |   Floating Terminal / Global Dispatcher  |
                      |          (Orca Lead Coordinator)         |
                      +--------------------+---------------------+
                                           |
                        orca orchestration dispatch --inject
                                           |
                                           v
                      +------------------------------------------+
                      |                 TIER 2                   |
                      |     Worktree Lead Project Orchestrator   |
                      |        (OpenCode: GPT-5.6 Sol Lead)      |
                      +----+-----------+-----------+-----------+-+
                           |           |           |           |
            OpenCode task  |           |           |           |  OpenCode task
                           v           v           v           v
            +----------------+   +-----------+   +--------+  +---------------+
            | worker-gemini  |   | worker-gpt|   | tester |  | code-reviewer |
            | (Deep/Complex) |   |  (Rapid)  |   | (Tests)|  | (Defect Audit)|
            +----------------+   +-----------+   +--------+  +---------------+
```

### 1. Tier 1: Floating Terminal (Global Task Intake & Dispatcher)
- **Role**: Coordinates across repositories with total system visibility.
- **Instant Delegation Policy**: The floating terminal coordinator **never** modifies code directly. It immediately dispatches tasks to target project worktrees using Orca.
- **Asynchronous Handoff**: Spawns isolated terminals (`opencode --model openai/gpt-5.6-sol`), dispatches tasks with lifecycle preambles, and returns control to the user immediately.

### 2. Tier 2: Project Orchestrator (Sol in Project Worktree)
- **Role**: The technical architect and lead project manager inside each target worktree.
- **Mandatory Subagent Delegation**: Sol **never** performs line-by-line edits or runs test suites directly. Sol:
  1. Deconstructs the specification into modular units of work.
  2. Spawns specialized subagents via OpenCode's `task` tool.
  3. Enforces Zero-Redundancy verification rules.
  4. Returns `worker_done` back to the Tier 1 Orca Orchestrator once verified.

---

## Specialized Subagent Team

Every subagent is pre-configured with dedicated model parameters, reasoning efforts, and behavioral contracts in `~/.config/opencode/agent/`:

| Subagent | Role | Default Model | Reasoning Effort | Best For |
| :--- | :--- | :--- | :--- | :--- |
| **`worker-gemini`** | Senior Implementer | `google/antigravity-gemini-3.8-flash` | **High** | Deep logic, architecture, complex refactors, difficult edge cases |
| **`worker-gpt`** | Rapid Implementer | `openai/gpt-5.6-luna` | **Low** | Routine features, UI components, boilerplate, targeted quick fixes |
| **`tester`** | Test Engineer | `google/antigravity-gemini-3.7-flash` | **Medium** | Isolated unit/integration tests, reproducing defects, boundary testing |
| **`code-reviewer`** | Defect Auditor | `google/antigravity-gemini-3.8-flash` | **Medium** | Pre-completion diff review, regression checks, security audits |
| **`researcher`** | Codebase Detective | `google/antigravity-gemini-3.7-flash` | **Medium** | Tracing dependencies, reading APIs, gathering facts (read-only) |

---

## Zero-Redundancy Verification Rules

Standard agent workflows waste 40-70% of their token budget and execution time rerunning identical tests. This setup enforces strict rules:

1. **Never Double-Test:** Either the orchestrator verifies or the worker verifies — **never both**. If a subagent provides test evidence, the orchestrator accepts it and stops.
2. **No Pre-Flight Reruns:** If a failure trace or error is provided in the prompt, subagents **must not** rerun the test to "reproduce" it. They proceed straight to diagnosis and fixing.
3. **Isolated Test Execution Only:** During iterations, workers run **only the single affected test file** (`pytest tests/test_foo.py` or `npm test -- path/to/test.ts`), never the full test suite.
4. **Reuse Past Evidence:** Never rerun a passing test, lint, or build command on unchanged code solely for a fresher timestamp.

---

## Bundled Skills

The setup includes high-leverage skills installed into `~/.agents/skills/`:

- **`ponytail`**: The ultimate anti-over-engineering skill. Enforces the "lazy developer ladder": YAGNI first, stdlib before custom code, native platform features before packages, single lines before fifty.
- **`caveman`**: Ultra-compressed communication mode. Cuts token consumption by ~65% by omitting conversational filler while preserving 100% technical fidelity.
- **`orchestration`**: Version-matched discovery and operational guide for Orca multi-agent dispatch and DAGs.
- **`orca-cli`**: CLI operations for worktree management, terminal injection, and embedded browser automation.

---

## Quick Installation

Choose the installation method that fits your workflow:

### Option 1: AI Agent Prompt (Recommended)
Feed [`INSTALL_PROMPT.md`](INSTALL_PROMPT.md) directly to OpenCode, Claude Code, Cursor, Windsurf, or Codex. The agent will discover your environment, back up existing configs, copy subagents and skills, and verify the installation autonomously.

### Option 2: Automated Script (Linux, macOS, WSL)
Run the POSIX installer:
```bash
git clone https://github.com/ItsAtharva9928/opencode-orca-orchestration.git
cd opencode-orca-orchestration
chmod +x install.sh
./install.sh
```

Flags available:
- `./install.sh --dry-run`: Preview actions without touching the filesystem.
- `./install.sh --force`: Overwrite existing files without prompting.
- `./install.sh --no-backup`: Skip timestamped `.bak` files.

### Option 3: PowerShell Script (Windows)
Run from PowerShell:
```powershell
git clone https://github.com/ItsAtharva9928/opencode-orca-orchestration.git
cd opencode-orca-orchestration
.\install.ps1
```

Flags available:
- `.\install.ps1 -DryRun`
- `.\install.ps1 -Force`
- `.\install.ps1 -NoBackup`

### Option 4: Manual Copy
```bash
# 1. Target directories
mkdir -p ~/.config/opencode/agent ~/.agents/skills

# 2. Instructions & Config
cp ORCHESTRATION.md ~/.config/opencode/
cp opencode.jsonc ~/.config/opencode/

# 3. Agents & Skills
cp agent/*.md ~/.config/opencode/agent/
cp -R skills/* ~/.agents/skills/
```

---

## Daily Usage Workflow

### 1. Global Intake in Tier 1 (Orca Floating Terminal)
When receiving a new feature or bug request in the global terminal:
```bash
# Spawn an OpenCode instance in the project worktree
orca terminal create \
  --worktree "path:/path/to/project-worktree" \
  --title "Implement Auth Flow" \
  --command "opencode --model openai/gpt-5.6-sol"

# Dispatch task to the terminal asynchronously
orca orchestration dispatch \
  --task auth_feature_01 \
  --to terminal_handle \
  --inject
```

### 2. Autonomous Orchestration in Tier 2 (Target Worktree)
Inside the worktree, OpenCode (Sol) reads `ORCHESTRATION.md` and automatically decomposes the task:
- Sol launches `worker-gemini` for complex domain models.
- Sol launches `worker-gpt` for UI views and standard endpoints.
- Sol launches `tester` to write isolated regression tests.
- Sol launches `code-reviewer` for final sanity checks.
- Sol finishes and reports:
```bash
orca orchestration reply --task auth_feature_01 --message "worker_done"
```

---

## Directory Structure

```
opencode-orca-orchestration/
├── ORCHESTRATION.md              # The master 2-tier contract & zero-redundancy rules
├── opencode.jsonc                # Production OpenCode configuration with safe permissions
├── INSTALL_PROMPT.md             # One-click prompt for AI agent autonomous installation
├── install.sh                    # Automated POSIX Bash installer
├── install.ps1                   # Automated Windows PowerShell installer
├── agent/                        # Specialized subagent definitions
│   ├── worker-gemini.md          # Deep thinking worker (Gemini 3.8 Flash, high thinking)
│   ├── worker-gpt.md             # Fast implementation worker (GPT-5.6 Luna, low thinking)
│   ├── tester.md                 # Isolated test engineer (Gemini 3.7 Flash)
│   ├── code-reviewer.md          # Pre-merge defect auditor (Gemini 3.8 Flash)
│   └── researcher.md             # Read-only codebase detective (Gemini 3.7 Flash)
├── skills/                       # High-leverage skills
│   ├── ponytail/SKILL.md         # Anti-overengineering / YAGNI ladder
│   ├── caveman/SKILL.md          # 65% token-saving terse communication
│   ├── orchestration/SKILL.md    # Orca multi-agent coordination contract
│   └── orca-cli/SKILL.md         # Orca CLI worktree & terminal control
├── templates/
│   └── opencode.jsonc.example    # Annotated configuration template with provider examples
├── LICENSE                       # MIT License
└── CONTRIBUTING.md               # Guidelines for contributions
```

---

## Customizing Models & Providers

You can adapt the default models in `~/.config/opencode/agent/*.md` or `~/.config/opencode/opencode.jsonc` to match your available API providers:

- **Anthropic Claude**: Replace subagent frontmatter `model:` with `anthropic/claude-3-7-sonnet`.
- **OpenAI**: Use `openai/gpt-5` or `openai/o3-mini`.
- **OpenRouter / Local (vLLM / Ollama)**: Point `baseURL` in `provider` blocks to your endpoint.

---

## License

MIT License. See [LICENSE](LICENSE) for full details.
