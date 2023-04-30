#!/bin/bash
set -e
source scripts/outputFormat.sh

#################### INSTALL HOMEBREW #####################
if [[ "$(uname)" == "Darwin" ]]; then
  title "Setting correct path for CPU architecture"
  if [[ "$(arch)" == "arm64" ]]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
  else
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
  fi

  # Install brew
  if test ! $(which brew); then
    title "Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo
  fi

  # Get Brew directory
  BREW_PREFIX=$(brew --prefix)

  title "Disabling Brew analytics."
  brew analytics off

  title "Installing Brew software."
  brew bundle | indent
  echo
  echo "Run 'brew doctor' to verify the installation after you reboot."

  # Fix permissions for Zsh compaudit
  chmod go-w $BREW_PREFIX/share

  # Link Brew OpenJDK
  sudo ln -sfn $BREW_PREFIX/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk

  # Ensure Brew Zsh is a valid shell option
  if ! cat /etc/shells | grep $BREW_PREFIX/bin/zsh > /dev/null; then
    title "Adding Homebrew Zsh to list of allowed shells."
    sudo sh -c 'echo ${BREW_PREFIX}/bin/zsh >> /etc/shells'
    echo
  fi

  # Ensure Brew Bash is a valid shell option
  if ! cat /etc/shells | grep $BREW_PREFIX/bin/bash > /dev/null; then
    title "Adding Homebrew Bash to list of allowed shells."
    sudo sh -c 'echo ${BREW_PREFIX}/bin/bash >> /etc/shells'
    echo
  fi
fi
