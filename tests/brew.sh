#!/usr/bin/env bash
# Brew: minimum tools available (these are in both Brewfile and Brewfile.ci).
set -euo pipefail

REQUIRED=(bat delta direnv eza fd fzf git jq mise rg starship tmux zsh chezmoi)
missing=()
for cmd in "${REQUIRED[@]}"; do
  command -v "$cmd" >/dev/null || missing+=("$cmd")
done

if [ ${#missing[@]} -gt 0 ]; then
  echo "Missing required tools: ${missing[*]}"
  exit 1
fi
