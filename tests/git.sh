#!/usr/bin/env bash
# Git: repository-owned configuration remains available for native deployment.
set -euo pipefail

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
[ -f "$root/home/dot_gitconfig" ] || { echo "repository git configuration missing"; exit 1; }

# Parse in an isolated environment; do not inspect or mutate the user's config.
GIT_CONFIG_GLOBAL=/dev/null git config --file "$root/home/dot_gitconfig" --get user.name >/dev/null
GIT_CONFIG_GLOBAL=/dev/null git config --file "$root/home/dot_gitconfig" --get user.email >/dev/null
