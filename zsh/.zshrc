# shellcheck disable=SC2148
# shellcheck disable=SC2034
plugins=(
  brew
  docker
  docker-compose
  git
  history
  terraform
)

# Extend with vars we dont want to share
if [ -f ~/.zshrc.vars ]; then
  # shellcheck disable=SC1090
  source ~/.zshrc.vars
fi

# init zsh
export ZSH=~/.oh-my-zsh
export ZSH_THEME=""
# shellcheck disable=SC1091
source $ZSH/oh-my-zsh.sh
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

# zplug
export ZPLUG_HOME="${HOMEBREW_PREFIX}/opt/zplug"
# shellcheck disable=SC1091
source "$ZPLUG_HOME/init.zsh"
zplug "dracula/zsh", as:theme
if ! zplug check; then
  zplug install
fi
zplug load

# zsh-autosuggestions
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=10"
# shellcheck disable=SC1091
source "${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# zsh-syntax-highlighting
# shellcheck disable=SC1091
source "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# brew
export PATH="${HOMEBREW_PREFIX}/sbin:/sbin:/usr/local/bin:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC2027 disable=SC2086 disable=1091
[ -s ""${HOMEBREW_PREFIX}"/opt/nvm/nvm.sh" ] && . ""${HOMEBREW_PREFIX}"/opt/nvm/nvm.sh"  # This loads nvm
# shellcheck disable=SC2027 disable=SC2086 disable=1091
[ -s ""${HOMEBREW_PREFIX}"/opt/nvm/etc/bash_completion.d/nvm" ] && . ""${HOMEBREW_PREFIX}"/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# ALIASES
alias gnb="git checkout main && git pull --rebase && git checkout -b"

# XDG
export XDG_CONFIG_HOME="$HOME/.config"

# TOOLS
### neovim
export EDITOR="nvim"
### pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
### starship
export STARSHIP_CONFIG="${HOME}/.starship/starship.toml"
eval "$(starship init zsh)"
### sdkman (Keep it last!)
# shellcheck disable=SC1091
[[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]] && source "${HOME}/.sdkman/bin/sdkman-init.sh"
