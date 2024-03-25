#!/usr/bin/env bash
set -ex

if ! command -v direnv version &>/dev/null; then
	echo "direnv not found, installing..."
	brew install direnv
fi

echo "Configuring direnv..."

stow -v -t "${HOME}" direnv
