# Zsh (oh-my-zsh) configuration by Emil Teurnberg

# For terminal to support 256 colors
export TERM="xterm-256color"

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# The theme to use. Look in: ~/.oh-my-zsh/themes/
ZSH_THEME="powerlevel9k/powerlevel9k"
DEFAULT_USER="$USER"

# Disables setting auto titles for terminal window.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git npm tmux colored-man-pages)

# User configuration

# The absolute path of where this script is run
export SCRIPT_PATH=${0:a:h}

# PATH Variable, order is important. optional python path added, OSX only.
export PATH="/usr/local/opt/python/libexec/bin:$HOME/.cargo/bin:$HOME/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin"

# Set java version to 8
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
export PATH=${JAVA_HOME}/bin:$PATH

# path to avoid apples locked down usr/bin
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH="/usr/local/bin:$PATH"
fi

source $ZSH/oh-my-zsh.sh

# Set default editor to vim
export EDITOR='vim'

# Loading nvm (node version manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# ALIASES. To see full list, run 'alias'

# Generic aliases
alias cl="clear"  # Short for clearing the terminal
alias pwdtree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'" # Prints a visual depiction of the directory tree from current dir
alias ssh-restart="eval \"\$(ssh-agent)\" && ssh-add" # When theres an issue with the ssh-agent, restart it and prompt for password again

# Project specific aliases
alias dotfiles="cd $SCRIPT_PATH" # Goes to the project folder for all dotfiles 

# Tool specific aliases
alias cnbin="cargo new --bin"
alias cnlib="cargo new"
alias cb="cargo build"
alias cr="cargo run"

alias octave="/usr/local/octave/3.8.0/bin/octave-3.8.0 ; exit;"

# Powerlevel9k Config
# Prompt segments
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator time)

# Segment customizations

POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
POWERLEVEL9K_SHORTEN_DELIMITER=""
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"

POWERLEVEL9K_STATUS_VERBOSE=false

POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'

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
