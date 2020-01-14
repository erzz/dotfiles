#!/bin/zsh

set -e
# Fix permissions in cases where perhaps re-running under a different user and similar scenarios
sudo chown -R $(whoami) /usr/local/var/homebrew
sudo chown -R $(whoami) /usr/local/Homebrew
sudo chown -R $(whoami) /usr/local/Caskroom
sudo chown -R $(whoami) /usr/local/Cellar/
sudo chown -R $(whoami) /usr/local/bin
sudo chown -R $(whoami) /usr/local/etc
sudo chown -R $(whoami) /usr/local/lib
sudo chown -R $(whoami) /usr/local/sbin
sudo chown -R $(whoami) /usr/local/share/aclocal
sudo chown -R $(whoami) /usr/local/share/doc
sudo chown -R $(whoami) /usr/local/share/info
sudo chown -R $(whoami) /usr/local/share/locale
sudo chown -R $(whoami) /usr/local/share/man
sudo chown -R $(whoami) /usr/local/share/zsh

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
if wget -O configs/hosts https://someonewhocares.org/hosts/hosts; then
  sudo cp /etc/hosts /etc/hosts.backup
  sudo cp configs/hosts /etc/hosts
else
  echo "Couldn't fetch the latest hosts file from https://someonewhocares.org/hosts/hosts so skipping this step in order to not screw up your computer!"
fi
