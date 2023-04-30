#!/bin/zsh

set -e

# Case for running as a test user on a github runner
chmod +x scripts/*.sh

if ! id -u runner; then
  scripts/InstallHomebrew.sh
  scripts/tweaks.sh
else
  echo "Skipping Homebrew install & tweaks for Github Workflow"
  defaults write NSGlobalDomain AppleLanguages "(en-US)"
fi

scripts/brewfile.sh
scripts/InstallOhMyZSH.sh
scripts/LinkDotfiles.sh
scripts/installAppStore.sh
