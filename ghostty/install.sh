#!/usr/bin/env bash
set -ex

if ! command -v ghostty &>/dev/null; then
	echo "ghostty not found, installing..."
	brew install ghostty
else
	echo "ghostty already installed, skipping..."
fi

echo "Configuring ghostty..."
stow -v -t "${HOME}" ghostty
