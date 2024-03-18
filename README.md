# Status
![](https://github.com/erzz/dotfiles/workflows/Test%20Dotfiles/badge.svg)

## Acknowledgments

* The inspiration of this repo is https://github.com/pkissling/dotfiles/
* Powered with make, cos honestly I have played with all the things like nix - but this just gets the job done without it being a full time job!
* Apply scoped sections when you want with make targets

## Installation

```bash
cd ~ \
  && curl -L https://github.com/erzz/dotfiles/archive/master.zip | bsdtar -xvf- \
  && mv dotfiles-master dotfiles \
  && cd dotfiles \
  && make
```

## Contents

### Do it all

Just run `make`

### Xcode CLI

Needed for brew - part of brew target too

```bash
make xcode
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

### OS Tweaks

Ever evolving OS tweaks to Finder, Activity Monitor, etc

```bash
make os
```

### SDKMan

The day I don't need Java any more will make me a happy man

```bash
make sdkman
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

### ZSH

The random configs of .zshrc that makes the magic happen

```bash
make zsh
```
