# Run a tmux session if not already in one
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux
fi

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

alias weather="curl wttr.in"

alias lg="lazygit"

alias ..="cd .."

alias dotnet-test-pretty='dotnet test --no-restore --verbosity=normal | awk '\''/Failed /{print "\n\033[31mFailed: " $2 "\033[0m"} /Error Message:/{print "\033[33mError: " substr($0, index($0, ":")+1) "\033[0m"; st=0} /Stack Trace:/{st=1; next} st==1 && /at /{print "\033[36mStack: " $0 "\033[0m"; st=0}'\'''

# Ranger, if installed
if command -v ranger &> /dev/null; then
  alias ra="ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR
fi

[ -s "/home/linuxbrew/.linuxbrew/bin/brew" ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# fzf
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
eval "$(fzf --zsh)"

if command -v zoxide &> /dev/null; then
  eval "$(zoxide init --cmd cd zsh)"
else
  echo "zoxide not installed"
fi

# Path
export PATH="/opt/nvim/:~/.dotnet/tools:~/.config/emacs/bin:$HOME/.local/bin:$PATH"

export EDITOR="nvim"

# GPG
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

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

# Convert video to MP4 with even dimensions
webm2mp4() {
    if [ $# -eq 0 ]; then
        echo "Usage: webm2mp4 <input_file>"
        return 1
    fi
    
    local input_file="$1"
    local output_file="${input_file%.*}.mp4"
    
    ffmpeg -i "$input_file" -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -c:v libx264 -preset slow -crf 22 -c:a aac -b:a 128k "$output_file"
}

# Start Screen
export PF_INFO="ascii title os host kernel uptime memory editor palette"
if command -v pfetch &> /dev/null; then
  pfetch
else
  echo "pfetch not installed"
fi

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

# Cargo
[ -s "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

export PATH="/home/jay/.config/herd-lite/bin:$PATH"
export PHP_INI_SCAN_DIR="/home/jay/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"

# bun completions
[ -s "/home/jay/.bun/_bun" ] && source "/home/jay/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Load Angular CLI autocompletion.
if ! command -v ng &> /dev/null; then
  source <(ng completion script)
fi

export ANDROID_HOME=/home/jay/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
