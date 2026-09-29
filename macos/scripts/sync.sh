#!/usr/bin/env bash
set -euo pipefail

# Always operate on the canonical checkout, regardless of mise's working directory.
DOTFILES_DIR="$HOME/dotfiles"

mise -C "$DOTFILES_DIR" run preflight

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
bash "$DOTFILES_DIR/macos/scripts/ensure-native-homebrew.sh"

# The pre-layout deployment linked the whole Git config directory. Retire that
# repository-owned parent link before deploying the split platform/shared files.
legacy_git_dir="$HOME/.config/git"
if [ -L "$legacy_git_dir" ]; then
  legacy_git_link="$(readlink -- "$legacy_git_dir")"
  if [[ "$legacy_git_link" = /* ]]; then
    legacy_git_target="$legacy_git_link"
  else
    legacy_git_target="$(dirname -- "$legacy_git_dir")/$legacy_git_link"
  fi
  legacy_git_target="$(readlink -m -- "$legacy_git_target")"
  if [[ "$legacy_git_target" == "$DOTFILES_DIR" || "$legacy_git_target" == "$DOTFILES_DIR/"* ]]; then
    legacy_git_backup="${legacy_git_dir}.dotfiles-backup.$(date +%Y%m%d%H%M%S)"
    mv -- "$legacy_git_dir" "$legacy_git_backup"
    printf '%s\n' "[sync] backed up stale repository Git config link to $legacy_git_backup"
  fi
fi

# Authenticate before installing tools that may need private GitHub releases.
if ! MISE_GITHUB_TOKEN="$(gh auth token)" || [[ -z "$MISE_GITHUB_TOKEN" ]]; then
  printf '%s\n' 'GitHub authentication is required: run gh auth login.' >&2
  exit 1
fi
export MISE_GITHUB_TOKEN

printf '%s\n' '[sync] installing fnox'
mise -C "$DOTFILES_DIR" --yes install fnox
printf '%s\n' '[sync] deploying configuration'

mise -C "$DOTFILES_DIR" bootstrap --force-dotfiles dotfiles apply --yes ~/.config/fnox
mise -C "$DOTFILES_DIR" bootstrap --force-dotfiles dotfiles apply --yes ~/.config/mise/config.toml
mise -C "$DOTFILES_DIR" bootstrap --force-dotfiles dotfiles apply --yes ~/.config/mise/config.apps.toml

printf '%s\n' '[sync] converging apps and remaining declarations'
mise -C "$DOTFILES_DIR" exec fnox -- fnox --non-interactive --no-daemon --if-missing error exec --replace -- \
  mise -C "$DOTFILES_DIR" -E apps bootstrap --force-dotfiles --yes
mise -C "$DOTFILES_DIR" run casks
mise -C "$DOTFILES_DIR" run fonts
mise -C "$DOTFILES_DIR" run post-install
