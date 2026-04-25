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
DRIFT_FLAG="/tmp/dotfiles-drift"

REPO="${HOME}/.local/share/chezmoi"
cd "${REPO}" || return

git fetch -q

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
if command -v chezmoi >/dev/null 2>&1; then
	if ! chezmoi diff --exclude=scripts >/dev/null 2>&1; then
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
	printf '%b\n' "${MESSAGES[@]}" >"$DRIFT_FLAG"
else
	rm -f "$DRIFT_FLAG"
fi
