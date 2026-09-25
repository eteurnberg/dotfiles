# Zsh (oh-my-zsh) configuration by Emil Teurnberg

# Powerlevel10k instant prompt: replays a cached prompt before the rest of this
# file runs, so the shell is usable immediately rather than after oh-my-zsh
# finishes. Must stay at the very top, and anything above it that writes to the
# console or reads input breaks it -- p10k says so on startup when that happens.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Machine/personal-specific values (emails, tokens, etc.) not tracked in the
# dotfiles repo. See .zshrc.local.example for the expected shape.
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# The theme to use. Look in: ~/.oh-my-zsh/themes/
ZSH_THEME="powerlevel10k/powerlevel10k"
DEFAULT_USER="$USER"

# Disables setting auto titles for terminal window.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git npm tmux colored-man-pages docker docker-compose ng web-search kubectl vi-mode
  dotnet rust history-substring-search extract fzf
  zsh-completions you-should-use zsh-autosuggestions zsh-syntax-highlighting)

# User configuration

# The dotfiles repo itself. :A resolves ~/.zshrc through its symlink to the
# repo checkout, then :h takes the containing directory.
export DOTFILES_REPO=${${(%):-%N}:A:h}

source $ZSH/oh-my-zsh.sh

# Use the SDK's generated completion (written by `dotfiles completions`) rather
# than the oh-my-zsh dotnet plugin's. Has to come after oh-my-zsh, which
# registers the plugin's version after compinit. False until that step has run.
(( $+functions[_dotnet] )) && compdef _dotnet dotnet

# Per-directory node versions from .nvmrc/.node-version. --use-on-cd replaces
# the chpwd hook nvm needed, and recursive matches nvm's search of parent
# directories. Unlike that hook, fnm won't install a missing version for you.
command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd --version-file-strategy=recursive --shell zsh)"

# ALIASES. To see full list, run 'alias'

# Generic aliases
alias cl="clear"  # Short for clearing the terminal
alias cat="bat --paging=never"  # Syntax-highlighted, line-numbered cat; use `bat` directly for paging
alias ls="eza --icons=auto"  # Git-aware, colorized directory listing; use /bin/ls for the literal original
alias l="eza --icons=auto -lah"    # Was oh-my-zsh's l='ls -lah'; explicit, doesn't rely on ls-alias chaining
alias ll="eza --icons=auto -lh"    # Was oh-my-zsh's ll='ls -lh'
alias la="eza --icons=auto -lAh"   # Was oh-my-zsh's la='ls -lAh'
alias lsa="eza --icons=auto -lah"  # Was oh-my-zsh's lsa='ls -lah' (identical to l, kept for parity)
alias pwdtree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'" # Prints a visual depiction of the directory tree from current dir

# OS X specific alias
alias brewup="brew update && brew upgrade"

# Project specific aliases
alias cdot="cd $DOTFILES_REPO" # Goes to the project folder for all dotfiles

# TOOL SPECIFIC
# Rust
alias cnbin="cargo new --bin"
alias cnlib="cargo new"
alias cb="cargo build"
alias cr="cargo run"

# Node/NPM
alias npmrs="npm run serve"

# Docker
alias dockerka='docker stop $(docker ps -a -q)'

# Powerlevel10k Config
# Still POWERLEVEL9K_* -- powerlevel10k kept the old parameter names, so this
# block is what powerlevel9k used, unchanged.

# Icon set. powerlevel9k was left at its default, which only has Powerline
# glyphs, so the vcs segment rendered without its branch icon. MesloLGS Nerd
# Font (Brewfile) is v3, matching what lazygit-config.yml already declares.
POWERLEVEL9K_MODE="nerdfont-v3"

# Icon spacing. Every icon string already ends in a space, and p10k adds
# another between a segment's icon and its content -- so left at the default
# each one renders two spaces wide. "none" strips the trailing space from the
# icons and lets p10k's single separator stand, which is what all four of
# powerlevel10k's own shipped configs do. The icons that genuinely need their
# own padding (the vcs branch/tag/commit icons, which butt up against the
# branch name rather than a separator) get it back from p10k regardless.
POWERLEVEL9K_ICON_PADDING=none

# Prompt segments
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator time)

# Segment customizations

POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
POWERLEVEL9K_SHORTEN_DELIMITER=""
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"

POWERLEVEL9K_STATUS_VERBOSE=false

POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'

# Reload this shell in place. Has to be a function, not a script -- a child
# process can't alter its parent's environment. exec replaces the current
# shell rather than nesting one; -l re-runs .zshenv/.zprofile/.zshrc.
reload () {
  exec zsh -l
}

# Weather service
wttr () {
  curl wttr.in/"$1"
}

# Custom commands for opening files in browsers
chrome () {
    open -a "Google Chrome" "$1"
}

firefox () {
    open -a "Firefox" "$1"
}

safari () {
    open -a "Safari" "$1"
}

dotnet() {
  if [[ "$1" == "ef" && "$PWD" == "$HOME/Dev/mavatar"(|/*) ]]; then
    command dotnet ef "${@:2}" \
      --project ./src/Infrastructure/ \
      --startup-project ./src/Api/
  else
    command dotnet "$@"
  fi
}

create_mimer_token() {
  if [ -z "${WORK_EMAIL:-}" ]; then
    echo "WORK_EMAIL is not set -- add it to ~/.zshrc.local" >&2
    return 1
  fi
  command mimer-token --org 1 --user 7 --email "$WORK_EMAIL" --role admin
}

