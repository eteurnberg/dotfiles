-- New capability, not ported parity -- .vimrc never configured a fuzzy
-- finder. Zero new external dependencies: both hard deps (ripgrep, fd)
-- are already in the tracked Brewfile.
return {
  'nvim-telescope/telescope.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons' },
  lazy = false,
  config = function()
    require('telescope').setup()
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope: find files' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope: live grep' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope: buffers' })
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope: help tags' })
  end,
}
