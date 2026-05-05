# shellcheck shell=bash
# shellcheck disable=SC2154  # vars (BLUE, etc.) come from bootstrap/lib.sh
# bootstrap/01-prereqs.sh — Phase 1: prerequisites (automated where possible).

phase "Phase 1: Prerequisites"

step "Xcode Command Line Tools"
# Note: the orchestrator's curl-pipe path also gates on this (it needs git
# to clone the repo before the phase files exist). On the curl-pipe path
# CLT will already be installed by the time we get here; on a direct
# `./bootstrap.sh` invocation this is the only check. Either way the
# guard below is idempotent — it just prints "already installed".
if xcode-select -p >/dev/null 2>&1; then
  ok "already installed"
else
  warn "installing — a GUI installer will appear; this script will wait for it."
  xcode-select --install || true
  while ! xcode-select -p >/dev/null 2>&1; do sleep 10; done
  ok "installed"
fi

step "Homebrew"
# Check the binary path directly: a fresh shell on a new Mac may not have
# brew on PATH yet (added by ~/.zprofile, which only sources for new login
# shells). `command -v brew` would falsely report missing.
if [ -x /opt/homebrew/bin/brew ] || [ -x /usr/local/bin/brew ]; then
  ok "already installed"
else
  warn "installing..."
  # NONINTERACTIVE=1 skips Homebrew's "Press RETURN to continue" prompt;
  # sudo is already cached above so no password prompt either.
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ok "installed"
fi
# Make brew available in this script's environment.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
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
