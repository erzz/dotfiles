#!/usr/bin/env bash
# Opencode: repository owns the configuration.
set -euo pipefail

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
[ -d "$root/configs/opencode" ] || { echo "repository opencode configuration missing"; exit 1; }
