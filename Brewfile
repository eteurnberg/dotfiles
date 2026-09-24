brew "git"
brew "zsh"
brew "vim"    # fallback only -- .vimrc is now plugin-free, see nvim/ for the real config
brew "tmux"
brew "neovim" # the primary editor; config lives in nvim/

# CLI tools this repo's tracked config depends on
brew "git-delta"  # .gitconfig sets core.pager = delta
brew "lazygit"    # lazygit-config.yml
brew "bat"        # .zshrc aliases cat -> bat
brew "eza"        # .zshrc aliases ls/l/ll/la/lsa -> eza
brew "fzf"        # .zshrc loads the oh-my-zsh fzf plugin
brew "fnm"        # .zshrc evals `fnm env` for per-directory node versions
brew "jq"         # used by claude setup, also general usage
brew "terminal-notifier"  # claude-global/notify.sh

# nvim-treesitter's main branch generates parsers with the tree-sitter CLI
# at install/update time. Note this is a different formula from the
# `tree-sitter` library (which Neovim already pulls in as a dependency and
# which ships no binary); upstream also specifically wants the package
# manager build here, not the npm one.
brew "tree-sitter-cli"

# Linters, wired up in nvim via nvim-lint
brew "shellcheck"  # shell
brew "rumdl"       # markdown

# Recommended, but no tracked config depends on them
brew "ripgrep"
brew "fd"
brew "gh"
brew "mas"       # installs Mac App Store apps from a Brewfile
brew "azure-cli"
brew "pandoc"    # document conversion; tectonic is its PDF engine
brew "tectonic"

# GUI terminal emulator
cask "ghostty"    # ghostty-config is symlinked to ~/.config/ghostty/config

# Claude Code; its user-level config is tracked in claude-global/
cask "claude-code"

# The dotnet oh-my-zsh plugin, .zshrc's dotnet wrapper and install.sh's
# completions step all shell out to this
cask "dotnet-sdk"

# Nerd Font, for icons in eza/lazygit and Powerline-style separators in
# tmux/vim-airline/the zsh prompt (superset of the plain Powerline fonts
# already cloned by install.sh -- no regression for either existing use)
cask "font-meslo-lg-nerd-font"
