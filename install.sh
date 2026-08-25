#!/usr/bin/env bash

set -euo pipefail

export DOTFILES_DIRECTORY

# Variables, make any wanted changes here
TPM_LOCATION=~/.tmux/plugins/tpm
OH_MY_ZSH_LOCATION=~/.oh-my-zsh
OH_MY_ZSH_POWERLEVEL9K_THEME_LOCATION="$OH_MY_ZSH_LOCATION/custom/themes/powerlevel9k"

# Get absolute path to the directory the script is located in
DOTFILES_DIRECTORY="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

FONTS_DIR="$DOTFILES_DIRECTORY/fonts"

# List of dotfiles being kept track of
dotfiles=(".vimrc" ".tmux.conf" ".tmuxline_snapshot.conf" ".zshenv" ".zprofile" ".zshrc" ".gitconfig" ".gitignore_global")

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

    # -n matters when $dest is already a symlink pointing at a directory
    # (nvim/ is): without it ln follows the link and drops the new symlink
    # *inside* the target, so re-running this script would create a
    # self-referential nvim/nvim. Harmless for file symlinks, required for
    # directory ones, and supported by both BSD and GNU ln.
    ln -sfnv "$src" "$dest"
}

# Install Homebrew-managed packages listed in Brewfile, if Homebrew itself
# is available. --no-upgrade keeps this idempotent -- it only installs
# what's missing, matching every other step below, rather than upgrading
# already-installed packages on every re-run.
if command -v brew >/dev/null 2>&1; then
    brew bundle install --no-upgrade --file="$DOTFILES_DIRECTORY/Brewfile"
else
    echo "Homebrew not found -- skipping Brewfile install. See README for the manual package list." >&2
fi

# Install oh-my-zsh, if not installed already
if [ ! -d "$OH_MY_ZSH_LOCATION" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Tmux Plugin Manager, if not installed already
if [ ! -d "$TPM_LOCATION" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_LOCATION"
fi

# Install oh-my-zsh theme powerlevel9k if not already installed
if [ ! -d "$OH_MY_ZSH_POWERLEVEL9K_THEME_LOCATION" ]; then
    git clone https://github.com/bhilburn/powerlevel9k.git "$OH_MY_ZSH_POWERLEVEL9K_THEME_LOCATION"
fi

# Install third-party oh-my-zsh plugins referenced in .zshrc's plugins=(),
# if not already installed. Entries are "install dir name|git url".
ZSH_CUSTOM_PLUGINS_DIR="$OH_MY_ZSH_LOCATION/custom/plugins"
zsh_plugins=(
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting"
    "zsh-completions|https://github.com/zsh-users/zsh-completions"
    "you-should-use|https://github.com/MichaelAquilina/zsh-you-should-use.git"
)
for entry in "${zsh_plugins[@]}"; do
    plugin_dir="${entry%%|*}"
    plugin_url="${entry#*|}"
    if [ ! -d "$ZSH_CUSTOM_PLUGINS_DIR/$plugin_dir" ]; then
        git clone --depth 1 "$plugin_url" "$ZSH_CUSTOM_PLUGINS_DIR/$plugin_dir"
    fi
done

# Install powerline fonts, if not installed already
if [ ! -d "$FONTS_DIR" ]; then
    git clone https://github.com/powerline/fonts "$FONTS_DIR"
    "$FONTS_DIR/install.sh"
fi

for dotfile in "${dotfiles[@]}"; do
  link_dotfile "$DOTFILES_DIRECTORY/${dotfile}" "${HOME}/${dotfile}"
done

# Symlink individual files from claude-global/ (not .claude/ itself, since
# ~/.claude also holds Claude Code's own runtime data -- history, cache,
# settings.json, plugins, ...) into ~/.claude/. Only files meant to apply to
# every project on this machine belong in claude-global/; anything specific
# to working on this dotfiles repo (e.g. .claude/settings.local.json,
# .claude/settings.json) stays in .claude/ and is picked up automatically as
# this project's own settings, without ever being symlinked to $HOME.
CLAUDE_DIR="$DOTFILES_DIRECTORY/claude-global"
if [ -d "$CLAUDE_DIR" ]; then
    mkdir -p "${HOME}/.claude"
    for claude_file in "$CLAUDE_DIR"/*; do
        [ -f "$claude_file" ] && link_dotfile "$claude_file" "${HOME}/.claude/$(basename "$claude_file")"
    done
fi

# Symlink lazygit's config file specifically, since ~/.config/lazygit could
# hold other runtime state alongside it
mkdir -p "${HOME}/.config/lazygit"
link_dotfile "$DOTFILES_DIRECTORY/lazygit-config.yml" "${HOME}/.config/lazygit/config.yml"

# Symlink Ghostty's config file specifically, since ~/.config/ghostty could
# hold other runtime state (themes, cache) alongside it
mkdir -p "${HOME}/.config/ghostty"
link_dotfile "$DOTFILES_DIRECTORY/ghostty-config" "${HOME}/.config/ghostty/config"

# Symlink the whole nvim/ directory as one unit, unlike the per-file
# treatment above -- Neovim's XDG layout keeps all plugin/cache/state data
# under ~/.local/share/nvim and ~/.local/state/nvim, never inside
# ~/.config/nvim itself, so nothing untracked can ever need to coexist
# there the way Claude Code's or lazygit's runtime data does.
mkdir -p "${HOME}/.config"
link_dotfile "$DOTFILES_DIRECTORY/nvim" "${HOME}/.config/nvim"

if [ -d "$BACKUP_DIR" ]; then
    echo "Backed up pre-existing files to $BACKUP_DIR"
fi

# Config git to use new global gitignore file. Quoted so the shell doesn't
# expand the tilde before git sees it -- git expands ~/ itself when reading
# config, so this stays portable across machines/usernames instead of
# baking in an absolute path. That's exactly what SC2088 warns about, but
# here it's the intent, so the warning is silenced rather than "fixed".
# shellcheck disable=SC2088
git config --global core.excludesfile '~/.gitignore_global'

# Install/sync lazy.nvim-managed Neovim plugins, if nvim is installed. Runs
# headless so a fresh machine bootstraps fully non-interactively -- no
# manual :Lazy sync needed on a new box.
if command -v nvim >/dev/null 2>&1; then
    nvim --headless "+Lazy! sync" +qa
fi

# Change shell to zsh if not changed already. chsh requires the target to
# be listed in /etc/shells -- true automatically for the system zsh, but
# not for one just brewed above, so check first rather than hard-failing
# under set -e; fixing /etc/shells needs sudo, too invasive to do silently.
ZSH_BIN="$(command -v zsh)"
if [ "$SHELL" != "$ZSH_BIN" ]; then
    if grep -qxF "$ZSH_BIN" /etc/shells 2>/dev/null; then
        chsh -s "$ZSH_BIN"
    else
        echo "NOTE: $ZSH_BIN isn't listed in /etc/shells, so chsh was skipped." >&2
        echo "Run: sudo sh -c \"echo $ZSH_BIN >> /etc/shells\" && chsh -s $ZSH_BIN" >&2
    fi
fi
