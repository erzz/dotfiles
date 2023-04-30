#!/bin/bash
set -e
source scripts/outputFormat.sh

title "Checking for OH-MY-ZSH"
if [ -d ~/.oh-my-zsh ]; then
  echo "OH-MY-ZSH already installed"
  exit 0
fi

# Install Oh-my-zsh
title "Installing OH-MY-ZSH"
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install p10k theme (Skip in the case of actions CI test)
if id -u runner; then
  echo "Skipping p10k install for CI test"
else
  title "Installing p10k theme"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi
