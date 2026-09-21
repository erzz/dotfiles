#!/usr/bin/env bash
set -euo pipefail

umask 077
required_vars=(GH_TOKEN ARTIFACTORY_AUTH_TOKEN NPM_TOKEN LINEARB_API_KEY NPM_ORG_SCOPE NPM_REGISTRY_HOST GITHUB_ORG_SCOPE)
for variable in "${required_vars[@]}"; do
  if [[ -z "${!variable:-}" ]]; then
    printf '%s\n' "render-private-config: required environment variable is missing: ${variable}" >&2
    exit 1
  fi
done

secrets_dir="$HOME/.local/state"
secrets_file="$secrets_dir/secrets.env"
npmrc_file="$HOME/.npmrc"
mkdir -p "$secrets_dir" "$(dirname "$npmrc_file")"
secrets_tmp=$(mktemp "$secrets_dir/.secrets.env.XXXXXX")
npmrc_tmp=$(mktemp "$(dirname "$npmrc_file")/.npmrc.XXXXXX")
secrets_backup=$(mktemp "$secrets_dir/.secrets.env.backup.XXXXXX")
npmrc_backup=$(mktemp "$(dirname "$npmrc_file")/.npmrc.backup.XXXXXX")
rm -f "$secrets_backup" "$npmrc_backup"

committed=0
rollback() {
  local status=$?
  if (( committed == 0 )); then
    rm -f "$secrets_file" "$npmrc_file"
    [[ -e "$secrets_backup" ]] && mv -f "$secrets_backup" "$secrets_file"
    [[ -e "$npmrc_backup" ]] && mv -f "$npmrc_backup" "$npmrc_file"
  else
    rm -f "$secrets_backup" "$npmrc_backup"
  fi
  rm -f "$secrets_tmp" "$npmrc_tmp"
  exit "$status"
}
trap rollback EXIT

{
  printf '# Rendered by fnox from 1Password; refresh with `mise run render-private-config`.\n'
  printf 'export GH_TOKEN=%q\n' "$GH_TOKEN"
  printf 'export ARTIFACTORY_AUTH_TOKEN=%q\n' "$ARTIFACTORY_AUTH_TOKEN"
  printf 'export NPM_TOKEN=%q\n' "$NPM_TOKEN"
  printf 'export LINEARB_API_KEY=%q\n' "$LINEARB_API_KEY"
} >"$secrets_tmp"
{
  printf '# Rendered by fnox from 1Password; refresh with `mise run render-private-config`.\n'
  printf '%s:registry=https://%s\n' "$NPM_ORG_SCOPE" "$NPM_REGISTRY_HOST"
  printf '@%s:registry=https://npm.pkg.github.com/\n' "$GITHUB_ORG_SCOPE"
  printf '//npm.pkg.github.com/:_authToken=${GH_TOKEN}\n'
} >"$npmrc_tmp"
chmod 600 "$secrets_tmp" "$npmrc_tmp"

# Move both old files aside before either replacement; failures restore the pair.
[[ -e "$secrets_file" ]] && mv -f "$secrets_file" "$secrets_backup"
[[ -e "$npmrc_file" ]] && mv -f "$npmrc_file" "$npmrc_backup"
mv -f "$secrets_tmp" "$secrets_file"
mv -f "$npmrc_tmp" "$npmrc_file"
committed=1
