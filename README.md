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

### Kanata Setup

Kanata, the utility to remap specific keys of my keyboard to others, needs some configuration to run.

Follow the first 4 steps in this installation guide: <https://github.com/jtroo/kanata/blob/main/docs/setup-linux.md>

The systemd file is included in my dotfiles and just needs to be stowed and then started:

```bash
systemctl --user daemon-reload
systemctl --user enable kanata.service --now
systemctl --user status kanata.service   # check whether the service is running
```
