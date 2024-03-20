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
