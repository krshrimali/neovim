-- Gruvbox Material Theme Configuration
local colorscheme = "gruvbox-material"

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found!")
  return
end

-- Transparency is now handled by the transparent.nvim plugin (lua/user/nvim_transparent.lua)
-- The manual background clearing below is disabled to avoid conflicts
-- vim.api.nvim_create_autocmd("ColorScheme", {
--   pattern = "*",
--   callback = function()
--     local hl_groups = {
--       "Normal",
--       "NormalNC",
--       "NormalFloat",
--       "SignColumn",
--       "EndOfBuffer",
--       "LineNr",
--       "CursorLineNr",
--       "Folded",
--       "FoldColumn",
--     }
--     for _, group in ipairs(hl_groups) do
--       vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
--     end
--   end,
-- })
--
-- vim.cmd "doautocmd ColorScheme"
