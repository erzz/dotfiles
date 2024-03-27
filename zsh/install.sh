#!/usr/bin/env bash
set -ex

echo "Activating zsh config..."

# create symlinks
stow -v -t "${HOME}" zsh

# install zsh, if not installed already
if [ -z "${ZSH}" ] || ! [ -d "${ZSH}" ]; then
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

	# set zsh as default shell
	chsh -s /bin/zsh

	# load zsh
	exec /bin/zsh
fi

# upgrade zsh
sh "$ZSH/tools/upgrade.sh"
