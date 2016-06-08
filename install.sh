#!/usr/bin/env bash

export DOTFILES_DIRECTORY

# Variables, make any wanted changes here
VUNDLE_LOCATION=~/.vim/bundle/Vundle.vim

# Get absolute path to the directory the script is run in
DOTFILES_DIRECTORY="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Install Vundle for vim, if not installed already
if [ ! -d "$VUNDLE_LOCATION" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git $VUNDLE_LOCATION 
fi

ln -sfv $DOTFILES_DIRECTORY/.vimrc ~
ln -sfv $DOTFILES_DIRECTORY/.tmux.conf ~
ln -sfv $DOTFILES_DIRECTORY/.zshrc ~
ln -sfv $DOTFILES_DIRECTORY/.gitconfig ~
ln -sfv $DOTFILES_DIRECTORY/.gitignore_global ~

# Install Vundle plugins
vim +PluginInstall +qall

# Change shell to zsh if not changed already
chsh -s $(which zsh)