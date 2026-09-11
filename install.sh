#!/usr/bin/env bash
#
# Install-or-reload script for these dotfiles.
#
# Every step is idempotent -- each one either creates what's missing or
# refreshes what's already there -- so this is as much a "reload" as an
# "install" and is safe to re-run any time. Once it has run once it is also
# available as the `dotfiles` command from anywhere (see step_symlinks).
#
# Note that editing an already-tracked file needs no run at all: the tracked
# files are symlinked into place, so edits are live immediately. Re-running
# matters when adding a *new* tracked file, changing the Brewfile, or
# changing Neovim's plugin set.
#
# Usage:
#   ./install.sh                 run every step, in order
#   ./install.sh symlinks        run only the named step(s)
#   ./install.sh symlinks neovim run several, in the order given
#   ./install.sh --list          list the steps
#   ./install.sh --help          this message
#
# Targeted like that, ordering is your responsibility -- see STEPS below for
# the dependencies between them. A plain full run is always correct.
#
# Written for bash 3.2, which is what macOS still ships (so: no associative
# arrays, no `readlink -f`).

set -euo pipefail

# Resolve this script's own location *through* symlinks. When invoked as
# ~/.local/bin/dotfiles, BASH_SOURCE[0] is that symlink, so a plain dirname
# would yield ~/.local/bin rather than the repo and every symlink target
# below would be wrong. Plain readlink (no -f) because BSD and GNU differ.
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
    SOURCE_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$SOURCE_DIR/$SOURCE"
done
DOTFILES_DIRECTORY="$(cd -P "$(dirname "$SOURCE")" && pwd)"
export DOTFILES_DIRECTORY

# Variables, make any wanted changes here
TPM_LOCATION=~/.config/tmux/plugins/tpm
OH_MY_ZSH_LOCATION=~/.oh-my-zsh
OH_MY_ZSH_POWERLEVEL9K_THEME_LOCATION="$OH_MY_ZSH_LOCATION/custom/themes/powerlevel9k"
ZSH_CUSTOM_PLUGINS_DIR="$OH_MY_ZSH_LOCATION/custom/plugins"
ZSH_CUSTOM_COMPLETIONS_DIR="$OH_MY_ZSH_LOCATION/custom/completions"

FONTS_DIR="$DOTFILES_DIRECTORY/fonts"

# List of dotfiles being kept track of
dotfiles=(".vimrc" ".zshenv" ".zprofile" ".zshrc" ".gitconfig" ".gitignore_global")

# Where pre-existing real files get moved before being replaced by a symlink
BACKUP_DIR="${HOME}/.dotfiles_backup/$(date +%Y%m%d%H%M%S)"

# The steps, in the order a full run executes them. Dependencies:
#   packages -> neovim   (needs nvim installed)
#   packages -> tmux     (tpm's plugin install needs the tmux binary)
#   symlinks -> neovim   (Lazy sync reads ~/.config/nvim)
#   symlinks -> tmux     (tpm reads the plugin list from ~/.config/tmux/tmux.conf,
#                         and picks its plugin directory by that file's presence)
#   omz      -> zsh      (plugins live under ~/.oh-my-zsh/custom)
#   omz      -> completions (they land under ~/.oh-my-zsh/custom)
STEPS=(packages omz zsh completions fonts symlinks tmux git neovim shell)

step_description() {
    case "$1" in
        packages)    echo "Install Homebrew packages listed in Brewfile" ;;
        omz)         echo "Install oh-my-zsh" ;;
        zsh)         echo "Install the powerlevel9k theme and third-party zsh plugins" ;;
        completions) echo "Generate zsh completions for tools that emit their own" ;;
        tmux)        echo "Install Tmux Plugin Manager (tpm) and the plugins tmux.conf declares" ;;
        fonts)       echo "Install Powerline fonts" ;;
        symlinks)    echo "Symlink tracked config into place, plus the 'dotfiles' command" ;;
        git)         echo "Point git at the global gitignore" ;;
        neovim)      echo "Install/sync lazy.nvim-managed Neovim plugins" ;;
        shell)       echo "Make zsh the login shell" ;;
        *)           echo "(no description)" ;;
    esac
}

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
step_packages() {
    if command -v brew >/dev/null 2>&1; then
        brew bundle install --no-upgrade --file="$DOTFILES_DIRECTORY/Brewfile"
    else
        echo "Homebrew not found -- skipping Brewfile install. See README for the manual package list." >&2
    fi
}

# Install oh-my-zsh, if not installed already
step_omz() {
    if [ ! -d "$OH_MY_ZSH_LOCATION" ]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

# Install oh-my-zsh theme powerlevel9k, plus the third-party plugins
# referenced in .zshrc's plugins=(), if not already installed. Plugin
# entries are "install dir name|git url".
step_zsh() {
    if [ ! -d "$OH_MY_ZSH_POWERLEVEL9K_THEME_LOCATION" ]; then
        git clone https://github.com/bhilburn/powerlevel9k.git "$OH_MY_ZSH_POWERLEVEL9K_THEME_LOCATION"
    fi

    local zsh_plugins entry plugin_dir plugin_url
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
}

# Generate completions for tools that emit their own but ship no file. Not
# tracked in the repo: the output is large and pinned to the local tool version.
step_completions() {
    mkdir -p "$ZSH_CUSTOM_COMPLETIONS_DIR"

    local refresh_cache=0

    # Needs the .NET 10 SDK; on failure the oh-my-zsh plugin's completion stays.
    # Temp file so a failed run can't truncate a working _dotnet, unprefixed so
    # compinit can't load it mid-run. The sed drops MSBuild-style specs (/v=,
    # /nologo), which _arguments rejects -- taking the whole spec list with them.
    if command -v dotnet >/dev/null 2>&1; then
        if dotnet completions script zsh 2>/dev/null \
            | sed -E "/^[[:space:]]*'\\/[A-Za-z?]/d" > "$ZSH_CUSTOM_COMPLETIONS_DIR/.dotnet.tmp"; then
            mv "$ZSH_CUSTOM_COMPLETIONS_DIR/.dotnet.tmp" "$ZSH_CUSTOM_COMPLETIONS_DIR/_dotnet"
            refresh_cache=1
        else
            rm -f "$ZSH_CUSTOM_COMPLETIONS_DIR/.dotnet.tmp"
            echo "'dotnet completions' failed (it needs the .NET 10 SDK or newer) -- keeping the oh-my-zsh plugin's completion." >&2
        fi
    else
        echo "dotnet not found -- skipping its completion." >&2
    fi

    # oh-my-zsh only rebuilds the dump when $fpath or its own git revision
    # changes, so a new file in an already-listed dir needs this to be noticed.
    if [ "$refresh_cache" -eq 1 ]; then
        rm -f "${ZDOTDIR:-$HOME}"/.zcompdump*
        echo "Cleared the zsh completion cache -- run 'reload' or open a new shell to pick the new completions up."
    fi
}

# Install Tmux Plugin Manager and the plugins tmux.conf declares, if not
# installed already. Runs after symlinks: tpm decides where to keep plugins by
# looking for ~/.config/tmux/tmux.conf, and reads the plugin list out of it, so
# the symlink has to exist first or this installs nothing into the wrong place.
step_tmux() {
    if [ ! -d "$TPM_LOCATION" ]; then
        git clone https://github.com/tmux-plugins/tpm "$TPM_LOCATION"
    fi

    # install_plugins is itself idempotent -- it skips plugins already checked
    # out -- but it needs a tmux server to read the @plugin options, so it can
    # only run once tmux itself is installed.
    if command -v tmux >/dev/null 2>&1; then
        "$TPM_LOCATION/bin/install_plugins"
    else
        echo "tmux not found -- skipping plugin install. Run '$TPM_LOCATION/bin/install_plugins' once tmux is available." >&2
    fi
}

# Install powerline fonts, if not installed already
step_fonts() {
    if [ ! -d "$FONTS_DIR" ]; then
        git clone https://github.com/powerline/fonts "$FONTS_DIR"
        "$FONTS_DIR/install.sh"
    fi
}

step_symlinks() {
    local dotfile claude_entry stale

    for dotfile in "${dotfiles[@]}"; do
        link_dotfile "$DOTFILES_DIRECTORY/${dotfile}" "${HOME}/${dotfile}"
    done

    # Symlink individual entries from claude-global/ (not .claude/ itself, since
    # ~/.claude also holds Claude Code's own runtime data -- history, projects,
    # sessions, cache, plugins, ...) into ~/.claude/. Only config meant to apply
    # to every project on this machine belongs in claude-global/; anything
    # specific to working on this dotfiles repo (e.g. .claude/settings.local.json,
    # .claude/settings.json) stays in .claude/ and is picked up automatically as
    # this project's own settings, without ever being symlinked to $HOME.
    #
    # Directories are linked as well as files, so config that Claude Code reads
    # from a directory (rules/, agents/, commands/, skills/, output-styles/,
    # workflows/) can be tracked just by adding it here. Note this cuts both
    # ways: whatever lands in ~/.claude/<name> is written straight into the repo,
    # so directories Claude Code *accumulates state* in -- agent-memory/ in
    # particular -- must stay out of claude-global/.
    local claude_dir="$DOTFILES_DIRECTORY/claude-global"
    if [ -d "$claude_dir" ]; then
        mkdir -p "${HOME}/.claude"
        for claude_entry in "$claude_dir"/*; do
            # Guards the unmatched glob, which stays literal when the dir is empty
            [ -e "$claude_entry" ] || continue
            link_dotfile "$claude_entry" "${HOME}/.claude/$(basename "$claude_entry")"
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

    # Same per-file treatment for tmux: ~/.config/tmux also holds tpm's plugin
    # checkouts, which must stay untracked.
    #
    # Clear the two ~/.tmux* entries left behind by the older layout first.
    # tmux searches ~/.tmux.conf *before* ~/.config/tmux/tmux.conf, so a stale
    # one keeps winning and the move would silently have no effect.
    for stale in "${HOME}/.tmux.conf" "${HOME}/.tmuxline_snapshot.conf"; do
        if [ -L "$stale" ]; then
            rm -v "$stale"
        elif [ -e "$stale" ]; then
            mkdir -p "$BACKUP_DIR"
            mv -v "$stale" "$BACKUP_DIR/"
        fi
    done
    mkdir -p "${HOME}/.config/tmux"
    link_dotfile "$DOTFILES_DIRECTORY/tmux.conf" "${HOME}/.config/tmux/tmux.conf"

    # Symlink the whole nvim/ directory as one unit, unlike the per-file
    # treatment above -- Neovim's XDG layout keeps all plugin/cache/state data
    # under ~/.local/share/nvim and ~/.local/state/nvim, never inside
    # ~/.config/nvim itself, so nothing untracked can ever need to coexist
    # there the way Claude Code's or lazygit's runtime data does.
    mkdir -p "${HOME}/.config"
    link_dotfile "$DOTFILES_DIRECTORY/nvim" "${HOME}/.config/nvim"

    # Make this script runnable from anywhere as `dotfiles`. ~/.local/bin is
    # already first on PATH via .zshenv, so this needs no PATH change -- and
    # unlike a shell alias it works from non-interactive shells too.
    mkdir -p "${HOME}/.local/bin"
    link_dotfile "$DOTFILES_DIRECTORY/install.sh" "${HOME}/.local/bin/dotfiles"

    if [ -d "$BACKUP_DIR" ]; then
        echo "Backed up pre-existing files to $BACKUP_DIR"
    fi
}

# Config git to use new global gitignore file. Quoted so the shell doesn't
# expand the tilde before git sees it -- git expands ~/ itself when reading
# config, so this stays portable across machines/usernames instead of
# baking in an absolute path
step_git() {
    # shellcheck disable=SC2088
    git config --global core.excludesfile '~/.gitignore_global'
}

# Install/sync lazy.nvim-managed Neovim plugins, if nvim is installed. Runs
# headless so a fresh machine bootstraps fully non-interactively -- no
# manual :Lazy sync needed on a new box.
step_neovim() {
    if command -v nvim >/dev/null 2>&1; then
        nvim --headless "+Lazy! sync" +qa
    fi
}

# Change shell to zsh if not changed already. chsh requires the target to
# be listed in /etc/shells -- true automatically for the system zsh, but
# not for one just brewed above, so check first rather than hard-failing
# under set -e; fixing /etc/shells needs sudo, too invasive to do silently.
step_shell() {
    local zsh_bin
    zsh_bin="$(command -v zsh)"
    if [ "$SHELL" != "$zsh_bin" ]; then
        if grep -qxF "$zsh_bin" /etc/shells 2>/dev/null; then
            chsh -s "$zsh_bin"
        else
            echo "NOTE: $zsh_bin isn't listed in /etc/shells, so chsh was skipped." >&2
            echo "Run: sudo sh -c \"echo $zsh_bin >> /etc/shells\" && chsh -s $zsh_bin" >&2
        fi
    fi
}

# Prints the header comment above (lines 3-23) as the usage text, so the
# two can't drift apart. Keep the range in step if that block moves.
usage() {
    sed -n '3,23p' "$0" | sed 's/^# \{0,1\}//'
}

list_steps() {
    local step
    echo "Steps, in the order a full run executes them:"
    for step in "${STEPS[@]}"; do
        printf '  %-11s %s\n' "$step" "$(step_description "$step")"
    done
}

is_valid_step() {
    local candidate="$1" step
    for step in "${STEPS[@]}"; do
        [ "$step" = "$candidate" ] && return 0
    done
    return 1
}

run_step() {
    echo "==> $1: $(step_description "$1")"
    "step_$1"
}

main() {
    local requested=()
    local arg step

    for arg in "$@"; do
        case "$arg" in
            -h|--help) usage; return 0 ;;
            -l|--list) list_steps; return 0 ;;
            -*)
                echo "Unknown option: $arg" >&2
                echo "Try --help." >&2
                return 1
                ;;
            *)
                if ! is_valid_step "$arg"; then
                    echo "Unknown step: $arg" >&2
                    echo "Valid steps: ${STEPS[*]}" >&2
                    return 1
                fi
                requested+=("$arg")
                ;;
        esac
    done

    # No steps named: run them all, in STEPS order.
    if [ ${#requested[@]} -eq 0 ]; then
        requested=("${STEPS[@]}")
    fi

    for step in "${requested[@]}"; do
        run_step "$step"
    done
}

main "$@"
