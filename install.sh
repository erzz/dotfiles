#!/bin/zsh

set -e

scripts/InstallHomebrew.sh
scripts/LinkDotfiles.sh
scripts/InstallOhMyZSH.sh

# ###########################################################
# /etc/hosts -- spyware/ad blocking
# ###########################################################
sudo cp /etc/hosts /etc/hosts.backup
sudo cp configs/hosts /etc/hosts

