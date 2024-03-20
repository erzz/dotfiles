#!/usr/bin/env bash
set -ex

echo "Configuring git..."

# create new git folder
mkdir -p "${HOME}"/.git

# create symlinks
ln -sfv "${HOME}/dotfiles/git/.gitconfig" "${HOME}"
ln -sfv "${HOME}/dotfiles/git/.gitignore_global" "${HOME}/.git"
