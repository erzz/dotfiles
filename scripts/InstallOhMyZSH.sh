#!/bin/bash
set -ex
# Install Oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install p10k theme (Skip in the case of actions CI test)
if id -u runner; then
  echo "Skipping p10k install for CI test"
else
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi