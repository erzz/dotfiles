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
# Secrets rendered/refreshed by `mise run sync` through fnox into
# ~/.local/state/secrets.env (mode 0600). Loaded before mise activation so
# private npm tools can authenticate via $GH_TOKEN.
if [ -r "$HOME/.local/state/secrets.env" ]; then
  set -a
  # shellcheck disable=SC1091
  source "$HOME/.local/state/secrets.env"
  set +a
fi

# <--------------------- OH-MY-ZSH ----------------------->
# Select the installed Homebrew prefix on Intel or Apple Silicon before
# loading plugins that provide completions and shell integrations.
if command -v brew >/dev/null 2>&1; then
  export HOMEBREW_PREFIX="$(brew --prefix)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
elif [[ -x /usr/local/bin/brew ]]; then
  export HOMEBREW_PREFIX="/usr/local"
fi
FPATH="${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/zsh/site-functions:}${FPATH}"
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
# shellcheck disable=SC1035,SC1072
} &!

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
export PATH="${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:}/sbin:/usr/local/bin:$PATH"
export HOMEBREW_AUTO_UPDATE_SECS=2629746

### DIRENV
eval "$(direnv hook zsh)"

### TERM

DISABLE_AUTO_TITLE="true"

precmd() {
  # sets the tab title to current dir
  echo -ne "\e]2;${PWD##*/}\a"

}

### EDITOR
export EDITOR="zed"

### DOCKER
# Do not set DOCKER_HOST; Docker contexts select Colima.

### PRETTIERD
export PRETTIERD_DEFAULT_CONFIG=~/.config/prettierd/global.json

### STARSHIP
eval "$(starship init zsh)"

### Zoxide
eval "$(zoxide init zsh)"

export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate zsh)"

### BUN
#  bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# LM Studio CLI, when installed for this user.
[[ -d "$HOME/.lmstudio/bin" ]] && export PATH="$PATH:$HOME/.lmstudio/bin"


# >>> oh-my-opencode-slim background subagents >>>
export OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true
# <<< oh-my-opencode-slim background subagents <<<

# >>> oh-my-opencode-slim multiplexer launcher >>>
oc() {
  local port
  port=$(jot -r 1 49152 65535)
  OPENCODE_PORT="$port" opencode --port "$port" "$@"
}
# <<< oh-my-opencode-slim multiplexer launcher <<<
