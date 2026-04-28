#!/usr/bin/env bash
# Tmux: config symlinked, TPM installed.
set -euo pipefail

[ -L "${HOME}/.tmux.conf" ] || { echo ".tmux.conf not a symlink"; exit 1; }
[ -d "${HOME}/.tmux/plugins/tpm" ] || { echo "TPM not installed"; exit 1; }
command -v tmux >/dev/null || { echo "tmux not on PATH"; exit 1; }
