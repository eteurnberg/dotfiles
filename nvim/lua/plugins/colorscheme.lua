-- Replaces lifepillar/vim-solarized8: a Lua-native port with tuned
-- treesitter/LSP/gitsigns/lualine highlight groups, still genuinely
-- Solarized Dark -- look and feel preserved, correctness improved.
return {
  'maxmx03/solarized.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.termguicolors = true
    vim.o.background = 'dark'
    require('solarized').setup()
    vim.cmd.colorscheme('solarized')
  end,
}
