# shellcheck disable=SC2148
# <---------------------- PLUGINS ------------------------>
# shellcheck disable=SC2034
plugins=(
  brew
  docker
  docker-compose
  git
  history
  terraform
)

# <------------------ PRIVATE INCLUDES ------------------->
# Keep secrets in `.localrc`
if [[ -a ~/.localrc ]] then
  # shellcheck disable=SC1090
  source ~/.localrc
fi

# <--------------------- OH-MY-ZSH ----------------------->
# init zsh
export ZSH=~/.oh-my-zsh
export ZSH_THEME=""
# shellcheck disable=SC1091
source $ZSH/oh-my-zsh.sh
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

# <----------------------- ZPLUG ------------------------->
# zplug
export ZPLUG_HOME="${HOMEBREW_PREFIX}/opt/zplug"
# shellcheck disable=SC1091
source "$ZPLUG_HOME/init.zsh"
zplug "dracula/zsh", as:theme
if ! zplug check; then
  zplug install
fi
zplug load

# <----------------------- DRIFT ------------------------->
~/dotfiles/drift/detect.sh

# <---------------------- HELPERS ------------------------>
# zsh-autosuggestions
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=10"
# shellcheck disable=SC1091
source "${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# zsh-syntax-highlighting
# shellcheck disable=SC1091
source "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# <---------------------- ALIASES ------------------------>
alias gnb="git checkout main && git pull --rebase && git checkout -b"
alias vim="nvim"
alias vi="nvim"

# <----------------------- TOOLS ------------------------->
# XDG
export XDG_CONFIG_HOME="$HOME/.config"

# HOMEBREW
export PATH="${HOMEBREW_PREFIX}/sbin:/sbin:/usr/local/bin:$PATH"

# NVM
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC2027 disable=SC2086 disable=1091
[ -s ""${HOMEBREW_PREFIX}"/opt/nvm/nvm.sh" ] && . ""${HOMEBREW_PREFIX}"/opt/nvm/nvm.sh"  # This loads nvm
# shellcheck disable=SC2027 disable=SC2086 disable=1091
[ -s ""${HOMEBREW_PREFIX}"/opt/nvm/etc/bash_completion.d/nvm" ] && . ""${HOMEBREW_PREFIX}"/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

### DIRENV
eval "$(direnv hook zsh)"

### NEOVIM
export EDITOR="nvim"

### PYENV
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

### STARSHIP
export STARSHIP_CONFIG="${HOME}/.starship/starship.toml"
eval "$(starship init zsh)"

### SDKMAN (Keep it last!)
# shellcheck disable=SC1091
[[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]] && source "${HOME}/.sdkman/bin/sdkman-init.sh"
