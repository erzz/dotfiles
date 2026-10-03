#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${HOME}/dotfiles"
MISE_FRAGMENT_SOURCE="$DOTFILES_DIR/omarchy/configs/mise/dotfiles.toml"
MISE_FRAGMENT_TARGET="$HOME/.config/mise/conf.d/dotfiles.toml"
FORCE="${OMARCHY_DOTFILES_FORCE:-0}"
CONFLICTS=()
AUTHORITATIVE=0

bash "$DOTFILES_DIR/omarchy/scripts/omarchy-preflight.sh"

if [ ! -f "$MISE_FRAGMENT_SOURCE" ]; then
  printf '%s\n' "[omarchy-sync] mise fragment is missing: $MISE_FRAGMENT_SOURCE" >&2
  exit 1
fi

resolved_path() {
  readlink -m -- "$1"
}

is_repository_link() {
  local target="$1"
  local target_link target_resolved

  [ -L "$target" ] || return 1
  target_link="$(readlink -- "$target")"
  if [[ "$target_link" = /* ]]; then
    target_resolved="$target_link"
  else
    target_resolved="$(dirname -- "$target")/$target_link"
  fi
  target_resolved="$(resolved_path "$target_resolved")"
  [[ "$target_resolved" == "$DOTFILES_DIR" || "$target_resolved" == "$DOTFILES_DIR/"* ]]
}

link_path() {
  local source="$1"
  local target="$2"
  local backup

  if [ ! -e "$source" ] && [ ! -L "$source" ]; then
    printf '%s\n' "[omarchy-sync] source is missing: $source" >&2
    exit 1
  fi

  if [ -L "$target" ] && [ "$(resolved_path "$target")" = "$(resolved_path "$source")" ]; then
    return 0
  fi

  # Refresh links from the pre-layout repository structure without touching
  # unrelated user or Omarchy-owned symlinks.
  if is_repository_link "$target"; then
    backup="${target}.omarchy-backup.$(date +%Y%m%d%H%M%S)"
    mv -- "$target" "$backup"
    printf '%s\n' "[omarchy-sync] backed up stale repository link $target to $backup"
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ "$FORCE" != 1 ] && [ "$AUTHORITATIVE" != 1 ]; then
      CONFLICTS+=("$target")
      return 0
    fi
    backup="${target}.omarchy-backup.$(date +%Y%m%d%H%M%S)"
    mv -- "$target" "$backup"
    printf '%s\n' "[omarchy-sync] backed up $target to $backup"
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  printf '%s\n' "[omarchy-sync] linked $target"
}

merge_tree() {
  local source="$1"
  local target="$2"
  local entry name backup

  if [ -L "$target" ] && [ "$(resolved_path "$target")" = "$(resolved_path "$source")" ]; then
    return 0
  fi

  if [ -L "$target" ]; then
    if is_repository_link "$target" || [ "$FORCE" = 1 ]; then
      backup="${target}.omarchy-backup.$(date +%Y%m%d%H%M%S)"
      mv -- "$target" "$backup"
      printf '%s\n' "[omarchy-sync] backed up stale repository tree $target to $backup"
    else
      CONFLICTS+=("$target")
      return 0
    fi
  fi

  if [ -e "$target" ] && [ ! -d "$target" ]; then
    link_path "$source" "$target"
    return 0
  fi

  mkdir -p "$target"
  shopt -s nullglob dotglob
  for entry in "$source"/*; do
    name="$(basename "$entry")"
    if [ -d "$entry" ] && [ ! -L "$entry" ]; then
      merge_tree "$entry" "$target/$name"
    else
      link_path "$entry" "$target/$name"
    fi
  done
  shopt -u nullglob dotglob
}

printf '%s\n' '[omarchy-sync] installing repository mise tools'
mise -C "$DOTFILES_DIR" --yes install --jobs=4

printf '%s\n' '[omarchy-sync] converging repository Arch/AUR package inventories'
bash "$DOTFILES_DIR/omarchy/scripts/packages-omarchy.sh"
bash "$DOTFILES_DIR/omarchy/scripts/apps-omarchy.sh"

printf '%s\n' '[omarchy-sync] linking additive mise fragment'
link_path "$MISE_FRAGMENT_SOURCE" "$MISE_FRAGMENT_TARGET"

printf '%s\n' '[omarchy-sync] linking portable user configuration where targets are absent'
link_path "$DOTFILES_DIR/omarchy/configs/bash/dotfiles.bash" "$HOME/.config/dotfiles/bashrc"
link_path "$DOTFILES_DIR/omarchy/configs/git/.gitconfig.linux" "$HOME/.gitconfig"
link_path "$DOTFILES_DIR/common/configs/git/ignore" "$HOME/.config/git/ignore"
link_path "$DOTFILES_DIR/common/configs/fnox" "$HOME/.config/fnox"
link_path "$DOTFILES_DIR/common/configs/tmux/.tmux.conf" "$HOME/.tmux.conf"
link_path "$DOTFILES_DIR/common/configs/zellij" "$HOME/.config/zellij"
link_path "$DOTFILES_DIR/common/configs/direnv" "$HOME/.config/direnv"
link_path "$DOTFILES_DIR/common/configs/gh-dash" "$HOME/.config/gh-dash"
link_path "$DOTFILES_DIR/common/configs/prettierd" "$HOME/.config/prettierd"
AUTHORITATIVE=1
link_path "$DOTFILES_DIR/omarchy/configs/systemd/user/keyboard-backlight.service" \
  "$HOME/.config/systemd/user/keyboard-backlight.service"
AUTHORITATIVE=0

systemctl --user daemon-reload
systemctl --user enable --now keyboard-backlight.service

printf '%s\n' '[omarchy-sync] merging authoritative Neovim and OpenCode files'
AUTHORITATIVE=1
merge_tree "$DOTFILES_DIR/common/configs/nvim" "$HOME/.config/nvim"
merge_tree "$DOTFILES_DIR/common/configs/opencode" "$HOME/.config/opencode"
AUTHORITATIVE=0

printf '%s\n' '[omarchy-sync] restoring portable post-install integrations'
bash "$DOTFILES_DIR/omarchy/scripts/post-install-omarchy.sh"

printf '%s\n' '[omarchy-sync] converging private configuration and MCP tools'
bash "$DOTFILES_DIR/omarchy/scripts/private-omarchy.sh"

bashrc_source='[[ -r "$HOME/.config/dotfiles/bashrc" ]] && source "$HOME/.config/dotfiles/bashrc"'
if [ ! -f "$HOME/.bashrc" ]; then
  printf '%s\n' "[omarchy-sync] expected Bash startup file is missing: $HOME/.bashrc" >&2
else
  if ! grep -Fqx "$bashrc_source" "$HOME/.bashrc"; then
    printf '\n# Shared personal shell configuration managed by ~/dotfiles\n%s\n' "$bashrc_source" >>"$HOME/.bashrc"
    printf '%s\n' '[omarchy-sync] added the shared Bash configuration to ~/.bashrc'
  fi
fi

if [ "${#CONFLICTS[@]}" -gt 0 ]; then
  printf '%s\n' '[omarchy-sync] existing files were preserved:' >&2
  printf '  %s\n' "${CONFLICTS[@]}" >&2
  printf '%s\n' '[omarchy-sync] review them, or rerun with OMARCHY_DOTFILES_FORCE=1 to back them up and link repository versions.' >&2
fi

printf '%s\n' '[omarchy-sync] complete; Omarchy desktop, Docker, and global mise config were left untouched.'
