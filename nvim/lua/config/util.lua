local M = {}

-- Ported from .vimrc's StripTrailingWhiteSpaces(): strips trailing
-- whitespace from the whole buffer, preserving the last search pattern
-- and cursor/view position.
function M.strip_trailing_whitespace()
  local view = vim.fn.winsaveview()
  local search = vim.fn.getreg('/')
  vim.cmd([[keeppatterns %s/\s\+$//e]])
  vim.fn.setreg('/', search)
  vim.fn.winrestview(view)
end

return M
