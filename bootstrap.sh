#!/usr/bin/env bash
# bootstrap.sh — single-entry orchestrator for setting up a new Mac.
#
# Run on a fresh machine:
#   curl -fsSL https://raw.githubusercontent.com/erzz/dotfiles/main/bootstrap.sh | bash
#
# Or, after cloning the repo manually:
#   ./bootstrap.sh
#
# The script is idempotent: re-running it skips anything already done. It
# pauses at the small handful of steps that genuinely need a human (sign in
# to 1Password, toggle the CLI integration, sign in to App Store, etc.).
#
# Architecture: this script handles Layer 1 (prerequisites) and Layer 2
# (identity/credentials). It then hands off to chezmoi for Layer 3 (configs)
# and a few `run_onchange` scripts (brew bundle, mise install, tmux plugins,
# macOS prefs) which re-run when their inputs change.
#
# Phases live in bootstrap/:
#   bootstrap/lib.sh           — colour vars, helpers, `try` machinery
#   bootstrap/01-prereqs.sh    — Phase 1: Xcode CLT, Homebrew, bootstrap pkgs
#   bootstrap/02-identity.sh   — Phase 2: 1Password, gh, App Store
#   bootstrap/03-chezmoi.sh    — Phase 3: clone + chezmoi apply
#   bootstrap/04-finalisers.sh — Phase 4: Oh My Zsh, chsh, gh-dash, etc.

set -euo pipefail

GITHUB_USER="erzz"
REPO_NAME="dotfiles"
DOTFILES_DIR="${HOME}/.local/share/chezmoi"

# Optional: override the branch chezmoi clones from. Useful for testing an
# unmerged branch on a fresh machine before promoting it to main.
#   BOOTSTRAP_BRANCH=chezmoi-migration ./bootstrap.sh
# Leave unset for normal use (chezmoi will use the repo's default branch).
BOOTSTRAP_BRANCH="${BOOTSTRAP_BRANCH:-}"

# ─────────────────────────────────────────────────────────────────────
# Locate phase files
# ─────────────────────────────────────────────────────────────────────
#
# When invoked via `curl ... | bash`, this script is fed to bash on stdin
# and BASH_SOURCE is empty / "bash" / "/dev/stdin", so there is no sibling
# bootstrap/ directory we can source from. In that case we bootstrap the
# bootstrap: install git (via xcode-select if needed), clone the repo to
# DOTFILES_DIR, and re-exec the on-disk bootstrap.sh — which then finds
# bootstrap/ next to itself and proceeds normally.
#
# When invoked from a checkout (`./bootstrap.sh` or
# `bash /path/to/bootstrap.sh`), BASH_SOURCE[0] resolves to the script
# path and the sibling bootstrap/ dir is right there.

BOOTSTRAP_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/bootstrap"
fi

if [ -z "${BOOTSTRAP_DIR}" ] || [ ! -d "${BOOTSTRAP_DIR}" ]; then
  # ── Piped-from-curl path ───────────────────────────────────────────
  # No on-disk siblings. Clone the repo, then re-exec.
  printf '\033[1;34m==> Piped install detected — cloning repo first\033[0m\n\n'

  # git ships with Xcode CLT. Trigger the install if it's missing; this
  # opens a GUI installer that we wait for before continuing.
  if ! xcode-select -p >/dev/null 2>&1; then
    printf '\033[1;33m    ! Xcode Command Line Tools not present; launching installer...\033[0m\n'
    xcode-select --install || true
    while ! xcode-select -p >/dev/null 2>&1; do sleep 10; done
    printf '\033[1;32m    ✓ Xcode CLT installed\033[0m\n'
  fi

  if [ -d "${DOTFILES_DIR}/.git" ]; then
    printf '\033[1;32m    ✓ repo already at %s — re-execing\033[0m\n' "${DOTFILES_DIR}"
  else
    mkdir -p "$(dirname "${DOTFILES_DIR}")"
    CLONE_BRANCH_ARG=()
    if [ -n "${BOOTSTRAP_BRANCH}" ]; then
      CLONE_BRANCH_ARG=(--branch "${BOOTSTRAP_BRANCH}")
    fi
    git clone "${CLONE_BRANCH_ARG[@]}" \
      "https://github.com/${GITHUB_USER}/${REPO_NAME}.git" "${DOTFILES_DIR}"
    printf '\033[1;32m    ✓ cloned to %s\033[0m\n' "${DOTFILES_DIR}"
  fi

  # Re-exec the on-disk bootstrap.sh. This swaps the running process so
  # nothing here continues; everything from this point onward runs in the
  # new process, with BASH_SOURCE properly set and bootstrap/ visible.
  exec bash "${DOTFILES_DIR}/bootstrap.sh" "$@"
fi

# ─────────────────────────────────────────────────────────────────────
# From here on: on-disk path with bootstrap/ available.
# ─────────────────────────────────────────────────────────────────────

# shellcheck source=bootstrap/lib.sh
source "${BOOTSTRAP_DIR}/lib.sh"

# ─────────────────────────────────────────────────────────────────────
# Sanity
# ─────────────────────────────────────────────────────────────────────

if [ "$(uname -s)" != "Darwin" ]; then
  fail "This bootstrap is for macOS only (got $(uname -s))."
fi

phase "macOS dotfiles bootstrap"
echo "This will set up your Mac with brew, chezmoi, and the dotfiles repo."
echo "It pauses when you need to sign in to something. Total time: ~15-20 min"
echo "(most of which is brew bundle downloading apps in the background)."

# ─────────────────────────────────────────────────────────────────────
# Sudo: prompt once up-front and keep the timestamp alive for the whole
# run. Many cask installers (DisplayLink, etc.) and the Homebrew installer
# itself need sudo. Without keepalive, the macOS default ~5-min timeout
# expires mid-bundle and prompts mid-flow, breaking the unattended feel.
# ─────────────────────────────────────────────────────────────────────

box "ACTION NEEDED: sudo password" \
  "" \
  "The bootstrap installs Homebrew and several casks that need" \
  "admin rights. Entering your password once now means no more" \
  "interruptions for the rest of the run." \
  ""
sudo -v
# Background keepalive: refresh the sudo timestamp every 60s. Exits when
# this script exits (via the EXIT trap) or if the parent dies.
( while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill "${SUDO_KEEPALIVE_PID}" 2>/dev/null || true' EXIT
ok "sudo cached; keepalive running (pid ${SUDO_KEEPALIVE_PID})"

# ─────────────────────────────────────────────────────────────────────
# Phases
# ─────────────────────────────────────────────────────────────────────

# shellcheck source=bootstrap/01-prereqs.sh
source "${BOOTSTRAP_DIR}/01-prereqs.sh"

# shellcheck source=bootstrap/02-identity.sh
source "${BOOTSTRAP_DIR}/02-identity.sh"

# shellcheck source=bootstrap/03-chezmoi.sh
source "${BOOTSTRAP_DIR}/03-chezmoi.sh"

# shellcheck source=bootstrap/04-finalisers.sh
source "${BOOTSTRAP_DIR}/04-finalisers.sh"

# ─────────────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────────────

phase "Done!"
cat <<'EOF'
Next steps:

  1. Open a NEW terminal window so ~/.zshrc gets sourced (puts brew, mise,
     fnox on PATH).
  2. (Optional) Apply macOS preferences:
        chezmoi apply --data='{"macos":true}'
     A reboot is recommended afterwards for them to take effect.
  3. Re-run this bootstrap.sh anytime — it's idempotent and will only
     re-do what's needed.
EOF
