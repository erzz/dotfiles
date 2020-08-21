# Status
![](https://github.com/erzz/dotfiles/workflows/Test%20Dotfiles/badge.svg)

# Acknowledgments
* The basis of this repo is https://github.com/jponge/dotfiles
* Additional inspiration from https://github.com/atomantic/dotfiles

# Summary of current config
## Custom Installations
* Homebrew (of course!)
* Oh My ZSH configured with the powerlevel10k theme and plugins such as docker, fzf, git, history, kubectl, httpie, minikube, and zsh-syntax-highlighting.

## Configs
* Global .gitconfig and  .gitignore
* Too many OS tweaks to list - see `scripts/tweaks.sh` for more info

## Brew Casks 
* adobe-acrobat-reader
* appcleaner
* authy
* bbedit
* disk-inventory-x
* displaylink
* docker
* firefox
* google-chrome
* google-cloud-sdk
* istat-menus
* iterm2
* maccy
* microsoft-office
* onyx
* spotify
* the-unarchiver
* slack
* sourcetree
* whatsapp
* viscosity
* visual-studio-code
* vlc

## Brew Formulae
* bash-completion
* aspell
* bat
* binutils
* ccache
* coreutils
* curl
* dive
* flac
* git
* git-extras
* go
* gnupg2
* gnuplot
* graphviz
* htop
* httpie
* hostess
* hub
* imagemagick
* imapsync
* kubectl
* lame
* moreutils
* openjdk@11
* openssl
* p7zip
* pstree
* python
* rbenv
* rsync
* ruby-build
* shellcheck
* stow
* the_silver_searcher
* tree
* vim
* wget
* xz
* zsh
* zsh-completion
* zsh-syntax-highlighting

## Fonts
font-awesome-terminal-fonts font-cascadia font-cousine font-fira-code font-fontawesome font-hack font-handlee font-hasklig font-inconsolata font-open-sans font-open-sans-condensed font-montserrat font-noto-sans font-noto-emoji font-noto-color-emoji font-noto-serif font-pt-mono font-pt-sans font-pt-serif font-roboto font-roboto-condensed font-roboto-mono font-source-code-pro font-source-sans-pro font-source-serif-pro font-ubuntu

# Installation
1. `cd ~ && curl -L https://github.com/erzz/dotfiles/archive/master.zip | bsdtar -xvf- && mv dotfiles-master dotfiles && cd dotfiles && chmod +x install.sh && ./install.sh`

# Tests
## What cannot be tested
Due to the limitations of a Github Actions runner's Mac OS environment - its not possible to completely test the entire suite. 
Mainly the fact that one cannot sudo on a Github environment means `scripts/tweaks.sh` is not possible to test automatically but I can at least say that it ran without error on my 10.15.1 Macbook Pro :D
The testing also uses the runner's homebrew (again due to sudo limitations) so the `scripts/installHomebrew.sh` is not part of the tests but uses standard command everyone knows so well.

## What is tested by the pipeline
* The entire homebrew bundle `scripts/brewfile.sh` for the apps, formulae and fonts in `Brewfile`
* The oh-my-zsh install and config `scripts/installOhMyZSH.sh`
* Dotfile linking `scripts/LinkDotfiles.sh`

3 out of 5 test coverage aint bad I guess? :)
