# Multi-Tier Orchestration & Delegation Architecture

This system operates as a structured two-tier orchestration hierarchy:

## Tier 1: Floating Terminal (Global Task Giver & Dispatcher)
- **Role**: The coordinator in the floating terminal has cross-project visibility and acts as the top-level task intake and dispatcher.
- **Instant Delegation Policy**: When receiving an implementation, feature, bug-fix, or refactoring task, the floating terminal coordinator must NEVER write code inline. Instead, it must immediately delegate the task via Orca Orchestration to the target project worktree.
- **Agent & Model Contract**:
  - Launch ONLY OpenCode: `orca terminal create --worktree "path:<worktree_path>" --title "<Task Title>" --command "opencode --model openai/gpt-5.6-sol"`.
  - NEVER use Codex CLI or other external agent CLIs.
  - Model must always be `openai/gpt-5.6-sol` (or your configured lead orchestrator model) with reasoning effort set to `medium` (configured in `opencode.jsonc` or session).
- **Asynchronous Handoff**:
  - Dispatch the task via `orca orchestration dispatch --task <task_id> --to <terminal_handle> --inject`.
  - Monitor via `orca orchestration check`.
  - Free the floating terminal immediately so the user can continue issuing new tasks.

## Tier 2: Project Orchestrator (Sol / Lead Orchestrator in Worktree)
- **Role**: Sol acts as the lead project-level orchestrator and technical architect inside the target worktree.
- **Mandatory Subagent Delegation**: Sol must NOT perform line-by-line file modifications or manual test execution directly. Instead, Sol must:
  1. Break down the task into clean, modular units of work.
  2. Proactively delegate implementation and testing units to specialized subagents using OpenCode's `task` tool:
     - `worker-gemini`: For tasks that require deep thinking, architecture, complex logic, and edge-case analysis (configured on high thinking).
     - `worker-gpt`: For rapid implementation, boilerplate, UI components, utilities, and focused quick edits (configured on low thinking).
     - `tester`: For writing and executing targeted unit and integration tests.
     - `code-reviewer`: For diff review and defect detection prior to completion.
     - `researcher`: For codebase investigation, architecture analysis, and documentation lookups without modifying code.
  3. Supervise subagent outputs, coordinate handoffs, and ensure Zero-Redundancy rules.
  4. Once satisfied, send `worker_done` back to the Tier 1 Orca Orchestrator.

---

# Efficient Execution and Verification

These instructions apply to the primary orchestrator and every delegated agent.

## Scope Discipline

- Do only the work required to satisfy the user's request. Stop when the requested result is complete and proportionally verified.
- Do not add optional cleanup, speculative refactors, broad audits, extra reviews, builds, coverage, or release steps without user approval.
- Avoid duplicate work. Do not assign multiple agents the same investigation, implementation, review, or verification unless independent results are explicitly needed.
- The user controls the time and cost budget. Immediately honor requests to stop, skip tests, or reuse existing evidence.

## Zero-Redundancy Verification Rules (Strict)

1. **Never Double-Test:** 
   - Either the orchestrator verifies, or the worker verifies — **NEVER BOTH**.
   - If the orchestrator delegates an implementation or fix to a subagent, the orchestrator **MUST NOT** run test commands before delegating.
   - When a subagent returns with test evidence, the orchestrator **MUST NOT** rerun the test to "double-check". Accept valid subagent evidence, report it to the user, and stop immediately.

2. **No Pre-Flight Reruns:**
   - If an error trace or test failure is already provided in the prompt/context, subagents **MUST NOT** rerun the test to "reproduce" it. Proceed directly to diagnosis and fixing.

3. **Isolated Test Execution Only:**
   - During code changes, agents must run **only the single affected test file** (e.g., `pytest tests/test_foo.py` or `npm test -- path/to/test.ts`), **NEVER** the full test suite.
   - Run a full test suite at most once for an entire change set, and only if explicitly requested by the user or when broad regression risk warrants it.

4. **Reuse Past Evidence:**
   - Never rerun a successful test, lint, or build command on unchanged code solely for a newer timestamp, another agent, or a final summary.
   - A successful test summary remains valid even if an outer shell wrapper times out afterward.

## Delegation Contract

- Pass known errors, file paths, and test commands directly into the subagent prompt.
- Explicitly instruct the subagent: *"Do not rerun test suite before editing; run only [single_test_file] to verify."*
- Subagents must not independently run full suites, lint, builds, or other expensive commands unless explicitly assigned.

## Reporting

- Report exact existing command results without rerunning commands to reconstruct them.
- Once enough evidence exists, give the concise result and stop immediately.
