-- Neovim configuration by Emil Teurnberg
-- Stage 1 of a staged Vim -> Neovim migration: full functional parity via
-- lazy.nvim, before any plugin swaps (see nvim/lua/plugins/*.lua and the
-- migration plan for what changes in later stages).

require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.lazy')
