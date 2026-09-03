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
[jq](https://jqlang.github.io/jq/),
[Claude Code](https://claude.com/claude-code),
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

Config lives at `~/.config/tmux/tmux.conf` and needs tmux 3.5 or newer.
Prefix is `C-q`. Plugins are managed by tpm and installed by `./install.sh`.

| Key | Does |
|---|---|
| `prefix + \|` / `prefix + -` | split horizontally / vertically, in the current directory |
| `prefix + c` | new window, in the current directory |
| `prefix + h/j/k/l` | move between panes |
| `prefix + H/J/K/L` | resize pane |
| `prefix + C-h` / `prefix + C-l` | previous/next window |
| `prefix + Escape` | copy mode (`v` select, `C-v` rectangle, `y` copy, `Escape` exit) |
| `prefix + g` | lazygit in a popup |
| `prefix + ?` | list every binding, with descriptions |

Copying in copy mode puts the text on the system clipboard, over SSH too.
`prefix + C` opens tmux's own settings browser.

Sessions are saved by tmux-resurrect and restored by tmux-continuum, both on
tmux start and after a reboot.

## Claude Code

User-level config lives in `claude-global/`, whose contents are symlinked
individually into `~/.claude/`.

| File | Does |
|---|---|
| `CLAUDE.md` | Personal defaults loaded in every project |
| `settings.json` | Model, effort level, theme, status line and the notification hook |
| `statusline-command.sh` | Status line: model, directory, git branch, context used |
| `notify.sh` | Desktop notification when Claude wants input (`osascript` or `notify-send`) |

Both directories and files are linked, so tracking a new surface —
`rules/`, `agents/`, `commands/`, `skills/`, `output-styles/`, `workflows/` —
is a matter of adding it to `claude-global/` and running `dotfiles symlinks`.

Nothing else under `~/.claude` is tracked, and deliberately so: session
transcripts, caches, plugin checkouts and `~/.claude.json` are runtime state,
and the last of those holds the signed-in account and machine identifiers.
Project-scoped settings for this repo stay in `.claude/settings.json`;
`.claude/settings.local.json` is machine-local and excluded by
`.gitignore_global`.

Because `settings.json` is a symlink, anything changed through `/config` is
written straight back into the repo. If Claude Code ever replaces the symlink
with a regular file instead of writing through it, treat the repo copy as the
source of truth and re-run `dotfiles symlinks`.

## Markdown

`rumdl check .` lints, `rumdl fmt` auto-fixes. Rules are configured in
`.rumdl.toml`.
