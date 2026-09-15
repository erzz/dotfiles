#!/usr/bin/env bash
# Nvim: repository owns the configuration; headless start is optional.
set -euo pipefail

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
[ -d "$root/configs/nvim" ] || { echo "repository nvim configuration missing"; exit 1; }

if command -v nvim >/dev/null; then
  nvim --headless "+lua print('ok')" "+qa" >/dev/null 2>&1 \
    || { echo "nvim startup failed"; exit 1; }
fi
