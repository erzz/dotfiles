#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${HOME}/dotfiles"

bash "$DOTFILES_DIR/omarchy/scripts/require-private-auth-omarchy.sh"

fnox --non-interactive --no-daemon --if-missing error exec --replace -- \
  mise -C "$DOTFILES_DIR" -E private bootstrap files apply --yes
