#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${HOME}/dotfiles"

if [ "$(uname -s)" != Linux ] || [ ! -d /usr/share/omarchy ] || ! command -v omarchy >/dev/null 2>&1; then
  printf '%s\n' '[omarchy-preflight] Omarchy Linux is required.' >&2
  exit 1
fi

for command_name in git mise; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf '%s\n' "[omarchy-preflight] $command_name is required." >&2
    exit 1
  fi
done

if [ ! -d "$DOTFILES_DIR/.git" ] || [ ! -f "$DOTFILES_DIR/mise.toml" ]; then
  printf '%s\n' "[omarchy-preflight] canonical checkout missing at $DOTFILES_DIR." >&2
  exit 1
fi

printf '%s\n' '[omarchy-preflight] Omarchy, mise, Git, and the canonical checkout are ready.'
