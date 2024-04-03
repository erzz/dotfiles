.PHONY: alacritty brew brew-install devbox direnv git iterm languages nvim os prettierd starship stow tmux warp xcode zsh
default: .PHONY

alacritty: brew-install
	@chmod +x alacritty/install.sh
	@./alacritty/install.sh

brew: brew-install
	@chmod +x brew/bundle.sh
	@./brew/bundle.sh

brew-install: xcode
	@chmod +x brew/install.sh
	@./brew/install.sh

devbox: 
	@chmod +x devbox/install.sh
	@./devbox/install.sh

direnv: brew-install stow
	@chmod +x direnv/install.sh
	@./direnv/install.sh

git: stow
	stow git

iterm: brew-install
	@chmod +x iterm/install.sh
	@./iterm/install.sh

languages: brew-install
	echo "Installing SDKMAN..."
	@chmod +x languages/sdkman.sh
	@./languages/sdkman.sh
	@chmod +x languages/other.sh
	@./languages/other.sh

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
	stow tmux

warp: brew-install
	@chmod +x warp/install.sh
	@./warp/install.sh

xcode:
	echo "Installing Xcode (takes a while)..."
	@xcode-select --install || true

zsh: stow
	@chmod +x zsh/install.sh
	@./zsh/install.sh
