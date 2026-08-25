# My Dotfiles

Configuration for zsh (oh-my-zsh), Neovim, tmux, Ghostty and git, targeting
both macOS and Ubuntu. Kept public mainly for my own convenience, but you're
welcome to use them.

Tracked files are symlinked into place, so editing one here takes effect
immediately — no reinstall needed.

## Installing

Requires [Homebrew](https://brew.sh); everything else comes from the tracked
`Brewfile`. Without Homebrew that step is skipped and the packages have to be
installed by hand.

1. Clone this repo and `cd` into it.
2. Run `./install.sh`.

Backup anything you already have at the same paths first — existing real files
are moved to `~/.dotfiles_backup/<timestamp>`, but symlinks are overwritten.
`.gitconfig` carries my name and email, so change those.

## The `dotfiles` command

`install.sh` is an install-or-reload script: every step is idempotent, so
re-running is always safe. After the first run it's on `PATH` as `dotfiles`.

```sh
dotfiles              # run every step
dotfiles symlinks     # run one step, skipping the slow brew/Neovim ones
dotfiles --list       # show all steps
```

Re-run it after adding a new tracked file, or changing the `Brewfile` or
Neovim's plugin list.

## Reloading config in place

| Where | How |
|---|---|
| zsh | `reload` |
| Neovim | `<leader>sv` — options/keymaps/autocmds only; plugin changes need a restart |
| tmux | `prefix + r` |

## What's installed

Packages come from `Brewfile`: zsh, Neovim, tmux, git, plus
[delta](https://github.com/dandavison/delta) (git pager),
[lazygit](https://github.com/jesseduffield/lazygit),
[bat](https://github.com/sharkdp/bat),
[eza](https://github.com/eza-community/eza),
[ripgrep](https://github.com/BurntSushi/ripgrep),
[fd](https://github.com/sharkdp/fd),
[shellcheck](https://www.shellcheck.net),
[rumdl](https://github.com/rvben/rumdl),
[tree-sitter-cli](https://tree-sitter.github.io),
[Ghostty](https://ghostty.org) and the MesloLGS Nerd Font Mono font. A Nerd
Font is required for the icons and separators used by the shell prompt, tmux
status line, Neovim and lazygit.

`vim` is also installed, with a plugin-free `.vimrc` as a fallback for minimal
machines. Neovim is the real editor and is what `EDITOR` and git's
`core.editor` point at.

## Shell

| Alias | Runs |
|---|---|
| `cat` | `bat` — syntax-highlighted |
| `ls` `l` `ll` `la` | `eza` with icons, in varying detail |
| `cdot` | cd to this repo |
| `brewup` | update and upgrade Homebrew packages |
| `cl` | `clear` |
| `cb` `cr` `cnbin` `cnlib` | cargo build / run / new --bin / new |
| `dockerka` | stop all running containers |

Machine-specific values (work email, tokens) go in `~/.zshrc.local`, which is
untracked — see `.zshrc.local.example`.

## Neovim

Lua config in `nvim/`, symlinked to `~/.config/nvim` and managed by
[lazy.nvim](https://github.com/folke/lazy.nvim). Leader is `Space`.

| Key | Does |
|---|---|
| `gd` `gy` `gi` `gr` | LSP: definition, type definition, implementation, references |
| `K` | hover docs (falls back to devdocs for c/rust/haskell) |
| `<leader>rn` `<leader>ca` | rename symbol, code action |
| `<leader>f` | format buffer or selection |
| `[g` `]g` | previous/next diagnostic |
| `<leader>ff` `<leader>fg` `<leader>fb` `<leader>fh` | find files, live grep, buffers, help |
| `<leader>gs` `<leader>gd` `<leader>gb` `<leader>gl` | git status, diff, blame, log |
| `<leader>gh` | open current file/lines on GitHub |
| `jj` | escape to normal mode |
| `<C-x>` `<C-a>` | next/previous tab |
| `<F5>` | strip trailing whitespace |

LSP servers (`ts_ls`, `omnisharp`, `jsonls`) install themselves via
[mason.nvim](https://github.com/mason-org/mason.nvim) on first use.
Linting runs automatically for shell and markdown; formatting is on demand
only, never on save.

## tmux

Prefix is `C-q`. Plugins are managed by tpm; press `prefix + I` to install
them on a new machine.

| Key | Does |
|---|---|
| `prefix + \|` / `prefix + -` | split vertically / horizontally |
| `prefix + h/j/k/l` | move between panes |
| `prefix + H/J/K/L` | resize pane |
| `prefix + C-h` / `prefix + C-l` | previous/next window |
| `prefix + Escape` | copy mode (`v` select, `y` copy) |

Sessions are saved and restored automatically across reboots.

## Markdown

`rumdl check .` lints, `rumdl fmt` auto-fixes. Rules are configured in
`.rumdl.toml`.
