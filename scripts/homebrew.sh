#!/bin/bash
set -e

#################### INSTALL HOMEBREW #####################
if [[ "$(uname)" == "Darwin" ]]; then
  echo "Setting correct path for CPU architecture"
  if [[ "$(arch)" == "arm64" ]]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
  else
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
  fi

  # Install brew
  if test ! $(which brew); then
    echo "Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo
  fi

  # Get Brew directory
  BREW_PREFIX=$(brew --prefix)

  echo "Disabling Brew analytics."
  brew analytics off

  # Fix permissions for Zsh compaudit
  chmod go-w $BREW_PREFIX/share

  # Link Brew OpenJDK
  sudo ln -sfn $BREW_PREFIX/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk

  # Ensure Brew Zsh is a valid shell option
  if ! cat /etc/shells | grep $BREW_PREFIX/bin/zsh > /dev/null; then
    echo "Adding Homebrew Zsh to list of allowed shells."
    sudo sh -c 'echo ${BREW_PREFIX}/bin/zsh >> /etc/shells'
    echo
  fi

  # Ensure Brew Bash is a valid shell option
  if ! cat /etc/shells | grep $BREW_PREFIX/bin/bash > /dev/null; then
    echo "Adding Homebrew Bash to list of allowed shells."
    sudo sh -c 'echo ${BREW_PREFIX}/bin/bash >> /etc/shells'
    echo
  fi
fi
