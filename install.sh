#!/bin/zsh

set -e
source scripts/outputFormat.sh

##################### SUDO KEEPALIVE ######################
# sudo keep-alive, see https://gist.github.com/cowboy/3118588
title "install.sh: Setting SUDO keep-alive"
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

####################### XCODE CLI #########################
title "install.sh: Installing Xcode CLI tools if needed"
xcode-select --install 2>/dev/null || echo "XCode CLI already_installed"

################## SCRIPT PERMISSIONS #####################
title "install.sh: Setting script permissions"
chmod +x scripts/*.sh && echo "Scripts are executable"

######################### BREW ############################
title "install.sh: Installing Homebrew & Brewfile"
scripts/homebrew.sh

####################### ZSH & OMZ #########################
title "install.sh: Installing Oh My ZSH"
scripts/ohmyzsh.sh
title "install.sh: Linking dotfiles"
scripts/link.sh

####################### APP STORE #########################
scripts/appstore.sh

####################### TWEAK OS ##########################
title "install.sh: Checking if running in CI"
if ! id -u runner 2>/dev/null; then
  echo "Not running in CI, executing OS tweaks"
  scripts/tweaks.sh
else
  echo "Running in CI, skipping tweaks & setting locale"
  defaults write NSGlobalDomain AppleLanguages "(en-US)"
fi
