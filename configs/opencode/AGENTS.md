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

## Project Grounding

At the start of any session in a project directory, before answering substantive
questions or editing code:

1. **Project `AGENTS.md` present?** OpenCode has already loaded it. Use it. Do
   not re-read it as a tool call.
2. **No project `AGENTS.md` and the task is non-trivial?** Do a 30-second
   self-orientation: read `README.md` (or its top), list the top-level
   directory, and skim the manifest (`package.json`, `go.mod`, `pyproject.toml`,
   `Cargo.toml`, `flake.nix`, equivalent). This is ~3 cheap tool calls — not
   `@explore`.
3. **Only after that** may you ask the user project-shape questions.

For trivial requests ("what does this command do", "fix this typo", pure
conversation) skip grounding entirely.

If the project is non-trivial and has no `AGENTS.md`, **offer once at the end
of the session** to draft one based on what you learned. Use the shape defined
under "Project Brief Shape" below.

For an explicit deeper pass (new contributor, returning to a project after a
long absence, big refactor incoming), use `/ground`.

### Project Brief Shape

When drafting or updating a project `AGENTS.md`, keep it under ~120 lines and
use this shape. No prose padding.

```markdown
# Project: <name>

## Stack
One line. e.g. "Go 1.22, Echo, Postgres via sqlc, Tofu for infra"

## Layout
5–10 bullets. Top-level dirs and what lives there.

## How to run / test / build
Exact commands. No prose.

## Conventions
Bullets only. Linters, formatters, naming, error handling style.
Anything an outsider would get wrong on first try.

## Entry points
Where to start reading for common tasks.

## Gotchas
Things that surprised you. Things the agent has gotten wrong before.
```

If the brief grows past ~120 lines it is wrong — split details into separate
files referenced by path, and let the agent read those on demand.

## Delegation Defaults

These are **defaults the engineer must follow**, not options to consider. If
you skip a default, state which step and why in one sentence before proceeding.
Silent skipping is a bug.

For any task that touches code:

1. **Unfamiliar area in this session?** → `@explore` first. Skip only if you
   have already read the relevant files in this session, or if grounding
   covered it.
2. **More than ~30 lines of new code, or >2 files?** → `@planner` first.
3. **After implementation of any non-trivial change** → `@reviewer` before
   declaring done.

State your delegation choice explicitly at the start of a code-touching task,
e.g. *"Plan: explore=N (already read these files), planner=Y, reviewer=Y."*

### Specialist Routing

When the defaults above call for delegation, or when a task obviously fits a
specialist, route to:

- `@framing` — request wording may hide ambiguity or unstated intent
- `@planner` — non-trivial planning (loads the `planning` skill)
- `@plan-reviewer` — plan matters or spans multiple files/systems
- `@explore` — map unfamiliar codebases, return file paths with brief notes
- `@librarian` — external documentation or library behavior
- `@frontend` — frontend implementation
- `@cicd` — GitHub Actions, reusable workflows, releases, pipeline design
- `@quick` — trivial, low-risk tasks only
- `@deep` — research-heavy end-to-end implementation across multiple moving parts
- `@ultrabrain` — the hardest reasoning or architecture work
- `@writing` — documentation and polished prose
- `@git` — git strategy, branches, commits, PR-oriented repository work
- `@reviewer` — critique completed work for quality, edge cases, risks
- `@architect` — unusually hard debugging or architecture decisions after normal approaches fail
- `@orchestrator` — only through `/start-work` for explicit isolated orchestration runs

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
- `/ground` uses `@explore` to perform a deep project orientation pass and offer to write a project `AGENTS.md`

## Project-Specific Rules

If the project provides its own `AGENTS.md`, it sits alongside these global rules. Project rules describe the project; these globals describe the workflow. When they conflict, project-specific guidance about that project's code, conventions, or commands wins. Workflow conventions (delegation, handoff shape, blocking questions) stay as defined here.
