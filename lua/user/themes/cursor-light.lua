-- Cursor Light Theme for Neovim
-- A beautiful, eye-friendly light theme with excellent readability
-- Inspired by modern light themes with careful attention to contrast and eye comfort

local M = {}

-- Color Palette (carefully selected for eye comfort and readability)
local colors = {
  -- Base colors - soft, warm backgrounds that are easy on the eyes
  bg = "#fefefe", -- Main background - pure white with slight warmth
  bg_alt = "#f8f8f8", -- Alternative background (sidebars, etc.) - very light gray
  bg_dark = "#f0f0f0", -- Darker background for contrast
  bg_light = "#ffffff", -- Lighter background (selections, etc.)
  bg_popup = "#ffffff", -- Popup background
  bg_statusline = "#0078d4", -- Status line background - professional blue

  -- Foreground colors - high contrast for readability
  fg = "#2d2d2d", -- Main foreground - dark gray, easier than pure black
  fg_alt = "#404040", -- Alternative foreground
  fg_dark = "#666666", -- Darker foreground (comments, etc.)
  fg_light = "#1a1a1a", -- Lighter foreground - near black for emphasis

  -- Syntax colors - carefully chosen for both beauty and functionality
  blue = "#0078d4", -- Keywords, types - professional blue
  cyan = "#0aa3a3", -- Strings, constants - teal cyan
  green = "#107c10", -- Comments, strings - forest green
  yellow = "#ca5010", -- Functions, methods - warm orange-yellow
  orange = "#d83b01", -- Numbers, constants - vibrant orange
  red = "#d13438", -- Errors, deletions - clear red
  purple = "#8764b8", -- Keywords, operators - soft purple
  pink = "#e3008c", -- Special keywords - magenta pink

  -- UI colors - subtle and professional
  border = "#d1d1d1", -- Borders - light gray
  selection = "#cce8ff", -- Text selection - light blue
  search = "#fff2cd", -- Search highlight - light yellow
  match_paren = "#e6e6e6", -- Matching parentheses - light gray
  cursor_line = "#f5f5f5", -- Current line - very subtle gray
  line_number = "#999999", -- Line numbers - medium gray
  line_number_current = "#666666", -- Current line number - darker for emphasis

  -- Git colors - clear and distinct
  git_add = "#107c10", -- Green for additions
  git_change = "#0078d4", -- Blue for changes
  git_delete = "#d13438", -- Red for deletions

  -- Diagnostic colors - clear but not overwhelming
  error = "#d13438", -- Clear red for errors
  warning = "#ca5010", -- Orange for warnings
  info = "#0078d4", -- Blue for info
  hint = "#0aa3a3", -- Teal for hints

  -- Special colors for enhanced readability
  diff_add = "#e6ffed", -- Very light green for diff additions
  diff_change = "#fff5b4", -- Very light yellow for diff changes
  diff_delete = "#ffebee", -- Very light red for diff deletions
  diff_text = "#fff2cd", -- Light yellow for diff text changes

  -- Terminal colors - vibrant but not harsh
  terminal_black = "#2d2d2d",
  terminal_red = "#d13438",
  terminal_green = "#107c10",
  terminal_yellow = "#ca5010",
  terminal_blue = "#0078d4",
  terminal_magenta = "#8764b8",
  terminal_cyan = "#0aa3a3",
  terminal_white = "#f0f0f0",
  terminal_bright_black = "#666666",
  terminal_bright_red = "#ff6b6b",
  terminal_bright_green = "#51cf66",
  terminal_bright_yellow = "#ffd43b",
  terminal_bright_blue = "#339af0",
  terminal_bright_magenta = "#9775fa",
  terminal_bright_cyan = "#22b8cf",
  terminal_bright_white = "#ffffff",
}

-- Helper function to create highlight groups
local function hl(group, opts)
  if opts.link then
    vim.api.nvim_set_hl(0, group, { link = opts.link })
  else
    -- Respect transparency setting
    if vim.g.transparent_enabled and opts.bg then opts = vim.tbl_extend("force", opts, { bg = "NONE" }) end
    vim.api.nvim_set_hl(0, group, opts)
  end
end

-- Main theme function
function M.setup()
  vim.cmd "hi clear"
  if vim.fn.exists "syntax_on" then vim.cmd "syntax reset" end

  vim.o.background = "light"
  vim.g.colors_name = "cursor-light"

  -- Base highlight groups
  hl("Normal", { fg = colors.fg, bg = colors.bg })
  hl("NormalFloat", { fg = colors.fg, bg = colors.bg_popup })
  hl("NormalNC", { fg = colors.fg, bg = colors.bg })

  -- UI Elements
  hl("ColorColumn", { bg = colors.bg_dark })
  hl("Cursor", { fg = colors.bg, bg = colors.fg })
  hl("CursorLine", { bg = colors.cursor_line })
  hl("CursorColumn", { bg = colors.cursor_line })
  hl("CursorLineNr", { fg = colors.line_number_current, bold = true })
  hl("LineNr", { fg = colors.line_number })
  hl("SignColumn", { fg = colors.line_number, bg = colors.bg })
  hl("FoldColumn", { fg = colors.line_number, bg = colors.bg })

  -- Window elements
  hl("VertSplit", { fg = colors.border })
  hl("WinSeparator", { fg = colors.border })
  hl("StatusLine", { fg = colors.bg_light, bg = colors.bg_statusline, bold = true })
  hl("StatusLineNC", { fg = colors.fg_dark, bg = colors.bg_alt })
  hl("TabLine", { fg = colors.fg_dark, bg = colors.bg_alt })
  hl("TabLineFill", { bg = colors.bg_alt })
  hl("TabLineSel", { fg = colors.fg, bg = colors.bg, bold = true })

  -- Popup menu
  hl("Pmenu", { fg = colors.fg, bg = colors.bg_popup })
  hl("PmenuSel", { fg = colors.bg, bg = colors.blue })
  hl("PmenuSbar", { bg = colors.bg_dark })
  hl("PmenuThumb", { bg = colors.border })

  -- Search and selection
  hl("Search", { fg = colors.fg, bg = colors.search })
  hl("IncSearch", { fg = colors.bg, bg = colors.orange })
  hl("Visual", { bg = colors.selection })
  hl("VisualNOS", { bg = colors.selection })

  -- Messages and prompts
  hl("ErrorMsg", { fg = colors.error, bold = true })
  hl("WarningMsg", { fg = colors.warning, bold = true })
  hl("ModeMsg", { fg = colors.fg, bold = true })
  hl("MoreMsg", { fg = colors.green, bold = true })
  hl("Question", { fg = colors.blue, bold = true })

  -- Syntax highlighting
  hl("Comment", { fg = colors.green, italic = true })
  hl("Constant", { fg = colors.cyan })
  hl("String", { fg = colors.cyan })
  hl("Character", { fg = colors.cyan })
  hl("Number", { fg = colors.orange })
  hl("Boolean", { fg = colors.orange })
  hl("Float", { fg = colors.orange })

  hl("Identifier", { fg = colors.blue })
  hl("Function", { fg = colors.yellow })

  hl("Statement", { fg = colors.purple, bold = true })
  hl("Conditional", { fg = colors.purple, bold = true })
  hl("Repeat", { fg = colors.purple, bold = true })
  hl("Label", { fg = colors.purple, bold = true })
  hl("Operator", { fg = colors.purple })
  hl("Keyword", { fg = colors.purple, bold = true })
  hl("Exception", { fg = colors.purple, bold = true })

  hl("PreProc", { fg = colors.pink })
  hl("Include", { fg = colors.pink })
  hl("Define", { fg = colors.pink })
  hl("Macro", { fg = colors.pink })
  hl("PreCondit", { fg = colors.pink })

  hl("Type", { fg = colors.blue })
  hl("StorageClass", { fg = colors.blue })
  hl("Structure", { fg = colors.blue })
  hl("Typedef", { fg = colors.blue })

  hl("Special", { fg = colors.red })
  hl("SpecialChar", { fg = colors.red })
  hl("Tag", { fg = colors.red })
  hl("Delimiter", { fg = colors.fg })
  hl("SpecialComment", { fg = colors.green, bold = true })
  hl("Debug", { fg = colors.red })

  -- Diff highlighting
  hl("DiffAdd", { bg = colors.diff_add })
  hl("DiffChange", { bg = colors.diff_change })
  hl("DiffDelete", { fg = colors.git_delete, bg = colors.diff_delete })
  hl("DiffText", { bg = colors.diff_text })

  -- Spell checking
  hl("SpellBad", { fg = colors.error, undercurl = true })
  hl("SpellCap", { fg = colors.warning, undercurl = true })
  hl("SpellLocal", { fg = colors.info, undercurl = true })
  hl("SpellRare", { fg = colors.hint, undercurl = true })

  -- Matching parentheses
  hl("MatchParen", { bg = colors.match_paren, bold = true })

  -- Directory and file listings
  hl("Directory", { fg = colors.blue, bold = true })

  -- Special elements
  hl("Title", { fg = colors.purple, bold = true })
  hl("Todo", { fg = colors.bg, bg = colors.yellow, bold = true })
  hl("Underlined", { fg = colors.blue, underline = true })
  hl("Ignore", { fg = colors.fg_dark })
  hl("Error", { fg = colors.error, bold = true })

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

-- Export colors for other theme components
M.colors = colors

return M
