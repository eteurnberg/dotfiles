# Baseline shell/editor/multiplexer/vcs tools (assumed pre-existing before
# this change; git is even needed to clone this repo in the first place --
# kept here so a Homebrew-managed version is what ends up on PATH)
brew "git"
brew "zsh"
brew "vim"
brew "tmux"

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
