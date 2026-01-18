-- Cursor Dark Theme for Neovim
-- Inspired by Cursor IDE's dark theme and VS Code Dark+

local M = {}

-- Color Palette (based on Cursor/VS Code Dark+ theme)
local colors = {
  -- Base colors
  bg = "#1e1e1e", -- Main background
  bg_alt = "#252526", -- Alternative background (sidebars, etc.)
  bg_dark = "#181818", -- Darker background
  bg_light = "#2d2d30", -- Lighter background (selections, etc.)
  bg_popup = "#252526", -- Popup background
  bg_statusline = "#007acc", -- Status line background

  -- Foreground colors
  fg = "#d4d4d4", -- Main foreground
  fg_alt = "#cccccc", -- Alternative foreground
  fg_dark = "#969696", -- Darker foreground (comments, etc.)
  fg_light = "#ffffff", -- Lighter foreground

  -- Accent colors
  blue = "#569cd6", -- Keywords, types
  cyan = "#4ec9b0", -- Strings, constants
  green = "#6a9955", -- Comments, strings
  yellow = "#dcdcaa", -- Functions, methods
  orange = "#ce9178", -- Numbers, constants
  red = "#f44747", -- Errors, deletions
  purple = "#c586c0", -- Keywords, operators
  pink = "#d16d9e", -- Special keywords

  -- UI colors
  border = "#464647", -- Borders
  selection = "#264f78", -- Text selection
  search = "#613214", -- Search highlight
  match_paren = "#404040", -- Matching parentheses
  cursor_line = "#2a2d2e", -- Current line
  line_number = "#858585", -- Line numbers
  line_number_current = "#c6c6c6", -- Current line number

  -- Git colors
  git_add = "#4ec9b0",
  git_change = "#569cd6",
  git_delete = "#f44747",

  -- Diagnostic colors
  error = "#f44747",
  warning = "#ff8c00",
  info = "#569cd6",
  hint = "#4ec9b0",

  -- Terminal colors
  terminal_black = "#000000",
  terminal_red = "#cd3131",
  terminal_green = "#0dbc79",
  terminal_yellow = "#e5e510",
  terminal_blue = "#2472c8",
  terminal_magenta = "#bc3fbc",
  terminal_cyan = "#11a8cd",
  terminal_white = "#e5e5e5",
  terminal_bright_black = "#666666",
  terminal_bright_red = "#f14c4c",
  terminal_bright_green = "#23d18b",
  terminal_bright_yellow = "#f5f543",
  terminal_bright_blue = "#3b8eea",
  terminal_bright_magenta = "#d670d6",
  terminal_bright_cyan = "#29b8db",
  terminal_bright_white = "#ffffff",
}

-- Helper function to create highlight groups
local function hl(group, opts)
  if opts.link then
    vim.api.nvim_set_hl(0, group, { link = opts.link })
  else
    -- Respect transparency setting
    if vim.g.transparent_enabled and opts.bg then
      opts = vim.tbl_extend("force", opts, { bg = "NONE" })
    end
    vim.api.nvim_set_hl(0, group, opts)
  end
end

-- Main theme function
function M.setup()
  vim.cmd "hi clear"
  if vim.fn.exists "syntax_on" then vim.cmd "syntax reset" end

  vim.o.background = "dark"
  vim.g.colors_name = "cursor-dark"

  -- Base highlight groups
  hl("Normal", { fg = colors.fg, bg = colors.bg })
  hl("NormalFloat", { fg = colors.fg, bg = colors.bg_popup })
  hl("NormalNC", { fg = colors.fg, bg = colors.bg })

  -- UI Elements
  hl("ColorColumn", { bg = colors.bg_light })
  hl("Cursor", { fg = colors.bg, bg = colors.fg })
  hl("CursorLine", { bg = colors.cursor_line })
  hl("CursorColumn", { bg = colors.cursor_line })
  hl("CursorLineNr", { fg = colors.line_number_current, bold = true })
  hl("LineNr", { fg = colors.line_number })
  hl("SignColumn", { fg = colors.line_number, bg = colors.bg })
  hl("FoldColumn", { fg = colors.line_number, bg = colors.bg })
  hl("Folded", { fg = colors.fg_dark, bg = colors.bg_light })

  -- Search and selection
  hl("Search", { bg = colors.search })
  hl("IncSearch", { bg = colors.orange, fg = colors.bg })
  hl("Visual", { bg = colors.selection })
  hl("VisualNOS", { bg = colors.selection })

  -- Splits and windows
  hl("VertSplit", { fg = colors.border })
  hl("WinSeparator", { fg = colors.border })
  hl("StatusLine", { fg = colors.fg_light, bg = colors.bg_statusline })
  hl("StatusLineNC", { fg = colors.fg_dark, bg = colors.bg_alt })
  hl("TabLine", { fg = colors.fg_dark, bg = colors.bg_alt })
  hl("TabLineFill", { fg = colors.fg_dark, bg = colors.bg_alt })
  hl("TabLineSel", { fg = colors.fg_light, bg = colors.bg })

  -- Popup menu
  hl("Pmenu", { fg = colors.fg, bg = colors.bg_popup })
  hl("PmenuSel", { fg = colors.fg_light, bg = colors.selection })
  hl("PmenuSbar", { bg = colors.bg_light })
  hl("PmenuThumb", { bg = colors.fg_dark })

  -- Messages
  hl("ModeMsg", { fg = colors.fg })
  hl("MoreMsg", { fg = colors.green })
  hl("Question", { fg = colors.blue })
  hl("WarningMsg", { fg = colors.warning })
  hl("ErrorMsg", { fg = colors.error })

  -- Syntax highlighting
  hl("Comment", { fg = colors.green, italic = true })
  hl("Constant", { fg = colors.cyan })
  hl("String", { fg = colors.orange })
  hl("Character", { fg = colors.orange })
  hl("Number", { fg = colors.cyan })
  hl("Boolean", { fg = colors.blue })
  hl("Float", { fg = colors.cyan })

  hl("Identifier", { fg = colors.blue })
  hl("Function", { fg = colors.yellow })

  hl("Statement", { fg = colors.purple })
  hl("Conditional", { fg = colors.purple })
  hl("Repeat", { fg = colors.purple })
  hl("Label", { fg = colors.purple })
  hl("Operator", { fg = colors.fg })
  hl("Keyword", { fg = colors.blue })
  hl("Exception", { fg = colors.purple })

  hl("PreProc", { fg = colors.purple })
  hl("Include", { fg = colors.purple })
  hl("Define", { fg = colors.purple })
  hl("Macro", { fg = colors.purple })
  hl("PreCondit", { fg = colors.purple })

  hl("Type", { fg = colors.blue })
  hl("StorageClass", { fg = colors.blue })
  hl("Structure", { fg = colors.blue })
  hl("Typedef", { fg = colors.blue })

  hl("Special", { fg = colors.cyan })
  hl("SpecialChar", { fg = colors.orange })
  hl("Tag", { fg = colors.blue })
  hl("Delimiter", { fg = colors.fg })
  hl("SpecialComment", { fg = colors.green, italic = true })
  hl("Debug", { fg = colors.red })

  hl("Underlined", { fg = colors.blue, underline = true })
  hl("Ignore", { fg = colors.fg_dark })
  hl("Error", { fg = colors.error })
  hl("Todo", { fg = colors.bg, bg = colors.yellow, bold = true })

  -- Matching parentheses
  hl("MatchParen", { bg = colors.match_paren, bold = true })

  -- Diff
  hl("DiffAdd", { fg = colors.git_add, bg = colors.bg })
  hl("DiffChange", { fg = colors.git_change, bg = colors.bg })
  hl("DiffDelete", { fg = colors.git_delete, bg = colors.bg })
  hl("DiffText", { fg = colors.git_change, bg = colors.bg_light })

  -- Spell checking
  hl("SpellBad", { fg = colors.error, undercurl = true })
  hl("SpellCap", { fg = colors.warning, undercurl = true })
  hl("SpellLocal", { fg = colors.info, undercurl = true })
  hl("SpellRare", { fg = colors.hint, undercurl = true })

  -- Terminal colors
  vim.g.terminal_color_0 = colors.terminal_black
  vim.g.terminal_color_1 = colors.terminal_red
  vim.g.terminal_color_2 = colors.terminal_green
  vim.g.terminal_color_3 = colors.terminal_yellow
  vim.g.terminal_color_4 = colors.terminal_blue
  vim.g.terminal_color_5 = colors.terminal_magenta
  vim.g.terminal_color_6 = colors.terminal_cyan
  vim.g.terminal_color_7 = colors.terminal_white
  vim.g.terminal_color_8 = colors.terminal_bright_black
  vim.g.terminal_color_9 = colors.terminal_bright_red
  vim.g.terminal_color_10 = colors.terminal_bright_green
  vim.g.terminal_color_11 = colors.terminal_bright_yellow
  vim.g.terminal_color_12 = colors.terminal_bright_blue
  vim.g.terminal_color_13 = colors.terminal_bright_magenta
  vim.g.terminal_color_14 = colors.terminal_bright_cyan
  vim.g.terminal_color_15 = colors.terminal_bright_white
end

-- Export colors for other plugins to use
M.colors = colors

return M
