#!/usr/bin/env bash
# Opencode: config dir symlinked into the chezmoi configs/ tree.
set -euo pipefail

target="${HOME}/.config/opencode"
[ -L "$target" ] || { echo "$target not a symlink"; exit 1; }

resolved="$(readlink "$target")"
case "$resolved" in
  *chezmoi/configs/opencode*) ;;
  *) echo "$target points to $resolved (expected chezmoi configs/opencode)"; exit 1 ;;
esac
