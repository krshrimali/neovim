-- nvim-navic: Breadcrumbs plugin for LSP
-- Lightweight and fast context display

local M = {}

function M.setup()
  local status_ok, navic = pcall(require, "nvim-navic")
  if not status_ok then return end

  navic.setup {
    -- ASCII icons only (no nerd fonts)
    icons = {
      File = "F ",
      Module = "M ",
      Namespace = "N ",
      Package = "P ",
      Class = "C ",
      Method = "m ",
      Property = "p ",
      Field = "f ",
      Constructor = "c ",
      Enum = "E ",
      Interface = "I ",
      Function = "F ",
      Variable = "v ",
      Constant = "C ",
      String = "s ",
      Number = "# ",
      Boolean = "b ",
      Array = "[] ",
      Object = "{} ",
      Key = "k ",
      Null = "N ",
      EnumMember = "e ",
      Struct = "S ",
      Event = "E ",
      Operator = "o ",
      TypeParameter = "t ",
    },

    -- Highlight configuration
    highlight = true,
    separator = " > ",
    depth_limit = 0, -- No limit
    depth_limit_indicator = "..",
    safe_output = true,

    -- Performance
    lazy_update_context = true,
    click = false, -- Disable mouse click (not needed in lualine)
  }
end

-- Check if navic is available and has data
function M.is_available()
  local navic_ok, navic = pcall(require, "nvim-navic")
  if not navic_ok then return false end
  return navic.is_available()
end

-- Get location string for lualine
function M.get_location()
  local navic_ok, navic = pcall(require, "nvim-navic")
  if not navic_ok then return "" end

  if navic.is_available() then
    return navic.get_location()
  else
    return ""
  end
end

return M
