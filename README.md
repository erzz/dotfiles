# Summary

- Powered with `make`, cos honestly I have played with all the things like nix - but this just gets
  the job done without it being a full time job!
- Covers homebrew, git, terminal, various programming language installs, NVIM (Lazy), OS tweaks,
  starship and ZSH and more
- Can be applied in totality or individual components can be applied in a scoped way
- Devbox and direnv initial installs and config
- Detection of drift in dotfiles included

## Installation

Imagine a brand spanking new laptop!

Dotfiles will be perfect to get me up and running **except** for the fact that git is not yet
installed, yet I need git to fetch and run my dotfiles, which, in turn would be the thing to install
and configure git :cry:

Well fear not - on MacOS, just typing the word git in a terminal will prompt you to install xcode
cli tools including git.

So my approach would be simply (assuming you are in home directory):

```bash
git

# Do some clicking and get xcode cli tools installed

git clone https://github.com/erzz/dotfiles.git
cd dotfiles
make
```

Alternatively, if you do not want to track changes, you can run the following

```bash
cd ~ \
  && curl -L https://github.com/erzz/dotfiles/archive/main.zip | bsdtar -xvf- \
  && mv dotfiles-master dotfiles \
  && cd dotfiles \
  && make
```

## Do it all

Run everything

```bash
make
```

## Basics

### Homebrew

Whole bunch of clis, fonts, apps and vscode extensions etc. Subtargets `make xcode` and
`make brew-install` to ensure the pre-requisites are installed.

```bash
make brew
```

### Stow

Important as it drives creation of all symlinks to configuration files

```bash
make stow
```

### Global git config

Does what it says

```bash
make git
```

### ZSH

The random configs of .zshrc that makes the magic happen

```bash
make zsh
```

## Terminal

### Alacritty

Fast and small with some colours etc

```bash
make alacritty
```

### tmux

General tmux setup including keymaps, plugins and nvim integration

```bash
make tmux
```

## Programming & Dev environments

### Languages

Uses the various `<lang>env` tools to bootstrap the latest Go, Node, Python, Terraform etc

```bash
make languages
```

### Devbox

Automated and isolated dev environments of any configuration (powered by nix). Unfortunately they do
not provide a brew package yet, so this will prompt a little bit for sudo rights.

```bash
make devbox
```

### Direnv

Pairs beautifully with devbox/nix to automatically enable environments when you enter the directory.

```bash
make direnv
```

## OS Tweaks

Ever evolving OS tweaks to Finder, Activity Monitor, etc

```bash
make os
```

## Other

### NVIM

Based on LazyVIM with various tweaks, themes etc

```bash
make nvim
```

### Starship

My pretty (I think) Starship config cos no-one likes writing TOML unless they have to!

```bash
make starship
```

### prettierd

A global configuration for prettier for any projects that do not have it installed or configured

```bash
make prettierd
```

## Acknowledgements

- The inspiration of this repo is [pkissling](https://github.com/pkissling/dotfiles/)
