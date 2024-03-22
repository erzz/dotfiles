#!/usr/bin/env bash
set -ex

if ! command -v nvim &>/dev/null; then
    echo "nvim not found, installing..."
    brew install nvim
else
    echo "nvim already installed, skipping..."
fi

# create symlinks for nvim config directory
ln -sfv "${HOME}/dotfiles/nvim/" "${HOME}/.config/nvim"
