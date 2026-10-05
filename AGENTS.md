# Project: Personal Dotfiles

## Stack

Cross-platform dotfiles for macOS and Omarchy Linux Quattro or later. mise is the primary tool, package, configuration, and machine-convergence orchestrator; use Bash only for gaps mise cannot cover.

## Layout

- `mise.toml` — shared mise control plane, tools, tasks, bootstrap declarations, and dotfiles.
- `mise.apps.toml`, `macos/mise.apps.toml`, and `macos/` — macOS app overlay, Homebrew fallback inventories, configs, and scripts.
- `common/` — shared user configuration and secret-free templates.
- `omarchy/` — Omarchy additions, package inventories, configs, and scripts.
- `scripts/sync.sh` — shared OS dispatcher; platform-specific sync implementations live beside their configs.
- `common/configs/opencode/opencode.json` — deployed OpenCode config, including the mise MCP server.
- `.github/workflows/ci.yml` — task, shell, integration, source, JSON, and defaults validation.

## How to run / test / build

```bash
mise -C "$HOME/dotfiles" run sync
mise tasks validate
bash -n bootstrap.sh macos/scripts/*.sh omarchy/scripts/*.sh drift/*.sh
```

For shell changes, also run the CI ShellCheck command: `shellcheck --severity=warning <changed-script>`. Do not run machine-mutating sync during validation unless the task explicitly requires it and the target environment is appropriate.

## Conventions

- `mise run sync` is the canonical, repeatable convergence entry point for every supported OS. It must converge all repository-managed state on macOS and Omarchy Quattro+; isolate real OS differences behind the shared entry point and fail clearly on unsupported hosts.
- Keep declarations in the root mise control plane or its intentional platform overlays. Prefer shared `common/` config; put macOS-only state in `macos/` and Omarchy-only additions in `omarchy/`.
- Before choosing an implementation for tools, packages, dotfiles, macOS defaults, or Linux services, inspect the configured `mise` MCP server and its relevant resources/tools, then check the current official mise docs and installed CLI help. Compare native TOML and CLI capabilities before adding scripts or relying on another package/configuration manager.
- Prefer mise-managed tools and package backends, including documented `aqua:` and `npm:` backends when suitable. Use `[tools]` for versioned tools and `[bootstrap.packages]` for host packages; these are different mechanisms, and `mise install` alone does not apply bootstrap packages. On macOS, use Homebrew only when no suitable mise-managed option exists. Keep fallbacks declarative and narrow; imperative scripts are the last resort after mise capabilities are exhausted.
- Use mise's native `[dotfiles]`/bootstrap declarations for deployment rather than new stow or hand-written symlink machinery. Prefer `[bootstrap.macos.defaults]` (or a curated defaults table) for macOS preferences. For Linux units, check `[bootstrap.linux.systemd.units]` for user units and `[bootstrap.services]` for existing system services. Verify exact syntax, ownership, and behavior via MCP, docs, and CLI before falling back to scripts; these features have platform and system-manager constraints.
- Keep `mise run sync` as the sole normal convergence path; make changes idempotent, safe to repeat, explicit about platform and ownership boundaries, and avoid parallel sources of truth.
- Keep Omarchy-owned desktop/system configuration intact unless a change is explicitly scoped to this repository. Package additions should be additive; preserve unrelated user config and back it up before any intentional replacement.
- For Omarchy work, use the available Omarchy skills to explore supported workflows, debug issues, and guide implementation before inventing a solution; respect Omarchy's ownership boundaries.
- Never commit secrets. Render private local files with the existing fnox/1Password flow and restrictive permissions.

## Entry points

- `README.md` — supported workflows and ownership boundaries.
- `TODO.md`, `macos/TODO.md`, and `omarchy/TODO.md` — prioritized follow-up work, separated by platform scope.
- `mise.toml` — shared tool, task, bootstrap, and dotfiles declarations.
- `scripts/sync.sh`, `macos/scripts/sync.sh`, `omarchy/scripts/sync-omarchy.sh` — convergence flow.
- `macos/mise.apps.toml`, `omarchy/configs/mise/dotfiles.toml` — platform-specific mise additions.
- `common/configs/opencode/opencode.json` — OpenCode and mise MCP configuration.

## Gotchas

- The canonical checkout is `~/dotfiles`; use `mise -C "$HOME/dotfiles" ...` when invoking tasks from elsewhere.
- Linux support means Omarchy Quattro or later, not generic Arch or arbitrary Linux. Keep detection and documentation aligned with that support floor.
- Existing platform scripts and external package inventories are migration surface, not a reason to add more imperative logic. First establish whether mise can replace or absorb each behavior; migrate incrementally without breaking convergence or ownership guarantees.
- Omarchy owns its global mise config and most desktop configuration. The repository's Linux files are additive and deliberately limited.
- Treat MCP task execution as running project code with the user's permissions; inspect a task before invoking it. Avoid reading `mise://env` unless needed, since it may expose secrets.
