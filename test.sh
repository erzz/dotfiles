#!/usr/bin/env bash
#
# test.sh - Verify that bootstrap produced the expected outcome.
#
# Checks three things:
#   1. Stow symlinks exist and point to the dotfiles repo
#   2. Key CLI tools are installed and on PATH
#   3. Tools load the stowed configs (not defaults)
#
# Exit code: number of failed checks (0 = all passed)
#
set -uo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
PASS=0
FAIL=0

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
pass() {
	PASS=$((PASS + 1))
	printf '\033[1;32m  PASS: %s\033[0m\n' "$1"
}
fail() {
	FAIL=$((FAIL + 1))
	printf '\033[1;31m  FAIL: %s\033[0m\n' "$1"
}
section() { printf '\n\033[1;34m==> %s\033[0m\n' "$1"; }

# Check that a path is served by stow (either a direct symlink into dotfiles,
# or a file inside a stow-symlinked parent directory)
check_symlink() {
	local target="$1"
	local description="${2:-$1}"
	local resolved
	resolved="$(readlink -f "$target" 2>/dev/null)" || true
	if [[ "$resolved" == "${DOTFILES}"* ]]; then
		pass "symlink: ${description}"
	elif [ -L "$target" ] && [[ "$(readlink "$target")" == *dotfiles* ]]; then
		pass "symlink: ${description}"
	elif [ -e "$target" ]; then
		fail "symlink: ${description} (exists but does not resolve into dotfiles)"
	else
		fail "symlink: ${description} (missing)"
	fi
}

# Check that a command is available on PATH
check_command() {
	local cmd="$1"
	local description="${2:-$1}"
	if command -v "$cmd" &>/dev/null; then
		pass "command: ${description}"
	else
		fail "command: ${description} (not found)"
	fi
}

# Check that a command's output contains an expected string
check_output() {
	local description="$1"
	local expected="$2"
	shift 2
	local actual
	actual=$("$@" 2>/dev/null) || true
	if [[ "$actual" == *"$expected"* ]]; then
		pass "config: ${description}"
	else
		fail "config: ${description} (expected '${expected}', got '${actual}')"
	fi
}

# ---------------------------------------------------------------------------
# 1. Symlinks — verify stow wired configs to the right places
# ---------------------------------------------------------------------------
section "Symlinks"

check_symlink "${HOME}/.zshrc" ".zshrc"
check_symlink "${HOME}/.gitconfig" ".gitconfig"
check_symlink "${HOME}/.config/git/ignore" "git/ignore"
check_symlink "${HOME}/.config/starship.toml" "starship.toml"
check_symlink "${HOME}/.config/mise/config.toml" "mise/config.toml"
check_symlink "${HOME}/.config/direnv/direnv.toml" "direnv/direnv.toml"
check_symlink "${HOME}/.config/ghostty/config" "ghostty/config"
check_symlink "${HOME}/.config/zellij/config.kdl" "zellij/config.kdl"
check_symlink "${HOME}/.tmux.conf" ".tmux.conf"
check_symlink "${HOME}/.config/nvim" "nvim config dir"
check_symlink "${HOME}/.config/prettierd/global.json" "prettierd/global.json"
check_symlink "${HOME}/.config/gh-dash/config.yml" "gh-dash/config.yml"
check_symlink "${HOME}/.config/fnox/config.toml" "fnox/config.toml"

# ---------------------------------------------------------------------------
# 2. CLI tools — verify key commands are available
# ---------------------------------------------------------------------------
section "CLI tools"

# Core tools (in Brewfile.ci — always expected)
CI_TOOLS=(
	bat delta direnv eza fd fzf git jq mise
	rg shellcheck starship stow tmux zsh
)

# Additional tools (full Brewfile only)
FULL_TOOLS=(
	brew curl gh htop lazygit nvim shfmt tree
	yamllint yq zellij zoxide
)

for tool in "${CI_TOOLS[@]}"; do
	check_command "$tool"
done

if [ -z "${CI:-}" ]; then
	for tool in "${FULL_TOOLS[@]}"; do
		check_command "$tool"
	done
fi

# Oh My Zsh
if [ -d "${HOME}/.oh-my-zsh" ]; then
	pass "command: oh-my-zsh (installed)"
else
	fail "command: oh-my-zsh (not installed)"
fi

# ---------------------------------------------------------------------------
# 3. Config verification — tools load stowed configs, not defaults
# ---------------------------------------------------------------------------
section "Config verification"

# Git identity (use --global to avoid repo-local overrides)
check_output "git user.name" "Sean Erswell-Liljefelt" git config --global user.name
check_output "git user.email" "sean@erzz.com" git config --global user.email
check_output "git pull.rebase" "true" git config --global pull.rebase
check_output "git push.autoSetupRemote" "true" git config --global push.autoSetupRemote
check_output "git delta features" "side-by-side" git config --global delta.features
check_output "git alias.s = status" "status" git config --global alias.s

# Starship config symlinked and binary works
if starship --version &>/dev/null; then
	resolved="$(readlink -f "${HOME}/.config/starship.toml" 2>/dev/null)" || true
	if [[ "$resolved" == "${DOTFILES}"* ]]; then
		pass "config: starship uses dotfiles config"
	else
		fail "config: starship.toml does not resolve into dotfiles"
	fi
else
	fail "config: starship not available"
fi

# Mise config loaded
if mise config ls 2>/dev/null | grep -q "dotfiles"; then
	pass "config: mise loads dotfiles config"
elif [ -L "${HOME}/.config/mise/config.toml" ]; then
	pass "config: mise config symlinked (mise may not be activated in this shell)"
else
	fail "config: mise config not loaded"
fi

# Direnv config (already checked via symlink; verify binary works)
if direnv version &>/dev/null; then
	pass "config: direnv available"
else
	fail "config: direnv not available"
fi

# Default shell
current_shell="$(dscl . -read /Users/"$(whoami)" UserShell 2>/dev/null | awk '{print $2}')" || true
if [ "${current_shell}" = "/bin/zsh" ]; then
	pass "config: default shell is zsh"
elif [ -n "${CI:-}" ]; then
	pass "config: default shell check (skipped in CI)"
else
	fail "config: default shell is ${current_shell}, expected /bin/zsh"
fi

# TPM installed
if [ -d "${HOME}/.tmux/plugins/tpm" ]; then
	pass "config: TPM installed"
else
	fail "config: TPM not installed"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
section "Results: ${PASS} passed, ${FAIL} failed"

if [ "${FAIL}" -gt 0 ]; then
	exit 1
fi
