#!/usr/bin/env bash
set -euo pipefail

FNOX_CONFIG="$HOME/.config/fnox/config.toml"

if ! command -v fnox >/dev/null 2>&1; then
  printf '%s\n' '[omarchy-private] fnox is not installed; run mise run omarchy-sync first.' >&2
  exit 1
fi

if ! command -v op >/dev/null 2>&1; then
  printf '%s\n' '[omarchy-private] 1Password CLI is not installed; run mise run omarchy-install-packages.' >&2
  exit 1
fi

# Automated runs must use either a caller-supplied service-account token or an
# already-enabled 1Password desktop CLI integration. Do not invoke `op signin`:
# it requires a UI/password and can hang unattended.
if [ -z "${OP_SERVICE_ACCOUNT_TOKEN:-}" ] && [ -n "${FNOX_OP_SERVICE_ACCOUNT_TOKEN:-}" ]; then
  export OP_SERVICE_ACCOUNT_TOKEN="$FNOX_OP_SERVICE_ACCOUNT_TOKEN"
fi

if [ ! -f "$FNOX_CONFIG" ]; then
  printf '%s\n' "[omarchy-private] fnox configuration is missing: $FNOX_CONFIG" >&2
  exit 1
fi

if ! fnox --non-interactive --no-daemon --if-missing error -c "$FNOX_CONFIG" check; then
  printf '%s\n' '[omarchy-private] fnox could not resolve the configured 1Password secrets.' >&2
  printf '%s\n' '[omarchy-private] provide OP_SERVICE_ACCOUNT_TOKEN or enable the 1Password desktop CLI integration.' >&2
  exit 1
fi
