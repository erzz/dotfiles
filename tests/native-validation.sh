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
echo "Validated mise task/config/status commands; idempotency is not exercised"
