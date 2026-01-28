-- Simplified Neovim Configuration
-- Inspired by Helix's minimalism

require "user.options"
require "user.plugins"
require "user.keymaps"
require "user.autocommands"

-- Terminal config (deferred)
vim.defer_fn(function()
  require "user.terminal"
  require "user.functions"
end, 100)
