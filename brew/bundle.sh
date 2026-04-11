#!/usr/bin/env bash
set -ex

echo "Installing Homebrew packages..."

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

# install packages from Brewfile
brew bundle --file "${DOTFILES}/brew/Brewfile"

brew cleanup
