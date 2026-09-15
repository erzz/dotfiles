#!/usr/bin/env bash
# Tmux: repository owns the configuration; host plugin installation is optional.
set -euo pipefail

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
[ -f "$root/home/dot_tmux.conf" ] || { echo "repository tmux configuration missing"; exit 1; }
if command -v tmux >/dev/null; then
  tmux -f "$root/home/dot_tmux.conf" -C "list-commands" >/dev/null 2>&1 || {
    echo "tmux configuration failed to parse"; exit 1;
  }
fi
