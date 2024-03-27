#!/usr/bin/env bash
set -e

# install sdkman
# shellcheck source=/dev/null
# fetch sdkman, if not exist
if [ ! -f "${HOME}/.sdkman/bin/sdkman-init.sh" ]; then
	/bin/bash -c "$(curl -s https://get.sdkman.io)"
fi

# shellcheck disable=SC1091
source "${HOME}/.sdkman/bin/sdkman-init.sh"

# symlink sdkman config file
mkdir -p "${HOME}/.sdkman/etc"
ln -sfv "${HOME}/dotfiles/languages/config" "${HOME}/.sdkman/etc/config"

# update sdkman
sdk selfupdate

# install sdks
sed -e 's/[[:space:]]*#.*// ; /^[[:space:]]*$/d' "${HOME}/dotfiles/languages/sdks.txt" |
	while read -r SDK; do
		sdk list "${SDK}" | grep 'installed' || sdk install "${SDK}"
	done

# update sdks
sdk update

# sort sdks.txt file
UUID=$(uuidgen)
sort "${HOME}/dotfiles/languages/sdks.txt" >"/tmp/${UUID}"
mv "/tmp/${UUID}" "${HOME}/dotfiles/languages/sdks.txt"
