#!/usr/bin/env bash
set -ex

if ! command -v starship &>/dev/null; then
	echo "Starship not found, installing Starship..."
	brew install starship
else
	echo "Starship already installed, skipping..."
fi

echo "Making starship pretty..."
stow -v -t "${HOME}" starship
