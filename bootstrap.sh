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

set -euo pipefail

GITHUB_USER="erzz"
REPO_NAME="dotfiles"
DOTFILES_DIR="${HOME}/.local/share/chezmoi"

BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

phase()   { printf '\n%b==> %s%b\n\n' "${BLUE}" "$*" "${NC}"; }
step()    { printf '%b--> %s%b\n' "${BLUE}" "$*" "${NC}"; }
ok()      { printf '%b    ✓ %s%b\n' "${GREEN}" "$*" "${NC}"; }
warn()    { printf '%b    ! %s%b\n' "${YELLOW}" "$*" "${NC}"; }
fail()    { printf '%b    ✗ %s%b\n' "${RED}" "$*" "${NC}"; exit 1; }

box() {
  local line
  printf '%b┌─ %s ─' "${YELLOW}" "$1"
  for ((i=${#1}; i<60; i++)); do printf '─'; done
  printf '┐%b\n' "${NC}"
  shift
  for line in "$@"; do
    printf '%b│%b %-62s %b│%b\n' "${YELLOW}" "${NC}" "$line" "${YELLOW}" "${NC}"
  done
  printf '%b└' "${YELLOW}"
  for ((i=0; i<64; i++)); do printf '─'; done
  printf '┘%b\n' "${NC}"
}

prompt_continue() {
  printf '\n%bPress ENTER when done (or Ctrl-C to abort)...%b ' "${YELLOW}" "${NC}"
  read -r _
}

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
# Phase 1: prerequisites (automated where possible)
# ─────────────────────────────────────────────────────────────────────

phase "Phase 1: Prerequisites"

step "Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then
  ok "already installed"
else
  warn "installing — a GUI installer will appear; this script will wait for it."
  xcode-select --install || true
  while ! xcode-select -p >/dev/null 2>&1; do sleep 10; done
  ok "installed"
fi

step "Homebrew"
if command -v brew >/dev/null 2>&1; then
  ok "already installed"
else
  warn "installing (the installer will prompt for your sudo password)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ok "installed"
fi
# Make brew available in this script's environment.
eval "$(/opt/homebrew/bin/brew shellenv)"
brew analytics off >/dev/null 2>&1 || true

step "Bootstrap brew packages (1password, 1password-cli, gh, chezmoi)"
# We install only the packages needed to complete the rest of bootstrap.
# Everything else comes from `brew bundle` later.
for pkg in 1password 1password-cli gh chezmoi; do
  if brew list "$pkg" >/dev/null 2>&1 || brew list --cask "$pkg" >/dev/null 2>&1; then
    ok "$pkg already installed"
  else
    warn "installing $pkg..."
    brew install "$pkg"
  fi
done

# ─────────────────────────────────────────────────────────────────────
# Phase 2: identity (interactive — these need you)
# ─────────────────────────────────────────────────────────────────────

phase "Phase 2: Identity"

step "1Password.app sign-in"
if op account list 2>/dev/null | grep -q .; then
  ok "1Password CLI already integrated and signed in"
else
  box "ACTION NEEDED: sign in to 1Password" \
    "" \
    "Opening 1Password.app. Sign in with your master password" \
    "and Secret Key. When done, leave 1Password running and" \
    "come back here." \
    ""
  open -a "1Password" || warn "couldn't open 1Password.app — open it manually"
  prompt_continue

  box "ACTION NEEDED: enable 1Password CLI integration" \
    "" \
    "In 1Password.app:" \
    "  Settings → Developer → toggle 'Integrate with 1Password CLI'" \
    "" \
    "Optional: also enable 'Use Touch ID to unlock' on the same page" \
    "for fingerprint authentication." \
    ""
  warn "waiting for the integration to come online (poll every 5s)..."
  while ! op account list 2>/dev/null | grep -q .; do sleep 5; done
  ok "1Password CLI integrated"
fi

step "GitHub authentication"
if gh auth status >/dev/null 2>&1; then
  ok "gh already authenticated"
else
  box "ACTION NEEDED: authenticate gh" \
    "" \
    "Launching 'gh auth login'. Follow the browser flow:" \
    "  1. Copy the 8-character code shown in the terminal" \
    "  2. Paste it in the browser tab that opens" \
    "  3. Authorize the device" \
    ""
  prompt_continue
  gh auth login --hostname github.com --git-protocol https --web
  ok "gh authenticated"
fi
# Ensure git uses gh's credential helper from now on (idempotent).
gh auth setup-git >/dev/null 2>&1 || true

step "App Store sign-in (optional, needed for MAS apps)"
if mas account >/dev/null 2>&1; then
  ok "already signed in to App Store"
elif command -v mas >/dev/null 2>&1 && mas list >/dev/null 2>&1; then
  ok "App Store accessible (mas can list installed apps)"
else
  box "ACTION NEEDED: sign in to App Store (or skip)" \
    "" \
    "Opening App Store.app. Sign in with your Apple ID, then" \
    "return here." \
    "" \
    "If you don't want any Mac App Store apps, just press ENTER" \
    "to skip — bootstrap will continue and the MAS lines in the" \
    "Brewfile will warn but not fail." \
    ""
  open -a "App Store" || warn "couldn't open App Store.app — open it manually"
  prompt_continue
fi

# ─────────────────────────────────────────────────────────────────────
# Phase 3: clone + chezmoi apply (Layers 2 & 3)
# ─────────────────────────────────────────────────────────────────────

phase "Phase 3: Configs (chezmoi apply)"

step "Clone dotfiles repo"
if [ -d "${DOTFILES_DIR}/.git" ]; then
  ok "repo already cloned at ${DOTFILES_DIR}"
else
  warn "initialising chezmoi from github.com/${GITHUB_USER}/${REPO_NAME}..."
  chezmoi init "${GITHUB_USER}"
  ok "cloned"
fi

step "Apply chezmoi state (this triggers brew bundle, mise install, etc.)"
warn "this can take ~10 minutes the first time (downloading apps)..."
chezmoi apply --keep-going

# ─────────────────────────────────────────────────────────────────────
# Phase 4: finalisers (post-config setup)
# ─────────────────────────────────────────────────────────────────────

phase "Phase 4: Finalisers"

step "Oh My Zsh"
if [ -d "${HOME}/.oh-my-zsh" ]; then
  ok "already installed"
else
  warn "installing..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
  ok "installed"
fi

step "Default shell → zsh"
if [ "$(dscl . -read /Users/"$(whoami)" UserShell | awk '{print $2}')" = "/bin/zsh" ]; then
  ok "already zsh"
else
  warn "running chsh — will prompt for your password..."
  chsh -s /bin/zsh
  ok "shell changed"
fi

step "gh-dash extension"
if gh extension list 2>/dev/null | grep -q "dlvhdr/gh-dash"; then
  ok "already installed"
else
  warn "installing..."
  gh extension install dlvhdr/gh-dash
  ok "installed"
fi

step "docker-buildx CLI plugin"
if command -v docker-buildx >/dev/null 2>&1; then
  mkdir -p "${HOME}/.docker/cli-plugins"
  ln -sfn "$(brew --prefix)/bin/docker-buildx" "${HOME}/.docker/cli-plugins/docker-buildx"
  ok "linked"
else
  warn "docker-buildx not in brew bundle output — skipping"
fi

step "Tmux Plugin Manager (TPM)"
TPM_DIR="${HOME}/.tmux/plugins/tpm"
if [ -d "${TPM_DIR}" ]; then
  ok "already installed"
else
  git clone https://github.com/tmux-plugins/tpm "${TPM_DIR}"
  ok "installed"
fi

step "Tmux plugins"
TPM_INSTALL="${TPM_DIR}/bin/install_plugins"
if [ -x "${TPM_INSTALL}" ]; then
  "${TPM_INSTALL}" >/dev/null
  ok "installed"
fi

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
