# My Dotfiles
My configuration files. I use zshell with oh-my-zsh, vim and tmux. The goal is for these files to work on both OS X and Ubuntu. These are mainly kept here to be accessible to myself, but you are welcome to use and try them if you like.

## Prerequisites
[Homebrew](https://brew.sh) needs to be installed already. Given that, running `install.sh` installs everything else automatically from the tracked `Brewfile`: zsh, vim, tmux, git, [delta](https://github.com/dandavison/delta), [lazygit](https://github.com/jesseduffield/lazygit), [bat](https://github.com/sharkdp/bat), [eza](https://github.com/eza-community/eza), [ripgrep](https://github.com/BurntSushi/ripgrep), [fd](https://github.com/sharkdp/fd), [Ghostty](https://ghostty.org) and the MesloLGS Nerd Font Mono font. Without Homebrew, install these manually via your system's package manager instead -- `install.sh` skips the Brewfile step entirely if `brew` isn't on `PATH`.

`.gitconfig` sets `core.pager = delta`, so git diff output fails to render without git-delta. `.zshrc` aliases `cat` to `bat` and `ls`/`l`/`ll`/`la`/`lsa` to `eza`, so those break without their respective tools. ripgrep and fd (`rg`, `fd`) are just recommended -- no tracked config depends on them.

For the agnoster theme in oh-my-zsh to work properly, patched fonts are needed. `install.sh` clones and installs [Powerline-fonts](https://github.com/powerline/fonts) automatically.

`ghostty-config` is symlinked to `~/.config/ghostty/config`, sets the Solarized Dark theme to match vim/tmux/delta, and pins the Nerd Font installed via the `Brewfile` -- a superset of the plain Powerline fonts, so it also covers the separator glyphs tmux's status bar and the zsh prompt already relied on, plus unlocks the file/git icons `eza --icons=auto`, `lazygit-config.yml` (`gui.showIcons`) and the Neovim statusline now use.

## Neovim
`nvim/` is a Lua config (`install.sh` symlinks the whole directory to `~/.config/nvim`) managed by [lazy.nvim](https://github.com/folke/lazy.nvim), which `install.sh` also bootstraps and syncs headlessly. This is a staged migration away from classic `vim`/Vundle -- `vim` stays installed and fully working throughout as a fallback (and will remain one, trimmed to a zero-dependency config, once the migration finishes).

Current look and feel: [solarized.nvim](https://github.com/maxmx03/solarized.nvim) (Solarized Dark, same as before) with [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) for the statusline and [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) for git change signs -- replacing vim-solarized8/vim-airline/vim-gitgutter respectively, with the same visual intent. [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) provides syntax highlighting; [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (fuzzy find, `<leader>ff`/`<leader>fg`/`<leader>fb`/`<leader>fh`) and [which-key.nvim](https://github.com/folke/which-key.nvim) (keybind discovery popup) are new capability with no new external dependencies (telescope's `ripgrep`/`fd` are already in the `Brewfile`). The leader key is space, not Vim's default backslash. coc.nvim and ALE are still used unchanged for completion/LSP and linting -- ported as-is from `.vimrc`, not yet modernized.

## Installing
_NOTE:_ Backup any dotfiles you already have before installing. The symlinking will remove any files you might already have with the same names.
The .gitconfig file is setup to use my user name and email, you will want to change this.
1. Clone this repo and `cd` into it.
2. Run install.sh, you might have to run it as root.

To update, pull the repo and run install.sh again.
