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

-- Re-apply options/keymaps/autocmds without restarting. The cache clear is
-- the point: require() returns cached modules, so re-sourcing alone is a
-- no-op. Plugin specs aren't reloaded -- those still need a restart.
function M.reload_config()
  for _, name in ipairs({ 'config.util', 'config.options', 'config.keymaps', 'config.autocmds' }) do
    package.loaded[name] = nil
  end
  require('config.options')
  require('config.keymaps')
  require('config.autocmds')
  vim.notify('Reloaded nvim config (plugin changes need a restart)', vim.log.levels.INFO)
end

return M
