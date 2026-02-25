.PHONY: all brew brew-install direnv fnox ghostty gh-dash git mise nvim os prettierd starship stow tmux xcode zed zellij zsh

all: os brew stow git zsh mise fnox direnv starship ghostty tmux nvim zed zellij gh-dash prettierd

brew: brew-install
	@chmod +x brew/bundle.sh
	@./brew/bundle.sh

brew-install: xcode
	@chmod +x brew/install.sh
	@./brew/install.sh

direnv: brew-install stow
	@chmod +x direnv/install.sh
	@./direnv/install.sh

fnox: stow
	stow fnox

ghostty: brew-install
	@chmod +x ghostty/install.sh
	@./ghostty/install.sh

gh-dash: brew-install
	@chmod +x gh-dash/install.sh
	@./gh-dash/install.sh

git: stow
	stow git

mise: stow
	stow mise

nvim: brew-install stow
	@chmod +x nvim/install.sh
	@./nvim/install.sh

os:
	@chmod +x os/install.sh
	@./os/install.sh

prettierd: stow
	stow prettierd

starship: brew-install stow
	@chmod +x starship/install.sh
	@./starship/install.sh

stow: brew-install
	stow stow

tmux: brew-install stow
	@chmod +x tmux/install.sh
	@./tmux/install.sh

xcode:
	echo "Installing Xcode (takes a while)..."
	@xcode-select --install || true

zed: brew
	stow zed

zellij: brew-install stow
	@chmod +x zellij/install.sh
	@./zellij/install.sh

zsh: stow
	@chmod +x zsh/install.sh
	@./zsh/install.sh
