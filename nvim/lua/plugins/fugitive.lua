-- No modern replacement -- kept as-is indefinitely (per the migration plan)
return {
  'tpope/vim-fugitive',
  dependencies = { 'tpope/vim-rhubarb' },
  lazy = false,
  init = function()
    local map = vim.keymap.set
    map('n', '<leader>gs', ':Git<CR>')
    map('n', '<leader>gd', ':Gdiffsplit<CR>')
    map('n', '<leader>gb', ':Git blame<CR>')
    map('n', '<leader>gl', ':Gclog<CR>')
    map({ 'n', 'x' }, '<leader>gh', ':GBrowse<CR>')
  end,
}
