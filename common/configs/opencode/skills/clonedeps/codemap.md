# src/skills/clonedeps/

## Responsibility

Workflow-only bundled OpenCode skill for local dependency source mirroring. It
instructs the orchestrator to use `@librarian` for dependency discovery and
source URL/ref resolution, then perform approved git/filesystem operations
directly.

## Design

- `SKILL.md` is the prompt contract loaded by OpenCode and assigned only to the
  orchestrator.
- No helper script is bundled. The skill avoids brittle cross-ecosystem parsing
  and keeps repo-specific judgment in librarian/orchestrator.
- State is trackable project metadata stored in `.slim/clonedeps.json`; clone
  contents live under `.slim/clonedeps/repos/<safe-repo-name>/` and are
  ignored by git.
- The workflow updates `.gitignore`, `.ignore`, and root `AGENTS.md` with
  concise marker sections so cloned source stays out of git but visible to
  OpenCode and discoverable by future agents.

## Flow

1. Orchestrator checks `.slim/clonedeps.json` first and reuses existing clones
   when they satisfy the current task.
2. Orchestrator asks librarian for a small source-resolution plan across the
   repository's actual languages/ecosystems.
3. Orchestrator verifies refs and URLs where possible, uses HTTPS by default,
   rejects unsafe URL forms, and requires separate explicit approval for any
   safe transport/private-repository exception before network cloning unless
   cloning was explicitly requested.
4. Orchestrator inspects `.gitignore` and `.ignore`, normalizes or appends one
   complete managed block without changing unrelated rules, and clones only
   after protection is in place.
5. Orchestrator clones each approved source repo once into a temporary location
   using the approved URL, a pinned ref, shallow history where practical, and no
   submodules, then moves
   only complete clones into `.slim/clonedeps/repos/<safe-repo-name>/`.
6. Orchestrator writes `.slim/clonedeps.json` only for complete successful
   clones, never leaves partial state, and never runs scripts from clones.
7. Orchestrator updates root `AGENTS.md`; the
   AGENTS section lists each read-only clone path directly with a one-sentence
   purpose.

Cloning requires network access. Later inspection of an already cloned source
can be performed offline.

Cleanup requires confirmation for clone and metadata removal, removes existing
managed ignore blocks only after clone removal, and never adds a missing block
just to remove it.

## Integration

- Registered in `src/cli/custom-skills.ts` with orchestrator-only permission.
- Included in release verification via `scripts/verify-release-artifact.ts`.
- Documented in `docs/skills.md` and included in `src/skills/codemap.md`.
