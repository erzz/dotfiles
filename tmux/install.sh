#!/usr/bin/env bash
set -ex

if ! command -v tmux -v &>/dev/null; then
	echo "tmux not found, installing..."
	brew install tmux
else
	echo "tmux already installed, skipping..."
fi

if [ ! -d "${HOME}/.tmux" ]; then
	echo "Stowing tmux config..."
	stow -v -t "${HOME}" tmux
else
	echo "tmux already stowed, skipping..."
fi
