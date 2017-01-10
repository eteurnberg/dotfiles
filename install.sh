#!/usr/bin/env bash

export DOTFILES_DIRECTORY

# Variables, make any wanted changes here
VUNDLE_LOCATION=~/.vim/bundle/Vundle.vim
TPM_LOCATION=~/.tmux/plugins/tpm

# Get absolute path to the directory the script is run in
DOTFILES_DIRECTORY="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Install Vundle for vim, if not installed already
if [ ! -d "$VUNDLE_LOCATION" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git $VUNDLE_LOCATION 
fi

# Install Tmux Plugin Manager, if not installed already
if [ ! -d "$TPM_LOCATION" ]; then
    git clone https://github.com/tmux-plugins/tpm $TPM_LOCATION 
fi

git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

FONTS_DIR=/fonts

# Install powerline fonts
if [ ! -d "$DOTFILES_DIRECTORY$FONTS_DIR" ]; then
    git clone https://github.com/powerline/fonts
    ./fonts/install.sh
fi

ln -sfv $DOTFILES_DIRECTORY/.vimrc ~
ln -sfv $DOTFILES_DIRECTORY/.tmux.conf ~
ln -sfv $DOTFILES_DIRECTORY/.tmuxline_snapshot.conf ~
ln -sfv $DOTFILES_DIRECTORY/.zshrc ~
ln -sfv $DOTFILES_DIRECTORY/.gitconfig ~
ln -sfv $DOTFILES_DIRECTORY/.gitignore_global ~

# Config git to use new global gitignore file
git config --global core.excludesfile ~/.gitignore_global

# Install Vundle plugins
vim +PluginInstall +qall

# Change shell to zsh if not changed already
chsh -s $(which zsh)
