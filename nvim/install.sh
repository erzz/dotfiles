#!/usr/bin/env bash
set -ex

if ! command -v nvim &>/dev/null; then
    echo "nvim not found, installing..."
    brew install nvim
else
    echo "nvim already installed, skipping..."
fi

stow -v -t "${HOME}" nvim