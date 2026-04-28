#!/usr/bin/env bash
# Mise: config dir symlinked into the chezmoi configs/ tree.
set -euo pipefail

target="${HOME}/.config/mise"
[ -L "$target" ] || { echo "$target not a symlink"; exit 1; }

resolved="$(readlink "$target")"
case "$resolved" in
  *chezmoi/configs/mise*) ;;
  *) echo "$target points to $resolved (expected chezmoi configs/mise)"; exit 1 ;;
esac

command -v mise >/dev/null || { echo "mise not on PATH"; exit 1; }
