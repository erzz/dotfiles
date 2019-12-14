#!/bin/zsh

set -e

# Case for running as a test user on a github runner
if id -u runner; then
  echo "Skipping Homebrew install & tweaks for Github Workflow"
  defaults write NSGlobalDomain AppleLanguages "(en-US)"
  scripts/brewfile.sh
  scripts/InstallOhMyZSH.sh
  scripts/LinkDotfiles.sh
else
  scripts/InstallHomebrew.sh
  scripts/brewfile.sh
  scripts/InstallOhMyZSH.sh
  scripts/LinkDotfiles.sh
  scripts/tweaks.sh
fi


# ###########################################################
# /etc/hosts -- spyware/ad blocking
# ###########################################################
sudo cp /etc/hosts /etc/hosts.backup
sudo cp configs/hosts /etc/hosts
