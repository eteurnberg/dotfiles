-- Replaces ALE's formatting half. <leader>f is defined here rather than
-- in lsp.lua's LspAttach so there's a single owner: conform routes to
-- the LSP formatter by default and to a real formatter where one is
-- configured. (A buffer-local LspAttach mapping would otherwise shadow
-- this global one on exactly the buffers that have an LSP attached.)
return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  -- Declared here rather than in config so the mapping exists from
  -- startup: config only runs once the plugin loads, and with the events
  -- above that wouldn't happen until a write, leaving <leader>f dead in a
  -- fresh session. lazy.nvim registers this stub immediately and loads
  -- conform on first press.
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format({ async = true, lsp_format = 'fallback' })
      end,
      mode = { 'n', 'x' },
      desc = 'Format buffer or selection',
    },
  },
  config = function()
    local conform = require('conform')

    conform.setup({
      formatters_by_ft = {
        -- prettier stays project-local (node_modules/.bin), same
        -- reasoning as eslint in lint.lua -- conform resolves it from
        -- the buffer's project automatically.
        yaml = { 'prettier' },
      },
      -- Everything not listed above formats via its LSP server, matching
      -- what <leader>f did before this stage. No format-on-save: the
      -- existing strip-trailing-whitespace autocmd is the only thing
      -- that touches buffers on write.
      default_format_opts = {
        lsp_format = 'fallback',
      },
    })
  end,
}
