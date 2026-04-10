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
# Secrets managed by fnox + 1Password (loaded after mise activation below)

# <--------------------- OH-MY-ZSH ----------------------->
# Eza completions (must be on FPATH before OMZ runs compinit)
FPATH="/opt/homebrew/share/zsh/site-functions:${FPATH}"
# init zsh
export ZSH=~/.oh-my-zsh
export ZSH_THEME=""
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST
# shellcheck disable=SC1091
source $ZSH/oh-my-zsh.sh

# Recompile zcompdump in background if stale (prevents ~500ms compinit penalty)
{
  if [[ -s "$ZSH_COMPDUMP" && (! -s "${ZSH_COMPDUMP}.zwc" || "$ZSH_COMPDUMP" -nt "${ZSH_COMPDUMP}.zwc") ]]; then
    zcompile "$ZSH_COMPDUMP"
  fi
} &!

# <----------------------- DRIFT ------------------------->
~/dotfiles/drift/detect.sh &>/dev/null &

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
alias gg="lazygit"
alias vim="nvim"
alias vi="nvim"
alias ld="eza -lD --icons"
alias lf="eza -lf --icons --color=always | grep -v /"
alias lh="eza -dl .* --icons --group-directories-first"
alias ll="eza -al --icons --group-directories-first"
alias ls="eza -alf --icons --color=always --sort=size | grep -v /"
alias lt="eza -al --icons --sort=modified"
alias lT="eza -T --icons"

# <----------------------- TOOLS ------------------------->
# XDG
export XDG_CONFIG_HOME="$HOME/.config"

# HOMEBREW
export PATH="${HOMEBREW_PREFIX}/sbin:/sbin:/usr/local/bin:$PATH"
export HOMEBREW_AUTO_UPDATE_SECS=2629746

### DIRENV
eval "$(direnv hook zsh)"

### TERM

DISABLE_AUTO_TITLE="true"

precmd() {
  # sets the tab title to current dir
  echo -ne "\e]2;${PWD##*/}\a"

  # One-shot drift notification (written by background detect.sh)
  if [[ -f /tmp/dotfiles-drift ]]; then
    cat /tmp/dotfiles-drift
    rm -f /tmp/dotfiles-drift
  fi
}

### EDITOR
export EDITOR="zed"

### DOCKER
# Set the Docker host to use Colima's socket
export DOCKER_HOST="unix://${XDG_CONFIG_HOME:-$HOME/.config}/colima/default/docker.sock"
# Cap client API version to match Colima's dockerd
export DOCKER_API_VERSION=1.43

### PRETTIERD
export PRETTIERD_DEFAULT_CONFIG=~/.config/prettierd/global.json

### STARSHIP
eval "$(starship init zsh)"

### Zoxide
eval "$(zoxide init zsh)"

eval "$(mise activate zsh)"

### FNOX (secrets via 1Password - must be after mise activation)
eval "$(fnox activate zsh -c ~/.config/fnox/config.toml)"

### BUN 
#  bun completions
[ -s "/Users/sean.erswell-liljefelt/.bun/_bun" ] && source "/Users/sean.erswell-liljefelt/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

