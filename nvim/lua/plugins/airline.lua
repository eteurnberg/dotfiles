-- Stage 2 replaces this with lualine.nvim
return {
  'vim-airline/vim-airline',
  dependencies = { 'vim-airline/vim-airline-themes' },
  lazy = false,
  init = function()
    vim.g.airline_theme = 'solarized'
    vim.g.airline_solarized_bg = 'dark'
    vim.g.airline_powerline_fonts = 1
  end,
}
