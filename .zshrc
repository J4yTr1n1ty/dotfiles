# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found
zinit snippet OMZP::colored-man-pages
zinit snippet OMZP::tmux

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/themes/zen.toml)"

alias vim="nvim"
alias vi="nvim"
alias v="nvim"

alias ls="eza --color=auto"
alias ll="ls -l"
alias la="ls -a"
alias c="clear"
alias q="exit"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# fzf
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
eval "$(fzf --zsh)"

eval "$(zoxide init --cmd cd zsh)"
export PATH="/opt/nvim/:~/.dotnet/tools:~/.config/emacs/bin:$PATH"

export EDITOR="nvim"

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

LC_CTYPE=en_US.UTF-8
LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Start Screen
export PF_INFO="ascii title os host kernel uptime memory editor palette"
pfetch

# Load Angular CLI autocompletion.
source <(ng completion script)

# Go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# pnpm
export PNPM_HOME="/home/jay/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

. "$HOME/.cargo/env"
