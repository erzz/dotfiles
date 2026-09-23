#!/usr/bin/env bash
set -euo pipefail

# Always operate on the canonical checkout, regardless of mise's working directory.
DOTFILES_DIR="$HOME/dotfiles"
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

bash "$DOTFILES_DIR/bootstrap/ensure-native-homebrew.sh"

# Installing so many things at once can lead to rate limit exhaustion if not
# authenticated
if ! MISE_GITHUB_TOKEN="$(gh auth token)" || [[ -z "$MISE_GITHUB_TOKEN" ]]; then
  printf '%s\n' 'GitHub authentication is required: run gh auth login.' >&2
  exit 1
fi
export MISE_GITHUB_TOKEN

mise -C "$DOTFILES_DIR" -E apps bootstrap packages apply --yes brew:mas
MISE_TERMINAL_PROGRESS=true mise -C "$DOTFILES_DIR" -E apps bootstrap --only packages --yes
mise -C "$DOTFILES_DIR" run apply-private-config
mise -C "$DOTFILES_DIR" run casks
mise -C "$DOTFILES_DIR" run fonts
mise -C "$DOTFILES_DIR" run post-install
