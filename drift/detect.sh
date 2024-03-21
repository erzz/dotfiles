#!/usr/bin/env bash
COLOUR='\033[0;33m' # Yellow-ish
NC='\033[0m'        # No Color

cd ~/dotfiles || return

# Alerts based on unstaged changes to dotfiles directory
git fetch
if [ -n "$(git status --porcelain)" ]; then
  echo -e "${COLOUR}Changes detected in dotfiles, consider commiting them${NC}"
fi
