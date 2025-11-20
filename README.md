# My Dotfiles

Personal configuration files for a modern Linux development environment with Hyprland, Zsh, Tmux, and essential development tools.

## What's Included

- **Window Manager**: Hyprland with smooth animations and tiling
- **Shell**: Zsh with Oh My Posh for a clean prompt
- **Terminal**: Ghostty (primary), with Kitty and Alacritty configs
- **Editor**: Neovim with LazyVim configuration
- **Terminal Multiplexer**: Tmux with vi-mode bindings
- **File Manager**: Ranger for keyboard-driven navigation
- **App Launcher**: Wofi for clean application launching
- **Notifications**: Mako notification daemon
- **Keyboard Remapping**: Kanata for better key layouts

## Installation

### Prerequisites

Install the essential tools first:

**Arch Linux:**

```bash
yay -S stow git curl wget unzip
```

**Ubuntu/Debian:**

```bash
sudo apt update && sudo apt install stow git curl wget unzip
```

### Core Shell and Terminal Tools

```bash
# Essential command-line tools
yay -S zsh tmux fzf eza zoxide lazygit neovim ranger pfetch bat fd ripgrep

# For Ubuntu/Debian (some may need manual installation):
sudo apt install zsh tmux fzf neovim ranger bat fd-find ripgrep

# These tools need cargo or manual install on non-Arch systems:
cargo install eza zoxide
```

### Fonts

```bash
# JetBrains Mono Nerd Font (main font)
yay -S ttf-jetbrains-mono-nerd

# Monocraft
yay -S otf-monocraft

# For non-Arch systems, download manually:
# JetBrains: https://github.com/ryanoasis/nerd-fonts

# Refresh font cache
fc-cache -fv
```

### Oh My Posh

```bash
# Arch Linux:
yay -S oh-my-posh

# Manual installation (works on all systems):
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh
```

### Hyprland Desktop Environment

```bash
# Core Hyprland components
yay -S hyprland hyprpaper waybar wofi mako

# Terminal emulators
yay -S ghostty kitty alacritty

# System utilities
yay -S swaylock brightnessctl pamixer playerctl

# Network and Bluetooth management
yay -S blueman networkmanager nm-connection-editor
```

### Development Tools

#### Programming Languages

```bash
# .NET development
yay -S dotnet-runtime dotnet-sdk aspnet-runtime

# Go programming
yay -S go

# Rust development
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Node.js via NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
# Then install LTS: nvm install --lts

# Bun JavaScript runtime
curl -fsSL https://bun.sh/install | bash
```

### Additional Utilities

```bash
# System monitoring
yay -S htop btop

# Media tools
yay -S mpv pavucontrol

# Git enhancements
yay -S git-delta
```

## Setup Instructions

1. **Clone the repository:**

   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Install configurations using Stow:**

   ```bash
   stow .
   ```

3. **Set Zsh as default shell:**

   ```bash
   chsh -s $(which zsh)
   ```

4. **Install Tmux plugins:**

   ```bash
   tmux
   # Install tpm manually
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   # Press Ctrl+a followed by I to install plugins
   ```

5. **Setup Kanata (optional):**

   ```bash
   systemctl --user daemon-reload
   systemctl --user enable kanata.service --now
   systemctl --user status kanata.service
   ```

6. **Configure Hyprland:**
   - Log out and select Hyprland from your display manager
   - The configuration will load automatically

## Configuration Highlights

- **Zsh**: Zinit plugin manager with syntax highlighting, autosuggestions, and smart completions
- **Tmux**: Vi-mode keybindings, Tokyo Night theme, session persistence
- **Neovim**: LazyVim configuration with modern plugins
- **Hyprland**: Smooth animations and efficient tiling window management
- **Kanata**: Caps Lock remapped to Escape/Ctrl (tap/hold behavior)
- **Font**: JetBrains Mono NF

## Customization

The configuration is modular and easily customizable:

- **Shell settings**: `.zshrc`, `.bashrc`
- **Tmux configuration**: `.config/tmux/tmux.conf`
- **Window manager**: `.config/hypr/hyprland.conf`
- **Terminal appearance**: `.config/ghostty/config`, `.config/kitty/kitty.conf`
- **Editor setup**: `.config/nvim/` (LazyVim submodule)

## Troubleshooting

Common issues and solutions:

1. **Missing dependencies**: Verify all packages from the installation sections are installed
2. **Stow conflicts**: Try `stow --restow .` to refresh symlinks
3. **Shell not changing**: Verify with `echo $SHELL` and restart your session
4. **Hyprland issues**: Check logs with `journalctl --user -u hyprland`
5. **Kanata not working**: Check service status with `systemctl --user status kanata`

## Notes

- Multiple configuration options are provided (e.g., Waybar and AGS for status bars)
- Optimized for .NET, Angular, Go, and Rust development workflows
- Kanata requires additional system-level configuration for keyboard remapping
- All development tools include proper PATH configurations
- Font configurations gracefully fall back if primary fonts aren't available
