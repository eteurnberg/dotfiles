-- Ported from .vimrc's "File-type specific settings" block. The
-- plugin-devdocs augroup lives in plugins/devdocs.lua instead, since its
-- keymap depends on rhysd/devdocs.vim being loaded.

local util = require('config.util')

local strip_trailing_group = vim.api.nvim_create_augroup('strip-trailing', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  group = strip_trailing_group,
  pattern = {
    '*.php', '*.js', '*.jsx', '*.html', '*.txt', '*.md', '*.java',
    '*.py', '*.c', '*.cpp', '*.css', '*.scss', '.vimrc', '.zshrc',
  },
  callback = util.strip_trailing_whitespace,
})

local git_commit_group = vim.api.nvim_create_augroup('wrap-git-commit-lines', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = git_commit_group,
  pattern = 'gitcommit',
  callback = function()
    vim.opt_local.textwidth = 72
  end,
})
