# My Dotfiles
My configuration files. I use zshell with oh-my-zsh, vim and tmux. The goal is for these files to work on both OS X and Ubuntu. These are mainly kept here to be accessible to myself, but you are welcome to use and try them if you like.

## Prerequisites
[Homebrew](https://brew.sh) needs to be installed already. Given that, running `install.sh` installs everything else automatically from the tracked `Brewfile`: zsh, vim, tmux, git, [delta](https://github.com/dandavison/delta), [lazygit](https://github.com/jesseduffield/lazygit), [bat](https://github.com/sharkdp/bat), [eza](https://github.com/eza-community/eza), [ripgrep](https://github.com/BurntSushi/ripgrep), [fd](https://github.com/sharkdp/fd) and [Ghostty](https://ghostty.org). Without Homebrew, install these manually via your system's package manager instead -- `install.sh` skips the Brewfile step entirely if `brew` isn't on `PATH`.

`.gitconfig` sets `core.pager = delta`, so git diff output fails to render without git-delta. `.zshrc` aliases `cat` to `bat` and `ls`/`l`/`ll`/`la`/`lsa` to `eza`, so those break without their respective tools. ripgrep and fd (`rg`, `fd`) are just recommended -- no tracked config depends on them.

For the agnoster theme in oh-my-zsh to work properly, patched fonts are needed. `install.sh` clones and installs [Powerline-fonts](https://github.com/powerline/fonts) automatically.

`ghostty-config` is symlinked to `~/.config/ghostty/config` and sets the Solarized Dark theme to match vim/tmux/delta.

## Installing
_NOTE:_ Backup any dotfiles you already have before installing. The symlinking will remove any files you might already have with the same names.
The .gitconfig file is setup to use my user name and email, you will want to change this.
1. Clone this repo and `cd` into it.
2. Run install.sh, you might have to run it as root.

To update, pull the repo and run install.sh again.
