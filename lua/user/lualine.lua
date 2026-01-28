-- Simplified Lualine Configuration
local status_ok, lualine = pcall(require, "lualine")
if not status_ok then return end

lualine.setup {
  options = {
    globalstatus = true,
    icons_enabled = false,
    theme = "ayu_light", -- Light theme that works well
    component_separators = { left = "|", right = "|" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = { "alpha", "dashboard", "NvimTree" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    lualine_c = {
      { "filename", path = 1 }, -- Relative path
    },
    lualine_x = { "diagnostics" },
    lualine_y = { "filetype" },
    lualine_z = { "location", "progress" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
}
