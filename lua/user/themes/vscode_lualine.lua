-- Lualine theme builder for the VSCode colorschemes.
--
-- Each lua/lualine/themes/vscode*.lua file is a one-liner that calls
-- `require("user.themes.vscode_lualine").build("<variant-name>")`. The
-- builder pulls the palette out of `user.themes.vscode` and assembles a
-- statusbar that mirrors VSCode's actual chrome:
--
--   - Section A (mode): white text on a solid mode-colored background
--     (blue for normal, green for insert, purple for visual, etc.). High
--     contrast — `#ffffff` on the saturated brand colors is the same
--     contrast level VSCode itself uses for its statusbar.
--   - Section B (branch / diff): the theme's bright foreground on the
--     subtle "panel" background.
--   - Section C (filename / breadcrumbs): regular foreground on the editor
--     background, so it blends with the buffer below.
--
-- Inactive windows fade to the panel background with the muted foreground.

local M = {}

-- Pick the readable foreground (white or near-black) for a given hex bg
-- using a perceived-luminance threshold. Same heuristic VSCode uses for
-- its statusbar text.
local function readable_fg(hex)
  local r = tonumber(hex:sub(2, 3), 16) or 0
  local g = tonumber(hex:sub(4, 5), 16) or 0
  local b = tonumber(hex:sub(6, 7), 16) or 0
  local luma = (0.299 * r + 0.587 * g + 0.114 * b) / 255
  if luma > 0.6 then return "#1a1a1a" end
  return "#ffffff"
end

function M.build(name)
  local vscode = require "user.themes.vscode"
  local p = vscode.get_palette(name)
  if not p then error("vscode_lualine: unknown variant '" .. tostring(name) .. "'") end

  -- Mode-color overrides per palette. The default uses VSCode's iconic
  -- statusbar blue (#007acc) for normal mode — high contrast against
  -- white text and instantly recognizable. Other modes pick saturated
  -- accent colors from the palette.
  local mode = {
    normal = "#007acc",
    insert = p.git_add,
    visual = p.purple,
    replace = p.red,
    command = p.yellow,
    terminal = p.teal,
  }

  -- Some variants need special-casing so the mode bg isn't washed out.
  if name == "vscode-true-dark" then
    mode.normal = "#00aaff"
    mode.insert = "#00ff00"
    mode.visual = "#ff00ff"
    mode.replace = "#ff0033"
    mode.command = "#ffff00"
    mode.terminal = "#00ffff"
  elseif name == "vscode-true-light" then
    mode.normal = "#0000ff"
    mode.insert = "#008000"
    mode.visual = "#800080"
    mode.replace = "#cc0000"
    mode.command = "#996600"
    mode.terminal = "#008080"
  elseif name == "vscode-monokai" then
    mode.normal = "#66d9ef"
    mode.insert = "#a6e22e"
    mode.visual = "#fd971f"
    mode.replace = "#f92672"
    mode.command = "#e6db74"
    mode.terminal = "#ae81ff"
  elseif name == "vscode-abyss" then
    mode.normal = "#225588"
    mode.insert = "#37a554"
    mode.visual = "#9966b8"
    mode.replace = "#a72253"
    mode.command = "#dbb774"
    mode.terminal = "#52a4c4"
  end

  -- For the b/c sections, the Light variants need darker text for contrast.
  local b_fg = p.fg_alt
  if name:match "light" then b_fg = "#1a1a1a" end

  local function section(mode_bg)
    return {
      a = { fg = readable_fg(mode_bg), bg = mode_bg, gui = "bold" },
      b = { fg = b_fg, bg = p.bg_light },
      c = { fg = p.fg, bg = p.bg },
    }
  end

  return {
    normal = section(mode.normal),
    insert = section(mode.insert),
    visual = section(mode.visual),
    replace = section(mode.replace),
    command = section(mode.command),
    terminal = section(mode.terminal),
    inactive = {
      a = { fg = p.fg_dark, bg = p.bg_alt, gui = "bold" },
      b = { fg = p.fg_dark, bg = p.bg_alt },
      c = { fg = p.fg_dark, bg = p.bg_alt },
    },
  }
end

return M
