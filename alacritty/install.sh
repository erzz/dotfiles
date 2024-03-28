#!/usr/bin/env bash
set -ex

if ! command -v alacritty &>/dev/null; then
	echo "alacritty not found, installing..."
	brew install alacritty
else
	echo "alacritty already installed, skipping..."
fi

echo "Making starship pretty..."
stow -v -t "${HOME}"  alacritty

