# My Dotfiles

Configuration for zsh (oh-my-zsh), Neovim, tmux, Ghostty and git, targeting
both macOS and Ubuntu. Kept public mainly for my own convenience, but you're
welcome to use them.

Tracked files are symlinked into place, so editing one here takes effect
immediately — no reinstall needed.

## Installing

1. Clone this repo and `cd` into it.
2. Run `./install.sh`.

The first step installs [Homebrew](https://brew.sh) if it isn't there already;
everything else comes from the tracked `Brewfile`. That step is the one place
this may ask for a password.

Backup anything you already have at the same paths first — existing real files
are moved to `~/.dotfiles_backup/<timestamp>`, but symlinks are overwritten.
`.gitconfig` carries my name and email, so change those — or leave them and put
your own in `~/.gitconfig.local`, which is untracked and included last. See
`.gitconfig.local.example`.

Two further steps are opt-in and never part of a full run:

```sh
dotfiles apps    # GUI applications, from Brewfile.apps
dotfiles macos   # macOS system settings
```

## The `dotfiles` command

`install.sh` is an install-or-reload script: every step is idempotent, so
re-running is always safe. After the first run it's on `PATH` as `dotfiles`.

```sh
dotfiles              # run every step
dotfiles symlinks     # run one step, skipping the slow brew/Neovim ones
dotfiles --list       # show all steps, including the optional ones
```

Re-run it after adding a new tracked file, or changing the `Brewfile` or
Neovim's plugin list.

`apps` and `macos` are left out of a full run and only happen when named:
`apps` pulls down many GB of applications, and `macos` rewrites system settings
and restarts Dock and Finder — neither belongs in the step you run to pick up a
new dotfile.

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
[fzf](https://github.com/junegunn/fzf),
[fnm](https://github.com/Schniz/fnm) (node versions),
[gh](https://cli.github.com),
[mas](https://github.com/mas-cli/mas),
[shellcheck](https://www.shellcheck.net),
[rumdl](https://github.com/rvben/rumdl),
[tree-sitter-cli](https://tree-sitter.github.io),
[jq](https://jqlang.github.io/jq/),
[terminal-notifier](https://github.com/julienXX/terminal-notifier),
[Claude Code](https://claude.com/claude-code),
[Ghostty](https://ghostty.org) and the MesloLGS Nerd Font Mono font. A Nerd
Font is required for the icons and separators used by the shell prompt, tmux
status line, Neovim and lazygit.

Also [azure-cli](https://learn.microsoft.com/cli/azure/),
[pandoc](https://pandoc.org) and [tectonic](https://tectonic-typesetting.github.io)
(pandoc's PDF engine), and the [.NET SDK](https://dotnet.microsoft.com), which
the `dotnet` shell function, the oh-my-zsh `dotnet` plugin and `dotfiles
completions` all shell out to.

`vim` is also installed, with a plugin-free `.vimrc` as a fallback for minimal
machines. Neovim is the real editor and is what `EDITOR` and git's
`core.editor` point at.

GUI applications live in a separate `Brewfile.apps` — browsers, editors,
1Password, Alfred, OrbStack, Spotify and so on. They are installed only by
`dotfiles apps`, so a machine that just needs a terminal never pulls them down.

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

`dotfiles completions` generates tab completions into
`~/.oh-my-zsh/custom/completions` and clears the completion cache, so run
`reload` afterwards. Currently just `dotnet`, which needs the .NET 10 SDK;
re-run it after an SDK upgrade to pick up new commands and flags.

Node versions come from [fnm](https://github.com/Schniz/fnm), which switches on
`cd` based on `.nvmrc`, `.node-version` or `package.json`, searching parent
directories. Unlike the nvm hook this replaced, fnm will *not* install a
version it doesn't have — it says so and you run `fnm install`. Coming from
nvm, install your versions once (`fnm install 24 && fnm default 24`); `~/.nvm`
can then be deleted.

Machine-specific values (work email, tokens) go in `~/.zshrc.local`, which is
untracked — see `.zshrc.local.example`. Git identity works the same way:
`~/.gitconfig.local` is included last by `.gitconfig`, so a `[user]` block
there overrides the tracked default, and an `includeIf` scopes a work email to
one directory tree without putting the employer's name in this repo. See
`.gitconfig.local.example`.

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
| `notify.sh` | Desktop notification when Claude wants input (`terminal-notifier`, or `notify-send` on Linux) |

Notifications are built from the hook payload and the session transcript, so
each one names the session, the repo and branch it belongs to, and what is
actually being asked — the pending command for a permission prompt, Claude's
last message when a session goes idle. They are grouped by session id, so a
session replaces its own previous notification instead of stacking, and inside
tmux clicking one focuses the pane it came from.

Because the body can quote repo content, set *System Settings → Notifications →
Show previews* to *When Unlocked* if the machine is ever left on a lock screen
others can see.

`terminal-notifier`'s bottle is adhoc-signed, so macOS denies it notification
permission until its app bundle has been registered with Launch Services and
launched once. `dotfiles packages` does that. If notifications never appear,
run that step again, then check *System Settings → Notifications →
terminal-notifier*.

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

## macOS settings

`macos/defaults.sh` holds the system settings this machine wants — dark mode,
Dock size and autohide, tap-to-click off, key repeat, Finder view, where
screenshots go. `dotfiles macos` applies them all; the script also runs
standalone with a few more options:

```sh
./macos/defaults.sh --diff        # report differences, change nothing
./macos/defaults.sh --list        # list the setting groups
./macos/defaults.sh dock finder   # apply only the named group(s)
./macos/defaults.sh --no-restart  # apply without restarting Dock/Finder
```

Start with `--diff`. It compares every setting against the live machine and
writes nothing, which is also how a setting changed by hand in System Settings
gets noticed and folded back into the script. Applying is idempotent: only
settings that actually differ are written, and Dock, Finder, WindowManager and
ControlCenter are restarted only when one of their own settings changed.

Two caveats worth knowing. **Quit System Settings first** — it caches these
domains and writes its copy back when it closes, silently undoing the script.
And appearance, keyboard, pointer and trackpad settings are only read at login,
so those need a logout rather than a restart; the script says so when it has
written one.

## Manual setup

What a new machine still needs by hand.

Needs `sudo`:

| What | How |
|---|---|
| Touch ID for `sudo` | Copy `/etc/pam.d/sudo_local.template` to `sudo_local` and uncomment the `pam_tid.so` line. Survives OS updates, unlike editing `/etc/pam.d/sudo` |
| Touch ID inside tmux | `brew install pam-reattach`, then add `auth optional /opt/homebrew/lib/pam/pam_reattach.so` *above* the `pam_tid.so` line — without it Touch ID never fires in a tmux pane |
| Computer name | `scutil --set ComputerName`, `--set LocalHostName`, `--set HostName` |
| Time zone | `systemsetup -settimezone Europe/Stockholm` — also needs the calling terminal to hold Full Disk Access |
| Rosetta | `softwareupdate --install-rosetta --agree-to-license` |

Not scriptable, or not reliably:

- iCloud sign-in, and any app licence or login.
- Full Disk Access and other privacy grants — these gate the terminal itself,
  so they cannot be granted from it.
- Keyboard layouts. `AppleEnabledInputSources` is writable, but the input
  system caches it and frequently reverts; set them in System Settings.
- Firewall and Gatekeeper. `socketfilterfw` is deprecated and
  `spctl --master-disable` is refused on recent macOS; both are MDM or GUI only.

## Markdown

`rumdl check .` lints, `rumdl fmt` auto-fixes. Rules are configured in
`.rumdl.toml`.
