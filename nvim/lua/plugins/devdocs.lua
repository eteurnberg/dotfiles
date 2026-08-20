-- No modern replacement -- kept as-is indefinitely (per the migration plan)
return {
  'rhysd/devdocs.vim',
  lazy = false,
  init = function()
    local group = vim.api.nvim_create_augroup('plugin-devdocs', { clear = true })
    -- Overrides K in these filetypes for devdocs lookup; javascript is
    -- handled by coc's hover instead (see plugins/coc.lua's K mapping,
    -- which falls back to a literal K keypress when coc has no hover
    -- provider -- buffer-local mappings like this one take priority).
    vim.api.nvim_create_autocmd('FileType', {
      group = group,
      pattern = { 'c', 'rust', 'haskell' },
      callback = function(args)
        vim.keymap.set('n', 'K', '<Plug>(devdocs-under-cursor)', { buffer = args.buf })
      end,
    })
  end,
}
