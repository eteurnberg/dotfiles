-- Replaces vim-airline + vim-airline-themes. Theme name/options are
-- verified against the installed plugin after `Lazy sync` -- lualine
-- bundles many colorscheme-matching themes, but the exact key isn't
-- guessed here without checking.
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  lazy = false,
  config = function()
    require('lualine').setup({
      options = {
        theme = 'solarized_dark',
        globalstatus = true,
      },
    })
  end,
}
