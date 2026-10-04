#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${HOME}/dotfiles"
OFFICIAL_FILE="$DOTFILES_DIR/omarchy/packages/omarchy.apps.arch"
AUR_FILE="$DOTFILES_DIR/omarchy/packages/omarchy.apps.aur"

bash "$DOTFILES_DIR/omarchy/scripts/omarchy-preflight.sh"

read_packages() {
  awk 'NF && $1 !~ /^#/ { print $1 }' "$1"
}

if [ "${OMARCHY_PACKAGE_DRY_RUN:-0}" = 1 ]; then
  printf '%s\n' '[omarchy-install-apps] official packages:'
  read_packages "$OFFICIAL_FILE"
  printf '%s\n' '[omarchy-install-apps] AUR packages:'
  read_packages "$AUR_FILE"
  exit 0
fi

if ! sudo -n -v </dev/null >/dev/null 2>&1; then
  printf '%s\n' '[omarchy-install-apps] passwordless sudo authorization is required.' >&2
  exit 1
fi

mapfile -t official_packages < <(read_packages "$OFFICIAL_FILE")
if [ "${#official_packages[@]}" -gt 0 ]; then
  if [ "${OMARCHY_DOTFILES_SYSTEM_UPDATED:-0}" != 1 ]; then
    printf '%s\n' '[omarchy-install-apps] updating Omarchy before installing repository applications'
    omarchy update -y
  fi
  sudo -n pacman -S --needed --noconfirm "${official_packages[@]}" </dev/null
fi

mapfile -t aur_packages < <(read_packages "$AUR_FILE")
if [ "${#aur_packages[@]}" -gt 0 ]; then
  command -v yay >/dev/null 2>&1 || {
    printf '%s\n' '[omarchy-install-apps] yay is required for AUR applications.' >&2
    exit 1
  }
  for attempt in 1 2 3; do
    if yay -S --needed --noconfirm --answerclean None --answerdiff None --noremovemake \
      "${aur_packages[@]}" </dev/null; then
      break
    fi
    if [ "$attempt" -eq 3 ]; then
      printf '%s\n' '[omarchy-install-apps] AUR was unavailable after 3 attempts.' >&2
      exit 1
    fi
    printf '%s\n' "[omarchy-install-apps] AUR attempt $attempt failed; retrying in 10 seconds." >&2
    sleep 10
  done
fi
