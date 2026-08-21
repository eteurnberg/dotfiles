-- Supersedes pangloss/vim-javascript outright -- treesitter's JS/TS
-- grammar is a strict upgrade over a syntax-only classic plugin.
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'master',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = {
        'javascript', 'typescript', 'tsx', 'html', 'css', 'bash', 'rust',
        'c', 'lua', 'vim', 'vimdoc', 'markdown', 'markdown_inline', 'yaml',
        'json', 'c_sharp',
      },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
