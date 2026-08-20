-- Stage 3 replaces this with nvim-lspconfig + mason.nvim + blink.cmp.
-- Kept as a bridge for now -- coc.nvim works unchanged under Neovim (its
-- own README supports Neovim >= 0.8.0), so there's no reason to rush the
-- highest-complexity swap in this migration.
return {
  'neoclide/coc.nvim',
  branch = 'release',
  lazy = false,
  init = function()
    vim.g.coc_global_extensions = { 'coc-tsserver', 'coc-omnisharp', 'coc-json' }
  end,
  config = function()
    local keyset = vim.keymap.set

    -- Tab to cycle the completion popup, Enter to confirm. This is
    -- coc.nvim's own documented Lua-config idiom (v:lua.<fn>() bridging
    -- into vimscript expr-mappings), not a improvisation.
    function _G.coc_check_back_space()
      local col = vim.fn.col('.') - 1
      return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
    end

    local expr_opts = { silent = true, expr = true, replace_keycodes = false }
    keyset('i', '<TAB>', [[coc#pum#visible() ? coc#pum#next(1) : v:lua.coc_check_back_space() ? "\<Tab>" : coc#refresh()]], expr_opts)
    keyset('i', '<S-TAB>', [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], expr_opts)
    keyset('i', '<CR>', [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>"]], expr_opts)

    -- Navigation
    keyset('n', 'gd', '<Plug>(coc-definition)', { silent = true })
    keyset('n', 'gy', '<Plug>(coc-type-definition)', { silent = true })
    keyset('n', 'gi', '<Plug>(coc-implementation)', { silent = true })
    keyset('n', 'gr', '<Plug>(coc-references)', { silent = true })

    -- Hover docs on K, falling back to plain K (e.g. devdocs.vim's
    -- buffer-local mapping, which takes priority when present) for
    -- filetypes without a coc extension/hover provider
    function _G.coc_show_documentation()
      if vim.fn.CocAction('hasProvider', 'hover') == 1 then
        vim.fn.CocActionAsync('doHover')
      else
        vim.fn.feedkeys('K', 'in')
      end
    end
    keyset('n', 'K', ':call v:lua.coc_show_documentation()<CR>', { silent = true })

    -- Rename symbol, jump between diagnostics, code actions, format selection
    keyset('n', '<leader>rn', '<Plug>(coc-rename)', {})
    keyset('n', '[g', '<Plug>(coc-diagnostic-prev)', { silent = true })
    keyset('n', ']g', '<Plug>(coc-diagnostic-next)', { silent = true })
    keyset('n', '<leader>ca', '<Plug>(coc-codeaction-cursor)', {})
    keyset('x', '<leader>f', '<Plug>(coc-format-selected)', {})
    keyset('n', '<leader>f', '<Plug>(coc-format-selected)', {})
  end,
}
