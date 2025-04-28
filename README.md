# My dotfiles

## Installations

To install these dotfiles you need to install the following dependencies:

```bash
yay -S stow fzf oh-my-posh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install neovim zoxide
curl -fsSL https://get.pnpm.io/install.sh | sh -

```

If you want to use Hyprland, you will have to install the following dependencies (example using yay):

```bash
yay -S hyprland hyprpaper wofi ags-hyprpanel-git swaylock
```

After that clone the Repo into a directory of your choosing and run `stow .` in the cloned directory. Make sure to create a copy of the dotfiles.
