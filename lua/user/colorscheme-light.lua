-- Cursor Light Theme Configuration
-- This is a beautiful, eye-friendly light theme with excellent readability
-- Switch to this theme by requiring this file instead of the dark theme

-- Load the Cursor Light theme
local cursor_light_theme = require("user.themes.cursor-light-init")

-- Setup the theme
local status_ok, _ = pcall(cursor_light_theme.setup, {
  -- Options can be added here in the future
  -- transparent = false,
  -- italic_comments = true,
})

if not status_ok then
  vim.notify("Failed to load Cursor Light theme, falling back to default")
  vim.cmd("colorscheme default")
  return
end

-- Alternative: You can also load other light themes by uncommenting below
-- local colorscheme = "github_light"
-- local colorscheme = "onelight"
-- local colorscheme = "gruvbox-material"
-- local colorscheme = "catppuccin-latte"
-- local colorscheme = "tokyonight-day"

-- local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
-- if not status_ok then
--   vim.notify("colorscheme " .. colorscheme .. " not found!")
--   return
-- end