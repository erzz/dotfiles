# shellcheck shell=bash
# shellcheck disable=SC2154  # vars (BLUE, FINALISER_*, etc.) come from bootstrap/lib.sh
# bootstrap/04-finalisers.sh — Phase 4: post-config setup.
#
# Best-effort: a failure here is annoying but not fatal — Phases 1-3 have
# already produced a usable system. Each step runs through `try` (defined
# in bootstrap/lib.sh), which turns a non-zero exit into a counted warning
# rather than aborting. Re-running bootstrap.sh re-attempts anything that
# failed.

phase "Phase 4: Finalisers"

finalise_oh_my_zsh() {
  if [ -d "${HOME}/.oh-my-zsh" ]; then
    ok "already installed"
    return 0
  fi
  warn "installing..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc \
    && ok "installed"
}

finalise_default_shell() {
  # Capture the probe result with explicit failure handling. Without the
  # `|| return 1`, a `dscl` failure inside `try` (where errexit is disabled
  # because the function runs as an `if` condition) would silently fall
  # through to `chsh` and trigger an unexpected password prompt.
  local current_shell
  current_shell="$(dscl . -read /Users/"$(whoami)" UserShell 2>/dev/null | awk '{print $2}')" || return 1
  if [ "${current_shell}" = "/bin/zsh" ]; then
    ok "already zsh"
    return 0
  fi
  warn "running chsh — will prompt for your password..."
  chsh -s /bin/zsh && ok "shell changed"
}

finalise_gh_dash() {
  if gh extension list 2>/dev/null | grep -q "dlvhdr/gh-dash"; then
    ok "already installed"
    return 0
  fi
  warn "installing..."
  gh extension install dlvhdr/gh-dash && ok "installed"
}

finalise_docker_buildx() {
  if ! command -v docker-buildx >/dev/null 2>&1; then
    warn "docker-buildx not in brew bundle output — skipping"
    return 0
  fi
  mkdir -p "${HOME}/.docker/cli-plugins" \
    && ln -sfn "$(brew --prefix)/bin/docker-buildx" "${HOME}/.docker/cli-plugins/docker-buildx" \
    && ok "linked"
}

# Note: TPM (Tmux Plugin Manager) and tmux plugin install are owned
# entirely by the chezmoi run_onchange script
# (home/.chezmoiscripts/...11-tmux-plugins.sh.tmpl), which clones TPM
# if missing and runs `install_plugins`. bootstrap.sh used to duplicate
# this; that's been removed.

step "Oh My Zsh";              try "Oh My Zsh"           finalise_oh_my_zsh
step "Default shell → zsh";    try "Default shell"       finalise_default_shell
step "gh-dash extension";      try "gh-dash"             finalise_gh_dash
step "docker-buildx plugin";   try "docker-buildx"       finalise_docker_buildx

# Phase summary so any swallowed failures are still visible at the end.
if [ "${FINALISER_WARN}" -eq 0 ]; then
  ok "Phase 4: ${FINALISER_OK}/${FINALISER_OK} finalisers OK"
else
  warn "Phase 4: ${FINALISER_OK}/$((FINALISER_OK + FINALISER_WARN)) finalisers OK; ${FINALISER_WARN} failed: ${FINALISER_FAILS[*]}"
  warn "Re-run bootstrap.sh to retry any failed finalisers."
fi
