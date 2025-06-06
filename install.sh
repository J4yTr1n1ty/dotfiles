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

install_packages() {
  local packages=("$@")

  if [ ${#packages[@]} -eq 0 ]; then
    return 0
  fi

  print_step "Installing packages: ${packages[*]}"

  case "$PACKAGE_MANAGER" in
  "pacman")
    if command -v yay &>/dev/null; then
      yay -S --noconfirm "${packages[@]}" || {
        print_warning "yay failed, trying with pacman..."
        pacman -S --noconfirm "${packages[@]}"
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
  echo "1) Maple Mono NF (Primary)"
  echo "2) JetBrains Mono Nerd Font"
  echo "3) Both fonts"
  echo "4) Back to main menu"
  echo
  read -p "Enter your choice (1-4): " choice

  INSTALL_FONTS=()
  case $choice in
  1) INSTALL_FONTS=("maple") ;;
  2) INSTALL_FONTS=("jetbrains") ;;
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
  echo "5) Android Studio"
  echo "6) All development tools"
  echo "7) Back to main menu"
  echo
  read -p "Enter your choices (1-7, multiple numbers separated by space): " -a choices

  INSTALL_DEV_TOOLS=()
  for choice in "${choices[@]}"; do
    case $choice in
    1) INSTALL_DEV_TOOLS+=("dotnet") ;;
    2) INSTALL_DEV_TOOLS+=("go") ;;
    3) INSTALL_DEV_TOOLS+=("rust") ;;
    4) INSTALL_DEV_TOOLS+=("nodejs") ;;
    5) INSTALL_DEV_TOOLS+=("android") ;;
    6) INSTALL_DEV_TOOLS=("dotnet" "go" "rust" "nodejs" "android") ;;
    7) return ;;
    esac
  done
}

install_core_packages() {
  print_step "Installing core shell environment..."

  local packages=()
  case "$DISTRO" in
  "arch")
    packages=(stow zsh tmux fzf eza zoxide lazygit neovim ranger pfetch bat fd ripgrep git)
    ;;
  "debian")
    packages=(stow zsh tmux fzf neovim ranger bat fd-find ripgrep git)
    ;;
  esac

  install_packages "${packages[@]}"

  # Install tools not available in repositories
  if [ "$DISTRO" = "debian" ]; then
    print_step "Installing additional tools via cargo/manual installation..."

    # Install eza
    if ! command -v eza &>/dev/null; then
      sudo -u "$ACTUAL_USER" bash -c 'curl -sSfL https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz | tar xz -C ~/.local/bin'
    fi

    # Install zoxide
    if ! command -v zoxide &>/dev/null; then
      sudo -u "$ACTUAL_USER" bash -c 'curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh'
    fi

    # Install lazygit
    if ! command -v lazygit &>/dev/null; then
      LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
      curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
      tar xf lazygit.tar.gz lazygit
      install lazygit /usr/local/bin
      rm lazygit.tar.gz lazygit
    fi
  fi

  # Install Oh My Posh
  case "$DISTRO" in
  "arch")
    if command -v yay &>/dev/null; then
      yay -S --noconfirm oh-my-posh || {
        print_warning "yay failed for oh-my-posh, installing manually..."
        install_oh_my_posh_manual
      }
    else
      install_oh_my_posh_manual
    fi
    ;;
  "debian")
    install_oh_my_posh_manual
    ;;
  esac

  print_success "Core shell environment installed"
}

install_oh_my_posh_manual() {
  print_step "Installing Oh My Posh manually..."
  wget -q https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
  chmod +x /usr/local/bin/oh-my-posh
}

install_terminal_packages() {
  for terminal in "${INSTALL_TERMINALS[@]}"; do
    print_step "Installing $terminal..."

    case "$terminal" in
    "ghostty")
      case "$DISTRO" in
      "arch")
        if command -v yay &>/dev/null; then
          yay -S --noconfirm ghostty
        else
          print_warning "ghostty requires AUR, skipping..."
        fi
        ;;
      "debian")
        print_warning "ghostty not available in repositories, please install manually"
        ;;
      esac
      ;;
    "kitty" | "alacritty")
      install_packages "$terminal"
      ;;
    esac
  done

  print_success "Terminal emulators installed"
}

install_hyprland_packages() {
  print_step "Installing Hyprland desktop environment..."

  case "$DISTRO" in
  "arch")
    local packages=(hyprland hyprpaper waybar wofi mako swaylock brightnessctl pamixer playerctl blueman networkmanager nm-connection-editor)
    install_packages "${packages[@]}"
    ;;
  "debian")
    print_warning "Hyprland installation on Debian/Ubuntu requires manual setup"
    print_warning "Please refer to Hyprland documentation for installation instructions"
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
        if command -v yay &>/dev/null; then
          yay -S --noconfirm ttf-maple
        else
          install_maple_manual
        fi
        ;;
      "debian")
        install_maple_manual
        ;;
      esac
      ;;
    "jetbrains")
      case "$DISTRO" in
      "arch")
        if command -v yay &>/dev/null; then
          yay -S --noconfirm ttf-jetbrains-mono-nerd
        else
          install_jetbrains_manual
        fi
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
  sudo -u "$ACTUAL_USER" bash -c "
        cd '$font_dir'
        wget -q https://github.com/subframe7536/Maple-font/releases/latest/download/MapleMono-NF.zip
        unzip -q MapleMono-NF.zip
        rm MapleMono-NF.zip
    "
}

install_jetbrains_manual() {
  print_step "Installing JetBrains Mono Nerd Font manually..."
  local font_dir="$USER_HOME/.local/share/fonts"
  sudo -u "$ACTUAL_USER" mkdir -p "$font_dir"
  sudo -u "$ACTUAL_USER" bash -c "
        cd '$font_dir'
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
        unzip -q JetBrainsMono.zip
        rm JetBrainsMono.zip
    "
}

install_dev_tools() {
  for tool in "${INSTALL_DEV_TOOLS[@]}"; do
    print_step "Installing $tool..."

    case "$tool" in
    "dotnet")
      case "$DISTRO" in
      "arch")
        install_packages dotnet-runtime dotnet-sdk
        ;;
      "debian")
        print_warning ".NET installation on Debian/Ubuntu requires manual setup"
        print_warning "Please visit: https://dotnet.microsoft.com/download"
        ;;
      esac
      ;;
    "go")
      install_packages go
      ;;
    "rust")
      print_step "Installing Rust via rustup..."
      sudo -u "$ACTUAL_USER" bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'
      ;;
    "nodejs")
      print_step "Installing Node.js via NVM..."
      sudo -u "$ACTUAL_USER" bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash'
      print_warning "Run 'nvm install --lts' after restarting your shell"
      ;;
    "android")
      case "$DISTRO" in
      "arch")
        if command -v yay &>/dev/null; then
          yay -S --noconfirm android-studio
        else
          print_warning "Android Studio requires AUR, skipping..."
        fi
        ;;
      "debian")
        print_warning "Android Studio not available in repositories, please install manually"
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
    packages=(htop btop mpv pavucontrol git-delta)
    ;;
  "debian")
    packages=(htop mpv pavucontrol)
    ;;
  esac

  install_packages "${packages[@]}"

  # Install git-delta manually for Debian
  if [ "$DISTRO" = "debian" ] && ! command -v delta &>/dev/null; then
    print_step "Installing git-delta manually..."
    local delta_version=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    wget -q "https://github.com/dandavison/delta/releases/latest/download/git-delta_${delta_version}_amd64.deb"
    dpkg -i "git-delta_${delta_version}_amd64.deb"
    rm "git-delta_${delta_version}_amd64.deb"
  fi

  print_success "Additional utilities installed"
}

setup_dotfiles() {
  print_step "Setting up dotfiles with Stow..."

  cd "$DOTFILES_DIR"

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
EOF

  # Conditionally ignore Hyprland configs if not selected
  if [ "$INSTALL_HYPRLAND" = false ]; then
    echo ".config/hypr" >>"$stow_ignore"
    echo ".config/waybar" >>"$stow_ignore"
    echo ".config/wofi" >>"$stow_ignore"
    echo ".config/mako" >>"$stow_ignore"
    echo ".config/swaylock" >>"$stow_ignore"
  fi

  # Ignore terminal configs not selected
  local all_terminals=("ghostty" "kitty" "alacritty")
  for terminal in "${all_terminals[@]}"; do
    if [[ ! " ${INSTALL_TERMINALS[@]} " =~ " ${terminal} " ]]; then
      echo ".config/$terminal" >>"$stow_ignore"
    fi
  done

  # Run stow
  sudo -u "$ACTUAL_USER" stow . --target="$USER_HOME"

  print_success "Dotfiles linked successfully"
}

setup_shell() {
  if [ "$INSTALL_CORE" = true ]; then
    print_step "Setting up Zsh as default shell..."

    # Change shell for the actual user
    chsh -s "$(which zsh)" "$ACTUAL_USER"

    print_success "Zsh set as default shell"
    print_warning "Please restart your session to use the new shell"
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
  [ "$INSTALL_HYPRLAND" = true ] && [ "$DISTRO" = "arch" ] && install_hyprland_packages
  [ ${#INSTALL_FONTS[@]} -gt 0 ] && install_font_packages
  [ ${#INSTALL_DEV_TOOLS[@]} -gt 0 ] && install_dev_tools
  [ "$INSTALL_EXTRAS" = true ] && install_extra_packages

  # Setup dotfiles
  setup_dotfiles
  setup_shell

  echo
  print_success "Installation completed successfully!"
  echo
  print_step "Next steps:"
  echo "  1. Restart your terminal or session"
  [ "$INSTALL_CORE" = true ] && echo "  2. Start tmux and press Ctrl+a + I to install plugins"
  [ "$INSTALL_HYPRLAND" = true ] && echo "  3. Select Hyprland from your display manager"
  [[ " ${INSTALL_DEV_TOOLS[@]} " =~ " nodejs " ]] && echo "  4. Run 'nvm install --lts' to install Node.js"
  echo
  print_step "Enjoy your new setup! 🚀"
}

main "$@"
