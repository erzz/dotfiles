#!/usr/bin/env bash
set -ex

if ! command -v zellij -v &>/dev/null; then
  echo "zellij not found, installing..."
  brew install zellij
else
  echo "zellij already installed, skipping..."
fi

stow -v -t "${HOME}" zellij
