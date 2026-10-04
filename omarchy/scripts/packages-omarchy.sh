#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${HOME}/dotfiles"
OFFICIAL_FILE="$DOTFILES_DIR/omarchy/packages/omarchy.arch"
AUR_FILE="$DOTFILES_DIR/omarchy/packages/omarchy.aur"

if [ "$(uname -s)" != Linux ] || [ ! -d /usr/share/omarchy ] || ! command -v omarchy >/dev/null 2>&1; then
  printf '%s\n' '[omarchy-install-packages] Omarchy Linux is required.' >&2
  exit 1
fi

read_packages() {
  awk 'NF && $1 !~ /^#/ { print $1 }' "$1"
}

if [ "${OMARCHY_PACKAGE_DRY_RUN:-0}" = 1 ]; then
  printf '%s\n' '[omarchy-install-packages] official packages:'
  read_packages "$OFFICIAL_FILE"
  printf '%s\n' '[omarchy-install-packages] AUR packages:'
  read_packages "$AUR_FILE"
  exit 0
fi

if ! sudo -n -v </dev/null >/dev/null 2>&1; then
  printf '%s\n' '[omarchy-install-packages] passwordless sudo authorization is required.' >&2
  printf '%s\n' '[omarchy-install-packages] run this task from an already-authorized automation context.' >&2
  exit 1
fi

mapfile -t official_packages < <(read_packages "$OFFICIAL_FILE")
if [ "${#official_packages[@]}" -gt 0 ]; then
  if [ "${OMARCHY_DOTFILES_SYSTEM_UPDATED:-0}" != 1 ]; then
    printf '%s\n' '[omarchy-install-packages] updating Omarchy before installing repository packages'
    omarchy update -y
  fi
  sudo -n pacman -S --needed --noconfirm "${official_packages[@]}" </dev/null
fi

mapfile -t aur_packages < <(read_packages "$AUR_FILE")
if [ "${#aur_packages[@]}" -gt 0 ]; then
  command -v yay >/dev/null 2>&1 || {
    printf '%s\n' '[omarchy-install-packages] yay is required for AUR packages.' >&2
    exit 1
  }
  for attempt in 1 2 3; do
    if yay -S --needed --noconfirm --answerclean None --answerdiff None --noremovemake \
      "${aur_packages[@]}" </dev/null; then
      break
    fi
    if [ "$attempt" -eq 3 ]; then
      printf '%s\n' '[omarchy-install-packages] AUR was unavailable after 3 attempts.' >&2
      exit 1
    fi
    printf '%s\n' "[omarchy-install-packages] AUR attempt $attempt failed; retrying in 10 seconds." >&2
    sleep 10
  done
fi
