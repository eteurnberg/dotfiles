-- Replaces coc.nvim's tab-completion popup. blink.cmp is the current
-- default in kickstart.nvim/LazyVim, successor to nvim-cmp -- no
-- legacy nvim-cmp config here to preserve, so no reason to pick the
-- older one.
return {
  'saghen/blink.cmp',
  lazy = false,
  version = '1.*',
  opts = {
    keymap = { preset = 'default' },
    appearance = { nerd_font_variant = 'mono' },
    completion = { documentation = { auto_show = true } },
    sources = {
      default = { 'lsp', 'path', 'buffer' },
    },
  },
}
