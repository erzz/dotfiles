#!/usr/bin/env bash
COLOUR='\033[0;33m' # Yellow-ish
NC='\033[0m'        # No Color
DRIFT_FLAG="/tmp/dotfiles-drift"

cd ~/dotfiles || return

git fetch -q

MESSAGES=()

# Local uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
	MESSAGES+=("${COLOUR}Dotfiles have uncommitted changes${NC}")
fi

# Local branch behind remote
BEHIND=$(git rev-list --count 'HEAD..@{u}' 2>/dev/null)
if [ -n "$BEHIND" ] && [ "$BEHIND" -gt 0 ]; then
	MESSAGES+=("${COLOUR}Dotfiles are ${BEHIND} commit(s) behind remote${NC}")
fi

if [ ${#MESSAGES[@]} -gt 0 ]; then
	printf '%b\n' "${MESSAGES[@]}" >"$DRIFT_FLAG"
fi
