## Summary

* Powered with `make`, cos honestly I have played with all the things like nix - but this just gets
  the job done without it being a full time job!
* Covers homebrew, git, iterm, various programming language installs, OS tweaks, starship and ZSH
* Option to only apply various sections in a scoped way
* Coming soon (cos I haven't decided yet) one of devtools, flox or something similar for dev
  environments
* Detection of drift in dotfiles included

## Installation

Imagine a brand spanking new laptop!

Dotfiles will be perfect to get me up and running **except**
for the fact that git is not yet installed, yet I need git to fetch and run my dotfiles, which, in
turn would be the thing to install and configure git :cry:

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

## Contents

### Do it all

Runs everything

```bash
make
```

### Homebrew

Whole bunch of clis, fonts, apps and vscode extensions etc

```bash
make brew
```

### Global git config

Does what it says

```bash
make git
```

### Iterm2

Configure Iterm profile and colors

```bash
make iterm
```

### Languages

Uses the various `<lang>env` tools to bootstrap the latest Go, Node, Python, Terraform etc

```
make languages
```

### OS Tweaks

Ever evolving OS tweaks to Finder, Activity Monitor, etc

```bash
make os
```

### Starship config

My pretty (I think) Starship config cos no-one likes writing TOML unless they have to!

```bash
make starship
```

### Warp

Some experimental thing with Warp, not even sure I like it

```bash
make warp
```

### Xcode CLI

Needed for brew - part of `brew-install` target too

```bash
make xcode
```

### ZSH

The random configs of .zshrc that makes the magic happen

```bash
make zsh
```

## Acknowledgements

* The inspiration of this repo is https://github.com/pkissling/dotfiles/