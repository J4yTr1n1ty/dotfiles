# Load completions
autoload -Uz compinit && compinit

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

eval "$(zoxide init --cmd cd zsh)"
export PATH="/opt/nvim/:~/.dotnet/tools:~/.config/emacs/bin:$PATH"

export EDITOR="nvim"

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
