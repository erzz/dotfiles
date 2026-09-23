#!/usr/bin/env bash
set -euo pipefail

# Always operate on the canonical checkout, regardless of mise's working directory.
DOTFILES_DIR="$HOME/dotfiles"

mise -C "$DOTFILES_DIR" run preflight

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
bash "$DOTFILES_DIR/bootstrap/ensure-native-homebrew.sh"

# Authenticate before installing tools that may need private GitHub releases.
if ! MISE_GITHUB_TOKEN="$(gh auth token)" || [[ -z "$MISE_GITHUB_TOKEN" ]]; then
  printf '%s\n' 'GitHub authentication is required: run gh auth login.' >&2
  exit 1
fi
export MISE_GITHUB_TOKEN

printf '%s\n' '[sync] installing fnox'
mise -C "$DOTFILES_DIR" install fnox
printf '%s\n' '[sync] deploying configuration'

mise -C "$DOTFILES_DIR" bootstrap --force-dotfiles dotfiles apply --yes ~/.config/fnox
mise -C "$DOTFILES_DIR" bootstrap --force-dotfiles dotfiles apply --yes ~/.config/mise/config.toml
mise -C "$DOTFILES_DIR" bootstrap --force-dotfiles dotfiles apply --yes ~/.config/mise/config.apps.toml

printf '%s\n' '[sync] converging apps and remaining declarations'
mise -C "$DOTFILES_DIR" exec fnox -- fnox exec --replace -- \
  mise -C "$DOTFILES_DIR" -E apps bootstrap --force-dotfiles --yes
mise -C "$DOTFILES_DIR" run casks
mise -C "$DOTFILES_DIR" run fonts
mise -C "$DOTFILES_DIR" run post-install
