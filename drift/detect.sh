#!/usr/bin/env bash
# Detect drift between the dotfiles repo and the live machine.
# Writes any messages to /tmp/dotfiles-drift, which the shell prompt
# (see home/dot_zshrc) consumes on the next prompt.
#
# Drift sources checked:
#   1. Repo: uncommitted changes, behind remote
#   2. Symlinks/files: chezmoi diff (catches replaced symlinks, missing files)
#   3. Brew: packages declared in Brewfile but not installed
#   4. Mise: tools declared in mise config but not installed

COLOUR='\033[0;33m'
NC='\033[0m'
# Per-user flag path: avoids cross-user collisions on shared machines, and
# keeps each user's drift signal isolated.
DRIFT_FLAG="${TMPDIR:-/tmp}/dotfiles-drift.${UID}"
# Temp file for atomic write: build the message in a sibling file, then
# rename into place. Without this, two shells starting near-simultaneously
# could race and produce a half-written file the prompt reader would garble.
DRIFT_TMP="${DRIFT_FLAG}.$$"

REPO="${HOME}/.local/share/chezmoi"
# `return` would only be valid if this script were sourced; it's executed
# from a zsh background job, so `exit 0` is correct (and silent — drift
# detection failing should never spam the prompt).
cd "${REPO}" || exit 0

# Never block on auth prompts: this script runs in the background from
# zsh's precmd hook, and a tty-input prompt would suspend the shell.
export GIT_TERMINAL_PROMPT=0
git fetch -q </dev/null 2>/dev/null || true

MESSAGES=()

# 1. Local uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
	MESSAGES+=("${COLOUR}Dotfiles have uncommitted changes${NC}")
fi

# 2. Local branch behind remote
BEHIND=$(git rev-list --count 'HEAD..@{u}' 2>/dev/null)
if [ -n "$BEHIND" ] && [ "$BEHIND" -gt 0 ]; then
	MESSAGES+=("${COLOUR}Dotfiles are ${BEHIND} commit(s) behind remote${NC}")
fi

# 3. Chezmoi-managed file/symlink drift (replaced files, broken links, etc.)
# `chezmoi status` prints one line per drifted entry and always exits 0,
# so we check whether its output is non-empty (`chezmoi diff` always exits 0
# regardless of drift, so its exit code is useless here).
if command -v chezmoi >/dev/null 2>&1; then
	if [ -n "$(chezmoi status --exclude=scripts 2>/dev/null)" ]; then
		MESSAGES+=("${COLOUR}chezmoi reports file drift (run: chezmoi diff)${NC}")
	fi
fi

# 4. Brew bundle drift (packages in Brewfile not installed)
if command -v brew >/dev/null 2>&1 && [ -f "${REPO}/brew/Brewfile" ]; then
	if ! brew bundle check --quiet --file="${REPO}/brew/Brewfile" >/dev/null 2>&1; then
		MESSAGES+=("${COLOUR}Brewfile drift (run: brew bundle check)${NC}")
	fi
fi

# 5. Mise drift (tools in mise config but not installed)
if command -v mise >/dev/null 2>&1; then
	if mise ls --missing 2>/dev/null | grep -q .; then
		MESSAGES+=("${COLOUR}mise tools missing (run: mise install)${NC}")
	fi
fi

if [ ${#MESSAGES[@]} -gt 0 ]; then
	# Atomic write: build in $DRIFT_TMP, then mv into place. The prompt reader
	# only ever sees a complete file (or no file at all), never a partial one.
	printf '%b\n' "${MESSAGES[@]}" >"$DRIFT_TMP" && mv -f "$DRIFT_TMP" "$DRIFT_FLAG"
else
	rm -f "$DRIFT_FLAG" "$DRIFT_TMP"
fi
