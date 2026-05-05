#!/usr/bin/env bash
# Idempotency: chezmoi apply must converge.
# Run apply twice; on the second run, the diff must be empty.
set -euo pipefail

# First apply: best-effort warm-up. Brew/MAS apps and other one-shot
# installers can legitimately soft-fail on first run (network, MAS auth,
# etc.) without indicating broken state.
chezmoi apply --force >/dev/null 2>&1 || true

# Second apply MUST succeed. If it doesn't, the system is not converging
# and that's a real failure — not just "diff happens to be empty".
if ! chezmoi apply --force >/tmp/idempotency-apply.$$ 2>&1; then
	echo "second chezmoi apply failed (system is not converging):"
	sed 's/^/  /' /tmp/idempotency-apply.$$
	rm -f /tmp/idempotency-apply.$$
	exit 1
fi
rm -f /tmp/idempotency-apply.$$

# Diff must be empty (excluding scripts, which are runtime actions not file state)
out=$(chezmoi diff --exclude=scripts 2>&1)
if [ -n "$out" ]; then
	echo "chezmoi diff is non-empty after two applies:"
	echo "$out"
	exit 1
fi
