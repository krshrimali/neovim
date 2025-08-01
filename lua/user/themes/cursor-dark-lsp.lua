-- LSP and CoC.nvim highlights for Cursor Dark Theme
local colors = require("user.themes.cursor-dark").colors

local M = {}

-- Helper function to create highlight groups
local function hl(group, opts)
  if opts.link then
    vim.api.nvim_set_hl(0, group, { link = opts.link })
  else
    vim.api.nvim_set_hl(0, group, opts)
  end
end

function M.setup()
  -- LSP Diagnostic highlights
  hl("DiagnosticError", { fg = colors.error })
  hl("DiagnosticWarn", { fg = colors.warning })
  hl("DiagnosticInfo", { fg = colors.info })
  hl("DiagnosticHint", { fg = colors.hint })
  hl("DiagnosticOk", { fg = colors.green })
  
  hl("DiagnosticVirtualTextError", { fg = colors.error, italic = true })
  hl("DiagnosticVirtualTextWarn", { fg = colors.warning, italic = true })
  hl("DiagnosticVirtualTextInfo", { fg = colors.info, italic = true })
  hl("DiagnosticVirtualTextHint", { fg = colors.hint, italic = true })
  hl("DiagnosticVirtualTextOk", { fg = colors.green, italic = true })
  
  hl("DiagnosticUnderlineError", { undercurl = true, sp = colors.error })
  hl("DiagnosticUnderlineWarn", { undercurl = true, sp = colors.warning })
  hl("DiagnosticUnderlineInfo", { undercurl = true, sp = colors.info })
  hl("DiagnosticUnderlineHint", { undercurl = true, sp = colors.hint })
  hl("DiagnosticUnderlineOk", { undercurl = true, sp = colors.green })
  
  hl("DiagnosticFloatingError", { fg = colors.error })
  hl("DiagnosticFloatingWarn", { fg = colors.warning })
  hl("DiagnosticFloatingInfo", { fg = colors.info })
  hl("DiagnosticFloatingHint", { fg = colors.hint })
  hl("DiagnosticFloatingOk", { fg = colors.green })
  
  hl("DiagnosticSignError", { fg = colors.error })
  hl("DiagnosticSignWarn", { fg = colors.warning })
  hl("DiagnosticSignInfo", { fg = colors.info })
  hl("DiagnosticSignHint", { fg = colors.hint })
  hl("DiagnosticSignOk", { fg = colors.green })
  
  -- LSP Semantic tokens
  hl("@lsp.type.class", { fg = colors.blue })
  hl("@lsp.type.decorator", { fg = colors.yellow })
  hl("@lsp.type.enum", { fg = colors.blue })
  hl("@lsp.type.enumMember", { fg = colors.cyan })
  hl("@lsp.type.function", { fg = colors.yellow })
  hl("@lsp.type.interface", { fg = colors.blue })
  hl("@lsp.type.macro", { fg = colors.purple })
  hl("@lsp.type.method", { fg = colors.yellow })
  hl("@lsp.type.namespace", { fg = colors.blue })
  hl("@lsp.type.parameter", { fg = colors.fg })
  hl("@lsp.type.property", { fg = colors.cyan })
  hl("@lsp.type.struct", { fg = colors.blue })
  hl("@lsp.type.type", { fg = colors.blue })
  hl("@lsp.type.typeParameter", { fg = colors.blue })
  hl("@lsp.type.variable", { fg = colors.fg })
  
  hl("@lsp.mod.declaration", { bold = true })
  hl("@lsp.mod.definition", { bold = true })
  hl("@lsp.mod.readonly", { italic = true })
  hl("@lsp.mod.static", { italic = true })
  hl("@lsp.mod.deprecated", { strikethrough = true })
  hl("@lsp.mod.abstract", { italic = true })
  hl("@lsp.mod.async", { italic = true })
  hl("@lsp.mod.modification", { underline = true })
  hl("@lsp.mod.documentation", { italic = true })
  hl("@lsp.mod.defaultLibrary", { italic = true })
  
  -- LSP References
  hl("LspReferenceText", { bg = colors.cursor_line })
  hl("LspReferenceRead", { bg = colors.cursor_line })
  hl("LspReferenceWrite", { bg = colors.cursor_line, underline = true })
  
  -- LSP Code Lens
  hl("LspCodeLens", { fg = colors.fg_dark, italic = true })
  hl("LspCodeLensSeparator", { fg = colors.fg_dark, italic = true })
  
  -- LSP Signature Help
  hl("LspSignatureActiveParameter", { fg = colors.yellow, bold = true })
  
  -- LSP Inlay Hints
  hl("LspInlayHint", { fg = colors.fg_dark, italic = true })
  
  -- CoC.nvim specific highlights
  hl("CocErrorSign", { fg = colors.error })
  hl("CocWarningSign", { fg = colors.warning })
  hl("CocInfoSign", { fg = colors.info })
  hl("CocHintSign", { fg = colors.hint })
  
  hl("CocErrorFloat", { fg = colors.error, bg = colors.bg_popup })
  hl("CocWarningFloat", { fg = colors.warning, bg = colors.bg_popup })
  hl("CocInfoFloat", { fg = colors.info, bg = colors.bg_popup })
  hl("CocHintFloat", { fg = colors.hint, bg = colors.bg_popup })
  
  hl("CocErrorVirtualText", { fg = colors.error, italic = true })
  hl("CocWarningVirtualText", { fg = colors.warning, italic = true })
  hl("CocInfoVirtualText", { fg = colors.info, italic = true })
  hl("CocHintVirtualText", { fg = colors.hint, italic = true })
  
  hl("CocErrorLine", { bg = colors.bg_light })
  hl("CocWarningLine", { bg = colors.bg_light })
  hl("CocInfoLine", { bg = colors.bg_light })
  hl("CocHintLine", { bg = colors.bg_light })
  
  hl("CocErrorHighlight", { undercurl = true, sp = colors.error })
  hl("CocWarningHighlight", { undercurl = true, sp = colors.warning })
  hl("CocInfoHighlight", { undercurl = true, sp = colors.info })
  hl("CocHintHighlight", { undercurl = true, sp = colors.hint })
  
  hl("CocHighlightText", { bg = colors.cursor_line })
  hl("CocHighlightRead", { bg = colors.cursor_line })
  hl("CocHighlightWrite", { bg = colors.cursor_line, underline = true })
  
  hl("CocCodeLens", { fg = colors.fg_dark, italic = true })
  hl("CocInlayHint", { fg = colors.fg_dark, italic = true })
  
  -- CoC floating windows
  hl("CocFloating", { fg = colors.fg, bg = colors.bg_popup })
  hl("CocFloatingBorder", { fg = colors.border, bg = colors.bg_popup })
  hl("CocFloatingDividingLine", { fg = colors.border })
  
  -- CoC menu
  hl("CocMenuSel", { fg = colors.fg_light, bg = colors.selection })
  hl("CocSearch", { fg = colors.yellow })
  
  -- CoC list
  hl("CocListMode", { fg = colors.blue, bold = true })
  hl("CocListPath", { fg = colors.cyan })
  hl("CocSelectedText", { fg = colors.purple })
  hl("CocListsLine", { fg = colors.fg })
  hl("CocListsDesc", { fg = colors.fg_dark })
  
  -- CoC tree
  hl("CocTreeTitle", { fg = colors.blue, bold = true })
  hl("CocTreeDescription", { fg = colors.fg_dark })
  hl("CocTreeOpenClose", { fg = colors.blue })
  hl("CocTreeSelected", { bg = colors.selection })
  
  -- CoC symbols
  hl("CocSymbolDefault", { fg = colors.fg })
  hl("CocSymbolFile", { fg = colors.blue })
  hl("CocSymbolModule", { fg = colors.blue })
  hl("CocSymbolNamespace", { fg = colors.blue })
  hl("CocSymbolPackage", { fg = colors.blue })
  hl("CocSymbolClass", { fg = colors.blue })
  hl("CocSymbolMethod", { fg = colors.yellow })
  hl("CocSymbolProperty", { fg = colors.cyan })
  hl("CocSymbolField", { fg = colors.cyan })
  hl("CocSymbolConstructor", { fg = colors.yellow })
  hl("CocSymbolEnum", { fg = colors.blue })
  hl("CocSymbolInterface", { fg = colors.blue })
  hl("CocSymbolFunction", { fg = colors.yellow })
  hl("CocSymbolVariable", { fg = colors.fg })
  hl("CocSymbolConstant", { fg = colors.cyan })
  hl("CocSymbolString", { fg = colors.orange })
  hl("CocSymbolNumber", { fg = colors.cyan })
  hl("CocSymbolBoolean", { fg = colors.blue })
  hl("CocSymbolArray", { fg = colors.fg })
  hl("CocSymbolObject", { fg = colors.fg })
  hl("CocSymbolKey", { fg = colors.cyan })
  hl("CocSymbolNull", { fg = colors.blue })
  hl("CocSymbolEnumMember", { fg = colors.cyan })
  hl("CocSymbolStruct", { fg = colors.blue })
  hl("CocSymbolEvent", { fg = colors.purple })
  hl("CocSymbolOperator", { fg = colors.fg })
  hl("CocSymbolTypeParameter", { fg = colors.blue })
  
  -- CoC completion
  hl("CocPumMenu", { fg = colors.fg, bg = colors.bg_popup })
  hl("CocPumSearch", { fg = colors.yellow })
  hl("CocPumDetail", { fg = colors.fg_dark })
  hl("CocPumKind", { fg = colors.blue })
  hl("CocPumExtra", { fg = colors.fg_dark })
  hl("CocPumFloating", { fg = colors.fg, bg = colors.bg_popup })
  hl("CocPumShortcut", { fg = colors.purple })
  hl("CocPumDeprecated", { fg = colors.fg_dark, strikethrough = true })
  
  -- CoC snippets
  hl("CocSnippetVisual", { bg = colors.selection })
  
  -- CoC git
  hl("CocGitAddedSign", { fg = colors.git_add })
  hl("CocGitChangeRemovedSign", { fg = colors.git_change })
  hl("CocGitChangedSign", { fg = colors.git_change })
  hl("CocGitRemovedSign", { fg = colors.git_delete })
  hl("CocGitTopRemovedSign", { fg = colors.git_delete })
  
  -- CoC semantic highlighting
  hl("CocSem_namespace", { fg = colors.blue })
  hl("CocSem_type", { fg = colors.blue })
  hl("CocSem_class", { fg = colors.blue })
  hl("CocSem_enum", { fg = colors.blue })
  hl("CocSem_interface", { fg = colors.blue })
  hl("CocSem_struct", { fg = colors.blue })
  hl("CocSem_typeParameter", { fg = colors.blue })
  hl("CocSem_parameter", { fg = colors.fg })
  hl("CocSem_variable", { fg = colors.fg })
  hl("CocSem_property", { fg = colors.cyan })
  hl("CocSem_enumMember", { fg = colors.cyan })
  hl("CocSem_event", { fg = colors.purple })
  hl("CocSem_function", { fg = colors.yellow })
  hl("CocSem_method", { fg = colors.yellow })
  hl("CocSem_macro", { fg = colors.purple })
  hl("CocSem_keyword", { fg = colors.blue })
  hl("CocSem_modifier", { fg = colors.blue })
  hl("CocSem_comment", { fg = colors.green, italic = true })
  hl("CocSem_string", { fg = colors.orange })
  hl("CocSem_number", { fg = colors.cyan })
  hl("CocSem_regexp", { fg = colors.red })
  hl("CocSem_operator", { fg = colors.fg })
  hl("CocSem_decorator", { fg = colors.yellow })
  
  -- CoC modifiers
  hl("CocSem_declaration", { bold = true })
  hl("CocSem_definition", { bold = true })
  hl("CocSem_readonly", { italic = true })
  hl("CocSem_static", { italic = true })
  hl("CocSem_deprecated", { strikethrough = true })
  hl("CocSem_abstract", { italic = true })
  hl("CocSem_async", { italic = true })
  hl("CocSem_modification", { underline = true })
  hl("CocSem_documentation", { italic = true })
  hl("CocSem_defaultLibrary", { italic = true })
  
  -- CoC cursor
  hl("CocCursorRange", { bg = colors.selection })
  
  -- CoC status line
  hl("CocStatusLine", { fg = colors.fg })
  hl("CocStatusLineDiagnosticError", { fg = colors.error })
  hl("CocStatusLineDiagnosticWarning", { fg = colors.warning })
  hl("CocStatusLineDiagnosticInfo", { fg = colors.info })
  hl("CocStatusLineDiagnosticHint", { fg = colors.hint })
  
  -- CoC markdown
  hl("CocMarkdownHeader", { fg = colors.blue, bold = true })
  hl("CocMarkdownLink", { fg = colors.blue, underline = true })
  hl("CocMarkdownCode", { fg = colors.orange, bg = colors.bg_light })
  
  -- CoC hover
  hl("CocHoverRange", { bg = colors.cursor_line })
  
  -- CoC selection range
  hl("CocSelectionRange", { bg = colors.selection })
  
  -- CoC call hierarchy
  hl("CocCallHierarchyIncoming", { fg = colors.green })
  hl("CocCallHierarchyOutgoing", { fg = colors.blue })
  
  -- CoC type hierarchy
  hl("CocTypeHierarchySuper", { fg = colors.blue })
  hl("CocTypeHierarchySub", { fg = colors.cyan })
  
  -- CoC workspace symbols
  hl("CocWorkspaceSymbolsPath", { fg = colors.fg_dark })
  hl("CocWorkspaceSymbolsName", { fg = colors.fg })
  hl("CocWorkspaceSymbolsKind", { fg = colors.blue })
  
  -- CoC references
  hl("CocReferencesPath", { fg = colors.fg_dark })
  hl("CocReferencesName", { fg = colors.fg })
  hl("CocReferencesLine", { fg = colors.line_number })
  
  -- CoC implementations
  hl("CocImplementationsPath", { fg = colors.fg_dark })
  hl("CocImplementationsName", { fg = colors.fg })
  hl("CocImplementationsLine", { fg = colors.line_number })
  
  -- CoC definitions
  hl("CocDefinitionsPath", { fg = colors.fg_dark })
  hl("CocDefinitionsName", { fg = colors.fg })
  hl("CocDefinitionsLine", { fg = colors.line_number })
  
  -- CoC declarations
  hl("CocDeclarationsPath", { fg = colors.fg_dark })
  hl("CocDeclarationsName", { fg = colors.fg })
  hl("CocDeclarationsLine", { fg = colors.line_number })
  
  -- CoC type definitions
  hl("CocTypeDefinitionsPath", { fg = colors.fg_dark })
  hl("CocTypeDefinitionsName", { fg = colors.fg })
  hl("CocTypeDefinitionsLine", { fg = colors.line_number })
  
  -- CoC document symbols
  hl("CocDocumentSymbolsPath", { fg = colors.fg_dark })
  hl("CocDocumentSymbolsName", { fg = colors.fg })
  hl("CocDocumentSymbolsKind", { fg = colors.blue })
  hl("CocDocumentSymbolsLine", { fg = colors.line_number })
  
  -- CoC outline
  hl("CocOutlineName", { fg = colors.fg })
  hl("CocOutlineKind", { fg = colors.blue })
  hl("CocOutlineLine", { fg = colors.line_number })
  hl("CocOutlineIndent", { fg = colors.fg_dark })
  
  -- CoC virtual text
  hl("CocVirtualText", { fg = colors.fg_dark, italic = true })
  
  -- CoC diagnostics display plugin highlights (custom)
  hl("DiagnosticsDisplayError", { fg = colors.error, bg = colors.bg_popup })
  hl("DiagnosticsDisplayWarning", { fg = colors.warning, bg = colors.bg_popup })
  hl("DiagnosticsDisplayInfo", { fg = colors.info, bg = colors.bg_popup })
  hl("DiagnosticsDisplayHint", { fg = colors.hint, bg = colors.bg_popup })
  hl("DiagnosticsDisplayBorder", { fg = colors.border, bg = colors.bg_popup })
  hl("DiagnosticsDisplayTitle", { fg = colors.blue, bg = colors.bg_popup, bold = true })
  hl("DiagnosticsDisplaySource", { fg = colors.fg_dark, bg = colors.bg_popup })
  hl("DiagnosticsDisplayCode", { fg = colors.orange, bg = colors.bg_popup })
  hl("DiagnosticsDisplayMessage", { fg = colors.fg, bg = colors.bg_popup })
  hl("DiagnosticsDisplayLineNumber", { fg = colors.line_number, bg = colors.bg_popup })
  hl("DiagnosticsDisplayFilename", { fg = colors.cyan, bg = colors.bg_popup })
  hl("DiagnosticsDisplaySeverity", { fg = colors.purple, bg = colors.bg_popup, bold = true })
  
  -- Additional LSP-related highlights for better integration
  hl("FloatBorder", { fg = colors.border, bg = colors.bg_popup })
  hl("LspInfoBorder", { fg = colors.border, bg = colors.bg_popup })
  hl("LspInfoTitle", { fg = colors.blue, bg = colors.bg_popup, bold = true })
  hl("LspInfoList", { fg = colors.fg, bg = colors.bg_popup })
  hl("LspInfoTip", { fg = colors.hint, bg = colors.bg_popup, italic = true })
  hl("LspInfoFiletype", { fg = colors.cyan, bg = colors.bg_popup })
  
  -- Copilot highlights
  hl("CopilotSuggestion", { fg = colors.fg_dark, italic = true })
  hl("CopilotAnnotation", { fg = colors.fg_dark, italic = true })
end

return M