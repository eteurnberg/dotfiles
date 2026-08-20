-- Stage 4 replaces this with nvim-lint + conform.nvim
return {
  'w0rp/ale',
  lazy = false,
  init = function()
    vim.g.ale_linters = {
      javascript = { 'eslint' },
      html = { 'HTMLHint' },
      bash = { 'shellcheck' },
      rust = { 'rustc' },
      text = { 'vale' },
      markdown = { 'vale' },
      latex = { 'vale' },
      yaml = { 'prettier' },
    }
  end,
}
