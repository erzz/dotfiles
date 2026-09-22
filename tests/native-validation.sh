#!/usr/bin/env bash
# Static/native validation only: this does not prove idempotency or convergence.
# Do not run sync/bootstrap here: those commands mutate HOME.
set -euo pipefail

command -v mise >/dev/null || { echo "mise not installed; skipping native task validation"; exit 0; }
mise tasks validate

tasks="$(mise tasks ls --hidden)"
for task in prepare sync check; do
  grep -qE "^${task}[[:space:]]" <<<"$tasks" || {
    echo "expected mise task missing: ${task}"
    exit 1
  }
done

# These are read-only plan/status checks; they must not install packages, casks,
# GUI applications, or require authentication.
mise bootstrap status >/dev/null
mise -E apps bootstrap status >/dev/null
config_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
grep -q 'mise -E apps bootstrap --force-dotfiles --yes' "$config_root/mise.toml"
! grep -q -- '--skip macos-defaults' "$config_root/mise.toml"
grep -q -- '"${MISE_CONFIG_ROOT:?}/brew/Brewfile.casks"' "$config_root/mise.toml"
grep -q -- '"${MISE_CONFIG_ROOT:?}/brew/Brewfile.fonts"' "$config_root/mise.toml"
grep -q 'mise run casks && mise run fonts' "$config_root/mise.toml"
echo "Validated mise task/config/status commands; idempotency is not exercised"
