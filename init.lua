-- Simplified Neovim Configuration
-- Inspired by Helix's minimalism

require "user.options"
require "user.plugins"
require "user.keymaps"
require "user.functions"
require "user.autocommands"
require("user.remote_mode").setup()
require("user.window_separators").setup()

-- -- Terminal config (deferred)
vim.defer_fn(function() require "user.terminal" end, 100)

-- vim.g.clipboard = "osc52"
dofile(vim.fn.expand "~/.config/zellij/plugins/zj-annotate/nvim/zj-annotate.nvim.lua")
