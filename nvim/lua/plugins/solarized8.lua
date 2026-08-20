-- Stage 2 replaces this with maxmx03/solarized.nvim (a Lua-native port
-- with tuned treesitter/LSP highlight groups)
return {
  'lifepillar/vim-solarized8',
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.termguicolors = true
    vim.o.background = 'dark'
    vim.cmd.colorscheme('solarized8')
  end,
}
