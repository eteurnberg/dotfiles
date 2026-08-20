-- Ported from .vimrc's "Generic editor"/"Searching"/"Swap files"/
-- "Autocompletion" blocks, plus a few general options that lived in the
-- old "Tabline related"/"CoC" blocks only because that's where the old
-- single-file .vimrc happened to group them.

vim.opt.number = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.cursorline = true
vim.opt.wildmenu = true
vim.opt.showmatch = true
vim.opt.hidden = true
vim.opt.list = false
vim.opt.wrap = true
vim.opt.linebreak = true
-- breakat intentionally left at Neovim's default -- .vimrc's
-- "breakat&vim" just reset it to Vim's own default too, nothing to port

vim.opt.backspace = { 'eol', 'start', 'indent' }
vim.opt.whichwrap:append('<,>,h,l')

vim.opt.splitright = true
vim.opt.splitbelow = true

if not vim.env.TMUX or vim.env.TMUX == '' then
  vim.opt.clipboard = 'unnamed'
end

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.omnifunc = 'syntaxcomplete#Complete'

vim.opt.swapfile = true
vim.opt.directory = { '.', vim.env.TEMP or '/tmp' }
vim.opt.shortmess:append('A')

vim.opt.laststatus = 2
vim.opt.showmode = false

-- These three came from the old CoC block but aren't coc-specific --
-- kept here rather than in plugins/coc.lua so they survive Stage 3's LSP
-- swap unchanged.
vim.opt.updatetime = 300
vim.opt.shortmess:append('c')
vim.opt.signcolumn = 'yes'
