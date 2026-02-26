#!/usr/bin/env bash
#
# bootstrap.sh - Idempotent setup for a new (or existing) macOS machine.
#
# Usage:
#   ./bootstrap.sh            # Full setup (skips macOS preferences)
#   ./bootstrap.sh --macos    # Full setup + macOS preferences (requires reboot)
#   ./bootstrap.sh --ci       # CI mode: formulae only, skip auth-dependent steps
#
# Safe to run repeatedly - every step is guarded or convergent.
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
MACOS=false
CI_MODE=false

for arg in "$@"; do
	case "$arg" in
	--macos) MACOS=true ;;
	--ci) CI_MODE=true ;;
	*)
		echo "Unknown option: $arg"
		exit 1
		;;
	esac
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info() { printf '\033[1;34m==> %s\033[0m\n' "$1"; }
ok() { printf '\033[1;32m  OK: %s\033[0m\n' "$1"; }
warn() { printf '\033[1;33m  WARN: %s\033[0m\n' "$1"; }

# ---------------------------------------------------------------------------
# Stage 1: Prerequisites
# ---------------------------------------------------------------------------
info "Stage 1: Prerequisites"

# Xcode Command Line Tools (skip in CI — runners have CLT pre-installed)
if [ "${CI:-}" != "true" ]; then
	if xcode-select -p &>/dev/null; then
		ok "Xcode CLT already installed"
	else
		echo "Installing Xcode Command Line Tools (this takes a while)..."
		xcode-select --install
		echo "Press any key once the Xcode CLT install has completed..."
		read -r -n 1
	fi
else
	ok "CI detected — skipping Xcode CLT install"
fi

# Homebrew
if command -v brew &>/dev/null; then
	ok "Homebrew already installed"
else
	echo "Installing Homebrew..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew analytics off

# Brew bundle - installs everything declared in the Brewfile
# In CI mode, only install taps and formulae (skip casks, MAS apps, VSCode extensions)
info "Running brew bundle (this may take a while on first run)..."
if [ "${CI_MODE}" = true ]; then
	grep -E '^(tap|brew) ' "${DOTFILES}/brew/Brewfile" | brew bundle --file=-
else
	brew bundle --file "${DOTFILES}/brew/Brewfile"
fi
brew cleanup

# ---------------------------------------------------------------------------
# Stage 2: Stow all configs (convergent via --restow)
# ---------------------------------------------------------------------------
info "Stage 2: Stowing configs"

# List of stow packages (directories that contain config to symlink)
STOW_PACKAGES=(
	direnv
	drift
	fnox
	gh-dash
	ghostty
	git
	mise
	nvim
	opencode
	prettierd
	starship
	stow
	tmux
	zed
	zellij
	zsh
)

# In CI, remove files that conflict with stow (e.g. runner's default .gitconfig)
if [ "${CI_MODE}" = true ]; then
	for pkg in "${STOW_PACKAGES[@]}"; do
		if [ -d "${DOTFILES}/${pkg}" ]; then
			while IFS= read -r rel; do
				target="${HOME}/${rel}"
				if [ -f "$target" ] && [ ! -L "$target" ]; then
					rm -f "$target"
				fi
			done < <(cd "${DOTFILES}/${pkg}" && find . -type f | sed 's|^\./||')
		fi
	done
fi

for pkg in "${STOW_PACKAGES[@]}"; do
	if [ -d "${DOTFILES}/${pkg}" ]; then
		stow --dir="${DOTFILES}" --target="${HOME}" --restow "${pkg}"
		ok "Stowed ${pkg}"
	else
		warn "Package directory ${pkg}/ not found, skipping"
	fi
done

# ---------------------------------------------------------------------------
# Stage 3: Shell setup
# ---------------------------------------------------------------------------
info "Stage 3: Shell setup"

# Oh My Zsh (guarded - only install if missing)
if [ -d "${HOME}/.oh-my-zsh" ]; then
	ok "Oh My Zsh already installed"
else
	echo "Installing Oh My Zsh..."
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

# Set zsh as default shell (guarded)
current_shell="$(dscl . -read /Users/"$(whoami)" UserShell | awk '{print $2}')"
if [ "${current_shell}" = "/bin/zsh" ]; then
	ok "Default shell is already zsh"
else
	echo "Changing default shell to zsh..."
	chsh -s /bin/zsh
fi

# ---------------------------------------------------------------------------
# Stage 4: Tool activation
# ---------------------------------------------------------------------------
info "Stage 4: Tool activation"

# mise - install all tools declared in ~/.config/mise/config.toml
if command -v mise &>/dev/null; then
	echo "Installing mise-managed tools..."
	mise install --yes
	ok "mise tools installed"
else
	warn "mise not found (should have been installed by brew bundle)"
fi

# gh-dash extension (guarded, skip in CI — requires auth)
if [ "${CI_MODE}" != true ]; then
	if command -v gh &>/dev/null; then
		if gh extension list 2>/dev/null | grep -q "dlvhdr/gh-dash"; then
			ok "gh-dash extension already installed"
		else
			echo "Installing gh-dash extension..."
			gh extension install dlvhdr/gh-dash
		fi
	else
		warn "gh not found (should have been installed by brew bundle)"
	fi
else
	ok "CI mode — skipping gh-dash extension (requires auth)"
fi

# TPM (Tmux Plugin Manager)
TPM_DIR="${HOME}/.tmux/plugins/tpm"
if [ -d "${TPM_DIR}" ]; then
	ok "TPM already installed"
else
	echo "Installing TPM..."
	git clone https://github.com/tmux-plugins/tpm "${TPM_DIR}"
fi

# Install tmux plugins (non-interactive)
if [ -x "${TPM_DIR}/bin/install_plugins" ]; then
	echo "Installing tmux plugins..."
	"${TPM_DIR}/bin/install_plugins"
	ok "Tmux plugins installed"
fi

# ---------------------------------------------------------------------------
# Stage 5: macOS preferences (optional, flag-gated)
# ---------------------------------------------------------------------------
if [ "${MACOS}" = true ]; then
	info "Stage 5: macOS preferences"
	chmod +x "${DOTFILES}/os/install.sh"
	"${DOTFILES}/os/install.sh"
	echo ""
	warn "A reboot is recommended for macOS preference changes to take effect."
else
	info "Stage 5: macOS preferences (skipped - pass --macos to apply)"
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------
echo ""
info "Bootstrap complete!"
echo "  - Open a new terminal to pick up shell changes"
echo "  - Run 'mise install' any time to update mise-managed tools"
echo "  - Run './bootstrap.sh --macos' to apply macOS preferences"
