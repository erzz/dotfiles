#!/usr/bin/env bash

set -ex

# Run the installer with the --force flag to avoid prompts
curl -fsSL https://get.jetpack.io/devbox | bash -f