#!/usr/bin/env bash

set -ex

if ! command -v devbox &>/dev/null; then
	echo "devbox not found, installing..."
	curl -fsSL https://get.jetpack.io/devbox | bash -f
else
	echo "devbox already installed, skipping..."
fi
