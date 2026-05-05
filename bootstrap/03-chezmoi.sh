# shellcheck shell=bash
# shellcheck disable=SC2154  # vars (GITHUB_USER, etc.) come from bootstrap.sh
# bootstrap/03-chezmoi.sh — Phase 3: clone + chezmoi apply (Layers 2 & 3).

phase "Phase 3: Configs (chezmoi apply)"

step "Clone dotfiles repo"
if [ -d "${DOTFILES_DIR}/.git" ]; then
  ok "repo already cloned at ${DOTFILES_DIR}"
  if [ -n "${BOOTSTRAP_BRANCH}" ]; then
    warn "BOOTSTRAP_BRANCH=${BOOTSTRAP_BRANCH} set but repo already cloned; checking out branch..."
    git -C "${DOTFILES_DIR}" fetch origin "${BOOTSTRAP_BRANCH}"
    git -C "${DOTFILES_DIR}" checkout "${BOOTSTRAP_BRANCH}"
    git -C "${DOTFILES_DIR}" pull --ff-only origin "${BOOTSTRAP_BRANCH}"
    ok "on branch ${BOOTSTRAP_BRANCH}"
  fi
else
  if [ -n "${BOOTSTRAP_BRANCH}" ]; then
    warn "initialising chezmoi from github.com/${GITHUB_USER}/${REPO_NAME} (branch: ${BOOTSTRAP_BRANCH})..."
    chezmoi init --branch "${BOOTSTRAP_BRANCH}" "${GITHUB_USER}"
  else
    warn "initialising chezmoi from github.com/${GITHUB_USER}/${REPO_NAME}..."
    chezmoi init "${GITHUB_USER}"
  fi
  ok "cloned"
fi

step "Apply chezmoi state (this triggers brew bundle, mise install, etc.)"
warn "this can take ~10 minutes the first time (downloading apps)..."
# Re-run 'chezmoi init' to ensure the locally-generated config
# (~/.config/chezmoi/chezmoi.toml) reflects the latest source template.
# Without this, a cached config from an earlier run can keep stale settings
# (e.g. mode=file when the template now says mode=symlink), causing files
# that should be symlinks to remain regular files.
chezmoi init "${GITHUB_USER}" >/dev/null
# --force: overwrite any pre-existing files in $HOME (e.g. macOS-default
#   ~/.zshrc) that would otherwise cause chezmoi to prompt interactively
#   and hang the bootstrap. Safe in a fresh-machine bootstrap context.
# --keep-going: don't abort the whole apply on a single file/script error;
#   surface warnings instead so the user can see what failed at the end.
chezmoi apply --force --keep-going
