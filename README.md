# My Dotfiles
My configuration files. I use zshell with oh-my-zsh, vim and tmux. The goal is for these files to work on both OS X and Ubuntu. These are mainly kept here to be accessible to myself, but you are welcome to use and try them if you like.

## Prerequisites
[Homebrew](https://brew.sh) needs to be installed already. Given that, running `install.sh` installs everything else automatically from the tracked `Brewfile`: zsh, vim, tmux, git, [delta](https://github.com/dandavison/delta), [lazygit](https://github.com/jesseduffield/lazygit), [bat](https://github.com/sharkdp/bat), [eza](https://github.com/eza-community/eza), [ripgrep](https://github.com/BurntSushi/ripgrep), [fd](https://github.com/sharkdp/fd), [Ghostty](https://ghostty.org) and the MesloLGS Nerd Font Mono font. Without Homebrew, install these manually via your system's package manager instead -- `install.sh` skips the Brewfile step entirely if `brew` isn't on `PATH`.

`.gitconfig` sets `core.pager = delta`, so git diff output fails to render without git-delta. `.zshrc` aliases `cat` to `bat` and `ls`/`l`/`ll`/`la`/`lsa` to `eza`, so those break without their respective tools. ripgrep and fd (`rg`, `fd`) are just recommended -- no tracked config depends on them.

For the agnoster theme in oh-my-zsh to work properly, patched fonts are needed. `install.sh` clones and installs [Powerline-fonts](https://github.com/powerline/fonts) automatically.

`ghostty-config` is symlinked to `~/.config/ghostty/config`, sets the Solarized Dark theme to match vim/tmux/delta, and pins the Nerd Font installed via the `Brewfile` -- a superset of the plain Powerline fonts, so it also covers the separator glyphs tmux's status bar and the zsh prompt already relied on, plus unlocks the file/git icons `eza --icons=auto`, `lazygit-config.yml` (`gui.showIcons`) and the Neovim statusline now use.

## Neovim
`nvim/` is a Lua config (`install.sh` symlinks the whole directory to `~/.config/nvim`) managed by [lazy.nvim](https://github.com/folke/lazy.nvim), which `install.sh` also bootstraps and syncs headlessly. This is a staged migration away from classic `vim`/Vundle -- `vim` stays installed and fully working throughout as a fallback (and will remain one, trimmed to a zero-dependency config, once the migration finishes).

Current look and feel: [solarized.nvim](https://github.com/maxmx03/solarized.nvim) (Solarized Dark, same as before) with [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) for the statusline and [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) for git change signs -- replacing vim-solarized8/vim-airline/vim-gitgutter respectively, with the same visual intent. [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) provides syntax highlighting; [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (fuzzy find, `<leader>ff`/`<leader>fg`/`<leader>fb`/`<leader>fh`) and [which-key.nvim](https://github.com/folke/which-key.nvim) (keybind discovery popup) are new capability with no new external dependencies (telescope's `ripgrep`/`fd` are already in the `Brewfile`). The leader key is space, not Vim's default backslash.

LSP/completion is native: [mason.nvim](https://github.com/mason-org/mason.nvim) + [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) install and enable `ts_ls`/`omnisharp`/`jsonls` (1:1 replacing coc.nvim's `coc-tsserver`/`coc-omnisharp`/`coc-json`), with [blink.cmp](https://github.com/saghen/blink.cmp) for completion. `gd`/`gy`/`gi`/`gr`/`<leader>rn`/`<leader>ca`/`[g`/`]g` all now come from `vim.lsp.buf.*`/`vim.diagnostic.*` rather than coc; `K` still checks for a hover-capable client first and falls back to devdocs.vim's buffer-local mapping otherwise, same logic as before.

Linting is [nvim-lint](https://github.com/mfussenegger/nvim-lint) and formatting ([`<leader>f`](#)) is [conform.nvim](https://github.com/stevearc/conform.nvim), replacing ALE. Only linters that are actually installed run: shellcheck (via the `Brewfile`) for shell, and eslint resolved from a project's own `node_modules/.bin` — never a global install, so a project's pinned version always wins. Anything without a configured formatter falls back to its LSP server's formatting, which is what `<leader>f` did before. Formatting is on demand only; nothing reformats on save.

ALE's old linter table listed html/rust/text/markdown/latex too, but none of those binaries were ever installed, so those linters had never actually run — they were dropped rather than ported.

## Installing
_NOTE:_ Backup any dotfiles you already have before installing. The symlinking will remove any files you might already have with the same names.
The .gitconfig file is setup to use my user name and email, you will want to change this.
1. Clone this repo and `cd` into it.
2. Run install.sh, you might have to run it as root.

To update, pull the repo and run install.sh again.
