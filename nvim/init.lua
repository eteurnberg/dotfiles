-- Neovim configuration by Emil Teurnberg
-- Staged Vim -> Neovim migration -- see the migration plan for what
-- changes in each stage.

-- Must be set before any <leader> keymap is defined -- ours below, and
-- every plugin's own leader mappings set during require('config.lazy').
-- .vimrc never set this, so Vim's implicit default was backslash;
-- switched to space here, the modern convention.
vim.g.mapleader = ' '

require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.lazy')
