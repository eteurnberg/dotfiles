# Sourced for every zsh invocation (scripts, cron jobs, editor/IDE
# integrations, tmux status-line commands -- not just interactive shells),
# so this stays limited to PATH/env vars that are cheap to set and don't
# require running an external command. Setup that forks a process
# (Homebrew's shellenv, OrbStack's init) lives in .zprofile instead, since
# that only needs to run once per login; interactive-only setup (oh-my-zsh,
# nvm, aliases, functions) stays in .zshrc.
#
# typeset -U path keeps entries unique, as long as every later addition
# also uses array syntax (path=(...) / path+=(...)) rather than string
# concatenation (export PATH="dir:$PATH"), which bypasses the dedup.
typeset -U path

path=(
  $HOME/.local/bin
  $HOME/.cargo/bin
  $HOME/usr/bin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
  /opt/X11/bin
  $HOME/.dotnet/tools
  $path
)

if [[ "$OSTYPE" == "darwin"* ]]; then
  path=(/usr/local/bin $path)
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  path=(/snap/bin $path)
fi

export PATH
export EDITOR='nvim'
