#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

case "$(uname -s)" in
  Darwin)
    exec bash "$DOTFILES_DIR/macos/scripts/sync.sh" "$@"
    ;;
  Linux)
    if [ -d /usr/share/omarchy ] && command -v omarchy >/dev/null 2>&1; then
      exec bash "$DOTFILES_DIR/omarchy/scripts/sync-omarchy.sh" "$@"
    fi
    printf '%s\n' '[sync] unsupported Linux host: Omarchy was not detected.' >&2
    exit 1
    ;;
  *)
    printf '%s\n' "[sync] unsupported operating system: $(uname -s)" >&2
    exit 1
    ;;
esac
