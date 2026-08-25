# Baseline shell/editor/multiplexer/vcs tools (assumed pre-existing before
# this change; git is even needed to clone this repo in the first place --
# kept here so a Homebrew-managed version is what ends up on PATH)
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

# nvim-treesitter's main branch generates parsers with the tree-sitter CLI
# at install/update time. Note this is a different formula from the
# `tree-sitter` library (which Neovim already pulls in as a dependency and
# which ships no binary); upstream also specifically wants the package
# manager build here, not the npm one.
brew "tree-sitter-cli"

# Shell linting, wired up in nvim via nvim-lint. ALE nominally had this
# configured for years but shellcheck was never actually installed, so it
# had never once run until now.
brew "shellcheck"

# Recommended, but no tracked config depends on them
brew "ripgrep"
brew "fd"

# GUI terminal emulator
cask "ghostty"    # ghostty-config is symlinked to ~/.config/ghostty/config

# Nerd Font, for icons in eza/lazygit and Powerline-style separators in
# tmux/vim-airline/the zsh prompt (superset of the plain Powerline fonts
# already cloned by install.sh -- no regression for either existing use)
cask "font-meslo-lg-nerd-font"
