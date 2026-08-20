-- Ported from .vimrc's "Key bindings"/"Searching" blocks. Leader-based
-- fugitive/rhubarb mappings live in plugins/fugitive.lua instead, since
-- they're plugin-specific and only make sense once that plugin loads.

local map = vim.keymap.set
local util = require('config.util')

map('i', 'jj', '<Esc>')
map('n', '<C-X>', ':tabn<CR>')
map('n', '<C-A>', ':tabp<CR>')
map('n', '<C-O>', 'o<Esc>k')
map('n', '<C-P>', 'O<Esc>j')
map('n', '<leader>sv', ':source $MYVIMRC<CR>')

map('n', '<F5>', util.strip_trailing_whitespace)
map('n', 'j', 'gj')
map('n', 'k', 'gk')

map('n', '<leader><space>', ':nohlsearch<CR>')
map('n', 'gV', '`[v`]')
