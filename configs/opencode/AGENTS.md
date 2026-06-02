# Global OpenCode Rules

These rules apply across every OpenCode session, in every project. They are loaded both as the
user-level `AGENTS.md` and as merged instructions in any project that has its own `AGENTS.md`.

This setup uses **oh-my-opencode-slim** as the primary agent harness. The source of truth lives in:

- `opencode.json` — OpenCode configuration, MCP servers, and plugin registration
- `oh-my-opencode-slim.json` — plugin preset, model, skill, and MCP routing configuration
- `agents/*.md` — supplementary local specialists that sit alongside plugin agents
- `skills/**/SKILL.md` — reusable workflow guidance
- `commands/*.md` — native planning, review, and orchestration shortcuts

## Working Model

The default agent is **orchestrator** from oh-my-opencode-slim. That is the main conversational
entrypoint and the agent that owns planning, implementation, delegation, and verification.

oh-my-opencode-slim provides native OpenCode agents and delegation tools. Use natural language for
normal work; the Orchestrator decides when to delegate. You can also delegate manually with
`@agentName <task>`.

### Available Custom Specialists

The plugin provides `@explorer`, `@librarian`, `@oracle`, `@designer`, `@fixer`, and `@council`
agents. These local agents remain available alongside the plugin agents for domain-specific MCP
workflows:

- `@designer` — UI/UX design, frontend implementation, and Skapa Design System compliance (has
  `skapa_*` MCP tools)
- `@cicd` — INGKA reusable workflow pipelines (has `workflows_*` MCP tools)

## Information Gathering

Before asking the user for any information that could be obtained from the workspace, **use your
tools to find it yourself**. This includes file contents, directory layouts, git state, command
output, and configuration values.

Acceptable to ask the user for:

- Intent, preferences, priorities, or trade-offs
- Information that genuinely lives outside the workspace (credentials, external system state, things
  only they know)
- Confirmation before destructive or irreversible actions

Not acceptable to ask the user for:

- "Can you check what's in file X?"
- "What does directory Y look like?"
- "What's your current branch / git status?"
- "Is tool Z installed?"
- Any factual question answerable by `read`, `glob`, `grep`, or `bash`

If you catch yourself drafting a question, ask first: _can a tool answer this?_ If yes, run the
tool. Asking the user is the slower, more expensive path.

## Project Grounding

At the start of any session in a project directory, before answering substantive questions or
editing code:

1. **Project `AGENTS.md` present?** OpenCode has already loaded it. Use it. Do not re-read it as a
   tool call.
2. **No project `AGENTS.md` and the task is non-trivial?** Do a 30-second self-orientation: read
   `README.md` (or its top), list the top-level directory, and skim the manifest (`package.json`,
   `go.mod`, `pyproject.toml`, `Cargo.toml`, `flake.nix`, equivalent). This is ~3 cheap tool calls —
   not `@explorer`.
3. **Only after that** may you ask the user project-shape questions.

For trivial requests ("what does this command do", "fix this typo", pure conversation) skip
grounding entirely.

If the project is non-trivial and has no `AGENTS.md`, **offer once at the end of the session** to
draft one based on what you learned. Use the shape defined under "Project Brief Shape" below.

For an explicit deeper pass (new contributor, returning to a project after a long absence, big
refactor incoming), use `/ground`.

### Project Brief Shape

When drafting or updating a project `AGENTS.md`, keep it under ~120 lines and use this shape. No
prose padding.

```markdown
# Project: <name>

## Stack

One line. e.g. "Go 1.22, Echo, Postgres via sqlc, Tofu for infra"

## Layout

5–10 bullets. Top-level dirs and what lives there.

## How to run / test / build

Exact commands. No prose.

## Conventions

Bullets only. Linters, formatters, naming, error handling style. Anything an outsider would get
wrong on first try.

## Entry points

Where to start reading for common tasks.

## Gotchas

Things that surprised you. Things the agent has gotten wrong before.
```

If the brief grows past ~120 lines it is wrong — split details into separate files referenced by
path, and let the agent read those on demand.

## Delegation

The Orchestrator handles orchestration and delegation internally using the oh-my-opencode-slim
specialist agents. For domain-specific work with MCP tools, use the custom specialists:

- **Frontend/UI work needing Skapa** → `@designer`
- **CI/CD pipelines needing INGKA workflows** → `@cicd`

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

## MCP Servers

Two domain-specific MCP servers are configured globally:

- **skapa** — Skapa Design System component documentation, usage examples, and styling guidance
- **workflows** — INGKA reusable GitHub Actions workflow search, details, and YAML generation

These are available to all agents. The `@designer` and `@cicd` specialists are tuned to use them
effectively.

## Project-Specific Rules

If the project provides its own `AGENTS.md`, it sits alongside these global rules. Project rules
describe the project; these globals describe the workflow. When they conflict, project-specific
guidance about that project's code, conventions, or commands wins. Workflow conventions (delegation,
handoff shape, blocking questions) stay as defined here.
