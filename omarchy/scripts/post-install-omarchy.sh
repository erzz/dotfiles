#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${HOME}/dotfiles"

bash "$DOTFILES_DIR/omarchy/scripts/omarchy-preflight.sh"

printf '%s\n' '[omarchy-post-install] installing configured tmux plugins'
clone_repo() {
  local url="$1"
  local target="$2"
  local ref="${3:-}"

  if [ -e "$target" ]; then
    return 0
  fi

  mkdir -p "$(dirname "$target")"
  if [ -n "$ref" ]; then
    git clone --depth=1 --branch "$ref" "$url" "$target"
  else
    git clone --depth=1 "$url" "$target"
  fi
}

clone_repo "https://github.com/tmux-plugins/tpm.git" "$HOME/.tmux/plugins/tpm" "v3.1.0"
clone_repo "https://github.com/wfxr/tmux-power.git" "$HOME/.tmux/plugins/tmux-power" "v1"
clone_repo "https://github.com/tmux-plugins/tmux-resurrect.git" "$HOME/.tmux/plugins/tmux-resurrect" "v4.0.0"
clone_repo "https://github.com/tmux-plugins/tmux-continuum.git" "$HOME/.tmux/plugins/tmux-continuum" "v3.1.0"

codeburn_dir="$HOME/.config/omarchy/plugins/codeburn"
if [ -d "$codeburn_dir" ]; then
  omarchy plugin enable codeburn
else
  omarchy plugin add https://github.com/erzz/omarchy-codeburn.git --enable
fi

scratchpad_plugin_source="$DOTFILES_DIR/omarchy/plugins/erzz.scratchpad-indicator"
scratchpad_plugin_root="$HOME/.config/omarchy/plugins"
scratchpad_plugin_link="$scratchpad_plugin_root/erzz.scratchpad-indicator"

if [ ! -d "$scratchpad_plugin_source" ]; then
  printf '[omarchy-post-install] scratchpad indicator plugin source is missing: %s\n' "$scratchpad_plugin_source" >&2
  exit 1
fi

mkdir -p "$scratchpad_plugin_root"
if [ -L "$scratchpad_plugin_link" ]; then
  scratchpad_link_target="$(readlink "$scratchpad_plugin_link")"
  if [ "$scratchpad_link_target" != "$scratchpad_plugin_source" ]; then
    printf '[omarchy-post-install] refusing to replace plugin symlink pointing elsewhere: %s -> %s\n' \
      "$scratchpad_plugin_link" "$scratchpad_link_target" >&2
    exit 1
  fi
elif [ -e "$scratchpad_plugin_link" ]; then
  printf '[omarchy-post-install] refusing to replace existing plugin path: %s\n' "$scratchpad_plugin_link" >&2
  exit 1
else
  if ! ln -s "$scratchpad_plugin_source" "$scratchpad_plugin_link"; then
    printf '[omarchy-post-install] failed to create plugin symlink: %s -> %s\n' \
      "$scratchpad_plugin_link" "$scratchpad_plugin_source" >&2
    exit 1
  fi
fi

omarchy-shell shell rescanPlugins
omarchy plugin enable erzz.scratchpad-indicator
omarchy bar move erzz.scratchpad-indicator --after omarchy.workspaces
omarchy bar set omarchy.clock format 'ddd d MMM HH:mm'

tpm_install="$HOME/.tmux/plugins/tpm/bin/install_plugins"
if [ -x "$tpm_install" ] && [ -e "$HOME/.tmux.conf" ] && grep -qE '^\s*set\s+-g\s+@plugin' "$HOME/.tmux.conf" 2>/dev/null; then
  "$tpm_install"
else
  printf '%s\n' '[omarchy-post-install] TPM or configured tmux plugins not found; skipping.'
fi

printf '%s\n' '[omarchy-post-install] installing gh-dash extension'
if command -v gh >/dev/null 2>&1; then
  if ! gh auth status >/dev/null 2>&1; then
    printf '%s\n' '[omarchy-post-install] gh is not authenticated; skipping gh-dash.'
  elif gh extension list 2>/dev/null | grep -q 'dlvhdr/gh-dash'; then
    printf '%s\n' '[omarchy-post-install] gh-dash already installed.'
  else
    gh extension install dlvhdr/gh-dash
  fi
else
  printf '%s\n' '[omarchy-post-install] gh is unavailable; skipping gh-dash.'
fi

printf '%s\n' '[omarchy-post-install] installing agent-browser assets'
if [ -n "${CI:-}" ]; then
  printf '%s\n' '[omarchy-post-install] CI mode; skipping agent-browser assets.'
elif mise -C "$DOTFILES_DIR" where npm:agent-browser >/dev/null 2>&1; then
  if command -v chromium >/dev/null 2>&1 || command -v chromium-browser >/dev/null 2>&1 || command -v google-chrome >/dev/null 2>&1; then
    printf '%s\n' '[omarchy-post-install] system Chromium/Chrome found; agent-browser will use it.'
  elif ! mise -C "$DOTFILES_DIR" x npm:agent-browser -- agent-browser install; then
    printf '%s\n' '[omarchy-post-install] browser binary install failed; use a system browser or configure a provider.' >&2
  fi
else
  printf '%s\n' '[omarchy-post-install] agent-browser is unavailable; skipping.'
fi
