#!/usr/bin/env bash
set -ex

if ! command -v starship &>/dev/null; then
    echo "Starship not found, installing Starship..."
    brew install starship
else
    echo "Starship already installed, skipping..."
fi

echo "Making starship pretty..."
# create .starship and .starship/helper folder, if not exist
mkdir -p "${HOME}/.starship"

# create symlinks for starship.toml config file
ln -sfv "${HOME}/dotfiles/starship/starship.toml" "${HOME}/.starship"
