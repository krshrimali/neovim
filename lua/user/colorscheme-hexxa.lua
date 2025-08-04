-- Hexxa Dark Theme Configuration
-- Switch to this beautiful theme inspired by the original Hexxa theme
-- To use this theme, change your init.lua to require this file instead of the cursor theme

-- Load the Hexxa Dark theme
local hexxa_theme = require("user.themes.hexxa-dark-init")

-- Setup the theme
local status_ok, _ = pcall(hexxa_theme.setup, {
  -- Options can be added here in the future
  -- transparent = false,
  -- italic_comments = true,
})

if not status_ok then
  vim.notify("Failed to load Hexxa Dark theme, falling back to default")
  vim.cmd("colorscheme default")
  return
end

-- Alternative: You can also load other themes by uncommenting below
-- local colorscheme = "tokyonight"
-- local colorscheme = "gruvbox-material"
-- local colorscheme = "catppuccin"
-- local colorscheme = "github_dark"

-- local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
-- if not status_ok then
--   vim.notify("colorscheme " .. colorscheme .. " not found!")
--   return
-- end