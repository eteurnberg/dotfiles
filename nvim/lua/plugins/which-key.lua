-- New capability -- keybind discovery, worth having now that the leader
-- key surface area (git, coc, telescope) has grown.
return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  config = function()
    require('which-key').setup()
  end,
}
