# My dotfiles

## Installations

To install these dotfiles you need to install the following dependencies:
```bash
yay -S stow fzf
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install neovim zoxide
curl -fsSL https://get.pnpm.io/install.sh | sh -

```



After that clone the Repo into a directory of your choosing and run `stow .` in the cloned directory. Make sure to create a copy of the dotfiles.
