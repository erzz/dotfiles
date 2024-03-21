.PHONY: brew brew-install devbox git iterm languages os starship warp xcode zsh
default: .PHONY

brew-install: xcode
	@chmod +x brew/install.sh
	@./brew/install.sh

brew: brew-install
	@chmod +x brew/bundle.sh
	@./brew/bundle.sh

devbox:
	@chmod +x devbox/install.sh
	@./devbox/install.sh

git:
	@chmod +x git/install.sh
	@./git/install.sh

iterm: brew-install
	@chmod +x iterm/install.sh
	@./iterm/install.sh

languages: brew-install
	echo "Installing SDKMAN..."
	@chmod +x languages/sdkman.sh
	@./languages/sdkman.sh
	@chmod +x languages/other.sh
	@./languages/other.sh

os:
	@chmod +x os/install.sh
	@./os/install.sh

starship: brew-install
	@chmod +x starship/install.sh
	@./starship/install.sh

warp: brew-install
	@chmod +x warp/install.sh
	@./warp/install.sh

xcode:
	echo "Installing Xcode (takes a while)..."
	@xcode-select --install || true

zsh: brew
	@chmod +x zsh/install.sh
	@./zsh/install.sh
