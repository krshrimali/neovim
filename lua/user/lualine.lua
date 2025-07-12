M = {}
local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
  return
end

local lualine_scheme = "auto"
-- local lualine_scheme = "onedarker_alt"

local status_theme_ok, theme = pcall(require, "lualine.themes." .. lualine_scheme)
if not status_theme_ok then
  return
end

local navic = require("nvim-navic")

-- check if value in table
local function contains(t, value)
  for _, v in pairs(t) do
    if v == value then
      return true
    end
  end
  return false
end

vim.o.statusline = vim.o.tabline

local hl_str = function(str)
  return "%#" .. "#" .. str .. "%*"
end

local hide_in_width_60 = function()
  return vim.o.columns > 60
end

local hide_in_width = function()
  return vim.o.columns > 80
end

local hide_in_width_100 = function()
  return vim.o.columns > 100
end

local icons = require "user.icons"

local diagnostics = {
  "diagnostics",
  sources = { "nvim_diagnostic" },
  colored = false,
  update_in_insert = false,
  always_visible = true,
  padding = 1,
}

local diff = {
  "diff",
  colored = true,
  symbols = { added = icons.git.Add .. " ", modified = icons.git.Mod .. " ", removed = icons.git.Remove .. " " }, -- changes diff symbols
  cond = hide_in_width_60,
  separator = "│ " .. "%*",
}

local filetype = {
  "filetype",
  fmt = function(str)
    local ui_filetypes = {
      "help",
      "packer",
      "neogitstatus",
      "NvimTree",
      "Trouble",
      "lir",
      "Outline",
      "spectre_panel",
      "toggleterm",
      "DressingSelect",
      "",
      "nil",
    }

    local return_val = function(str_)
      -- return hl_str(" ", "SLSep") .. hl_str(str, "SLFT") .. hl_str("", "SLSep")
      return hl_str " (" .. hl_str(str_) .. hl_str ")"
    end

    if str == "TelescopePrompt" then
      return return_val(icons.ui.Telescope)
    end

    local function get_term_num()
      local t_status_ok, toggle_num = pcall(vim.api.nvim_buf_get_var, 0, "toggle_number")
      if not t_status_ok then
        return ""
      end
      return toggle_num
    end

    if str == "toggleterm" then
      -- 
      local term = " " .. "%*" .. get_term_num() .. "%*"

      return return_val(term)
    end

    if contains(ui_filetypes, str) then
      return ""
    else
      return return_val(str)
    end
  end,
  icons_enabled = false,
  padding = 0,
}

local branch = {
  "branch",
  icons_enabled = true,
  icon = " " .. "%*",
  -- color = "Constant",
  -- colored = false,
  padding = 1,
  -- cond = hide_in_width_100,
  fmt = function(str)
    if str == "" or str == nil then
      return "!=vcs"
    end

    return str
  end,
}

local progress = {
  "progress",
  fmt = function(str)
    -- return "▊"
    return hl_str "(" .. hl_str "%P/%L" .. hl_str ") "
    -- return "  "
  end,
  -- color = "SLProgress",
  padding = 0,
}

-- local current_signature = {
--   function()
--     local buf_ft = vim.bo.filetype

--     if buf_ft == "toggleterm" or buf_ft == "TelescopePrompt" then
--       return ""
--     end
--     -- if not pcall(require, "lsp_signature") then
--     --   return ""
--     -- end

--     local sig = require("lsp_signature").status_line()
--     -- return sig.label .. " " .. sig.hint

--     if not require("user.functions").isempty(sig.hint) then
--       -- return "%#SLSeparator#│ : " .. hint .. "%*"
--       -- return "%#SLSeparator#│ " .. hint .. "%*"
--       return sig.hint .. "%*"
--     end

--     -- return "functions empty"
--     return ""
--   end,
--   cond = hide_in_width_100,
--   padding = 0,
-- }

local spaces = {
  function()
    local buf_ft = vim.bo.filetype

    local ui_filetypes = {
      "help",
      "packer",
      "neogitstatus",
      "NvimTree",
      "Trouble",
      "lir",
      "Outline",
      "spectre_panel",
      "DressingSelect",
      "",
    }
    local space = ""

    if contains(ui_filetypes, buf_ft) then
      space = " "
    end

    local shiftwidth = vim.api.nvim_buf_get_option(0, "shiftwidth")

    if shiftwidth == nil then
      return ""
    end

    -- TODO: update codicons and use their indent
    return hl_str " (" .. hl_str("Spaces: " .. shiftwidth .. space) .. hl_str ")"
  end,
  padding = 0,
  -- separator = "%#SLSeparator#" .. " │" .. "%*",
  -- cond = hide_in_width_100,
}

local lanuage_server = {
  function()
    local buf_ft = vim.bo.filetype
    local ui_filetypes = {
      "help",
      "packer",
      "neogitstatus",
      "NvimTree",
      "Trouble",
      "lir",
      "Outline",
      "spectre_panel",
      "toggleterm",
      "DressingSelect",
      "TelescopePrompt",
      "lspinfo",
      "lsp-installer",
      "",
    }

    if contains(ui_filetypes, buf_ft) then
      if M.language_servers == nil then
        return ""
      else
        return M.language_servers
      end
    end

    local clients = vim.lsp.get_clients { bufnr = 0 }
    local client_names = {}
    local copilot_active = false

    -- add client
    for _, client in pairs(clients) do
      if client.name ~= "copilot" and client.name ~= "null-ls" then
        table.insert(client_names, client.name)
      end
      if client.name == "copilot" then
        copilot_active = true
      end
    end

    -- add formatter
    local s = require "null-ls.sources"
    local available_sources = s.get_available(buf_ft)
    local registered = {}
    for _, source in ipairs(available_sources) do
      for method in pairs(source.methods) do
        registered[method] = registered[method] or {}
        table.insert(registered[method], source.name)
      end
    end

    local formatter = registered["NULL_LS_FORMATTING"]
    local linter = registered["NULL_LS_DIAGNOSTICS"]
    if formatter ~= nil then
      vim.list_extend(client_names, formatter)
    end
    if linter ~= nil then
      vim.list_extend(client_names, linter)
    end

    -- join client names with commas
    local client_names_str = table.concat(client_names, ", ")

    -- check client_names_str if empty
    local language_servers = ""
    local client_names_str_len = #client_names_str
    if client_names_str_len ~= 0 then
      language_servers = hl_str "" .. hl_str(client_names_str) .. hl_str ""
    end
    if copilot_active then
      language_servers = language_servers .. " " .. icons.git.Octoface .. "%*"
    end

    if client_names_str_len == 0 and not copilot_active then
      return ""
    else
      M.language_servers = language_servers
      return language_servers:gsub(", anonymous source", "")
    end
  end,
  padding = 0,
  cond = hide_in_width,
  -- separator = "%#SLSeparator#" .. " │" .. "%*",
}

local location = {
  "location",
  fmt = function(str)
    -- return "▊"
    return hl_str " (" .. hl_str(str) .. hl_str ") "
    -- return hl_str(" (") .. hl_str(str) .. hl_str(") ")
    -- return "  "
  end,
  padding = 0,
}

local custom_auto_theme = require 'lualine.themes.auto'
custom_auto_theme.normal.c.bg = NONE

lualine.setup {
  options = {
    globalstatus = true,
    icons_enabled = true,
    theme = custom_auto_theme,
    -- theme = theme,
    -- theme = "shado",
    -- theme = "catppuccin",
    -- theme = "darkplus",
    -- theme = "gruvbox-material",
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = { "alpha", "dashboard" },
    always_divide_middle = true,
  },
  sections = {
    -- lualine_a = { left_pad, mode, branch, right_pad },
    -- lualine_a = { "mode", "branch", diff },
    -- lualine_a = { 'filename', file_status=true, path=2 },
    -- lualine_b = { diagnostics },
    -- lualine_c = {},
    lualine_c = { 'filename', { navic.get_location, cond = navic.is_available } },
    -- lualine_x = { diff, spaces, "encoding", filetype },
    -- lualine_x = { diff, lanuage_server, spaces, filetype },
    -- lualine_x = { lanuage_server, spaces, filetype },
    -- lualine_x = { lanuage_server, spaces, filetype },
    lualine_x = { lanuage_server, spaces },
    lualine_y = {
      -- "buffers",
      -- show_filename_only = true,
      -- show_modified_status = true,

      -- mode = 0,
      -- max_length = vim.o.columns * 2 / 3,

      -- buffer_color = {
      --   active = "lualine_x_normal",
      --   inactive = "lualine_x_inactive",
      -- },
    },
    -- {
    --   "filename",
    --   file_status = true,
    --   path = 3,
    -- },
    lualine_z = { location, progress },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = {},
}
