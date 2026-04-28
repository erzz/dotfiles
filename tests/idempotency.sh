#!/usr/bin/env bash
# Idempotency: chezmoi apply must converge.
# Run apply twice; on the second run, the diff must be empty.
set -euo pipefail

# First apply (best-effort; brew/MAS apps may soft-fail)
chezmoi apply --force >/dev/null 2>&1 || true

# Second apply must produce no diff
chezmoi apply --force >/dev/null 2>&1 || true

# Diff must be empty (excluding scripts, which are runtime actions not file state)
out=$(chezmoi diff --exclude=scripts 2>&1)
if [ -n "$out" ]; then
	echo "chezmoi diff is non-empty after two applies:"
	echo "$out"
	exit 1
fi
