-- VSCode Themes for Neovim
-- Faithful ports of Visual Studio Code's official color themes, including
-- the canonical semantic-token palettes (variables, numbers, types,
-- functions, control-flow keywords, etc.).
--
-- Variants:
--   :colorscheme vscode               -- Dark+ (the classic)
--   :colorscheme vscode-light         -- Light+ (the classic)
--   :colorscheme vscode-dark-modern   -- Dark Modern (newer default, 2022+)
--   :colorscheme vscode-light-modern  -- Light Modern (newer default, 2022+)
--   :colorscheme vscode-monokai       -- Monokai (built-in)
--   :colorscheme vscode-abyss         -- Abyss (deep blue, built-in)
--
-- Covers Treesitter (@-groups), LSP semantic tokens, diagnostics,
-- and every plugin already supported elsewhere in this config. A matching
-- lualine theme ships per variant — see lua/lualine/themes/vscode*.lua,
-- which `theme = "auto"` picks up automatically.

local M = {}

-- ---------------------------------------------------------------------------
-- Palettes
-- ---------------------------------------------------------------------------

-- VSCode Dark+ — pulled from the official theme JSON.
local dark = {
  -- Editor chrome
  bg = "#1f1f1f",
  bg_alt = "#181818", -- activity/sidebar
  bg_dark = "#141414",
  bg_light = "#2a2d2e", -- hover/list rows
  bg_popup = "#252526",
  bg_statusline = "#007acc",
  bg_float = "#252526",

  fg = "#cccccc",
  fg_alt = "#d4d4d4",
  fg_dark = "#808080",
  fg_light = "#ffffff",

  -- Syntax / semantic tokens (the iconic Dark+ palette)
  blue = "#569cd6", -- keywords, primitive types
  light_blue = "#9cdcfe", -- variables, parameters, properties
  bright_blue = "#4fc1ff", -- constants
  teal = "#4ec9b0", -- types, classes, interfaces
  green = "#6a9955", -- comments
  number_green = "#b5cea8", -- numbers, enum members
  yellow = "#dcdcaa", -- functions, methods
  orange = "#ce9178", -- strings
  red = "#f44747", -- errors
  regex_red = "#d16969", -- regex
  purple = "#c586c0", -- control-flow keywords (if/for/return/import)
  pink = "#d16d9e",

  -- UI
  border = "#3c3c3c",
  selection = "#264f78",
  selection_inactive = "#3a3d41",
  search = "#623315",
  search_current = "#ff8c00",
  match_paren = "#515c6a",
  cursor_line = "#2a2d2e",
  line_number = "#858585",
  line_number_current = "#c6c6c6",
  indent = "#404040",
  indent_active = "#707070",

  -- Git
  git_add = "#487e02",
  git_change = "#1b81a8",
  git_delete = "#f44747",
  git_add_bg = "#1e3a1e",
  git_change_bg = "#1e3a4a",
  git_delete_bg = "#3a1e1e",

  -- Diagnostics
  error = "#f14c4c",
  warning = "#cca700",
  info = "#3794ff",
  hint = "#4ec9b0",

  -- Terminal
  term = {
    "#000000", "#cd3131", "#0dbc79", "#e5e510",
    "#2472c8", "#bc3fbc", "#11a8cd", "#e5e5e5",
    "#666666", "#f14c4c", "#23d18b", "#f5f543",
    "#3b8eea", "#d670d6", "#29b8db", "#ffffff",
  },
}

-- VSCode Light+ — official Light+ JSON.
local light = {
  bg = "#ffffff",
  bg_alt = "#f8f8f8",
  bg_dark = "#ececec",
  bg_light = "#f0f0f0",
  bg_popup = "#f3f3f3",
  bg_statusline = "#007acc",
  bg_float = "#f3f3f3",

  fg = "#3b3b3b",
  fg_alt = "#000000",
  fg_dark = "#6c6c6c",
  fg_light = "#000000",

  -- Syntax / semantic tokens
  blue = "#0000ff", -- keywords, primitive types
  light_blue = "#001080", -- variables, parameters, properties
  bright_blue = "#0070c1", -- constants
  teal = "#267f99", -- types, classes, interfaces
  green = "#008000", -- comments
  number_green = "#098658", -- numbers
  yellow = "#795e26", -- functions, methods
  orange = "#a31515", -- strings
  red = "#cd3131", -- errors
  regex_red = "#811f3f", -- regex
  purple = "#af00db", -- control-flow keywords
  pink = "#800000", -- HTML tags

  -- UI
  border = "#d4d4d4",
  selection = "#add6ff",
  selection_inactive = "#e5ebf1",
  search = "#fdff00",
  search_current = "#a8ac94",
  match_paren = "#b4b4b4",
  cursor_line = "#f5f5f5",
  line_number = "#237893",
  line_number_current = "#0b216f",
  indent = "#d3d3d3",
  indent_active = "#939393",

  -- Git
  git_add = "#587c0c",
  git_change = "#0451a5",
  git_delete = "#ad0707",
  git_add_bg = "#dcfdcb",
  git_change_bg = "#dbedf8",
  git_delete_bg = "#fddfdf",

  -- Diagnostics
  error = "#e51400",
  warning = "#bf8803",
  info = "#1a85ff",
  hint = "#267f99",

  -- Terminal
  term = {
    "#000000", "#cd3131", "#107c10", "#949800",
    "#0451a5", "#bc05bc", "#0598bc", "#555555",
    "#666666", "#cd3131", "#14ce14", "#b5ba00",
    "#0451a5", "#bc05bc", "#0598bc", "#a5a5a5",
  },
}

-- ---------------------------------------------------------------------------
-- Highlight application
-- ---------------------------------------------------------------------------

local function make_hl()
  return function(group, opts)
    if opts.link then
      vim.api.nvim_set_hl(0, group, { link = opts.link })
    else
      if vim.g.transparent_enabled and opts.bg then
        opts = vim.tbl_extend("force", opts, { bg = "NONE" })
      end
      vim.api.nvim_set_hl(0, group, opts)
    end
  end
end

local function apply(c, name, background)
  vim.cmd "hi clear"
  if vim.fn.exists "syntax_on" then vim.cmd "syntax reset" end
  vim.o.background = background
  vim.g.colors_name = name

  local hl = make_hl()

  -----------------------------------------------------------------------
  -- Editor base
  -----------------------------------------------------------------------
  hl("Normal", { fg = c.fg, bg = c.bg })
  hl("NormalNC", { fg = c.fg, bg = c.bg })
  hl("NormalFloat", { fg = c.fg, bg = c.bg_float })
  hl("FloatBorder", { fg = c.border, bg = c.bg_float })
  hl("FloatTitle", { fg = c.blue, bg = c.bg_float, bold = true })
  hl("ColorColumn", { bg = c.bg_light })
  hl("Conceal", { fg = c.fg_dark })
  hl("Cursor", { fg = c.bg, bg = c.fg })
  hl("lCursor", { fg = c.bg, bg = c.fg })
  hl("CursorIM", { fg = c.bg, bg = c.fg })
  hl("CursorLine", { bg = c.cursor_line })
  hl("CursorColumn", { bg = c.cursor_line })
  hl("CursorLineNr", { fg = c.line_number_current, bold = true })
  hl("LineNr", { fg = c.line_number })
  hl("SignColumn", { fg = c.line_number, bg = c.bg })
  hl("FoldColumn", { fg = c.line_number, bg = c.bg })
  hl("Folded", { fg = c.fg_dark, bg = c.bg_light })
  hl("EndOfBuffer", { fg = c.bg })
  hl("NonText", { fg = c.indent })
  hl("SpecialKey", { fg = c.indent })
  hl("Whitespace", { fg = c.indent })
  hl("Directory", { fg = c.blue })
  hl("Title", { fg = c.blue, bold = true })

  hl("Search", { bg = c.search, fg = c.fg })
  hl("IncSearch", { bg = c.search_current, fg = c.bg, bold = true })
  hl("CurSearch", { bg = c.search_current, fg = c.bg, bold = true })
  hl("Substitute", { bg = c.search_current, fg = c.bg })
  hl("Visual", { bg = c.selection })
  hl("VisualNOS", { bg = c.selection })

  hl("VertSplit", { fg = c.border })
  hl("WinSeparator", { fg = c.border })
  hl("StatusLine", { fg = c.fg_light, bg = c.bg_statusline })
  hl("StatusLineNC", { fg = c.fg_dark, bg = c.bg_alt })
  hl("TabLine", { fg = c.fg_dark, bg = c.bg_alt })
  hl("TabLineFill", { fg = c.fg_dark, bg = c.bg_alt })
  hl("TabLineSel", { fg = c.fg_light, bg = c.bg })
  hl("WinBar", { fg = c.fg, bg = c.bg })
  hl("WinBarNC", { fg = c.fg_dark, bg = c.bg })

  hl("Pmenu", { fg = c.fg, bg = c.bg_popup })
  hl("PmenuSel", { fg = c.fg_light, bg = c.selection, bold = true })
  hl("PmenuSbar", { bg = c.bg_light })
  hl("PmenuThumb", { bg = c.fg_dark })
  hl("PmenuKind", { fg = c.blue, bg = c.bg_popup })
  hl("PmenuKindSel", { fg = c.blue, bg = c.selection, bold = true })
  hl("PmenuExtra", { fg = c.fg_dark, bg = c.bg_popup })
  hl("PmenuExtraSel", { fg = c.fg_dark, bg = c.selection })

  hl("ModeMsg", { fg = c.fg, bold = true })
  hl("MoreMsg", { fg = c.green })
  hl("MsgArea", { fg = c.fg })
  hl("Question", { fg = c.blue })
  hl("WarningMsg", { fg = c.warning })
  hl("ErrorMsg", { fg = c.error })
  hl("MatchParen", { fg = c.fg_light, bg = c.match_paren, bold = true })

  -----------------------------------------------------------------------
  -- Legacy syntax (covers anything without treesitter)
  -----------------------------------------------------------------------
  hl("Comment", { fg = c.green, italic = true })
  hl("Constant", { fg = c.bright_blue })
  hl("String", { fg = c.orange })
  hl("Character", { fg = c.orange })
  hl("Number", { fg = c.number_green })
  hl("Boolean", { fg = c.blue })
  hl("Float", { fg = c.number_green })

  hl("Identifier", { fg = c.light_blue })
  hl("Function", { fg = c.yellow })

  hl("Statement", { fg = c.purple })
  hl("Conditional", { fg = c.purple })
  hl("Repeat", { fg = c.purple })
  hl("Label", { fg = c.purple })
  hl("Operator", { fg = c.fg })
  hl("Keyword", { fg = c.blue })
  hl("Exception", { fg = c.purple })

  hl("PreProc", { fg = c.purple })
  hl("Include", { fg = c.purple })
  hl("Define", { fg = c.purple })
  hl("Macro", { fg = c.purple })
  hl("PreCondit", { fg = c.purple })

  hl("Type", { fg = c.teal })
  hl("StorageClass", { fg = c.blue })
  hl("Structure", { fg = c.teal })
  hl("Typedef", { fg = c.teal })

  hl("Special", { fg = c.yellow })
  hl("SpecialChar", { fg = c.orange })
  hl("Tag", { fg = c.blue })
  hl("Delimiter", { fg = c.fg })
  hl("SpecialComment", { fg = c.green, italic = true, bold = true })
  hl("Debug", { fg = c.red })

  hl("Underlined", { fg = c.blue, underline = true })
  hl("Ignore", { fg = c.fg_dark })
  hl("Error", { fg = c.error })
  hl("Todo", { fg = c.bg, bg = c.yellow, bold = true })

  -----------------------------------------------------------------------
  -- Diff
  -----------------------------------------------------------------------
  hl("DiffAdd", { bg = c.git_add_bg })
  hl("DiffChange", { bg = c.git_change_bg })
  hl("DiffDelete", { bg = c.git_delete_bg, fg = c.git_delete })
  hl("DiffText", { bg = c.git_change_bg, bold = true })

  hl("diffAdded", { fg = c.git_add })
  hl("diffRemoved", { fg = c.git_delete })
  hl("diffChanged", { fg = c.git_change })
  hl("diffFile", { fg = c.blue })
  hl("diffNewFile", { fg = c.blue })
  hl("diffOldFile", { fg = c.blue })
  hl("diffLine", { fg = c.purple })

  -----------------------------------------------------------------------
  -- Spell
  -----------------------------------------------------------------------
  hl("SpellBad", { undercurl = true, sp = c.error })
  hl("SpellCap", { undercurl = true, sp = c.warning })
  hl("SpellLocal", { undercurl = true, sp = c.info })
  hl("SpellRare", { undercurl = true, sp = c.hint })

  -----------------------------------------------------------------------
  -- Treesitter (@-groups)
  -----------------------------------------------------------------------
  hl("@comment", { link = "Comment" })
  hl("@comment.documentation", { fg = c.green, italic = true })
  hl("@comment.error", { fg = c.error, bold = true })
  hl("@comment.warning", { fg = c.warning, bold = true })
  hl("@comment.note", { fg = c.info, bold = true })
  hl("@comment.todo", { fg = c.bg, bg = c.yellow, bold = true })

  hl("@constant", { fg = c.bright_blue })
  hl("@constant.builtin", { fg = c.blue })
  hl("@constant.macro", { fg = c.purple })

  hl("@constructor", { fg = c.teal })
  hl("@diff.delta", { fg = c.git_change })
  hl("@diff.minus", { fg = c.git_delete })
  hl("@diff.plus", { fg = c.git_add })

  hl("@error", { fg = c.error })
  hl("@exception", { fg = c.purple })

  hl("@field", { fg = c.light_blue })
  hl("@property", { fg = c.light_blue })

  hl("@function", { fg = c.yellow })
  hl("@function.builtin", { fg = c.yellow })
  hl("@function.call", { fg = c.yellow })
  hl("@function.macro", { fg = c.purple })
  hl("@function.method", { fg = c.yellow })
  hl("@function.method.call", { fg = c.yellow })
  hl("@method", { fg = c.yellow })
  hl("@method.call", { fg = c.yellow })

  hl("@keyword", { fg = c.blue })
  hl("@keyword.conditional", { fg = c.purple })
  hl("@keyword.debug", { fg = c.purple })
  hl("@keyword.directive", { fg = c.purple })
  hl("@keyword.directive.define", { fg = c.purple })
  hl("@keyword.exception", { fg = c.purple })
  hl("@keyword.function", { fg = c.blue })
  hl("@keyword.import", { fg = c.purple })
  hl("@keyword.export", { fg = c.purple })
  hl("@keyword.operator", { fg = c.blue })
  hl("@keyword.repeat", { fg = c.purple })
  hl("@keyword.return", { fg = c.purple })
  hl("@keyword.coroutine", { fg = c.purple })
  hl("@keyword.storage", { fg = c.blue })
  hl("@keyword.modifier", { fg = c.blue })
  hl("@keyword.type", { fg = c.blue })

  hl("@label", { fg = c.light_blue })
  hl("@module", { fg = c.teal })
  hl("@namespace", { fg = c.teal })
  hl("@none", {})

  hl("@number", { fg = c.number_green })
  hl("@number.float", { fg = c.number_green })
  hl("@boolean", { fg = c.blue })
  hl("@character", { fg = c.orange })
  hl("@character.special", { fg = c.yellow })

  hl("@operator", { fg = c.fg })
  hl("@parameter", { fg = c.light_blue })
  hl("@variable.parameter", { fg = c.light_blue })

  hl("@punctuation.bracket", { fg = c.fg })
  hl("@punctuation.delimiter", { fg = c.fg })
  hl("@punctuation.special", { fg = c.purple })

  hl("@string", { fg = c.orange })
  hl("@string.documentation", { fg = c.green })
  hl("@string.escape", { fg = c.yellow })
  hl("@string.regexp", { fg = c.regex_red })
  hl("@string.special", { fg = c.yellow })
  hl("@string.special.path", { fg = c.orange })
  hl("@string.special.symbol", { fg = c.light_blue })
  hl("@string.special.url", { fg = c.blue, underline = true })

  hl("@tag", { fg = c.pink })
  hl("@tag.builtin", { fg = c.pink })
  hl("@tag.attribute", { fg = c.light_blue })
  hl("@tag.delimiter", { fg = c.fg_dark })

  hl("@type", { fg = c.teal })
  hl("@type.builtin", { fg = c.blue })
  hl("@type.definition", { fg = c.teal })
  hl("@type.qualifier", { fg = c.blue })

  hl("@variable", { fg = c.light_blue })
  hl("@variable.builtin", { fg = c.blue })
  hl("@variable.member", { fg = c.light_blue })

  hl("@attribute", { fg = c.yellow })

  -- Markup
  hl("@markup", { fg = c.fg })
  hl("@markup.emphasis", { italic = true })
  hl("@markup.strong", { bold = true })
  hl("@markup.underline", { underline = true })
  hl("@markup.strikethrough", { strikethrough = true })
  hl("@markup.heading", { fg = c.blue, bold = true })
  hl("@markup.heading.1", { fg = c.blue, bold = true })
  hl("@markup.heading.2", { fg = c.teal, bold = true })
  hl("@markup.heading.3", { fg = c.yellow, bold = true })
  hl("@markup.heading.4", { fg = c.orange, bold = true })
  hl("@markup.heading.5", { fg = c.purple, bold = true })
  hl("@markup.heading.6", { fg = c.pink, bold = true })
  hl("@markup.quote", { fg = c.green, italic = true })
  hl("@markup.math", { fg = c.number_green })
  hl("@markup.link", { fg = c.blue, underline = true })
  hl("@markup.link.label", { fg = c.light_blue })
  hl("@markup.link.url", { fg = c.orange, underline = true })
  hl("@markup.raw", { fg = c.orange })
  hl("@markup.raw.block", { fg = c.orange })
  hl("@markup.list", { fg = c.purple })
  hl("@markup.list.checked", { fg = c.green })
  hl("@markup.list.unchecked", { fg = c.fg_dark })

  -----------------------------------------------------------------------
  -- LSP semantic tokens
  -----------------------------------------------------------------------
  hl("@lsp.type.class", { fg = c.teal })
  hl("@lsp.type.decorator", { fg = c.yellow })
  hl("@lsp.type.enum", { fg = c.teal })
  hl("@lsp.type.enumMember", { fg = c.bright_blue })
  hl("@lsp.type.function", { fg = c.yellow })
  hl("@lsp.type.interface", { fg = c.teal })
  hl("@lsp.type.macro", { fg = c.purple })
  hl("@lsp.type.method", { fg = c.yellow })
  hl("@lsp.type.namespace", { fg = c.teal })
  hl("@lsp.type.parameter", { fg = c.light_blue })
  hl("@lsp.type.property", { fg = c.light_blue })
  hl("@lsp.type.struct", { fg = c.teal })
  hl("@lsp.type.type", { fg = c.teal })
  hl("@lsp.type.typeParameter", { fg = c.teal })
  hl("@lsp.type.variable", { fg = c.light_blue })
  hl("@lsp.type.keyword", { fg = c.blue })
  hl("@lsp.type.string", { fg = c.orange })
  hl("@lsp.type.number", { fg = c.number_green })
  hl("@lsp.type.regexp", { fg = c.regex_red })
  hl("@lsp.type.operator", { fg = c.fg })
  hl("@lsp.type.comment", { fg = c.green, italic = true })
  hl("@lsp.type.modifier", { fg = c.blue })
  hl("@lsp.type.event", { fg = c.purple })
  hl("@lsp.type.builtinType", { fg = c.blue })
  hl("@lsp.type.selfKeyword", { fg = c.blue })

  hl("@lsp.mod.declaration", {})
  hl("@lsp.mod.definition", {})
  hl("@lsp.mod.readonly", { fg = c.bright_blue })
  hl("@lsp.mod.static", {})
  hl("@lsp.mod.deprecated", { strikethrough = true })
  hl("@lsp.mod.abstract", { italic = true })
  hl("@lsp.mod.async", {})
  hl("@lsp.mod.modification", {})
  hl("@lsp.mod.documentation", { italic = true })
  hl("@lsp.mod.defaultLibrary", { fg = c.blue })

  -- Common modifier combos VSCode uses
  hl("@lsp.typemod.variable.readonly", { fg = c.bright_blue })
  hl("@lsp.typemod.variable.defaultLibrary", { fg = c.blue })
  hl("@lsp.typemod.function.defaultLibrary", { fg = c.yellow })
  hl("@lsp.typemod.type.defaultLibrary", { fg = c.blue })
  hl("@lsp.typemod.class.defaultLibrary", { fg = c.teal })
  hl("@lsp.typemod.parameter.readonly", { fg = c.light_blue })

  -----------------------------------------------------------------------
  -- LSP diagnostics & references
  -----------------------------------------------------------------------
  hl("DiagnosticError", { fg = c.error })
  hl("DiagnosticWarn", { fg = c.warning })
  hl("DiagnosticInfo", { fg = c.info })
  hl("DiagnosticHint", { fg = c.hint })
  hl("DiagnosticOk", { fg = c.git_add })

  hl("DiagnosticVirtualTextError", { fg = c.error, italic = true })
  hl("DiagnosticVirtualTextWarn", { fg = c.warning, italic = true })
  hl("DiagnosticVirtualTextInfo", { fg = c.info, italic = true })
  hl("DiagnosticVirtualTextHint", { fg = c.hint, italic = true })

  hl("DiagnosticUnderlineError", { undercurl = true, sp = c.error })
  hl("DiagnosticUnderlineWarn", { undercurl = true, sp = c.warning })
  hl("DiagnosticUnderlineInfo", { undercurl = true, sp = c.info })
  hl("DiagnosticUnderlineHint", { undercurl = true, sp = c.hint })

  hl("DiagnosticSignError", { fg = c.error })
  hl("DiagnosticSignWarn", { fg = c.warning })
  hl("DiagnosticSignInfo", { fg = c.info })
  hl("DiagnosticSignHint", { fg = c.hint })

  hl("DiagnosticFloatingError", { fg = c.error })
  hl("DiagnosticFloatingWarn", { fg = c.warning })
  hl("DiagnosticFloatingInfo", { fg = c.info })
  hl("DiagnosticFloatingHint", { fg = c.hint })

  hl("LspReferenceText", { bg = c.bg_light })
  hl("LspReferenceRead", { bg = c.bg_light })
  hl("LspReferenceWrite", { bg = c.bg_light, underline = true })
  hl("LspCodeLens", { fg = c.fg_dark, italic = true })
  hl("LspCodeLensSeparator", { fg = c.fg_dark, italic = true })
  hl("LspSignatureActiveParameter", { fg = c.yellow, bold = true })
  hl("LspInlayHint", { fg = c.fg_dark, bg = c.bg_light, italic = true })
  hl("LspInfoBorder", { fg = c.border, bg = c.bg_popup })

  -----------------------------------------------------------------------
  -- GitSigns
  -----------------------------------------------------------------------
  hl("GitSignsAdd", { fg = c.git_add })
  hl("GitSignsChange", { fg = c.git_change })
  hl("GitSignsDelete", { fg = c.git_delete })
  hl("GitSignsAddNr", { fg = c.git_add })
  hl("GitSignsChangeNr", { fg = c.git_change })
  hl("GitSignsDeleteNr", { fg = c.git_delete })
  hl("GitSignsAddLn", { bg = c.git_add_bg })
  hl("GitSignsChangeLn", { bg = c.git_change_bg })
  hl("GitSignsDeleteLn", { bg = c.git_delete_bg })
  hl("GitSignsCurrentLineBlame", { fg = c.fg_dark, italic = true })

  -----------------------------------------------------------------------
  -- Telescope / FZF-Lua
  -----------------------------------------------------------------------
  hl("TelescopeNormal", { fg = c.fg, bg = c.bg_popup })
  hl("TelescopeBorder", { fg = c.border, bg = c.bg_popup })
  hl("TelescopePromptNormal", { fg = c.fg, bg = c.bg_popup })
  hl("TelescopePromptBorder", { fg = c.border, bg = c.bg_popup })
  hl("TelescopePromptTitle", { fg = c.bg, bg = c.blue, bold = true })
  hl("TelescopePreviewTitle", { fg = c.bg, bg = c.git_add, bold = true })
  hl("TelescopeResultsTitle", { fg = c.bg, bg = c.purple, bold = true })
  hl("TelescopeSelection", { fg = c.fg_light, bg = c.selection })
  hl("TelescopeSelectionCaret", { fg = c.blue })
  hl("TelescopeMultiSelection", { fg = c.purple })
  hl("TelescopeMatching", { fg = c.yellow, bold = true })
  hl("TelescopePromptPrefix", { fg = c.blue })

  hl("FzfLuaNormal", { fg = c.fg, bg = c.bg_popup })
  hl("FzfLuaBorder", { fg = c.border, bg = c.bg_popup })
  hl("FzfLuaTitle", { fg = c.bg, bg = c.blue, bold = true })
  hl("FzfLuaPreviewTitle", { fg = c.bg, bg = c.git_add, bold = true })
  hl("FzfLuaCursor", { fg = c.bg, bg = c.fg })
  hl("FzfLuaCursorLine", { bg = c.selection })
  hl("FzfLuaCursorLineNr", { fg = c.line_number_current, bold = true })
  hl("FzfLuaSearch", { fg = c.yellow, bold = true })
  hl("FzfLuaScrollBorderEmpty", { fg = c.border })
  hl("FzfLuaScrollBorderFull", { fg = c.blue })
  hl("FzfLuaScrollFloatEmpty", { fg = c.border })
  hl("FzfLuaScrollFloatFull", { fg = c.blue })
  hl("FzfLuaHelpNormal", { fg = c.fg, bg = c.bg_popup })
  hl("FzfLuaHelpBorder", { fg = c.border, bg = c.bg_popup })
  hl("FzfLuaHeaderText", { fg = c.purple })
  hl("FzfLuaHeaderBind", { fg = c.yellow })
  hl("FzfLuaPathColNr", { fg = c.bright_blue })
  hl("FzfLuaPathLineNr", { fg = c.line_number })
  hl("FzfLuaBufNr", { fg = c.bright_blue })
  hl("FzfLuaBufFlagCur", { fg = c.purple })
  hl("FzfLuaBufFlagAlt", { fg = c.blue })

  -----------------------------------------------------------------------
  -- NvimTree
  -----------------------------------------------------------------------
  hl("NvimTreeNormal", { fg = c.fg, bg = c.bg_alt })
  hl("NvimTreeNormalNC", { fg = c.fg, bg = c.bg_alt })
  hl("NvimTreeWinSeparator", { fg = c.border, bg = c.bg_alt })
  hl("NvimTreeEndOfBuffer", { fg = c.bg_alt, bg = c.bg_alt })
  hl("NvimTreeRootFolder", { fg = c.purple, bold = true })
  hl("NvimTreeFolderName", { fg = c.fg })
  hl("NvimTreeFolderIcon", { fg = c.yellow })
  hl("NvimTreeEmptyFolderName", { fg = c.fg_dark })
  hl("NvimTreeOpenedFolderName", { fg = c.fg, bold = true })
  hl("NvimTreeExecFile", { fg = c.git_add })
  hl("NvimTreeOpenedFile", { fg = c.fg_light, bold = true })
  hl("NvimTreeSpecialFile", { fg = c.yellow })
  hl("NvimTreeImageFile", { fg = c.purple })
  hl("NvimTreeMarkdownFile", { fg = c.blue })
  hl("NvimTreeIndentMarker", { fg = c.indent })
  hl("NvimTreeGitDirty", { fg = c.warning })
  hl("NvimTreeGitStaged", { fg = c.git_add })
  hl("NvimTreeGitMerge", { fg = c.purple })
  hl("NvimTreeGitRenamed", { fg = c.yellow })
  hl("NvimTreeGitNew", { fg = c.git_add })
  hl("NvimTreeGitDeleted", { fg = c.git_delete })
  hl("NvimTreeGitIgnored", { fg = c.fg_dark })
  hl("NvimTreeCursorLine", { bg = c.bg_light })
  hl("NvimTreeLspDiagnosticsError", { fg = c.error })
  hl("NvimTreeLspDiagnosticsWarning", { fg = c.warning })
  hl("NvimTreeLspDiagnosticsInformation", { fg = c.info })
  hl("NvimTreeLspDiagnosticsHint", { fg = c.hint })

  -----------------------------------------------------------------------
  -- Lualine fallback highlights (lualine itself uses lua/lualine/themes/
  -- vscode*.lua so these only matter if a plugin reads the legacy groups)
  -----------------------------------------------------------------------
  hl("lualine_a_normal", { fg = "#ffffff", bg = c.bg_statusline, bold = true })
  hl("lualine_a_insert", { fg = "#ffffff", bg = c.git_add, bold = true })
  hl("lualine_a_visual", { fg = "#ffffff", bg = c.purple, bold = true })
  hl("lualine_a_replace", { fg = "#ffffff", bg = c.red, bold = true })
  hl("lualine_a_command", { fg = "#ffffff", bg = c.yellow, bold = true })
  hl("lualine_a_terminal", { fg = "#ffffff", bg = c.teal, bold = true })
  hl("lualine_a_inactive", { fg = c.fg_dark, bg = c.bg_alt })
  hl("lualine_b_normal", { fg = c.fg_alt, bg = c.bg_light })
  hl("lualine_b_inactive", { fg = c.fg_dark, bg = c.bg_alt })
  hl("lualine_c_normal", { fg = c.fg, bg = c.bg })
  hl("lualine_c_inactive", { fg = c.fg_dark, bg = c.bg_alt })

  -----------------------------------------------------------------------
  -- Bufferline
  -----------------------------------------------------------------------
  hl("BufferLineFill", { bg = c.bg_dark })
  hl("BufferLineBackground", { fg = c.fg_dark, bg = c.bg_alt })
  hl("BufferLineBufferSelected", { fg = c.fg_light, bg = c.bg, bold = true })
  hl("BufferLineBufferVisible", { fg = c.fg, bg = c.bg_light })
  hl("BufferLineCloseButton", { fg = c.fg_dark, bg = c.bg_alt })
  hl("BufferLineCloseButtonSelected", { fg = c.red, bg = c.bg })
  hl("BufferLineCloseButtonVisible", { fg = c.fg_dark, bg = c.bg_light })
  hl("BufferLineIndicatorSelected", { fg = c.blue, bg = c.bg })
  hl("BufferLineModified", { fg = c.warning, bg = c.bg_alt })
  hl("BufferLineModifiedSelected", { fg = c.warning, bg = c.bg })
  hl("BufferLineModifiedVisible", { fg = c.warning, bg = c.bg_light })
  hl("BufferLineSeparator", { fg = c.bg_dark, bg = c.bg_alt })
  hl("BufferLineSeparatorSelected", { fg = c.bg_dark, bg = c.bg })
  hl("BufferLineSeparatorVisible", { fg = c.bg_dark, bg = c.bg_light })

  -----------------------------------------------------------------------
  -- Diffview / Neogit
  -----------------------------------------------------------------------
  hl("DiffviewNormal", { fg = c.fg, bg = c.bg })
  hl("DiffviewCursorLine", { bg = c.bg_light })
  hl("DiffviewVertSplit", { fg = c.border })
  hl("DiffviewSignColumn", { fg = c.line_number, bg = c.bg })
  hl("DiffviewStatusLine", { fg = c.fg_light, bg = c.bg_statusline })
  hl("DiffviewStatusLineNC", { fg = c.fg_dark, bg = c.bg_alt })
  hl("DiffviewFilePanelTitle", { fg = c.blue, bold = true })
  hl("DiffviewFilePanelCounter", { fg = c.purple })
  hl("DiffviewFilePanelFileName", { fg = c.fg })
  hl("DiffviewFolderName", { fg = c.blue })
  hl("DiffviewFolderSign", { fg = c.yellow })
  hl("DiffviewReference", { fg = c.purple })
  hl("DiffviewHash", { fg = c.yellow })
  hl("DiffviewTimeAgo", { fg = c.teal })
  hl("DiffviewCommitAuthor", { fg = c.orange })

  hl("NeogitBranch", { fg = c.purple })
  hl("NeogitRemote", { fg = c.orange })
  hl("NeogitHunkHeader", { fg = c.fg_light, bg = c.bg_light })
  hl("NeogitHunkHeaderHighlight", { fg = c.fg_light, bg = c.selection })
  hl("NeogitDiffContextHighlight", { bg = c.bg_light })
  hl("NeogitDiffDeleteHighlight", { fg = c.git_delete, bg = c.git_delete_bg })
  hl("NeogitDiffAddHighlight", { fg = c.git_add, bg = c.git_add_bg })
  hl("NeogitCommitViewHeader", { fg = c.blue, bold = true })
  hl("NeogitFilePath", { fg = c.teal })
  hl("NeogitObjectId", { fg = c.yellow })
  hl("NeogitStash", { fg = c.purple })
  hl("NeogitTagName", { fg = c.yellow })
  hl("NeogitTagDistance", { fg = c.teal })

  -----------------------------------------------------------------------
  -- Which-key
  -----------------------------------------------------------------------
  hl("WhichKey", { fg = c.blue })
  hl("WhichKeyGroup", { fg = c.purple })
  hl("WhichKeyDesc", { fg = c.fg })
  hl("WhichKeySeparator", { fg = c.green })
  hl("WhichKeySeperator", { fg = c.green })
  hl("WhichKeyFloat", { bg = c.bg_popup })
  hl("WhichKeyBorder", { fg = c.border, bg = c.bg_popup })
  hl("WhichKeyValue", { fg = c.teal })

  -----------------------------------------------------------------------
  -- Trouble / TODO Comments
  -----------------------------------------------------------------------
  hl("TroubleText", { fg = c.fg })
  hl("TroubleCount", { fg = c.purple, bg = c.bg_light })
  hl("TroubleNormal", { fg = c.fg, bg = c.bg })
  hl("TroubleSignError", { fg = c.error })
  hl("TroubleSignWarning", { fg = c.warning })
  hl("TroubleSignInformation", { fg = c.info })
  hl("TroubleSignHint", { fg = c.hint })
  hl("TroubleLocation", { fg = c.fg_dark })
  hl("TroubleFile", { fg = c.blue })

  hl("TodoBgFIX", { fg = c.bg, bg = c.error, bold = true })
  hl("TodoBgHACK", { fg = c.bg, bg = c.warning, bold = true })
  hl("TodoBgNOTE", { fg = c.bg, bg = c.info, bold = true })
  hl("TodoBgPERF", { fg = c.bg, bg = c.purple, bold = true })
  hl("TodoBgTEST", { fg = c.bg, bg = c.teal, bold = true })
  hl("TodoBgTODO", { fg = c.bg, bg = c.yellow, bold = true })
  hl("TodoBgWARN", { fg = c.bg, bg = c.warning, bold = true })
  hl("TodoFgFIX", { fg = c.error })
  hl("TodoFgHACK", { fg = c.warning })
  hl("TodoFgNOTE", { fg = c.info })
  hl("TodoFgPERF", { fg = c.purple })
  hl("TodoFgTEST", { fg = c.teal })
  hl("TodoFgTODO", { fg = c.yellow })
  hl("TodoFgWARN", { fg = c.warning })
  hl("TodoSignFIX", { fg = c.error })
  hl("TodoSignHACK", { fg = c.warning })
  hl("TodoSignNOTE", { fg = c.info })
  hl("TodoSignPERF", { fg = c.purple })
  hl("TodoSignTEST", { fg = c.teal })
  hl("TodoSignTODO", { fg = c.yellow })
  hl("TodoSignWARN", { fg = c.warning })

  -----------------------------------------------------------------------
  -- Illuminate, Indent, Spectre, BQF, Treesitter context
  -----------------------------------------------------------------------
  hl("IlluminatedWordText", { bg = c.bg_light })
  hl("IlluminatedWordRead", { bg = c.bg_light })
  hl("IlluminatedWordWrite", { bg = c.bg_light, underline = true })

  hl("IblIndent", { fg = c.indent })
  hl("IblWhitespace", { fg = c.indent })
  hl("IblScope", { fg = c.indent_active })
  hl("IndentBlanklineChar", { fg = c.indent })
  hl("IndentBlanklineContextChar", { fg = c.indent_active })

  hl("SpectreSearch", { fg = c.bg, bg = c.search_current })
  hl("SpectreReplace", { fg = c.bg, bg = c.git_add })
  hl("SpectreFile", { fg = c.blue })
  hl("SpectreBorder", { fg = c.border })
  hl("SpectreDir", { fg = c.purple })
  hl("SpectreHeader", { fg = c.blue, bold = true })

  hl("BqfPreviewBorder", { fg = c.border })
  hl("BqfPreviewTitle", { fg = c.blue, bold = true })
  hl("BqfPreviewThumb", { bg = c.selection })
  hl("BqfPreviewSbar", { bg = c.bg_light })
  hl("BqfPreviewCursorLine", { bg = c.cursor_line })
  hl("BqfPreviewRange", { bg = c.selection })
  hl("BqfSign", { fg = c.blue })

  hl("TreesitterContext", { bg = c.bg_light })
  hl("TreesitterContextLineNumber", { fg = c.line_number_current, bg = c.bg_light })
  hl("TreesitterContextSeparator", { fg = c.border })
  hl("TreesitterContextBottom", { underline = true, sp = c.border })

  -----------------------------------------------------------------------
  -- Render Markdown
  -----------------------------------------------------------------------
  hl("RenderMarkdownH1", { fg = c.blue, bold = true })
  hl("RenderMarkdownH2", { fg = c.teal, bold = true })
  hl("RenderMarkdownH3", { fg = c.yellow, bold = true })
  hl("RenderMarkdownH4", { fg = c.orange, bold = true })
  hl("RenderMarkdownH5", { fg = c.purple, bold = true })
  hl("RenderMarkdownH6", { fg = c.pink, bold = true })
  hl("RenderMarkdownCode", { bg = c.bg_light })
  hl("RenderMarkdownCodeInline", { fg = c.orange, bg = c.bg_light })
  hl("RenderMarkdownBullet", { fg = c.purple })
  hl("RenderMarkdownTableHead", { fg = c.blue, bold = true })
  hl("RenderMarkdownTableRow", { fg = c.fg })
  hl("RenderMarkdownSuccess", { fg = c.git_add })
  hl("RenderMarkdownInfo", { fg = c.info })
  hl("RenderMarkdownHint", { fg = c.hint })
  hl("RenderMarkdownWarn", { fg = c.warning })
  hl("RenderMarkdownError", { fg = c.error })
  hl("RenderMarkdownQuote", { fg = c.green, italic = true })

  -----------------------------------------------------------------------
  -- Mason / Lazy / Noice
  -----------------------------------------------------------------------
  hl("MasonHeader", { fg = c.bg, bg = c.blue, bold = true })
  hl("MasonHeaderSecondary", { fg = c.bg, bg = c.purple, bold = true })
  hl("MasonHighlight", { fg = c.blue })
  hl("MasonHighlightBlock", { fg = c.bg, bg = c.blue })
  hl("MasonHighlightBlockBold", { fg = c.bg, bg = c.blue, bold = true })
  hl("MasonHighlightSecondary", { fg = c.purple })
  hl("MasonHighlightBlockSecondary", { fg = c.bg, bg = c.purple })
  hl("MasonMuted", { fg = c.fg_dark })
  hl("MasonMutedBlock", { fg = c.fg_dark, bg = c.bg_light })
  hl("MasonError", { fg = c.error })
  hl("MasonWarning", { fg = c.warning })

  hl("LazyProgressTodo", { fg = c.fg_dark })
  hl("LazyProgressDone", { fg = c.git_add })
  hl("LazyCommit", { fg = c.yellow })
  hl("LazyCommitScope", { fg = c.purple, italic = true })
  hl("LazyCommitType", { fg = c.blue, bold = true })
  hl("LazyCommitIssue", { fg = c.pink })
  hl("LazyButton", { fg = c.bg, bg = c.blue })
  hl("LazyButtonActive", { fg = c.bg, bg = c.purple, bold = true })
  hl("LazyH1", { fg = c.bg, bg = c.blue, bold = true })
  hl("LazyH2", { fg = c.purple, bold = true })
  hl("LazyProp", { fg = c.teal })
  hl("LazyValue", { fg = c.fg })
  hl("LazyDir", { fg = c.blue })
  hl("LazyUrl", { fg = c.blue, underline = true })
  hl("LazySpecial", { fg = c.teal })
  hl("LazyComment", { fg = c.green, italic = true })

  hl("NoiceCmdlineIcon", { fg = c.blue })
  hl("NoiceCmdlinePopup", { fg = c.fg, bg = c.bg_popup })
  hl("NoiceCmdlinePopupBorder", { fg = c.border, bg = c.bg_popup })
  hl("NoiceCmdlinePopupTitle", { fg = c.blue, bold = true })
  hl("NoiceConfirm", { fg = c.fg, bg = c.bg_popup })
  hl("NoiceConfirmBorder", { fg = c.border, bg = c.bg_popup })
  hl("NoicePopup", { fg = c.fg, bg = c.bg_popup })
  hl("NoicePopupBorder", { fg = c.border, bg = c.bg_popup })
  hl("NoiceFormatLevelError", { fg = c.error })
  hl("NoiceFormatLevelWarn", { fg = c.warning })
  hl("NoiceFormatLevelInfo", { fg = c.info })
  hl("NoiceFormatLevelDebug", { fg = c.hint })
  hl("NoiceLspProgressClient", { fg = c.purple })
  hl("NoiceLspProgressSpinner", { fg = c.blue })
  hl("NoiceVirtualText", { fg = c.fg_dark })

  -----------------------------------------------------------------------
  -- Blink.cmp
  -----------------------------------------------------------------------
  hl("BlinkCmpMenu", { fg = c.fg, bg = c.bg_popup })
  hl("BlinkCmpMenuBorder", { fg = c.border, bg = c.bg_popup })
  hl("BlinkCmpMenuSelection", { fg = c.fg_light, bg = c.selection })
  hl("BlinkCmpScrollBarThumb", { bg = c.blue })
  hl("BlinkCmpScrollBarGutter", { bg = c.bg_light })
  hl("BlinkCmpLabel", { fg = c.fg })
  hl("BlinkCmpLabelDeprecated", { fg = c.fg_dark, strikethrough = true })
  hl("BlinkCmpLabelMatch", { fg = c.yellow, bold = true })
  hl("BlinkCmpLabelDetail", { fg = c.fg_dark })
  hl("BlinkCmpLabelDescription", { fg = c.fg_dark })
  hl("BlinkCmpKind", { fg = c.blue })
  hl("BlinkCmpKindText", { fg = c.fg })
  hl("BlinkCmpKindMethod", { fg = c.yellow })
  hl("BlinkCmpKindFunction", { fg = c.yellow })
  hl("BlinkCmpKindConstructor", { fg = c.yellow })
  hl("BlinkCmpKindField", { fg = c.light_blue })
  hl("BlinkCmpKindVariable", { fg = c.light_blue })
  hl("BlinkCmpKindClass", { fg = c.teal })
  hl("BlinkCmpKindInterface", { fg = c.teal })
  hl("BlinkCmpKindModule", { fg = c.teal })
  hl("BlinkCmpKindProperty", { fg = c.light_blue })
  hl("BlinkCmpKindUnit", { fg = c.number_green })
  hl("BlinkCmpKindValue", { fg = c.bright_blue })
  hl("BlinkCmpKindEnum", { fg = c.teal })
  hl("BlinkCmpKindKeyword", { fg = c.purple })
  hl("BlinkCmpKindSnippet", { fg = c.git_add })
  hl("BlinkCmpKindColor", { fg = c.pink })
  hl("BlinkCmpKindFile", { fg = c.blue })
  hl("BlinkCmpKindReference", { fg = c.purple })
  hl("BlinkCmpKindFolder", { fg = c.yellow })
  hl("BlinkCmpKindEnumMember", { fg = c.bright_blue })
  hl("BlinkCmpKindConstant", { fg = c.bright_blue })
  hl("BlinkCmpKindStruct", { fg = c.teal })
  hl("BlinkCmpKindEvent", { fg = c.purple })
  hl("BlinkCmpKindOperator", { fg = c.fg })
  hl("BlinkCmpKindTypeParameter", { fg = c.teal })
  hl("BlinkCmpDoc", { fg = c.fg, bg = c.bg_popup })
  hl("BlinkCmpDocBorder", { fg = c.border, bg = c.bg_popup })
  hl("BlinkCmpDocSeparator", { fg = c.border, bg = c.bg_popup })
  hl("BlinkCmpDocCursorLine", { bg = c.cursor_line })
  hl("BlinkCmpSignatureHelp", { fg = c.fg, bg = c.bg_popup })
  hl("BlinkCmpSignatureHelpBorder", { fg = c.border, bg = c.bg_popup })
  hl("BlinkCmpSignatureHelpActiveParameter", { fg = c.yellow, bold = true })
  hl("BlinkCmpGhostText", { fg = c.fg_dark, italic = true })

  -----------------------------------------------------------------------
  -- Navic / Aerial / Outline (breadcrumbs & symbol trees)
  -----------------------------------------------------------------------
  for _, prefix in ipairs { "Navic", "Aerial" } do
    hl(prefix .. "IconsFile", { fg = c.blue })
    hl(prefix .. "IconsModule", { fg = c.teal })
    hl(prefix .. "IconsNamespace", { fg = c.teal })
    hl(prefix .. "IconsPackage", { fg = c.teal })
    hl(prefix .. "IconsClass", { fg = c.teal, bold = true })
    hl(prefix .. "IconsMethod", { fg = c.yellow })
    hl(prefix .. "IconsProperty", { fg = c.light_blue })
    hl(prefix .. "IconsField", { fg = c.light_blue })
    hl(prefix .. "IconsConstructor", { fg = c.yellow, bold = true })
    hl(prefix .. "IconsEnum", { fg = c.teal })
    hl(prefix .. "IconsInterface", { fg = c.teal })
    hl(prefix .. "IconsFunction", { fg = c.yellow })
    hl(prefix .. "IconsVariable", { fg = c.light_blue })
    hl(prefix .. "IconsConstant", { fg = c.bright_blue })
    hl(prefix .. "IconsString", { fg = c.orange })
    hl(prefix .. "IconsNumber", { fg = c.number_green })
    hl(prefix .. "IconsBoolean", { fg = c.blue })
    hl(prefix .. "IconsArray", { fg = c.fg })
    hl(prefix .. "IconsObject", { fg = c.fg })
    hl(prefix .. "IconsKey", { fg = c.light_blue })
    hl(prefix .. "IconsNull", { fg = c.blue })
    hl(prefix .. "IconsEnumMember", { fg = c.bright_blue })
    hl(prefix .. "IconsStruct", { fg = c.teal, bold = true })
    hl(prefix .. "IconsEvent", { fg = c.purple })
    hl(prefix .. "IconsOperator", { fg = c.fg })
    hl(prefix .. "IconsTypeParameter", { fg = c.teal })
  end
  hl("NavicText", { fg = c.fg })
  hl("NavicSeparator", { fg = c.fg_dark })
  hl("AerialLine", { bg = c.bg_light })
  hl("AerialLineNC", { bg = c.bg_light })
  hl("AerialGuide", { fg = c.indent })
  hl("OutlineGuides", { fg = c.indent })
  hl("OutlineFoldMarker", { fg = c.blue })
  hl("OutlineDetails", { fg = c.fg_dark })

  -----------------------------------------------------------------------
  -- Misc plugins also covered by the existing themes
  -----------------------------------------------------------------------
  hl("DressingBorder", { fg = c.border, bg = c.bg_popup })
  hl("DressingTitle", { fg = c.blue, bold = true })
  hl("DressingSelectIdx", { fg = c.purple })
  hl("DressingSelectText", { fg = c.fg })

  hl("AvanteTitle", { fg = c.blue, bold = true })
  hl("AvanteReversedTitle", { fg = c.bg, bg = c.blue, bold = true })
  hl("AvanteSubtitle", { fg = c.teal })
  hl("AvanteThirdTitle", { fg = c.yellow })
  hl("AvanteConflictCurrent", { fg = c.git_add })
  hl("AvanteConflictIncoming", { fg = c.git_change })
  hl("AvanteConflictAncestor", { fg = c.purple })

  hl("ClaudeCodeNormal", { fg = c.fg, bg = c.bg_popup })
  hl("ClaudeCodeBorder", { fg = c.border, bg = c.bg_popup })
  hl("ClaudeCodeTitle", { fg = c.purple, bg = c.bg_popup, bold = true })
  hl("ClaudeCodePrompt", { fg = c.blue })
  hl("ClaudeCodeResponse", { fg = c.fg })
  hl("ClaudeCodeCode", { fg = c.orange, bg = c.bg_light })
  hl("ClaudeCodeError", { fg = c.error })
  hl("ClaudeCodeWarning", { fg = c.warning })
  hl("ClaudeCodeInfo", { fg = c.info })
  hl("ClaudeCodeSuccess", { fg = c.git_add })

  hl("CopilotSuggestion", { fg = c.fg_dark, italic = true })
  hl("CopilotAnnotation", { fg = c.fg_dark, italic = true })

  hl("AlphaShortcut", { fg = c.blue })
  hl("AlphaHeader", { fg = c.purple })
  hl("AlphaHeaderLabel", { fg = c.teal })
  hl("AlphaFooter", { fg = c.green, italic = true })
  hl("AlphaButtons", { fg = c.fg })

  -----------------------------------------------------------------------
  -- Snacks Picker
  -- The picker's defaults link many groups (file, dirname, hidden paths)
  -- to NonText/Conceal, which the editor base intentionally renders very
  -- dim. That makes filenames disappear in the picker — override the
  -- key text groups so they stay readable on every variant.
  -----------------------------------------------------------------------
  hl("SnacksPicker", { fg = c.fg, bg = c.bg_popup })
  hl("SnacksPickerNormal", { fg = c.fg, bg = c.bg_popup })
  hl("SnacksPickerBorder", { fg = c.border, bg = c.bg_popup })
  hl("SnacksPickerTitle", { fg = c.bg, bg = c.blue, bold = true })
  hl("SnacksPickerFooter", { fg = c.fg_dark, bg = c.bg_popup })

  -- List window (results)
  hl("SnacksPickerList", { fg = c.fg, bg = c.bg_popup })
  hl("SnacksPickerListNormal", { fg = c.fg, bg = c.bg_popup })
  hl("SnacksPickerListBorder", { fg = c.border, bg = c.bg_popup })
  hl("SnacksPickerListTitle", { fg = c.bg, bg = c.blue, bold = true })
  hl("SnacksPickerListCursorLine", { bg = c.selection })

  -- Input window (prompt)
  hl("SnacksPickerInput", { fg = c.fg, bg = c.bg_popup })
  hl("SnacksPickerInputNormal", { fg = c.fg, bg = c.bg_popup })
  hl("SnacksPickerInputBorder", { fg = c.border, bg = c.bg_popup })
  hl("SnacksPickerInputTitle", { fg = c.bg, bg = c.blue, bold = true })
  hl("SnacksPickerInputCursorLine", { bg = c.bg_popup })
  hl("SnacksPickerInputSearch", { fg = c.yellow, bold = true })
  hl("SnacksPickerPrompt", { fg = c.blue, bold = true })

  -- Preview window
  hl("SnacksPickerPreview", { fg = c.fg, bg = c.bg })
  hl("SnacksPickerPreviewNormal", { fg = c.fg, bg = c.bg })
  hl("SnacksPickerPreviewBorder", { fg = c.border, bg = c.bg })
  hl("SnacksPickerPreviewTitle", { fg = c.bg, bg = c.purple, bold = true })
  hl("SnacksPickerPreviewCursorLine", { bg = c.cursor_line })

  -- The headline fix: filenames, dirnames, and path-component groups.
  hl("SnacksPickerFile", { fg = c.fg })           -- basename of a file (was invisible)
  hl("SnacksPickerDir", { fg = c.fg_dark })       -- dirname of a path  (was invisible)
  hl("SnacksPickerDirectory", { fg = c.blue })    -- standalone directory entries
  hl("SnacksPickerPathHidden", { fg = c.fg_dark, italic = true })
  hl("SnacksPickerPathIgnored", { fg = c.fg_dark, italic = true })
  hl("SnacksPickerLink", { fg = c.teal, italic = true })
  hl("SnacksPickerLinkBroken", { fg = c.error, italic = true })

  -- Selection / highlighting
  hl("SnacksPickerMatch", { fg = c.yellow, bold = true })
  hl("SnacksPickerSelected", { fg = c.purple, bold = true })
  hl("SnacksPickerUnselected", { fg = c.fg_dark })
  hl("SnacksPickerTotals", { fg = c.fg_dark })
  hl("SnacksPickerIdx", { fg = c.number_green })
  hl("SnacksPickerRow", { fg = c.number_green })
  hl("SnacksPickerCol", { fg = c.fg_dark })
  hl("SnacksPickerDelim", { fg = c.fg_dark })
  hl("SnacksPickerComment", { fg = c.green, italic = true })
  hl("SnacksPickerDesc", { fg = c.fg_dark })
  hl("SnacksPickerDimmed", { fg = c.fg_dark })
  hl("SnacksPickerSpecial", { fg = c.purple })
  hl("SnacksPickerLabel", { fg = c.purple, bold = true })
  hl("SnacksPickerSpinner", { fg = c.blue })
  hl("SnacksPickerTree", { fg = c.fg_dark })
  hl("SnacksPickerBold", { fg = c.fg, bold = true })
  hl("SnacksPickerItalic", { fg = c.fg, italic = true })
  hl("SnacksPickerCode", { fg = c.orange })
  hl("SnacksPickerToggle", { fg = c.bg, bg = c.blue, bold = true })

  -- Git groups inside the picker
  hl("SnacksPickerGitCommit", { fg = c.yellow })
  hl("SnacksPickerGitBranch", { fg = c.purple, bold = true })
  hl("SnacksPickerGitBranchCurrent", { fg = c.git_add, bold = true })
  hl("SnacksPickerGitDate", { fg = c.teal })
  hl("SnacksPickerGitAuthor", { fg = c.orange })
  hl("SnacksPickerGitMsg", { fg = c.fg })
  hl("SnacksPickerGitType", { fg = c.blue, bold = true })
  hl("SnacksPickerGitScope", { fg = c.purple, italic = true })
  hl("SnacksPickerGitBreaking", { fg = c.error, bold = true })
  hl("SnacksPickerGitIssue", { fg = c.pink })
  hl("SnacksPickerGitDetached", { fg = c.warning })
  hl("SnacksPickerGitStatus", { fg = c.purple })
  hl("SnacksPickerGitStatusAdded", { fg = c.git_add })
  hl("SnacksPickerGitStatusModified", { fg = c.warning })
  hl("SnacksPickerGitStatusDeleted", { fg = c.git_delete })
  hl("SnacksPickerGitStatusRenamed", { fg = c.purple })
  hl("SnacksPickerGitStatusUntracked", { fg = c.fg_dark })
  hl("SnacksPickerGitStatusIgnored", { fg = c.fg_dark })
  hl("SnacksPickerGitStatusUnmerged", { fg = c.error })
  hl("SnacksPickerGitStatusStaged", { fg = c.hint })

  -- Snacks notifier (already covered partially elsewhere; ensure parity)
  hl("SnacksNotifierInfo", { fg = c.info })
  hl("SnacksNotifierWarn", { fg = c.warning })
  hl("SnacksNotifierError", { fg = c.error })
  hl("SnacksNotifierDebug", { fg = c.hint })
  hl("SnacksNotifierTrace", { fg = c.purple })
  hl("SnacksNotifierTitle", { fg = c.fg_alt, bold = true })
  hl("SnacksNotifierBorder", { fg = c.border })
  hl("SnacksNotifierFooter", { fg = c.fg_dark })
  hl("SnacksNotifierIcon", { fg = c.blue })

  -----------------------------------------------------------------------
  -- Terminal palette
  -----------------------------------------------------------------------
  for i = 0, 15 do
    vim.g["terminal_color_" .. i] = c.term[i + 1]
  end
end

-- ---------------------------------------------------------------------------
-- Additional variants
-- ---------------------------------------------------------------------------

-- Dark Modern — VSCode's newer default since 2022. Same syntax palette as
-- Dark+, but the editor chrome is flatter / more neutral (no blue statusbar
-- when no folder is open, slimmer borders).
local dark_modern = vim.tbl_deep_extend("force", {}, dark, {
  bg = "#1f1f1f",
  bg_alt = "#181818",
  bg_dark = "#141414",
  bg_light = "#2a2a2a",
  bg_popup = "#1f1f1f",
  bg_float = "#1f1f1f",
  bg_statusline = "#181818", -- the modern flat statusbar
  border = "#2b2b2b",
  selection = "#0e3a5f",
  cursor_line = "#232323",
  indent = "#2e2e2e",
  indent_active = "#5a5a5a",
})

-- Light Modern — newer default light theme.
local light_modern = vim.tbl_deep_extend("force", {}, light, {
  bg = "#ffffff",
  bg_alt = "#f8f8f8",
  bg_dark = "#ececec",
  bg_light = "#e8e8e8",
  bg_popup = "#ffffff",
  bg_float = "#ffffff",
  bg_statusline = "#f8f8f8",
  border = "#e5e5e5",
  selection = "#add6ff",
  cursor_line = "#f5f5f5",
  indent = "#e5e5e5",
  indent_active = "#a0a0a0",
})

-- Monokai — VSCode's built-in Monokai (token colors from monokai-color-theme).
local monokai = {
  bg = "#272822",
  bg_alt = "#1e1f1c",
  bg_dark = "#1e1f1c",
  bg_light = "#3e3d32",
  bg_popup = "#1e1f1c",
  bg_float = "#1e1f1c",
  bg_statusline = "#414339",

  fg = "#f8f8f2",
  fg_alt = "#f8f8f2",
  fg_dark = "#75715e",
  fg_light = "#ffffff",

  blue = "#66d9ef", -- types (cyan, italic in real Monokai)
  light_blue = "#fd971f", -- parameters (orange)
  bright_blue = "#ae81ff", -- constants (purple)
  teal = "#66d9ef",
  green = "#88846f", -- comments
  number_green = "#ae81ff", -- numbers (purple)
  yellow = "#a6e22e", -- functions (lime)
  orange = "#e6db74", -- strings (yellow)
  red = "#f92672", -- errors / keywords
  regex_red = "#e6db74",
  purple = "#f92672", -- control flow (pink)
  pink = "#f92672",

  border = "#3e3d32",
  selection = "#49483e",
  selection_inactive = "#414339",
  search = "#878b91",
  search_current = "#e6db74",
  match_paren = "#75715e",
  cursor_line = "#3e3d32",
  line_number = "#90908a",
  line_number_current = "#f8f8f2",
  indent = "#3b3a32",
  indent_active = "#75715e",

  git_add = "#a6e22e",
  git_change = "#66d9ef",
  git_delete = "#f92672",
  git_add_bg = "#293728",
  git_change_bg = "#1c3038",
  git_delete_bg = "#3a1e2a",

  error = "#f92672",
  warning = "#e6db74",
  info = "#66d9ef",
  hint = "#a6e22e",

  term = {
    "#272822", "#f92672", "#a6e22e", "#f4bf75",
    "#66d9ef", "#ae81ff", "#a1efe4", "#f8f8f2",
    "#75715e", "#f92672", "#a6e22e", "#f4bf75",
    "#66d9ef", "#ae81ff", "#a1efe4", "#f9f8f5",
  },
}

-- Abyss — VSCode's built-in deep-blue theme.
local abyss = {
  bg = "#000c18",
  bg_alt = "#051336",
  bg_dark = "#000511",
  bg_light = "#082050",
  bg_popup = "#051336",
  bg_float = "#051336",
  bg_statusline = "#1c1c2a",

  fg = "#6688cc",
  fg_alt = "#9aa5ce",
  fg_dark = "#406385",
  fg_light = "#ffffff",

  blue = "#225588", -- keywords
  light_blue = "#2277ff", -- variables
  bright_blue = "#82aaff", -- constants
  teal = "#ffeebb", -- types
  green = "#384887", -- comments
  number_green = "#f280d0", -- numbers (pink in Abyss)
  yellow = "#ddbb88", -- functions
  orange = "#22aa44", -- strings (green!)
  red = "#ff6688", -- errors
  regex_red = "#ff6688",
  purple = "#9966b8", -- control flow
  pink = "#225588",

  border = "#082050",
  selection = "#770811",
  selection_inactive = "#082050",
  search = "#ff009f",
  search_current = "#e3008c",
  match_paren = "#082050",
  cursor_line = "#082050",
  line_number = "#406385",
  line_number_current = "#949494",
  indent = "#0f1c4d",
  indent_active = "#406385",

  git_add = "#37a554",
  git_change = "#52a4c4",
  git_delete = "#a72253",
  git_add_bg = "#0a2818",
  git_change_bg = "#062538",
  git_delete_bg = "#2a0814",

  error = "#a72253",
  warning = "#ff8c00",
  info = "#82aaff",
  hint = "#ffeebb",

  term = {
    "#000c18", "#a72253", "#37a554", "#dbb774",
    "#225588", "#9966b8", "#52a4c4", "#6688cc",
    "#406385", "#a72253", "#37a554", "#dbb774",
    "#225588", "#9966b8", "#52a4c4", "#ffffff",
  },
}

-- True Dark — pure #000 background, #fff foreground, fully saturated
-- primary/secondary accent colors. No greys, no off-tones, no warmth.
-- Maximum contrast, OLED-friendly.
local true_dark = {
  bg = "#000000",
  bg_alt = "#000000",
  bg_dark = "#000000",
  bg_light = "#1a1a1a",
  bg_popup = "#0a0a0a",
  bg_float = "#0a0a0a",
  bg_statusline = "#000000",

  fg = "#ffffff",
  fg_alt = "#ffffff",
  fg_dark = "#888888",
  fg_light = "#ffffff",

  -- Pure saturated syntax colors
  blue = "#00aaff", -- keywords (pure azure)
  light_blue = "#66ddff", -- variables (cyan-ish, distinct from blue)
  bright_blue = "#00ffff", -- constants (pure cyan)
  teal = "#00ffcc", -- types (pure aqua)
  green = "#00cc66", -- comments (pure green, slightly dim for readability)
  number_green = "#00ff00", -- numbers (pure green)
  yellow = "#ffff00", -- functions (pure yellow)
  orange = "#ff8800", -- strings (pure orange)
  red = "#ff0033", -- errors (pure red)
  regex_red = "#ff3366",
  purple = "#ff00ff", -- control flow (pure magenta)
  pink = "#ff66cc",

  border = "#222222",
  selection = "#003366",
  selection_inactive = "#1a1a1a",
  search = "#665500",
  search_current = "#ffaa00",
  match_paren = "#444444",
  cursor_line = "#0f0f0f",
  line_number = "#666666",
  line_number_current = "#ffffff",
  indent = "#1a1a1a",
  indent_active = "#444444",

  git_add = "#00ff00",
  git_change = "#00aaff",
  git_delete = "#ff0033",
  git_add_bg = "#002200",
  git_change_bg = "#001a33",
  git_delete_bg = "#220011",

  error = "#ff0033",
  warning = "#ffaa00",
  info = "#00aaff",
  hint = "#00ffcc",

  term = {
    "#000000", "#ff0033", "#00ff00", "#ffff00",
    "#00aaff", "#ff00ff", "#00ffff", "#ffffff",
    "#666666", "#ff3366", "#33ff33", "#ffff33",
    "#33bbff", "#ff33ff", "#33ffff", "#ffffff",
  },
}

-- True Light — pure #fff background, #000 foreground. Same philosophy as
-- True Dark but tone-adjusted so each color stays readable on white
-- (pure yellow/cyan disappear on white, so functions become deep gold and
-- types become teal).
local true_light = {
  bg = "#ffffff",
  bg_alt = "#ffffff",
  bg_dark = "#ffffff",
  bg_light = "#e8e8e8",
  bg_popup = "#f5f5f5",
  bg_float = "#f5f5f5",
  bg_statusline = "#ffffff",

  fg = "#000000",
  fg_alt = "#000000",
  fg_dark = "#666666",
  fg_light = "#000000",

  blue = "#0000ff", -- keywords (pure blue)
  light_blue = "#0066cc", -- variables
  bright_blue = "#003399", -- constants (deep blue)
  teal = "#008080", -- types (pure teal)
  green = "#008000", -- comments (pure green)
  number_green = "#006600", -- numbers (deep green)
  yellow = "#996600", -- functions (deep gold — pure yellow disappears)
  orange = "#cc4400", -- strings (deep orange)
  red = "#cc0000", -- errors
  regex_red = "#990033",
  purple = "#800080", -- control flow (pure purple)
  pink = "#cc0066",

  border = "#cccccc",
  selection = "#cce5ff",
  selection_inactive = "#e8e8e8",
  search = "#ffff00",
  search_current = "#ffaa00",
  match_paren = "#bbbbbb",
  cursor_line = "#f5f5f5",
  line_number = "#999999",
  line_number_current = "#000000",
  indent = "#e8e8e8",
  indent_active = "#888888",

  git_add = "#008000",
  git_change = "#0000ff",
  git_delete = "#cc0000",
  git_add_bg = "#e6ffe6",
  git_change_bg = "#e6f0ff",
  git_delete_bg = "#ffe6e6",

  error = "#cc0000",
  warning = "#cc6600",
  info = "#0000ff",
  hint = "#008080",

  term = {
    "#000000", "#cc0000", "#008000", "#996600",
    "#0000ff", "#800080", "#008080", "#000000",
    "#666666", "#ff0000", "#00cc00", "#cc9900",
    "#0066ff", "#cc00cc", "#00cccc", "#000000",
  },
}

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

M.palettes = {
  ["vscode"] = { palette = dark, background = "dark" },
  ["vscode-light"] = { palette = light, background = "light" },
  ["vscode-dark-modern"] = { palette = dark_modern, background = "dark" },
  ["vscode-light-modern"] = { palette = light_modern, background = "light" },
  ["vscode-monokai"] = { palette = monokai, background = "dark" },
  ["vscode-abyss"] = { palette = abyss, background = "dark" },
  ["vscode-true-dark"] = { palette = true_dark, background = "dark" },
  ["vscode-true-light"] = { palette = true_light, background = "light" },
}

-- Backwards-compatible aliases for the original short names.
local aliases = { dark = "vscode", light = "vscode-light" }

function M.get_palette(name)
  name = aliases[name] or name or "vscode"
  local entry = M.palettes[name]
  return entry and entry.palette or nil
end

function M.load(name)
  name = aliases[name] or name or "vscode"
  local entry = M.palettes[name]
  if not entry then
    vim.notify("vscode theme: unknown variant '" .. name .. "'", vim.log.levels.ERROR)
    return
  end
  apply(entry.palette, name, entry.background)
end

function M.setup(opts)
  opts = opts or {}
  M.load(opts.variant or opts.name)
end

return M
