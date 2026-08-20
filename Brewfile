# Baseline shell/editor/multiplexer/vcs tools (assumed pre-existing before
# this change; git is even needed to clone this repo in the first place --
# kept here so a Homebrew-managed version is what ends up on PATH)
brew "git"
brew "zsh"
brew "vim"    # kept as a fallback through the Neovim migration (see nvim/)
brew "tmux"
brew "neovim" # nvim/ -- migrating from vim/Vundle in stages, see the plan

# CLI tools this repo's tracked config depends on
brew "git-delta"  # .gitconfig sets core.pager = delta
brew "lazygit"    # lazygit-config.yml
brew "bat"        # .zshrc aliases cat -> bat
brew "eza"        # .zshrc aliases ls/l/ll/la/lsa -> eza

# Recommended, but no tracked config depends on them
brew "ripgrep"
brew "fd"

# GUI terminal emulator
cask "ghostty"    # ghostty-config is symlinked to ~/.config/ghostty/config

# Nerd Font, for icons in eza/lazygit and Powerline-style separators in
# tmux/vim-airline/the zsh prompt (superset of the plain Powerline fonts
# already cloned by install.sh -- no regression for either existing use)
cask "font-meslo-lg-nerd-font"
