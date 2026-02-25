#!/usr/bin/env bash
set -ex

echo "Installing Homebrew packages..."

# install packages from Brewfile
brew bundle --file "${HOME}/dotfiles/brew/Brewfile"

brew cleanup
