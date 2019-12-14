# Status
![](https://github.com/erzz/dotfiles/workflows/Test%20Dotfiles/badge.svg?branch=master)

# Acknowledgment

* The basis of this repo is https://github.com/jponge/dotfiles
* Additional inspiration from https://github.com/atomantic/dotfiles

# Summary of current config
* Bunch of apps installed via homebrew (Brewfile)
* Zsh & Git configured via home/*
* Whole load of OS tweaks in scripts/tweaks.sh
* Install and config of OMZ plugins
* Custom hosts file deployed from http://someonewhocares.org/hosts/

# Getting up and running

1. `./install.sh`

# Tests
Due to the limitations of a Github Actions runner's Mac OS environment - its not possible to completely test the entire suite (cannot sudo for example so `scripts/tweaks.sh` is not possible, plus we use the runners homebrew so the `scripts/installHomebrew.sh` is not tested either) so a best effort is made with what we can test. 

Currently we can test:
* The entire homebrew bundle `scripts/brewfile.sh`
* The oh-my-zsh install and config `scripts/installOhMyZSH.sh`
* Dotfile linking `scripts/LinkDotfiles.sh`

3 out of 5 aint bad I guess? :)
