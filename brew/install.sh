#!/usr/bin/env bash
set -ex

# install brew, if not installed
if ! command -v brew &>/dev/null; then
	echo "Homebrew not found, installing Homebrew..."

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	# Evaluating the brew shell environment
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew analytics off
