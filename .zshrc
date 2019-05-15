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
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git mercurial npm tmux colored-man-pages docker docker-compose)

# User configuration

# The absolute path of where this script is run
export SCRIPT_PATH=${0:a:h}

# $PATH variable config
# ---------------------

# Initial PATH. Normal bin locations in order of importance
export PATH="$HOME/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin"

# If on MacOS, add additional bin location in front (used by Brew)
# Useful to avoid locked down bin locations in MacOS
# Also add GNU grep tools to path, instead of standard. Downloaded using brew
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH="/usr/local/bin:$PATH"
  export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"
fi

# Add Cargo to the path (for Rust and associated tools)
export PATH="$HOME/.cargo/bin:$PATH"

# Add Anaconda3 python install location to path
# export PATH="$HOME/anaconda3/bin:$PATH"  # commented out by conda initialize

# Set Java version used to Java 8 and add it to path
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
export PATH=${JAVA_HOME}/bin:$PATH

source $ZSH/oh-my-zsh.sh

# Set default editor to vim
export EDITOR='vim'

# Loading nvm (node version manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Call nvm use with correct version when .nvmrc is present in a directory
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc   

# ALIASES. To see full list, run 'alias'

# Generic aliases
alias cl="clear"  # Short for clearing the terminal
alias pwdtree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'" # Prints a visual depiction of the directory tree from current dir
alias ssh-restart="eval \"\$(ssh-agent)\" && ssh-add" # When theres an issue with the ssh-agent, restart it and prompt for password again

# OS X specific alias
alias brewup="brew update && brew upgrade"

# Project specific aliases
alias dotfiles="cd $SCRIPT_PATH" # Goes to the project folder for all dotfiles 

# TOOL SPECIFIC
# Rust
alias cnbin="cargo new --bin"
alias cnlib="cargo new"
alias cb="cargo build"
alias cr="cargo run"

# Octave
alias octave="/usr/local/octave/3.8.0/bin/octave-3.8.0 ; exit;"

# Docker
alias dockerka='docker stop $(docker ps -a -q)'

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

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/emil.teurnberg/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/emil.teurnberg/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/emil.teurnberg/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/emil.teurnberg/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/emil.teurnberg/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/emil.teurnberg/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/emil.teurnberg/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/emil.teurnberg/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
