#!/bin/zsh

set -e

####################### XCODE CLI #########################
echo "install.sh: Installing Xcode CLI tools if needed"
xcode-select --install 2>/dev/null || echo "XCode CLI already_installed"

######################### BREW ############################
echo "install.sh: Installing Homebrew & Brewfile"
scripts/homebrew.sh

########################## NIX ############################
echo "install.sh: Installing Nix"
sudo curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
sudo . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "install.sh: Applying Nix configuration"
make deploy

###### STARSHIP & CONFIG

################## SCRIPT PERMISSIONS #####################
# title "install.sh: Setting script permissions"
# chmod +x scripts/*.sh && echo "Scripts are executable"

# # Important: as it blasts away the current .zshrc 
# # should run before the other scripts
# ####################### ZSH & OMZ #########################
# title "install.sh: Installing Oh My ZSH"
# scripts/ohmyzsh.sh

# ##################### LINK DOTFILES #######################
# # title "install.sh: Linking dotfiles"
# # scripts/link.sh

# ####################### APP STORE #########################
# scripts/appstore.sh

# ####################### TWEAK OS ##########################
# title "install.sh: Checking if running in CI"
# if ! id -u runner 2>/dev/null; then
#   echo "Not running in CI, executing OS tweaks"
#   scripts/tweaks.sh
# else
#   echo "Running in CI, skipping tweaks & setting locale"
#   defaults write NSGlobalDomain AppleLanguages "(en-US)"
# fi
