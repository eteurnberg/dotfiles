-- Replaces coc.nvim for LSP. 1:1 server mapping from the old
-- g:coc_global_extensions: coc-tsserver -> ts_ls, coc-omnisharp ->
-- omnisharp, coc-json -> jsonls. ALE stays untouched (still covers
-- filetypes coc/LSP here never did).
return {
  {
    'mason-org/mason.nvim',
    lazy = false,
    config = function()
      require('mason').setup()
    end,
  },
  {
    'mason-org/mason-lspconfig.nvim',
    dependencies = { 'mason-org/mason.nvim', 'neovim/nvim-lspconfig' },
    lazy = false,
    config = function()
      local servers = { 'ts_ls', 'omnisharp', 'jsonls' }
      require('mason-lspconfig').setup({ ensure_installed = servers })
      vim.lsp.enable(servers)
    end,
  },
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    init = function()
      -- Ported from .vimrc's CoC block: navigation, rename, diagnostic
      -- nav, code actions, format. K is handled separately below --
      -- it needs the devdocs-fallback logic, not a plain LSP mapping.
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { buffer = args.buf }
          local map = vim.keymap.set
          map('n', 'gd', vim.lsp.buf.definition, opts)
          map('n', 'gy', vim.lsp.buf.type_definition, opts)
          map('n', 'gi', vim.lsp.buf.implementation, opts)
          map('n', 'gr', vim.lsp.buf.references, opts)
          map('n', '<leader>rn', vim.lsp.buf.rename, opts)
          map('n', '<leader>ca', vim.lsp.buf.code_action, opts)
          map({ 'n', 'x' }, '<leader>f', function()
            vim.lsp.buf.format({ async = true })
          end, opts)
        end,
      })

      vim.keymap.set('n', '[g', function() vim.diagnostic.jump({ count = -1 }) end, { silent = true })
      vim.keymap.set('n', ']g', function() vim.diagnostic.jump({ count = 1 }) end, { silent = true })

      -- Hover docs on K, falling back to plain K (devdocs.vim's
      -- buffer-local mapping, which takes priority when present) for
      -- filetypes without an attached hover-capable LSP client.
      vim.keymap.set('n', 'K', function()
        local clients = vim.lsp.get_clients({ bufnr = 0, method = 'textDocument/hover' })
        if #clients > 0 then
          vim.lsp.buf.hover()
        else
          vim.fn.feedkeys('K', 'in')
        end
      end, { silent = true })
    end,
  },
}
