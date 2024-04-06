#!/usr/bin/env bash
set -ex

if [ ! -d "/Applications/Obsidian.app" ]; then
	echo "Obsidian not found, installing Obsidian..."
	brew install --cask obsidian
fi
