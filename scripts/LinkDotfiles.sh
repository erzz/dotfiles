#!/bin/bash
# Link all dotfiles into ~ using GNU Stow, assuming we are in ~/dotfiles
set -ex
for config in $(ls -A home); do
    if [ -f ~/"$config" ]; then
        echo "Backing up $config to old-$config"
        mv ~/"$config" ~/old-"$config"
    fi
done

stow -R -t ~ home
