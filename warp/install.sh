#!/usr/bin/env bash
set -ex

if [ ! -d "/Applications/Warp.app" ]; then
	echo "Warp not found, installing Warp..."
	brew install --cask warp
fi

echo "Configuring warp..."
defaults write dev.warp.Warp-Stable -string "${HOME}/dotfiles/warp/settings.plist"
defaults read dev.warp.Warp-Stable >"${HOME}/dotfiles/warp/settings.plist"
