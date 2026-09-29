#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${HOME}/dotfiles"

bash "$DOTFILES_DIR/omarchy/scripts/omarchy-preflight.sh"
bash "$DOTFILES_DIR/omarchy/scripts/require-private-auth-omarchy.sh"

printf '%s\n' '[omarchy-private] rendering fnox-backed npm and secrets configuration'
fnox --non-interactive --no-daemon --if-missing error exec --replace -- \
  mise -C "$DOTFILES_DIR" -E private bootstrap files apply --yes

printf '%s\n' '[omarchy-private] installing private MCP tools with fnox credentials'
fnox --non-interactive --no-daemon --if-missing error exec --replace -- sh -c '
  export MISE_GITHUB_TOKEN="${GH_TOKEN:-}"
  exec mise -C "$HOME/dotfiles" --yes -E private install --jobs=4
'
