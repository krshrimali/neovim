-- Visible, theme-aware window separators
--
-- Two things make splits hard to see by default here:
--   1. `fillchars.vert` was a space, so the vertical separator had no glyph to
--      color -- every theme's `WinSeparator` fg was simply never drawn.
--   2. The themes' `border` colors sit only a few steps away from the
--      background (e.g. #464647 on #1e1e1e), which reads as nothing.
--
-- Instead of patching each of the colorschemes in `lua/user/themes`, this
-- module derives a separator color from whatever `Normal` currently is, so it
-- follows any colorscheme (including plugin ones) and both backgrounds.

local M = {}

-- How far to blend Normal's fg into its bg for the separator line.
-- Higher = more contrast. Dark themes need a bit more push to read clearly.
local BLEND_DARK = 0.45
local BLEND_LIGHT = 0.38

local function to_rgb(n) return { math.floor(n / 65536) % 256, math.floor(n / 256) % 256, n % 256 } end

local function to_hex(rgb) return string.format("#%02x%02x%02x", rgb[1], rgb[2], rgb[3]) end

local function blend(fg, bg, alpha)
  local out = {}
  for i = 1, 3 do
    out[i] = math.floor(bg[i] + (fg[i] - bg[i]) * alpha + 0.5)
    out[i] = math.max(0, math.min(255, out[i]))
  end
  return out
end

-- Perceived brightness, used to pick the blend strength.
local function luminance(rgb) return (0.299 * rgb[1] + 0.587 * rgb[2] + 0.114 * rgb[3]) / 255 end

local function separator_color()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local is_light = vim.o.background == "light"

  local bg = normal.bg and to_rgb(normal.bg) or (is_light and { 254, 254, 254 } or { 30, 30, 30 })
  local fg = normal.fg and to_rgb(normal.fg) or (is_light and { 40, 40, 40 } or { 212, 212, 212 })

  local alpha = luminance(bg) > 0.5 and BLEND_LIGHT or BLEND_DARK
  return to_hex(blend(fg, bg, alpha)), normal.bg and to_hex(bg) or nil
end

function M.apply()
  local fg, bg = separator_color()
  local hl = vim.api.nvim_set_hl

  -- `bg = nil` keeps transparency working when the theme has no Normal bg.
  hl(0, "WinSeparator", { fg = fg, bg = bg })
  hl(0, "VertSplit", { link = "WinSeparator" })

  -- Plugin windows that draw their own separators, so borders stay uniform
  -- across the whole layout instead of the sidebar fading out.
  for _, group in ipairs {
    "NvimTreeWinSeparator",
    "NvimTreeVertSplit",
    "DiffviewVertSplit",
    "DiffviewWinSeparator",
    "NeoTreeWinSeparator",
  } do
    hl(0, group, { link = "WinSeparator" })
  end
end

function M.setup()
  -- Real box-drawing glyphs, with the junction characters so crossings between
  -- horizontal and vertical splits connect instead of leaving gaps.
  vim.opt.fillchars:append {
    vert = "│",
    horiz = "─",
    horizup = "┴",
    horizdown = "┬",
    vertleft = "┤",
    vertright = "├",
    verthoriz = "┼",
  }

  M.apply()

  local group = vim.api.nvim_create_augroup("UserWindowSeparators", { clear = true })

  -- The theme modules in `lua/user/themes` re-apply highlights on a 10-50ms
  -- timer after ColorScheme, so run both immediately and after they settle.
  vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
    group = group,
    callback = function()
      M.apply()
      vim.defer_fn(M.apply, 80)
    end,
  })

  -- `:set background=light/dark` without a colorscheme change.
  vim.api.nvim_create_autocmd("OptionSet", {
    group = group,
    pattern = "background",
    callback = M.apply,
  })
end

return M
