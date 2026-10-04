# Shared personal shell settings for Omarchy's user-owned Bash startup.

if [ -r "$HOME/.local/state/secrets.env" ]; then
  set -a
  # shellcheck disable=SC1091
  source "$HOME/.local/state/secrets.env"
  set +a
fi

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"

alias vim="nvim"
alias vi="nvim"
alias gnb="git checkout main && git pull --rebase && git checkout -b"
alias gg="lazygit"
alias ld="eza -lD --icons"
alias lf="eza -lf --icons --color=always | grep -v /"
alias lh="eza -dl .* --icons --group-directories-first"
alias ll="eza -al --icons --group-directories-first"
alias ls="eza -alf --icons --color=always --sort=size | grep -v /"
alias lT="eza -T --icons"

alias oc=opencode
