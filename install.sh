#!/bin/zsh

set -e

# Case for running as a test user on a github runner
if id -u runner; then
  echo "Skipping Homebrew install for Github Workflow"
  defaults write NSGlobalDomain AppleLanguages "(en-US)"
else
  scripts/InstallHomebrew.sh
fi
#scripts/brewfile.sh #DEBUG
scripts/InstallOhMyZSH.sh
scripts/LinkDotfiles.sh
scripts/tweaks.sh

# ###########################################################
# /etc/hosts -- spyware/ad blocking
# ###########################################################
sudo cp /etc/hosts /etc/hosts.backup
sudo cp configs/hosts /etc/hosts
