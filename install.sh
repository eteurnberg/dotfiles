#!/usr/bin/env bash

export DOTFILES_DIRECTORY

# Variables, make any wanted changes here
VUNDLE_LOCATION=~/.vim/bundle/Vundle.vim
TPM_LOCATION=~/.tmux/plugins/tpm
OH_MY_ZSH_LOCATION=~/.oh-my-zsh
OH_MY_ZSH_POWERLEVEL9K_THEME_LOCATION="$OH_MY_ZSH_LOCATION/custom/themes/powerlevel9k"
FONTS_DIR=/fonts

# Get absolute path to the directory the script is located in
DOTFILES_DIRECTORY="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# List of dotfiles being kept track of
dotfiles=(".vimrc" ".tmux.conf" ".tmuxline_snapshot.conf" ".zshrc" ".gitconfig" ".gitignore_global")

# Install oh-my-zsh, if not installed already
if [ ! -d "$OH_MY_ZSH_LOCATION" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

# Install Vundle for vim, if not installed already
if [ ! -d "$VUNDLE_LOCATION" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git $VUNDLE_LOCATION
fi

# Install Tmux Plugin Manager, if not installed already
if [ ! -d "$TPM_LOCATION" ]; then
    git clone https://github.com/tmux-plugins/tpm $TPM_LOCATION
fi

# Install oh-my-zsh theme powerlevel9k if not already installed
if [ ! -d "$OH_MY_ZSH_POWERLEVEL9K_THEME_LOCATION" ]; then
    git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
fi

# Install powerline fonts
if [ ! -d "$DOTFILES_DIRECTORY$FONTS_DIR" ]; then
    git clone https://github.com/powerline/fonts
    ./fonts/install.sh
fi

for dotfile in "${dotfiles[@]}"; do
  ln -sfv "${HOME}/${dotfile}" "$DOTFILES_DIRECTORY"
done

# Config git to use new global gitignore file
git config --global core.excludesfile ~/.gitignore_global

# Install Vundle plugins
vim +PluginInstall +qall

# Change shell to zsh if not changed already
chsh -s "$(command -v zsh)"
