-- Replaces airblade/vim-gitgutter. No prior gitgutter keymaps existed to
-- port -- defaults only.
return {
  'lewis6991/gitsigns.nvim',
  lazy = false,
  config = function()
    require('gitsigns').setup()
  end,
}
