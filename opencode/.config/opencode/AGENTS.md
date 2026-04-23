# Global OpenCode Rules

These rules apply across every OpenCode session, in every project. They are loaded both as the user-level `AGENTS.md` and as merged instructions in any project that has its own `AGENTS.md`.

The setup is intentionally **plugin-free**. The source of truth lives in plain files under `~/.config/opencode/`:

- `opencode.json` — native OpenCode configuration and MCP servers
- `agents/*.md` — dedicated agents and delegation targets
- `skills/**/SKILL.md` — reusable workflow guidance
- `commands/*.md` — native planning, review, and orchestration shortcuts

## Working Model

The default agent is `@engineer`. That is the main conversational entrypoint for normal use.

Use `/start-work <task>` only when you want an explicit orchestration run in an isolated subtask.

## Information Gathering

Before asking the user for any information that could be obtained from the workspace, **use your
tools to find it yourself**. This includes file contents, directory layouts, git state, command
output, and configuration values.

Acceptable to ask the user for:

- Intent, preferences, priorities, or trade-offs
- Information that genuinely lives outside the workspace (credentials, external system state,
  things only they know)
- Confirmation before destructive or irreversible actions

Not acceptable to ask the user for:

- "Can you check what's in file X?"
- "What does directory Y look like?"
- "What's your current branch / git status?"
- "Is tool Z installed?"
- Any factual question answerable by `read`, `glob`, `grep`, or `bash`

If you catch yourself drafting a question, ask first: *can a tool answer this?* If yes, run the
tool. Asking the user is the slower, more expensive path.

## Delegation Rules

These rules are the canonical routing policy. Other agents (`engineer`, `orchestrator`, `start-work`) defer to this list — do not maintain a parallel copy elsewhere.

- Use `@framing` only when the request wording may hide ambiguity or unstated intent.
- Use `@planner` for non-trivial work, loading the `planning` skill.
- Use `@plan-reviewer` only when the plan matters or spans multiple files/systems.
- Use `@explore` to map unfamiliar codebases and return file paths with brief notes.
- Use `@librarian` for external documentation or library behavior.
- Use `@frontend` for frontend implementation.
- Use `@cicd` for GitHub Actions, reusable workflows, releases, and pipeline design.
- Use `@quick` for trivial, low-risk tasks only.
- Use `@deep` for research-heavy end-to-end implementation across multiple moving parts.
- Use `@ultrabrain` only for the hardest reasoning or architecture work.
- Use `@writing` for documentation and polished prose.
- Use `@git` for git strategy, branches, commits, and PR-oriented repository work.
- Use `@reviewer` after meaningful implementation work to critique quality, edge cases, and risks.
- Use `@architect` only for unusually hard debugging or architecture decisions after normal approaches fail.
- Use `@orchestrator` only through `/start-work` when you want an explicit isolated orchestration run.

## Handoff Standard

Keep delegated handoffs compact. Prefer this shape:

1. Summary
2. Files
3. Steps
4. Risks
5. Verification

Avoid large code excerpts unless they are essential.

## Blocking Questions

Subagents run in isolated sessions and cannot pause to ask the user. When a subagent hits a true
decision point that needs user input, it must return its result prefixed with `BLOCKED: <question>`
on its own line. The calling primary agent must surface that question to the user immediately and
verbatim, treating the task as paused rather than complete. Reserve `BLOCKED:` for genuine
decisions; for minor ambiguities, subagents should pick the most reasonable option, document the
assumption, and continue.

## Native-First Principle

Prefer native OpenCode features over external installers or opaque package behavior. If a behavior can
be expressed with agents, skills, commands, `AGENTS.md`, or `opencode.json`, keep it there.

## Native Commands

- `/plan <task>` uses `@planner` to produce a short execution plan
- `/review <change>` uses `@reviewer` to critique completed work
- `/start-work <task>` uses `@orchestrator` to run the native orchestration flow

## Project-Specific Rules

If the project provides its own `AGENTS.md`, it sits alongside these global rules. Project rules describe the project; these globals describe the workflow. When they conflict, project-specific guidance about that project's code, conventions, or commands wins. Workflow conventions (delegation, handoff shape, blocking questions) stay as defined here.
