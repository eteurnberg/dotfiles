# Sourced once per login shell -- for setup that forks a process (unlike
# .zshenv, which stays fast for every invocation) or only needs to run
# once per session. Runs after .zshenv, so anything prepended here ends up
# higher-priority than .zshenv's PATH.

# Homebrew environment (PATH, MANPATH, INFOPATH, etc.)
if [[ "$OSTYPE" == "darwin"* ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
fi

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
