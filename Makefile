.PHONY: all bootstrap brew brew-install direnv fnox ghostty gh-dash git mise mise-install nvim opencode os prettierd starship stow tmux xcode zed zellij zsh

# Full setup via bootstrap script
all: bootstrap

bootstrap:
	@chmod +x bootstrap.sh
	@./bootstrap.sh

# ---------------------------------------------------------------------------
# Individual targets (for "temporary machine" use or standalone setup)
# Each target is idempotent and can be run independently.
# Prerequisites: brew & stow must be available (run `make brew` first).
# ---------------------------------------------------------------------------

brew: brew-install
	@chmod +x brew/bundle.sh
	@./brew/bundle.sh

brew-install: xcode
	@chmod +x brew/install.sh
	@./brew/install.sh

xcode:
	@xcode-select -p &>/dev/null || xcode-select --install

# Config-only targets (stow --restow for convergence)
direnv:
	stow --restow direnv

drift:
	stow --restow drift

fnox:
	stow --restow fnox

ghostty:
	stow --restow ghostty

gh-dash:
	stow --restow gh-dash
	@if command -v gh &>/dev/null && ! gh extension list 2>/dev/null | grep -q "dlvhdr/gh-dash"; then \
		gh extension install dlvhdr/gh-dash; \
	fi

git:
	stow --restow git

mise:
	stow --restow mise

mise-install: mise
	@command -v mise &>/dev/null && mise install --yes || echo "mise not found - run 'make brew' first"

nvim:
	stow --restow nvim

opencode:
	stow --restow opencode

os:
	@chmod +x os/install.sh
	@./os/install.sh

prettierd:
	stow --restow prettierd

starship:
	stow --restow starship

stow:
	stow --restow stow

tmux:
	stow --restow tmux
	@if [ ! -d "$(HOME)/.tmux/plugins/tpm" ]; then \
		git clone https://github.com/tmux-plugins/tpm "$(HOME)/.tmux/plugins/tpm"; \
	fi
	@if [ -x "$(HOME)/.tmux/plugins/tpm/bin/install_plugins" ]; then \
		"$(HOME)/.tmux/plugins/tpm/bin/install_plugins"; \
	fi

zed:
	stow --restow zed

zellij:
	stow --restow zellij

zsh:
	stow --restow zsh
	@if [ ! -d "$(HOME)/.oh-my-zsh" ]; then \
		sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc; \
	fi
	@if [ "$$(dscl . -read /Users/$$(whoami) UserShell | awk '{print $$2}')" != "/bin/zsh" ]; then \
		chsh -s /bin/zsh; \
	fi
