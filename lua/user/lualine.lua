local status_ok, lualine = pcall(require, "lualine")
if not status_ok then return end

vim.o.statusline = vim.o.tabline

local hl_str = function(str) return "%#" .. "#" .. str .. "%*" end

local branch = {
  "branch",
  icons_enabled = false,
  icon = " G: " .. "%*",
  -- color = "Constant",
  -- colored = false,
  padding = 1,
  -- cond = hide_in_width_100,
  fmt = function(str)
    if str == "" or str == nil then return "!=vcs" end

    return str
  end,
}

local progress = {
  "progress",
  fmt = function(_)
    -- return "▊"
    return hl_str "(" .. hl_str "%P/%L" .. hl_str ") "
    -- return "  "
  end,
  -- color = "SLProgress",
  padding = 0,
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

-- Create custom theme for Cursor Dark
local function create_cursor_dark_theme()
  local cursor_colors = require("user.themes.init").get_colors()

  return {
    normal = {
      a = { fg = cursor_colors.bg, bg = cursor_colors.blue, gui = "bold" },
      b = { fg = cursor_colors.fg_light, bg = cursor_colors.bg_light },
      c = { fg = cursor_colors.fg, bg = cursor_colors.bg },
    },
    insert = {
      a = { fg = cursor_colors.bg, bg = cursor_colors.green, gui = "bold" },
    },
    visual = {
      a = { fg = cursor_colors.bg, bg = cursor_colors.purple, gui = "bold" },
    },
    replace = {
      a = { fg = cursor_colors.bg, bg = cursor_colors.red, gui = "bold" },
    },
    command = {
      a = { fg = cursor_colors.bg, bg = cursor_colors.yellow, gui = "bold" },
    },
    terminal = {
      a = { fg = cursor_colors.bg, bg = cursor_colors.cyan, gui = "bold" },
    },
    inactive = {
      a = { fg = cursor_colors.fg_dark, bg = cursor_colors.bg_alt },
      b = { fg = cursor_colors.fg_dark, bg = cursor_colors.bg_alt },
      c = { fg = cursor_colors.fg_dark, bg = cursor_colors.bg_alt },
    },
  }
end

local cursor_theme = create_cursor_dark_theme()

lualine.setup {
  options = {
    globalstatus = true,
    icons_enabled = false,
    theme = "auto",
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = { "alpha", "dashboard" },
    always_divide_middle = true,
  },
  sections = {
    lualine_a = {},
    lualine_b = { branch },
    lualine_c = {
      {
        "filename",
        path = 3, -- Show absolute path
      },
      {
        -- Breadcrumbs from nvim-navic
        function()
          local navic = require "nvim-navic"
          if navic.is_available() then return navic.get_location() end
          return ""
        end,
        cond = function()
          local navic = require "nvim-navic"
          return navic.is_available()
        end,
      },
    },
    lualine_x = {
      -- And show current time in NYC:
      {
        function()
          -- Function to get current NYC time as a string
          local function get_nyc_time()
            local UTC_OFFSET_NYC_STANDARD = -5 * 3600 -- UTC-5 in seconds
            local UTC_OFFSET_NYC_DST = -4 * 3600 -- UTC-4 in seconds during daylight saving

            -- Get current UTC time
            local utc_now = os.time(os.date "!*t")

            -- Very basic DST check:
            -- DST in NYC starts second Sunday in March and ends first Sunday in November
            local date_table = os.date("*t", utc_now - UTC_OFFSET_NYC_STANDARD)
            local year = date_table.year

            -- Calculate second Sunday in March
            local function second_sunday_of_march(y)
              local d = os.time { year = y, month = 3, day = 1, hour = 0 }
              local w = os.date("*t", d).wday
              local offset = (7 - w + 1) + 7 -- days until second Sunday
              return d + offset * 24 * 3600
            end

            -- Calculate first Sunday in November
            local function first_sunday_of_november(y)
              local d = os.time { year = y, month = 11, day = 1, hour = 0 }
              local w = os.date("*t", d).wday
              local offset = (7 - w + 1) -- days until first Sunday
              return d + offset * 24 * 3600
            end

            local second_sunday_march = second_sunday_of_march(year)
            local first_sunday_november = first_sunday_of_november(year)

            -- Decide if DST is in effect for NYC
            local nyc_offset = UTC_OFFSET_NYC_STANDARD
            if utc_now >= second_sunday_march and utc_now < first_sunday_november then
              nyc_offset = UTC_OFFSET_NYC_DST
            end

            local nyc_time = os.date("NYC: %Y%m%d %H:%M %p", utc_now + nyc_offset)
            return nyc_time
          end
          return get_nyc_time()
        end,
        padding = 1,
      },
    },
    lualine_z = { location, progress },
  },
  extensions = {},
}
