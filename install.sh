#!/bin/zsh

set -e
# Fix permissions in cases where perhaps re-running under a different user and similar scenarios
DIRS="/usr/local/var/homebrew /usr/local/Homebrew /usr/local/Caskroom /usr/local/Cellar /usr/local/bin /usr/local/etc /usr/local/lib /usr/local/sbin /usr/local/share/aclocal /usr/local/share/doc /usr/local/share/info /usr/local/share/locale /usr/local/share/man /usr/local/share/zsh"

for d in DIRS; do
  if [ -d $d ]; then
    sudo chown -R $(whoami) $d
  fi
done

# Case for running as a test user on a github runner
chmod +x scripts/*.sh
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
if curl -L -O configs/hosts https://someonewhocares.org/hosts/hosts; then
  sudo cp /etc/hosts /etc/hosts.backup
  sudo cp configs/hosts /etc/hosts
else
  echo "Couldn't fetch the latest hosts file from https://someonewhocares.org/hosts/hosts so skipping this step in order to not screw up your computer!"
fi
