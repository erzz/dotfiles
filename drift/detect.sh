#!/usr/bin/env bash
COLOUR='\033[0;33m' # Yellow-ish
NC='\033[0m'        # No Color
DRIFT_FLAG="/tmp/dotfiles-drift"

cd ~/dotfiles || return

# Alerts based on unstaged changes to dotfiles directory
git fetch -q
if [ -n "$(git status --porcelain)" ]; then
	echo -e "${COLOUR}Changes detected in dotfiles, consider committing them${NC}" >"$DRIFT_FLAG"
fi
