-- Replaces ALE's linting half (conform.nvim in format.lua covers the
-- rest). ALE's linter table had gone stale: of javascript/html/bash/
-- rust/text/markdown/latex/yaml, not one of the underlying binaries was
-- installed, so none had actually run in a long time. Carried forward
-- here are only the ones that now genuinely work:
--   * shellcheck -- added to the Brewfile alongside this change
--   * eslint     -- deliberately NOT installed globally; resolved from
--                   the project's node_modules/.bin so its version stays
--                   whatever the project pins
-- Dropped as dead config rather than ported: htmlhint and vale (never
-- installed, not wanted), and rustc (no Rust toolchain on this machine
-- at all -- and no rust_analyzer either, so nothing silently replaces it).
-- yaml moved to conform.nvim, since prettier is a formatter, not a linter.
return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPost', 'BufWritePost' },
  config = function()
    local lint = require('lint')

    lint.linters_by_ft = {
      sh = { 'shellcheck' },
      bash = { 'shellcheck' },
      javascript = { 'eslint' },
      markdown = { 'rumdl' },
    }

    -- nvim-lint ships rumdl as stream = "stderr", but rumdl writes its JSON
    -- to stdout, so diagnostics never appear without this.
    lint.linters.rumdl.stream = 'stdout'

    -- Prefer a project-local eslint over a global one; without this
    -- nvim-lint just runs whatever bare `eslint` resolves to, which here
    -- is nothing at all.
    local eslint = lint.linters.eslint
    local function local_eslint()
      local found = vim.fs.find('node_modules/.bin/eslint', {
        upward = true,
        path = vim.fn.expand('%:p:h'),
        type = 'file',
      })[1]
      return found
    end

    local function try_lint()
      local names = lint.linters_by_ft[vim.bo.filetype] or {}
      local runnable = {}
      for _, name in ipairs(names) do
        if name == 'eslint' then
          local bin = local_eslint()
          if bin then
            eslint.cmd = bin
            table.insert(runnable, name)
          end
        elseif vim.fn.executable(lint.linters[name].cmd) == 1 then
          table.insert(runnable, name)
        end
      end
      -- Only run what's actually present -- nvim-lint otherwise reports a
      -- failure for every missing binary, which is exactly the noise
      -- ALE's stale config would have produced had it ever surfaced it.
      if #runnable > 0 then
        lint.try_lint(runnable)
      end
    end

    vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'InsertLeave' }, {
      group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
      callback = try_lint,
    })

    -- lazy.nvim loads this plugin *on* BufReadPost, so the autocmd above
    -- is registered a moment too late to catch the very event that
    -- triggered the load -- the first buffer opened would otherwise never
    -- be linted until it was written or left insert mode.
    vim.schedule(try_lint)
  end,
}
