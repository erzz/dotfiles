#!/usr/bin/env bash
# Git: identity + key aliases load from the managed config.
set -euo pipefail

[ -L "${HOME}/.gitconfig" ] || { echo ".gitconfig not a symlink"; exit 1; }

# Identity
[ "$(git config --global user.name)"  = "Sean Erswell-Liljefelt" ] || { echo "git user.name wrong"; exit 1; }
[ "$(git config --global user.email)" = "sean@erzz.com" ]          || { echo "git user.email wrong"; exit 1; }

# Behaviour
[ "$(git config --global pull.rebase)"           = "true" ] || { echo "pull.rebase not true"; exit 1; }
[ "$(git config --global push.autoSetupRemote)"  = "true" ] || { echo "push.autoSetupRemote not true"; exit 1; }

# Aliases
[ -n "$(git config --global alias.s)" ] || { echo "git alias.s not set"; exit 1; }
