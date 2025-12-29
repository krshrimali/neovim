local M = {}

-- Configuration
local config = {
  ui = "fzf", -- "fzf", "telescope", or "float"
  show_undescribed = true,
  highlight_missing = true,
  group_by_prefix = true,
  show_source = true,
  show_line_numbers = true,
  open_keymap = "<leader>?k",
  cache_ttl = 60, -- seconds
}

-- Setup function
function M.setup(opts)
  opts = opts or {}
  config = vim.tbl_deep_extend("force", config, opts)
end

-- Open keymap viewer
function M.open(options)
  options = options or {}
  
  if config.ui == "fzf" then
    local fzf_ui = require("user.keymap_viewer.ui.fzf")
    fzf_ui.open(options)
  elseif config.ui == "telescope" then
    -- TODO: Implement Telescope UI
    vim.notify("Telescope UI not yet implemented", vim.log.levels.WARN)
  elseif config.ui == "float" then
    -- TODO: Implement Float UI
    vim.notify("Float UI not yet implemented", vim.log.levels.WARN)
  else
    vim.notify("Unknown UI backend: " .. config.ui, vim.log.levels.ERROR)
  end
end

-- Refresh cache
function M.refresh()
  if config.ui == "fzf" then
    local fzf_ui = require("user.keymap_viewer.ui.fzf")
    fzf_ui.refresh()
  end
end

-- Get all keymaps (for external use)
function M.get_keymaps()
  if config.ui == "fzf" then
    local fzf_ui = require("user.keymap_viewer.ui.fzf")
    return fzf_ui.get_keymaps()
  end
  return {}
end

-- Setup keymap
if config.open_keymap then
  vim.keymap.set("n", config.open_keymap, function()
    M.open()
  end, { desc = "Open Keymap Viewer", noremap = true, silent = true })
end

-- Create command
vim.api.nvim_create_user_command("KeymapViewer", function(opts)
  local args = opts.args
  local options = {}
  
  -- Parse mode filter if provided
  if args and args ~= "" then
    local modes = { n = "n", i = "i", v = "v", x = "x", t = "t", c = "c" }
    if modes[args] then
      options.mode = args
    end
  end
  
  M.open(options)
end, {
  desc = "Open Keymap Viewer",
  nargs = "?",
  complete = function()
    return { "n", "i", "v", "x", "t", "c" }
  end,
})

-- Refresh command
vim.api.nvim_create_user_command("KeymapViewerRefresh", function()
  M.refresh()
  vim.notify("Keymap cache refreshed", vim.log.levels.INFO)
end, {
  desc = "Refresh Keymap Viewer cache",
})

return M
