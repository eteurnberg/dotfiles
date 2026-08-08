#!/usr/bin/env bash

set -euo pipefail

export DOTFILES_DIRECTORY

# Variables, make any wanted changes here
VUNDLE_LOCATION=~/.vim/bundle/Vundle.vim
TPM_LOCATION=~/.tmux/plugins/tpm
OH_MY_ZSH_LOCATION=~/.oh-my-zsh
OH_MY_ZSH_POWERLEVEL9K_THEME_LOCATION="$OH_MY_ZSH_LOCATION/custom/themes/powerlevel9k"

# Get absolute path to the directory the script is located in
DOTFILES_DIRECTORY="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

FONTS_DIR="$DOTFILES_DIRECTORY/fonts"

# List of dotfiles being kept track of
dotfiles=(".vimrc" ".tmux.conf" ".tmuxline_snapshot.conf" ".zshrc" ".gitconfig" ".gitignore_global")

# Where pre-existing real files get moved before being replaced by a symlink
BACKUP_DIR="${HOME}/.dotfiles_backup/$(date +%Y%m%d%H%M%S)"

# Symlink $1 to $2, backing up whatever currently lives at $2 first if it's a
# real file/directory rather than an already-existing symlink
link_dotfile() {
    local src="$1"
    local dest="$2"

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        mkdir -p "$BACKUP_DIR"
        mv -v "$dest" "$BACKUP_DIR/"
    fi

    ln -sfv "$src" "$dest"
}

# Install oh-my-zsh, if not installed already
if [ ! -d "$OH_MY_ZSH_LOCATION" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Vundle for vim, if not installed already
if [ ! -d "$VUNDLE_LOCATION" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_LOCATION"
fi

# Install Tmux Plugin Manager, if not installed already
if [ ! -d "$TPM_LOCATION" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_LOCATION"
fi

# Install oh-my-zsh theme powerlevel9k if not already installed
if [ ! -d "$OH_MY_ZSH_POWERLEVEL9K_THEME_LOCATION" ]; then
    git clone https://github.com/bhilburn/powerlevel9k.git "$OH_MY_ZSH_POWERLEVEL9K_THEME_LOCATION"
fi

# Install powerline fonts, if not installed already
if [ ! -d "$FONTS_DIR" ]; then
    git clone https://github.com/powerline/fonts "$FONTS_DIR"
    "$FONTS_DIR/install.sh"
fi

for dotfile in "${dotfiles[@]}"; do
  link_dotfile "$DOTFILES_DIRECTORY/${dotfile}" "${HOME}/${dotfile}"
done

# Symlink individual files from .claude rather than the directory itself, since
# ~/.claude also holds Claude Code's own runtime data (history, cache, settings.json, plugins, ...)
CLAUDE_DIR="$DOTFILES_DIRECTORY/.claude"
if [ -d "$CLAUDE_DIR" ]; then
    mkdir -p "${HOME}/.claude"
    for claude_file in "$CLAUDE_DIR"/*; do
        [ -f "$claude_file" ] && link_dotfile "$claude_file" "${HOME}/.claude/$(basename "$claude_file")"
    done
fi

if [ -d "$BACKUP_DIR" ]; then
    echo "Backed up pre-existing files to $BACKUP_DIR"
fi

# Config git to use new global gitignore file
git config --global core.excludesfile ~/.gitignore_global

# Install Vundle plugins, if vim is installed
if command -v vim >/dev/null 2>&1; then
    vim +PluginInstall +qall
fi

# Change shell to zsh if not changed already
if [ "$SHELL" != "$(command -v zsh)" ]; then
    chsh -s "$(command -v zsh)"
fi
