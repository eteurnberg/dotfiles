-- Supersedes pangloss/vim-javascript outright -- treesitter's JS/TS
-- grammar is a strict upgrade over a syntax-only classic plugin.
--
-- Tracks the `main` branch, not `master`: upstream froze `master` for
-- backward compatibility only and states it does not support Neovim
-- 0.12. Running it here anyway broke markdown injection queries (as used
-- by LSP hover floats) because `master` predates Neovim's change to pass
-- directives a list of nodes per capture rather than a single node.
--
-- `main`'s API is quite different from `master`'s: no
-- nvim-treesitter.configs.setup, parsers come from install(), and
-- highlighting/indentation are enabled per-buffer by Neovim itself.
-- Lazy-loading is explicitly unsupported, hence lazy = false.
local languages = {
  'javascript', 'typescript', 'tsx', 'html', 'css', 'bash', 'rust',
  'c', 'lua', 'vim', 'vimdoc', 'markdown', 'markdown_inline', 'yaml',
  'json', 'c_sharp',
}

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter').install(languages)

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
      callback = function(args)
        -- Filetype and parser name don't always match (e.g. cs ->
        -- c_sharp), so let Neovim resolve the language and bail quietly
        -- when there's no parser installed for this buffer.
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang or not vim.treesitter.language.add(lang) then
          return
        end
        vim.treesitter.start(args.buf, lang)
        -- Indentation is still flagged experimental upstream; enabled
        -- here to match the previous master-branch config's indent.enable.
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
