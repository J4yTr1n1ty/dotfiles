#!/bin/bash

# Modular Dotfiles Installer
# Allows you to choose which components to install

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISTRO=""
PACKAGE_MANAGER=""
USER_HOME=""
ACTUAL_USER=""

# Component flags
INSTALL_CORE=false
INSTALL_TERMINALS=()
INSTALL_HYPRLAND=false
INSTALL_FONTS=()
INSTALL_DEV_TOOLS=()
INSTALL_EXTRAS=false

# Utility functions
print_header() {
  echo -e "${PURPLE}================================${NC}"
  echo -e "${PURPLE}  Dotfiles Modular Installer${NC}"
  echo -e "${PURPLE}================================${NC}"
  echo
}

print_step() {
  echo -e "${BLUE}==>${NC} ${1}"
}

print_success() {
  echo -e "${GREEN}✓${NC} ${1}"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} ${1}"
}

print_error() {
  echo -e "${RED}✗${NC} ${1}" >&2
}

detect_system() {
  print_step "Detecting system..."

  # Get the actual user (in case script is run with sudo)
  if [ -n "$SUDO_USER" ]; then
    ACTUAL_USER="$SUDO_USER"
    USER_HOME=$(eval echo ~$SUDO_USER)
  else
    ACTUAL_USER="$USER"
    USER_HOME="$HOME"
  fi

  # Detect distribution and package manager
  if command -v pacman &>/dev/null; then
    DISTRO="arch"
    PACKAGE_MANAGER="pacman"
    print_success "Detected Arch Linux"
  elif command -v apt &>/dev/null; then
    DISTRO="debian"
    PACKAGE_MANAGER="apt"
    print_success "Detected Debian/Ubuntu"
  else
    print_error "Unsupported distribution. Only Arch Linux and Debian/Ubuntu are supported."
    exit 1
  fi
}

install_yay() {
  if [ "$DISTRO" = "arch" ] && ! command -v yay &>/dev/null; then
    print_step "Installing yay AUR helper..."

    # Install base-devel and git if not present
    pacman -S --needed --noconfirm base-devel git

    # Clone and build yay as the actual user
    sudo -u "$ACTUAL_USER" bash -c "
      cd /tmp
      git clone https://aur.archlinux.org/yay.git
      cd yay
      makepkg -si --noconfirm
    "

    print_success "yay installed"
  fi
}

install_packages() {
  local packages=("$@")

  if [ ${#packages[@]} -eq 0 ]; then
    return 0
  fi

  print_step "Installing packages: ${packages[*]}"

  case "$PACKAGE_MANAGER" in
  "pacman")
    # Install yay first if needed
    install_yay

    if command -v yay &>/dev/null; then
      sudo -u "$ACTUAL_USER" yay -S --noconfirm "${packages[@]}" || {
        print_warning "yay failed for some packages, trying with pacman..."
        pacman -S --noconfirm "${packages[@]}" 2>/dev/null || true
      }
    else
      pacman -S --noconfirm "${packages[@]}"
    fi
    ;;
  "apt")
    apt update
    apt install -y "${packages[@]}"
    ;;
  esac
}

show_component_menu() {
  echo
  print_step "Choose components to install:"
  echo
  echo "1) Core Shell Environment (zsh, tmux, neovim) - Recommended"
  echo "2) Terminal Emulators"
  echo "3) Hyprland Desktop Environment"
  echo "4) Fonts"
  echo "5) Development Tools"
  echo "6) Additional Utilities"
  echo "7) Continue with selected components"
  echo "8) Exit"
  echo
  echo -e "${CYAN}Current selections:${NC}"
  [ "$INSTALL_CORE" = true ] && echo "  ✓ Core Shell Environment"
  [ ${#INSTALL_TERMINALS[@]} -gt 0 ] && echo "  ✓ Terminal Emulators: ${INSTALL_TERMINALS[*]}"
  [ "$INSTALL_HYPRLAND" = true ] && echo "  ✓ Hyprland Desktop Environment"
  [ ${#INSTALL_FONTS[@]} -gt 0 ] && echo "  ✓ Fonts: ${INSTALL_FONTS[*]}"
  [ ${#INSTALL_DEV_TOOLS[@]} -gt 0 ] && echo "  ✓ Development Tools: ${INSTALL_DEV_TOOLS[*]}"
  [ "$INSTALL_EXTRAS" = true ] && echo "  ✓ Additional Utilities"
  echo
}

select_terminals() {
  echo
  print_step "Select terminal emulators to install:"
  echo "1) Ghostty (Primary)"
  echo "2) Kitty"
  echo "3) Alacritty"
  echo "4) All terminals"
  echo "5) Back to main menu"
  echo
  read -p "Enter your choices (1-5, multiple numbers separated by space): " -a choices

  INSTALL_TERMINALS=()
  for choice in "${choices[@]}"; do
    case $choice in
    1) INSTALL_TERMINALS+=("ghostty") ;;
    2) INSTALL_TERMINALS+=("kitty") ;;
    3) INSTALL_TERMINALS+=("alacritty") ;;
    4) INSTALL_TERMINALS=("ghostty" "kitty" "alacritty") ;;
    5) return ;;
    esac
  done
}

select_fonts() {
  echo
  print_step "Select fonts to install:"
  echo "1) JetBrains Mono Nerd Font (Primary)"
  echo "2) Maple Mono NF"
  echo "3) Both fonts"
  echo "4) Back to main menu"
  echo
  read -p "Enter your choice (1-4): " choice

  INSTALL_FONTS=()
  case $choice in
  1) INSTALL_FONTS=("jetbrains") ;;
  2) INSTALL_FONTS=("maple") ;;
  3) INSTALL_FONTS=("maple" "jetbrains") ;;
  4) return ;;
  esac
}

select_dev_tools() {
  echo
  print_step "Select development tools to install:"
  echo "1) .NET SDK"
  echo "2) Go"
  echo "3) Rust"
  echo "4) Node.js (via NVM)"
  echo "5) Bun JavaScript Runtime"
  echo "6) Android Development Tools"
  echo "7) All development tools"
  echo "8) Back to main menu"
  echo
  read -p "Enter your choices (1-8, multiple numbers separated by space): " -a choices

  INSTALL_DEV_TOOLS=()
  for choice in "${choices[@]}"; do
    case $choice in
    1) INSTALL_DEV_TOOLS+=("dotnet") ;;
    2) INSTALL_DEV_TOOLS+=("go") ;;
    3) INSTALL_DEV_TOOLS+=("rust") ;;
    4) INSTALL_DEV_TOOLS+=("nodejs") ;;
    5) INSTALL_DEV_TOOLS+=("bun") ;;
    6) INSTALL_DEV_TOOLS+=("android") ;;
    7) INSTALL_DEV_TOOLS=("dotnet" "go" "rust" "nodejs" "bun" "android") ;;
    8) return ;;
    esac
  done
}

install_core_packages() {
  print_step "Installing core shell environment..."

  # Install base-devel first on Arch for AUR builds
  if [ "$DISTRO" = "arch" ]; then
    pacman -S --needed --noconfirm base-devel git
  fi

  local packages=()
  case "$DISTRO" in
  "arch")
    # Most packages are now in official repositories!
    packages=(stow zsh tmux fzf neovim ranger bat fd ripgrep git curl wget unzip eza zoxide lazygit)
    install_packages "${packages[@]}"

    # Only a few AUR packages needed now
    local aur_packages=(pfetch-rs)
    install_packages "${aur_packages[@]}"
    ;;
  "debian")
    packages=(stow zsh tmux fzf neovim ranger bat fd-find ripgrep git curl wget unzip)
    install_packages "${packages[@]}"

    # Install tools not available in repositories
    install_debian_tools
    ;;
  esac

  # Install Oh My Posh
  install_oh_my_posh

  print_success "Core shell environment installed"
}

install_debian_tools() {
  print_step "Installing additional tools for Debian/Ubuntu..."

  # Create .local/bin directory
  sudo -u "$ACTUAL_USER" mkdir -p "$USER_HOME/.local/bin"

  # Install eza
  if ! command -v eza &>/dev/null; then
    print_step "Installing eza..."
    local eza_version=$(curl -s "https://api.github.com/repos/eza-community/eza/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    sudo -u "$ACTUAL_USER" bash -c "
      cd /tmp
      wget -q https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz
      tar xzf eza_x86_64-unknown-linux-gnu.tar.gz
      mv eza '$USER_HOME/.local/bin/'
      rm eza_x86_64-unknown-linux-gnu.tar.gz
    "
  fi

  # Install zoxide
  if ! command -v zoxide &>/dev/null; then
    print_step "Installing zoxide..."
    sudo -u "$ACTUAL_USER" bash -c 'curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh'
  fi

  # Install lazygit
  if ! command -v lazygit &>/dev/null; then
    print_step "Installing lazygit..."
    local lazygit_version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${lazygit_version}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    install /tmp/lazygit /usr/local/bin
    rm /tmp/lazygit.tar.gz /tmp/lazygit
  fi

  # Install pfetch-rs (Rust version)
  if ! command -v pfetch &>/dev/null; then
    print_step "Installing pfetch..."
    local pfetch_version=$(curl -s "https://api.github.com/Gobidev/pfetch-rs/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    sudo -u "$ACTUAL_USER" bash -c "
      cd /tmp
      wget -q https://github.com/Gobidev/pfetch-rs/releases/latest/download/pfetch-linux-amd64
      chmod +x pfetch-linux-amd64
      mv pfetch-linux-amd64 '$USER_HOME/.local/bin/pfetch'
    "
  fi
}

install_oh_my_posh() {
  case "$DISTRO" in
  "arch")
    # Try AUR packages first
    local aur_packages=(oh-my-posh-bin)
    install_packages "${aur_packages[@]}" || {
      print_warning "AUR installation failed, installing manually..."
      install_oh_my_posh_manual
    }
    ;;
  "debian")
    install_oh_my_posh_manual
    ;;
  esac
}

install_oh_my_posh_manual() {
  print_step "Installing Oh My Posh manually..."
  if ! command -v oh-my-posh &>/dev/null; then
    wget -q https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
    chmod +x /usr/local/bin/oh-my-posh
  fi
}

install_terminal_packages() {
  for terminal in "${INSTALL_TERMINALS[@]}"; do
    print_step "Installing $terminal..."

    case "$terminal" in
    "ghostty")
      case "$DISTRO" in
      "arch")
        # Ghostty is now in official extra repository!
        install_packages ghostty
        ;;
      "debian")
        print_warning "Ghostty requires manual compilation on Debian/Ubuntu"
        print_warning "Visit: https://ghostty.org/docs/install/source"
        ;;
      esac
      ;;
    "kitty")
      install_packages kitty
      ;;
    "alacritty")
      install_packages alacritty
      ;;
    esac
  done

  print_success "Terminal emulators installed"
}

install_hyprland_packages() {
  print_step "Installing Hyprland desktop environment..."

  case "$DISTRO" in
  "arch")
    # Core Hyprland packages
    local packages=(hyprland hyprpaper)
    install_packages "${packages[@]}"

    # Additional desktop components
    local desktop_packages=(waybar wofi mako swaylock brightnessctl pamixer playerctl)
    install_packages "${desktop_packages[@]}"

    # Network and Bluetooth
    local network_packages=(blueman networkmanager nm-connection-editor)
    install_packages "${network_packages[@]}"

    # Enable NetworkManager
    systemctl enable NetworkManager
    ;;
  "debian")
    print_warning "Hyprland installation on Debian/Ubuntu requires manual setup"
    print_warning "Please refer to: https://wiki.hyprland.org/Getting-Started/Installation/"
    ;;
  esac

  print_success "Hyprland packages installed"
}

install_font_packages() {
  for font in "${INSTALL_FONTS[@]}"; do
    print_step "Installing $font font..."

    case "$font" in
    "maple")
      case "$DISTRO" in
      "arch")
        # Try the main AUR package
        install_packages maplemono-nf || {
          print_warning "maplemono-nf not found, installing manually..."
          install_maple_manual
        }
        ;;
      "debian")
        install_maple_manual
        ;;
      esac
      ;;
    "jetbrains")
      case "$DISTRO" in
      "arch")
        install_packages ttf-jetbrains-mono-nerd
        ;;
      "debian")
        install_jetbrains_manual
        ;;
      esac
      ;;
    esac
  done

  # Refresh font cache
  sudo -u "$ACTUAL_USER" fc-cache -fv
  print_success "Fonts installed"
}

install_maple_manual() {
  print_step "Installing Maple Mono NF manually..."
  local font_dir="$USER_HOME/.local/share/fonts"
  sudo -u "$ACTUAL_USER" mkdir -p "$font_dir"

  # Get latest release info
  local release_info=$(curl -s "https://api.github.com/repos/subframe7536/Maple-font/releases/latest")
  local download_url=$(echo "$release_info" | grep -o '"browser_download_url": "[^"]*MapleMono-NF[^"]*\.zip"' | cut -d'"' -f4)

  if [ -n "$download_url" ]; then
    sudo -u "$ACTUAL_USER" bash -c "
      cd '$font_dir'
      wget -q '$download_url' -O MapleMono-NF.zip
      unzip -q MapleMono-NF.zip
      rm MapleMono-NF.zip
    "
    print_success "Maple Mono NF installed manually"
  else
    print_error "Failed to find Maple Mono NF download URL"
  fi
}

install_jetbrains_manual() {
  print_step "Installing JetBrains Mono Nerd Font manually..."
  local font_dir="$USER_HOME/.local/share/fonts"
  sudo -u "$ACTUAL_USER" mkdir -p "$font_dir"

  sudo -u "$ACTUAL_USER" bash -c "
    cd '$font_dir'
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
    unzip -q JetBrainsMono.zip
    rm JetBrainsMono.zip
  "
  print_success "JetBrains Mono Nerd Font installed manually"
}

install_dev_tools() {
  for tool in "${INSTALL_DEV_TOOLS[@]}"; do
    print_step "Installing $tool..."

    case "$tool" in
    "dotnet")
      case "$DISTRO" in
      "arch")
        install_packages dotnet-runtime dotnet-sdk aspnet-runtime
        ;;
      "debian")
        print_step "Installing .NET on Debian/Ubuntu..."
        # Add Microsoft repository
        wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
        dpkg -i /tmp/packages-microsoft-prod.deb
        rm /tmp/packages-microsoft-prod.deb
        apt update
        apt install -y dotnet-sdk-8.0 aspnetcore-runtime-8.0
        ;;
      esac
      ;;
    "go")
      install_packages go
      ;;
    "rust")
      print_step "Installing Rust via rustup..."
      if ! command -v rustup &>/dev/null; then
        sudo -u "$ACTUAL_USER" bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'
        print_success "Rust installed. Run 'source ~/.cargo/env' to update PATH"
      fi
      ;;
    "nodejs")
      print_step "Installing Node.js via NVM..."
      sudo -u "$ACTUAL_USER" bash -c '
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install --lts
      '
      print_success "Node.js installed via NVM"
      ;;
    "bun")
      print_step "Installing Bun JavaScript runtime..."
      sudo -u "$ACTUAL_USER" bash -c 'curl -fsSL https://bun.sh/install | bash'
      print_success "Bun installed"
      ;;
    "android")
      case "$DISTRO" in
      "arch")
        install_packages android-tools jdk-openjdk
        # Android Studio from AUR
        install_packages android-studio || {
          print_warning "Android Studio installation failed. Please install manually from: https://developer.android.com/studio"
        }
        ;;
      "debian")
        install_packages android-tools-adb android-tools-fastboot openjdk-11-jdk
        print_warning "Android Studio not available in repositories."
        print_warning "Download from: https://developer.android.com/studio"
        ;;
      esac
      ;;
    esac
  done

  print_success "Development tools installed"
}

install_extra_packages() {
  print_step "Installing additional utilities..."

  local packages=()
  case "$DISTRO" in
  "arch")
    # All packages are now in official repos!
    packages=(htop btop mpv pavucontrol git-delta)
    install_packages "${packages[@]}"
    ;;
  "debian")
    packages=(htop mpv pavucontrol)
    install_packages "${packages[@]}"

    # Install git-delta manually for Debian
    install_delta_manual
    ;;
  esac

  print_success "Additional utilities installed"
}

install_delta_manual() {
  if ! command -v delta &>/dev/null; then
    print_step "Installing git-delta manually..."
    local delta_version=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    local deb_file="git-delta_${delta_version}_amd64.deb"
    wget -q "https://github.com/dandavison/delta/releases/latest/download/${deb_file}" -O "/tmp/${deb_file}"
    dpkg -i "/tmp/${deb_file}" || apt-get install -f -y
    rm "/tmp/${deb_file}"
  fi
}

setup_dotfiles() {
  print_step "Setting up dotfiles with Stow..."

  cd "$DOTFILES_DIR"

  # Initialize git submodules for nvim and doom configs
  if [ -f ".gitmodules" ]; then
    sudo -u "$ACTUAL_USER" git submodule update --init --recursive
  fi

  # Create stow ignore file for conditional components
  local stow_ignore="$DOTFILES_DIR/.stow-local-ignore"

  # Always ignore certain files
  cat >"$stow_ignore" <<EOF
# Auto-generated ignore file
RCS
.+,v
CVS
\.\#.+
\.cvsignore
\.svn
_darcs
\.hg
\.git
\.gitignore
\.gitattributes
\.gitmodules
.+~
\#.*\#
^/README.*
^/LICENSE.*
^/COPYING
.*\.ttf
install\.sh
scripts
EOF

  # Conditionally ignore Hyprland configs if not selected
  if [ "$INSTALL_HYPRLAND" = false ]; then
    cat >>"$stow_ignore" <<EOF
\.config/hypr
\.config/waybar
\.config/wofi
\.config/mako
\.config/swaylock
\.config/hyprpaper
EOF
  fi

  # Ignore terminal configs not selected
  local all_terminals=("ghostty" "kitty" "alacritty")
  for terminal in "${all_terminals[@]}"; do
    if [[ ! " ${INSTALL_TERMINALS[@]} " =~ " ${terminal} " ]]; then
      echo ".config/$terminal" >>"$stow_ignore"
    fi
  done

  # Run stow
  sudo -u "$ACTUAL_USER" stow . --target="$USER_HOME" --restow

  print_success "Dotfiles linked successfully"
}

setup_shell() {
  if [ "$INSTALL_CORE" = true ]; then
    print_step "Setting up Zsh as default shell..."

    # Change shell for the actual user
    chsh -s "$(which zsh)" "$ACTUAL_USER"

    print_success "Zsh set as default shell"
  fi
}

setup_tmux() {
  if [ "$INSTALL_CORE" = true ]; then
    print_step "Setting up Tmux Plugin Manager..."

    local tpm_dir="$USER_HOME/.tmux/plugins/tpm"
    if [ ! -d "$tpm_dir" ]; then
      sudo -u "$ACTUAL_USER" bash -c "
        git clone https://github.com/tmux-plugins/tpm '$tpm_dir'
      "
      print_success "TPM installed. Press Ctrl+a + I in tmux to install plugins"
    fi
  fi
}

setup_services() {
  if [ "$INSTALL_HYPRLAND" = true ] && [ "$DISTRO" = "arch" ]; then
    print_step "Enabling system services..."

    # Enable NetworkManager
    systemctl enable NetworkManager

    # Enable Bluetooth
    systemctl enable bluetooth

    print_success "System services enabled"
  fi
}

main() {
  # Check if running as root
  if [ "$EUID" -ne 0 ]; then
    print_error "This script needs to be run with sudo"
    exit 1
  fi

  print_header
  detect_system

  # Interactive menu
  while true; do
    show_component_menu
    read -p "Enter your choice (1-8): " choice

    case $choice in
    1)
      INSTALL_CORE=true
      print_success "Core Shell Environment selected"
      ;;
    2)
      select_terminals
      ;;
    3)
      if [ "$DISTRO" = "arch" ]; then
        INSTALL_HYPRLAND=true
        print_success "Hyprland Desktop Environment selected"
      else
        print_warning "Hyprland auto-installation only supported on Arch Linux"
        read -p "Add Hyprland configs anyway? (y/n): " add_configs
        if [[ $add_configs =~ ^[Yy]$ ]]; then
          INSTALL_HYPRLAND=true
          print_success "Hyprland configs will be included"
        fi
      fi
      ;;
    4)
      select_fonts
      ;;
    5)
      select_dev_tools
      ;;
    6)
      INSTALL_EXTRAS=true
      print_success "Additional Utilities selected"
      ;;
    7)
      break
      ;;
    8)
      echo "Installation cancelled."
      exit 0
      ;;
    *)
      print_error "Invalid choice. Please try again."
      ;;
    esac

    echo
    read -p "Press Enter to continue..."
  done

  # Confirm installation
  echo
  print_step "Ready to install selected components"
  read -p "Continue with installation? (y/n): " confirm

  if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
  fi

  # Install selected components
  echo
  print_step "Starting installation..."

  [ "$INSTALL_CORE" = true ] && install_core_packages
  [ ${#INSTALL_TERMINALS[@]} -gt 0 ] && install_terminal_packages
  [ "$INSTALL_HYPRLAND" = true ] && install_hyprland_packages
  [ ${#INSTALL_FONTS[@]} -gt 0 ] && install_font_packages
  [ ${#INSTALL_DEV_TOOLS[@]} -gt 0 ] && install_dev_tools
  [ "$INSTALL_EXTRAS" = true ] && install_extra_packages

  # Setup dotfiles and configurations
  setup_dotfiles
  setup_shell
  setup_tmux
  setup_services

  echo
  print_success "Installation completed successfully!"
  echo
  print_step "Next steps:"
  echo "  1. Restart your terminal or session"
  [ "$INSTALL_CORE" = true ] && echo "  2. Start tmux and press Ctrl+a + I to install plugins"
  [ "$INSTALL_HYPRLAND" = true ] && echo "  3. Log out and select Hyprland from your display manager"
  [[ " ${INSTALL_DEV_TOOLS[@]} " =~ " nodejs " ]] && echo "  4. Run 'nvm use --lts' to activate Node.js"
  [[ " ${INSTALL_DEV_TOOLS[@]} " =~ " rust " ]] && echo "  5. Run 'source ~/.cargo/env' to activate Rust"
  echo
  print_step "IMPORTANT: Most packages are now in official Arch repositories!"
  print_step "This makes installation much more reliable than previous AUR-heavy setups"
  print_step "Configuration files are now linked to your home directory"
  print_step "Enjoy your new setup! 🚀"
}

main "$@"
