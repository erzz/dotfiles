#!/usr/bin/env bash
# Native mise: verify the package declaration is present on macOS.
set -euo pipefail

if [ "$(uname -s)" != "Darwin" ] || [ -n "${CI:-}" ]; then
  exit 0
fi

REQUIRED=(git jq mise)
missing=()
for cmd in "${REQUIRED[@]}"; do
  command -v "$cmd" >/dev/null || missing+=("$cmd")
done

if [ ${#missing[@]} -gt 0 ]; then
  echo "Missing required tools: ${missing[*]}"
  exit 1
fi
