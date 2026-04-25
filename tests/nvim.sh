#!/usr/bin/env bash
# Nvim: config dir symlinked, headless start succeeds (skipped if nvim missing).
set -euo pipefail

target="${HOME}/.config/nvim"
[ -L "$target" ] || { echo "$target not a symlink"; exit 1; }

resolved="$(readlink "$target")"
case "$resolved" in
  *chezmoi/configs/nvim*) ;;
  *) echo "$target points to $resolved (expected chezmoi configs/nvim)"; exit 1 ;;
esac

if command -v nvim >/dev/null; then
  nvim --headless "+lua print('ok')" "+qa" >/dev/null 2>&1 \
    || { echo "nvim startup failed"; exit 1; }
fi
