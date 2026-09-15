#!/usr/bin/env bash
# Mise: repository owns the native mise configuration.
set -euo pipefail

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
[ -f "$root/mise.toml" ] || { echo "mise.toml missing from repository root"; exit 1; }
[ -f "$root/mise.apps.toml" ] || { echo "mise.apps.toml missing from repository root"; exit 1; }

command -v mise >/dev/null || { echo "mise not on PATH"; exit 1; }

# Parse both declarations without installing tools or applying bootstrap state.
mise tasks validate
mise config ls >/dev/null
mise -E apps config ls >/dev/null

! grep -q '{{ config_root }}' "$root/mise.toml"
! grep -qE '(^|[[:space:]])\./(bootstrap|brew)/' "$root/mise.toml"
grep -q '"${MISE_CONFIG_ROOT:?}/bootstrap/ensure-native-homebrew.sh"' "$root/mise.toml"
grep -q '"${MISE_CONFIG_ROOT:?}/bootstrap/render-private-config.sh"' "$root/mise.toml"
grep -q 'fnox exec --replace -- /bin/bash "${MISE_CONFIG_ROOT:?}/bootstrap/render-private-config.sh"' "$root/mise.toml"
grep -q 'renderer_path="${MISE_CONFIG_ROOT:?}/bootstrap/render-private-config.sh" && fnox exec --replace -- /bin/bash "\$renderer_path"' "$root/mise.toml"
! grep -q 'mise run render-private-config' "$root/mise.toml"
grep -q '&& printf.*converging apps' "$root/mise.toml"
grep -q -- '"${MISE_CONFIG_ROOT:?}/brew/Brewfile.casks"' "$root/mise.toml"
grep -q -- '"${MISE_CONFIG_ROOT:?}/brew/Brewfile.fonts"' "$root/mise.toml"
! grep -q 'pre-packages.*true' "$root/mise.toml"
