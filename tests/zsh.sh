#!/usr/bin/env bash
# Zsh: repository owns the shell configuration.
set -euo pipefail

[ -f "$(git rev-parse --show-toplevel 2>/dev/null || pwd)/home/dot_zshrc" ] || { echo "repository zsh configuration missing"; exit 1; }

# Host shell and plugin checks are outside repository-native CI validation.
if [ -z "${CI:-}" ]; then
  [ -d "${HOME}/.oh-my-zsh" ] || { echo "Oh My Zsh missing"; exit 1; }
fi

if [ -z "${CI:-}" ]; then
  current="$(dscl . -read /Users/"$(whoami)" UserShell 2>/dev/null | awk '{print $2}')"
  [ "$current" = "/bin/zsh" ] || { echo "Default shell is $current, expected /bin/zsh"; exit 1; }
fi
