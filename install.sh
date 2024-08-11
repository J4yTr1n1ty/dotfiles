#!/bin/bash

error() {
    red='\033[0;31m'
    reset='\033[0m'
    echo -e "${red}Error: $1${reset}" >&2
}

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  error "This script needs to be run with sudo"
  exit 1
fi

# Determine the home directory of the user who invoked sudo, or root if run directly
if [ -n "$SUDO_USER" ]; then
  USER_HOME=$(eval echo ~$SUDO_USER)
  RUN_AS_USER="$SUDO_USER"
else
  USER_HOME="$HOME"
  RUN_AS_USER="root"
fi

# Function to install packages
install_packages() {
    local packages=("$@")
    local package_manager=""

    # Detect the package manager
    if command -v pacman &> /dev/null; then
        package_manager="pacman"
    elif command -v apt &> /dev/null; then
        package_manager="apt"
    else
        error "Neither pacman nor apt package manager found."
        return 1
    fi

    # Install packages based on the detected package manager
    case "$package_manager" in
        "pacman")
            if ! sudo pacman -Sy --noconfirm "${packages[@]}" >/dev/null 2>&1; then
                error "Unable to install packages using pacman. Exiting."
                exit 1
            fi
            ;;
        "apt")
            if ! sudo apt update >/dev/null 2>&1; then
                error "Unable to update packages using apt. Exiting."
                exit 1
            fi
            
            if ! sudo apt install -y "${packages[@]}" >/dev/null 2>&1; then
                error "Unable to install packages using apt. Exiting."
                exit 1
            fi
            ;;
        *)
            error "Unsupported package manager."
            return 1
            ;;
    esac
}

echo "Installing packages..."
install_packages stow fzf zoxide

echo "Linking dotfiles using stow..."
if ! cd "$USER_HOME/dotfiles"; then
    error "Unable to change directory to dotfiles directory."
    exit 1
fi

if ! stow . >/dev/null 2>&1; then
    error "Failed to link dotfiles using stow."
fi

echo "Installing and setting up nerd fonts..."
if [ "$RUN_AS_USER" != "root" ]; then
    if ! sudo -u "$RUN_AS_USER" curl -sSfL https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/install.sh | sudo -u "$RUN_AS_USER" sh >/dev/null; then
        error "Failed to install nerd fonts."
    fi
else
    if ! curl -sSfL https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/install.sh | sh >/dev/null; then
        error "Failed to install nerd fonts."
    fi
fi

wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip \
&& cd ~/.local/share/fonts \
&& unzip JetBrainsMono.zip \
&& rm JetBrainsMono.zip \
&& fc-cache -fv

echo "Installing and setting up zoxide..."
if [ "$RUN_AS_USER" != "root" ]; then
    if ! sudo -u "$RUN_AS_USER" curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sudo -u "$RUN_AS_USER" sh >/dev/null; then
        error "Failed to install zoxide."
    fi
else
    if ! curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh >/dev/null; then
        error "Failed to install zoxide."
    fi
fi

if [ ! -d "$USER_HOME/.fzf" ]; then
    echo "Cloning fzf repository..."
    if ! git clone --quiet --depth 1 https://github.com/junegunn/fzf.git "$USER_HOME/.fzf" >/dev/null 2>&1; then
        error "Failed to clone fzf repository."
    fi
else
    echo "Pulling changes from fzf repository..."
    if ! (cd "$USER_HOME/.fzf" && git pull) >/dev/null 2>&1; then
        error "Could not pull changes from repository."
    fi
fi

echo "Installing fzf..."
if ! yes | "$USER_HOME/.fzf/install" >/dev/null 2>&1; then
    error "Failed to install fzf."
fi

echo "Downloading ohmyposh..."
if ! sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh >/dev/null 2>&1; then
    error "Failed to install ohmyposh."
fi

echo "Changing permission for ohmyposh executable..."
if ! sudo chmod +x /usr/local/bin/oh-my-posh; then
    error "Failed to change permission for ohmyposh."
fi

echo "Changing default shell..."
if ! chsh -s $(which zsh) "$RUN_AS_USER" >/dev/null; then
    error "Failed to change default shell."
fi
