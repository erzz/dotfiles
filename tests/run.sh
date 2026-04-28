#!/usr/bin/env bash
# Discovery runner: finds tests/<name>.sh files and runs each.
# A test passes if its script exits 0; fails otherwise.
# Per-test scripts should be small (≤30 lines) and test one concern.
#
# Usage: ./tests/run.sh [name]   # name limits to a single test
set -uo pipefail

TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
FILTER="${1:-*}"

PASS=0
FAIL=0
FAILED_NAMES=()

printf '\033[1;34m==> Running tests in %s\033[0m\n' "${TESTS_DIR}"

for t in "${TESTS_DIR}"/${FILTER}.sh; do
	[ -f "$t" ] || continue
	[ "$(basename "$t")" = "run.sh" ] && continue
	name="$(basename "$t" .sh)"
	if bash "$t" >/tmp/test-output.$$ 2>&1; then
		printf '\033[1;32m  PASS\033[0m  %s\n' "$name"
		PASS=$((PASS + 1))
	else
		printf '\033[1;31m  FAIL\033[0m  %s\n' "$name"
		sed 's/^/        /' /tmp/test-output.$$
		FAIL=$((FAIL + 1))
		FAILED_NAMES+=("$name")
	fi
	rm -f /tmp/test-output.$$
done

printf '\n\033[1;34m==> Results: %d passed, %d failed\033[0m\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
