#!/usr/bin/env bash
set -ex

if [ ! -d "/Applications/iTerm.app" ]; then
  echo "iTerm not found, installing iTerm..."
  brew install --cask iterm2
fi

echo "Configuring iTerm..."

# Specify the preferences directory
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "${HOME}/dotfiles/iterm"

# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
