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

      -- OmniSharp chooses which projects to load by scanning its own
      -- process cwd, ignoring the root_dir Neovim resolves -- `:h
      -- vim.lsp.ClientConfig` spells out that cmd_cwd is "Not related to
      -- root_dir". So opening a .cs file from anywhere other than the
      -- project directory attaches a server that silently resolves
      -- nothing: empty hover, no completion, no-op rename. Passing -s
      -- pins the scan to the detected root. The cmd function form is the
      -- documented hook that receives the resolved config (hence
      -- root_dir); everything else (filetypes/root_dir/settings) still
      -- comes from nvim-lspconfig's own omnisharp config.
      vim.lsp.config('omnisharp', {
        cmd = function(dispatchers, config)
          local cmd = {
            vim.fn.executable('OmniSharp') == 1 and 'OmniSharp' or 'omnisharp',
            '-z',
            '--hostPID',
            tostring(vim.fn.getpid()),
            'DotNet:enablePackageRestore=false',
            '--encoding',
            'utf-8',
            '--languageserver',
          }
          if config.root_dir then
            vim.list_extend(cmd, { '-s', config.root_dir })
          end
          return vim.lsp.rpc.start(cmd, dispatchers)
        end,
      })

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
          -- <leader>f intentionally lives in plugins/format.lua, not
          -- here: conform.nvim routes to this same LSP formatter via
          -- lsp_format='fallback', and a buffer-local mapping here would
          -- shadow conform's global one on every LSP-attached buffer.
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
