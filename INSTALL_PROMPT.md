# Agent Setup Prompt: Two-Tier Multi-Agent Orchestration

> **Instructions for the User:**
> Copy and paste the prompt below directly into your AI coding assistant (OpenCode, Claude Code, Cursor, Windsurf, or Codex CLI) to have it autonomously install and verify this orchestration setup on your machine.

---

```markdown
You are an expert systems engineer and AI agent configuration specialist. Your task is to install, configure, and verify the OpenCode + Orca Two-Tier Multi-Agent Orchestration system on this machine.

Follow these strict step-by-step instructions:

### Step 1: Environment & Tooling Discovery
1. Detect the operating system, current user, shell, and user home directory:
   - Linux/macOS: `$HOME` (typically `~`)
   - Windows: `$env:USERPROFILE` or `C:\Users\<username>`
2. Check if `opencode` is installed (`opencode --version`):
   - If not installed, inform me or install it via `npm install -g opencode-ai` or `bun add -g opencode-ai` if permissions permit.
3. Check if `orca` is installed (`orca status` or `which orca` / `Get-Command orca`):
   - If Orca is present, verify connectivity. If absent, note that Orca is optional for standalone OpenCode subagent workflows but required for Tier 1 floating dispatcher handoffs.

### Step 2: Target Directory Preparation
Create the following directories if they do not already exist:
- Linux/macOS/WSL:
  - `~/.config/opencode`
  - `~/.config/opencode/agent`
  - `~/.agents/skills`
- Windows:
  - `%USERPROFILE%\.config\opencode`
  - `%USERPROFILE%\.config\opencode\agent`
  - `%USERPROFILE%\.agents\skills`

If an existing `opencode.jsonc` or `opencode.json` exists in `~/.config/opencode/`, create a timestamped backup (e.g. `opencode.jsonc.bak-<timestamp>`) before modifying.

### Step 3: Install Core Orchestration Contract & Subagents
From this repository (or using the files provided):
1. Copy `ORCHESTRATION.md` into `~/.config/opencode/ORCHESTRATION.md`.
2. Copy all subagent definitions from `agent/` into `~/.config/opencode/agent/`:
   - `worker-gemini.md` (High-thinking Gemini 3.8 Flash for deep architecture, complex logic, edge cases)
   - `worker-gpt.md` (Low-thinking GPT-5.6 Luna for rapid implementation, UI, boilerplate)
   - `tester.md` (Gemini 3.7 Flash for isolated test execution and verification)
   - `code-reviewer.md` (Gemini 3.8 Flash for pre-completion defect audits)
   - `researcher.md` (Gemini 3.7 Flash for zero-modification codebase investigation)
3. Copy all skills from `skills/` into `~/.agents/skills/`:
   - `ponytail` (Enforces laziest working solution, YAGNI, standard library first)
   - `caveman` (Cuts output tokens by ~65% using high-density terse communication)
   - `orchestration` (Orca multi-agent coordination contract)
   - `orca-cli` (Orca CLI worktree, terminal, and automation handler)

### Step 4: Configure `opencode.jsonc`
1. Ensure the `instructions` array includes:
   `"~/.config/opencode/ORCHESTRATION.md"` (or the absolute path resolved for this platform).
2. Configure permissions:
   - Allow core tools: `read`, `edit`, `glob`, `grep`, `list`, `task`, `skill`, `todowrite`, `question`, `webfetch`, `websearch`.
   - Deny destructive bash commands: `*rm -rf *`, `*rm -r *`, `*rmdir *`, `*git reset --hard*`, `*git clean -f*`, `*git push *--force*`, `*git push *-f *`, `*mkfs*`, `*dd if=*`, `*format *`.
3. Configure lead model: Set `"model": "openai/gpt-5.6-sol"` (or user's preferred lead orchestrator model).
4. Merge or preserve any existing API keys, custom providers, or OAuth tokens from the user's existing config.

### Step 5: Verification & Self-Test
1. Verify all files exist in their target paths with non-zero size.
2. If OpenCode is installed, check that the subagents and skills are discoverable:
   - Run a quick smoke check if supported.
3. Print a clean, formatted summary:
   - Status of OpenCode & Orca
   - Installed subagents and skills
   - Resolved configuration path
   - Example command to test: `opencode`
   - Example Orca Tier 1 dispatch command
```
