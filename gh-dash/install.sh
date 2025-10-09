#!/usr/bin/env bash
set -ex

# Check if gh cli is installed
if ! command -v gh --version &>/dev/null; then
  echo "gh cli required, installing..."
  brew install gh
else
  echo "gh cli already installed, skipping..."
fi

# Check if dash is installed
if ! command -v gh dash --version &>/dev/null; then
  echo "gh dash not found, installing..."
  gh extension install dlvhdr/gh-dash
else
  echo "gh dash already installed, skipping..."
fi

echo "Configuring gh dash..."
stow -v -t "${HOME}" gh-dash
