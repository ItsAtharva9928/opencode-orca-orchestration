# Contributing to OpenCode + Orca Orchestration

We welcome contributions, improvements, bug reports, and agent additions!

## Guiding Principles

1. **Zero-Redundancy:** Every addition to this setup must serve to reduce redundant execution, save tokens, or prevent regressions.
2. **Model Agility:** Subagents should define sane defaults, but remain easy to swap to equivalent models (Anthropic, OpenAI, Google, OpenRouter, local).
3. **Safety First:** Maintain strict denial patterns for dangerous system operations (`rm -rf`, force pushes, formatting) in `opencode.jsonc`.
4. **Ponytail & Caveman:** Keep prompts terse, actionable, and free from conversational boilerplate.

## Adding or Improving Subagents

1. Add subagent definitions under `agent/<name>.md`.
2. Ensure the frontmatter defines:
   - `description`: A clear trigger summary that OpenCode's orchestrator can evaluate when deciding delegation.
   - `mode: subagent`
   - `model`: Sane model provider ID.
   - `variant`: Thinking level (`none`, `low`, `medium`, `high`, `xhigh`).
3. Include the Operating Contract and Final Response structure.
4. Test the subagent locally by delegating a focused unit of work from an OpenCode session.

## Submitting Changes

1. Fork the repository and create your feature branch: `git checkout -b feature/my-new-subagent`.
2. Commit your changes: `git commit -m "feat(subagents): add specialized db-migrator"`.
3. Push to your branch and open a Pull Request.
