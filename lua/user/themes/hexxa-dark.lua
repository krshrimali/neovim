-- Hexxa Dark Theme for Neovim
-- Inspired by the Hexxa theme by Diogo Moretti
-- https://github.com/diogomoretti/hexxa-theme

local M = {}

-- Hexxa Color Palette (extracted from original theme)
M.colors = {
  -- Main background and foreground
  bg = "#120E1D",           -- Main background
  fg = "#F8F8F8",           -- Main foreground
  fg_alt = "#EEEEEE",       -- Alternative foreground
  fg_dim = "#F9F9F990",     -- Dimmed foreground
  
  -- Core colors from Hexxa theme
  blue = "#4D5BFC",         -- Primary blue
  cyan = "#00D0FF",         -- Cyan
  green = "#49DCB1",        -- Teal/green
  lime = "#CCFF66",         -- Lime green
  orange = "#EE964B",       -- Orange
  pink = "#FF5FA7",         -- Pink/magenta
  red = "#DB5461",          -- Red
  
  -- UI colors
  comment = "#666666",      -- Comments
  selection = "#717DFF39",  -- Selection background
  line_highlight = "#F9F9F907", -- Current line
  line_highlight_border = "#F9F9F904",
  
  -- Grays and neutrals
  gray1 = "#F9F9F933",     -- Line numbers
  gray2 = "#F9F9F966",     -- Whitespace, rulers
  gray3 = "#F9F9F980",     -- Word highlight border
  gray4 = "#F9F9F922",     -- Find match highlight
  gray5 = "#F9F9F920",     -- Inactive selection, borders
  gray6 = "#F9F9F910",     -- Hover backgrounds
  gray7 = "#F9F9F907",     -- Very subtle backgrounds
  
  -- Status and UI elements
  border = "#F9F9F920",
  active_border = "#4D5BFC",
  error = "#DB5461",
  warning = "#4D5BFC",
  info = "#49DCB1",
  hint = "#00D0FF",
  
  -- Git colors
  git_add = "#CCFF66",
  git_change = "#00D0FF", 
  git_delete = "#DB5461",
  
  -- Special
  none = "NONE",
}

-- Setup function to apply the theme
function M.setup()
  -- Clear existing highlights
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd("syntax reset")
  end
  
  vim.o.background = "dark"
  vim.g.colors_name = "hexxa-dark"
  
  local colors = M.colors
  
  -- Helper function to set highlights
  local function hl(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end
  
  -- Editor UI
  hl("Normal", { fg = colors.fg, bg = colors.bg })
  hl("NormalFloat", { fg = colors.fg, bg = colors.bg })
  hl("NormalNC", { fg = colors.fg_dim, bg = colors.bg })
  
  -- Cursor and lines
  hl("Cursor", { fg = colors.bg, bg = colors.fg })
  hl("CursorLine", { bg = colors.line_highlight })
  hl("CursorLineNr", { fg = colors.fg, bg = colors.line_highlight })
  hl("LineNr", { fg = colors.gray1 })
  hl("SignColumn", { fg = colors.gray1, bg = colors.bg })
  hl("FoldColumn", { fg = colors.gray2, bg = colors.bg })
  
  -- Visual selection
  hl("Visual", { bg = colors.selection })
  hl("VisualNOS", { bg = colors.selection })
  
  -- Search
  hl("Search", { fg = colors.bg, bg = colors.cyan })
  hl("IncSearch", { fg = colors.bg, bg = colors.cyan })
  hl("CurSearch", { fg = colors.bg, bg = colors.orange })
  
  -- Diff
  hl("DiffAdd", { fg = colors.git_add, bg = colors.none })
  hl("DiffChange", { fg = colors.git_change, bg = colors.none })
  hl("DiffDelete", { fg = colors.git_delete, bg = colors.none })
  hl("DiffText", { fg = colors.cyan, bg = colors.none, bold = true })
  
  -- Popup menu
  hl("Pmenu", { fg = colors.fg_alt, bg = colors.bg })
  hl("PmenuSel", { fg = colors.fg, bg = colors.gray5 })
  hl("PmenuSbar", { bg = colors.gray5 })
  hl("PmenuThumb", { bg = colors.gray3 })
  
  -- Borders and separators
  hl("VertSplit", { fg = colors.border })
  hl("WinSeparator", { fg = colors.border })
  hl("FloatBorder", { fg = colors.border, bg = colors.bg })
  
  -- Status line
  hl("StatusLine", { fg = colors.fg_dim, bg = colors.bg })
  hl("StatusLineNC", { fg = colors.gray2, bg = colors.bg })
  
  -- Tab line
  hl("TabLine", { fg = colors.fg_dim, bg = colors.bg })
  hl("TabLineFill", { fg = colors.fg_dim, bg = colors.bg })
  hl("TabLineSel", { fg = colors.fg, bg = colors.bg, bold = true })
  
  -- Messages
  hl("ErrorMsg", { fg = colors.error })
  hl("WarningMsg", { fg = colors.warning })
  hl("MoreMsg", { fg = colors.green })
  hl("Question", { fg = colors.cyan })
  
  -- Folds
  hl("Folded", { fg = colors.gray2, bg = colors.gray7 })
  
  -- Whitespace
  hl("Whitespace", { fg = colors.gray2 })
  hl("NonText", { fg = colors.gray2 })
  hl("SpecialKey", { fg = colors.gray2 })
  
  -- Spelling
  hl("SpellBad", { sp = colors.error, undercurl = true })
  hl("SpellCap", { sp = colors.warning, undercurl = true })
  hl("SpellLocal", { sp = colors.info, undercurl = true })
  hl("SpellRare", { sp = colors.hint, undercurl = true })
  
  -- Conceal
  hl("Conceal", { fg = colors.gray2 })
  
  -- Directory
  hl("Directory", { fg = colors.cyan })
  
  -- Title
  hl("Title", { fg = colors.lime, bold = true })
  
  -- Wild menu
  hl("WildMenu", { fg = colors.bg, bg = colors.cyan })
  
  -- Color column
  hl("ColorColumn", { bg = colors.gray7 })
  
  -- Match paren
  hl("MatchParen", { fg = colors.orange, bold = true })
  
  -- Basic syntax groups (fallbacks)
  hl("Comment", { fg = colors.comment, italic = true })
  hl("Constant", { fg = colors.blue })
  hl("String", { fg = colors.green })
  hl("Character", { fg = colors.green })
  hl("Number", { fg = colors.blue })
  hl("Boolean", { fg = colors.blue })
  hl("Float", { fg = colors.blue })
  hl("Identifier", { fg = colors.fg_alt })
  hl("Function", { fg = colors.lime })
  hl("Statement", { fg = colors.pink })
  hl("Conditional", { fg = colors.pink })
  hl("Repeat", { fg = colors.pink })
  hl("Label", { fg = colors.pink })
  hl("Operator", { fg = colors.orange })
  hl("Keyword", { fg = colors.orange })
  hl("Exception", { fg = colors.pink })
  hl("PreProc", { fg = colors.pink })
  hl("Include", { fg = colors.pink })
  hl("Define", { fg = colors.pink })
  hl("Macro", { fg = colors.pink })
  hl("PreCondit", { fg = colors.pink })
  hl("Type", { fg = colors.cyan })
  hl("StorageClass", { fg = colors.pink })
  hl("Structure", { fg = colors.cyan })
  hl("Typedef", { fg = colors.cyan })
  hl("Special", { fg = colors.orange })
  hl("SpecialChar", { fg = colors.orange })
  hl("Tag", { fg = colors.pink })
  hl("Delimiter", { fg = colors.fg_alt })
  hl("SpecialComment", { fg = colors.comment, italic = true })
  hl("Debug", { fg = colors.red })
  hl("Underlined", { fg = colors.cyan, underline = true })
  hl("Ignore", { fg = colors.gray2 })
  hl("Error", { fg = colors.error })
  hl("Todo", { fg = colors.orange, bold = true })
end

return M