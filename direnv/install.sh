#!/usr/bin/env bash
set -ex

if ! command -v direnv version &>/dev/null; then
    echo "direnv not found, installing..."
    brew install direnv
fi

echo "Configuring direnv..."
# create symlinks for direnv.toml config file
mkdir -p "${HOME}/.config/direnv"
ln -sfv "${HOME}/dotfiles/direnv/direnv.toml" "${HOME}/.config/direnv/direnv.toml"
