-- RELY ON DEFAULT THEME AS THE DEFAULT
-- Cursor Dark Theme Configuration
-- This is a custom theme inspired by Cursor IDE's dark theme

-- Load the Cursor Dark theme
-- local cursor_theme = require("user.themes.init")
--
-- -- Setup the theme
-- local status_ok, _ = pcall(cursor_theme.setup, {
--   -- Options can be added here in the future
--   -- transparent = true,
--   -- italic_comments = true,
-- })
--
-- if not status_ok then
--   vim.notify("Failed to load Cursor Dark theme, falling back to default")
--   vim.cmd("colorscheme default")
--   return
-- end

-- Alternative: You can also load other themes by uncommenting below
-- local colorscheme = "darkplus"
-- local colorscheme = "moonfly"
-- local colorscheme = "gruvbox-material"
-- local colorscheme = "bluloco-dark"
-- local colorscheme = "tokyonight"

-- local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
-- if not status_ok then
--   vim.notify("colorscheme " .. colorscheme .. " not found!")
--   return
-- end

-- Enable transparency by clearing background colors
-- This works with the transparent.nvim plugin and vim.g.transparent_enabled = true
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local hl_groups = {
      "Normal",
      "NormalNC",
      "NormalFloat",
      "SignColumn",
      "EndOfBuffer",
      "LineNr",
      "CursorLineNr",
      "Folded",
      "FoldColumn",
    }
    for _, group in ipairs(hl_groups) do
      vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
    end
  end,
})

-- Trigger the autocmd for the current colorscheme
vim.cmd "doautocmd ColorScheme"
