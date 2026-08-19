# My Dotfiles
My configuration files. I use zshell with oh-my-zsh, vim and tmux. The goal is for these files to work on both OS X and Ubuntu. These are mainly kept here to be accessible to myself, but you are welcome to use and try them if you like.

## Prerequisites
zsh, oh-my-zsh, vim, tmux and git needed. 
For the agnoster theme in oh-my-zsh to work properly patched fonts are needed. The recommeneded way to achieve this is to install [Powerline-fonts](https://github.com/powerline/fonts).
_NOTE:_ The install script should now install these automatically.

[delta](https://github.com/dandavison/delta), [lazygit](https://github.com/jesseduffield/lazygit) and [bat](https://github.com/sharkdp/bat) are needed too -- `.gitconfig` sets `core.pager = delta`, so git diff output will fail to render without it, and `.zshrc` aliases `cat` to `bat` for syntax-highlighted, line-numbered file output. Install all three via your system's package manager (e.g. `brew install git-delta lazygit bat`); the install script doesn't install packages, only plugin managers/plugins.

[Ghostty](https://ghostty.org) is used as the terminal emulator. `ghostty-config` is symlinked to `~/.config/ghostty/config` and sets the Solarized Dark theme to match vim/tmux/delta; Ghostty itself isn't installed by install.sh.

## Installing
_NOTE:_ Backup any dotfiles you already have before installing. The symlinking will remove any files you might already have with the same names.
The .gitconfig file is setup to use my user name and email, you will want to change this.
1. Clone this repo and `cd` into it.
2. Run install.sh, you might have to run it as root.

To update, pull the repo and run install.sh again.
