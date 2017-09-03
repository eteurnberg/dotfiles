# Zsh (oh-my-zsh) configuration by Emil Teurnberg

# For terminal to support 256 colors
export TERM="xterm-256color"

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Look in ~/.oh-my-zsh/themes/
ZSH_THEME="powerlevel9k/powerlevel9k"
DEFAULT_USER="$USER"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

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


export PATH="$HOME/usr/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin"

source $ZSH/oh-my-zsh.sh

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# path to avoid apples locked down usr/bin
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH="/usr/local/bin:$PATH"
fi

# Set default editor to vim
export EDITOR='vim'

# For a full list of active aliases, run `alias`.
alias cl="clear"  # Short for clearing the terminal
alias pwdtree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'" # Prints a visual depiction of the directory tree from current dir
alias dotfiles="cd $SCRIPT_PATH && vim -p *.md *.sh .*" # Goes to the project folder for these files and opens all files
alias ssh-restart="eval \"\$(ssh-agent)\" && ssh-add" # When theres an issue with the ssh-agent, restart it and prompt for password again

# Alias for SH Project, depending on system
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias shproject="cd ~/Development/NodeJS/sh-project/"
fi
if [[ "$OSTYPE" != "darwin"* ]]; then
  alias shproject="cd ~/Development/sh-project/"
fi

# Powerlevel9k Config
# Prompt segments
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir rbenv vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status battery)

# Segment customizations
POWERLEVEL9K_BATTERY_LOW_THRESHOLD=15

POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
POWERLEVEL9K_SHORTEN_DELIMITER=""
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"

POWERLEVEL9K_STATUS_VERBOSE=false

POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'

# Custom commands for opening files in browsers
chrome () {
    open -a "Google Chrome" "$1"
}

safari () {
    open -a "Safari" "$1"
}
