#!/usr/bin/env bash
# Zsh: .zshrc is symlinked, default shell is zsh, Oh My Zsh present.
set -euo pipefail

[ -L "${HOME}/.zshrc" ] || { echo ".zshrc not a symlink"; exit 1; }
[ -d "${HOME}/.oh-my-zsh" ] || { echo "Oh My Zsh missing"; exit 1; }

# Skip default-shell check in CI (chsh requires password)
if [ -z "${CI:-}" ]; then
  current="$(dscl . -read /Users/"$(whoami)" UserShell 2>/dev/null | awk '{print $2}')"
  [ "$current" = "/bin/zsh" ] || { echo "Default shell is $current, expected /bin/zsh"; exit 1; }
fi
