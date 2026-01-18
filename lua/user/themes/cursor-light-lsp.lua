-- LSP and CoC.nvim highlights for Cursor Light Theme
local colors = require("user.themes.cursor-light").colors

local M = {}

-- Helper function to create highlight groups (respects transparency)
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
  hl("@lsp.type.class", { fg = colors.blue, bold = true })
  hl("@lsp.type.decorator", { fg = colors.pink })
  hl("@lsp.type.enum", { fg = colors.blue, bold = true })
  hl("@lsp.type.enumMember", { fg = colors.cyan })
  hl("@lsp.type.function", { fg = colors.yellow })
  hl("@lsp.type.interface", { fg = colors.blue, italic = true })
  hl("@lsp.type.macro", { fg = colors.pink })
  hl("@lsp.type.method", { fg = colors.yellow })
  hl("@lsp.type.namespace", { fg = colors.blue, italic = true })
  hl("@lsp.type.parameter", { fg = colors.fg, italic = true })
  hl("@lsp.type.property", { fg = colors.blue })
  hl("@lsp.type.struct", { fg = colors.blue, bold = true })
  hl("@lsp.type.type", { fg = colors.blue })
  hl("@lsp.type.typeParameter", { fg = colors.blue, italic = true })
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

  hl("CocErrorLine", { bg = colors.diff_delete })
  hl("CocWarningLine", { bg = colors.diff_change })
  hl("CocInfoLine", { bg = colors.diff_add })
  hl("CocHintLine", { bg = colors.diff_add })

  hl("CocErrorHighlight", { undercurl = true, sp = colors.error })
  hl("CocWarningHighlight", { undercurl = true, sp = colors.warning })
  hl("CocInfoHighlight", { undercurl = true, sp = colors.info })
  hl("CocHintHighlight", { undercurl = true, sp = colors.hint })

  -- CoC List (FZF-style interface)
  hl("CocListMode", { fg = colors.bg, bg = colors.blue, bold = true })
  hl("CocListPath", { fg = colors.cyan })
  hl("CocListSearch", { fg = colors.yellow, bg = colors.search })
  hl("CocListLine", { fg = colors.fg })
  hl("CocListFgGreen", { fg = colors.green })
  hl("CocListFgRed", { fg = colors.red })
  hl("CocListFgYellow", { fg = colors.yellow })
  hl("CocListFgBlue", { fg = colors.blue })
  hl("CocListFgMagenta", { fg = colors.purple })
  hl("CocListFgCyan", { fg = colors.cyan })
  hl("CocListFgWhite", { fg = colors.fg })
  hl("CocListFgBlack", { fg = colors.fg_dark })
  hl("CocListBgGreen", { bg = colors.diff_add })
  hl("CocListBgRed", { bg = colors.diff_delete })
  hl("CocListBgYellow", { bg = colors.diff_change })
  hl("CocListBgBlue", { bg = colors.selection })
  hl("CocListBgMagenta", { bg = colors.selection })
  hl("CocListBgCyan", { bg = colors.selection })
  hl("CocListBgWhite", { bg = colors.bg_light })
  hl("CocListBgBlack", { bg = colors.bg_dark })

  -- CoC Completion menu
  hl("CocPumMenu", { fg = colors.fg, bg = colors.bg_popup })
  hl("CocPumShortcut", { fg = colors.purple })
  hl("CocPumDetail", { fg = colors.fg_dark })
  hl("CocPumExtra", { fg = colors.cyan })
  hl("CocPumFloating", { fg = colors.fg, bg = colors.bg_popup })
  hl("CocPumSearch", { fg = colors.yellow, bg = colors.search })
  hl("CocPumVirtualText", { fg = colors.fg_dark, italic = true })

  -- CoC Floating windows
  hl("CocFloating", { fg = colors.fg, bg = colors.bg_popup })
  hl("CocFloatingBorder", { fg = colors.border, bg = colors.bg_popup })
  hl("CocFloatingDividingLine", { fg = colors.border })

  -- CoC Hover
  hl("CocHoverRange", { bg = colors.selection })

  -- CoC Cursors (multiple cursors)
  hl("CocCursorRange", { bg = colors.selection })
  hl("CocHighlightText", { bg = colors.cursor_line })
  hl("CocHighlightRead", { bg = colors.cursor_line })
  hl("CocHighlightWrite", { bg = colors.cursor_line, underline = true })

  -- CoC Git integration
  hl("CocGitAddedSign", { fg = colors.git_add })
  hl("CocGitChangeRemovedSign", { fg = colors.git_delete })
  hl("CocGitChangedSign", { fg = colors.git_change })
  hl("CocGitRemovedSign", { fg = colors.git_delete })
  hl("CocGitTopRemovedSign", { fg = colors.git_delete })

  -- CoC Semantic highlighting
  hl("CocSemClass", { fg = colors.blue, bold = true })
  hl("CocSemEnum", { fg = colors.blue, bold = true })
  hl("CocSemInterface", { fg = colors.blue, italic = true })
  hl("CocSemStruct", { fg = colors.blue, bold = true })
  hl("CocSemType", { fg = colors.blue })
  hl("CocSemTypeParameter", { fg = colors.blue, italic = true })
  hl("CocSemParameter", { fg = colors.fg, italic = true })
  hl("CocSemProperty", { fg = colors.blue })
  hl("CocSemEnumMember", { fg = colors.cyan })
  hl("CocSemEvent", { fg = colors.yellow })
  hl("CocSemFunction", { fg = colors.yellow })
  hl("CocSemMethod", { fg = colors.yellow })
  hl("CocSemMacro", { fg = colors.pink })
  hl("CocSemKeyword", { fg = colors.purple, bold = true })
  hl("CocSemModifier", { fg = colors.purple })
  hl("CocSemComment", { fg = colors.green, italic = true })
  hl("CocSemString", { fg = colors.cyan })
  hl("CocSemNumber", { fg = colors.orange })
  hl("CocSemRegexp", { fg = colors.red })
  hl("CocSemOperator", { fg = colors.purple })
  hl("CocSemNamespace", { fg = colors.blue, italic = true })
  hl("CocSemVariable", { fg = colors.fg })
  hl("CocSemDecorator", { fg = colors.pink })
  hl("CocSemLabel", { fg = colors.purple })

  -- CoC Semantic modifiers
  hl("CocSemDeclaration", { bold = true })
  hl("CocSemDefinition", { bold = true })
  hl("CocSemReadonly", { italic = true })
  hl("CocSemStatic", { italic = true })
  hl("CocSemDeprecated", { strikethrough = true })
  hl("CocSemAbstract", { italic = true })
  hl("CocSemAsync", { italic = true })
  hl("CocSemModification", { underline = true })
  hl("CocSemDocumentation", { italic = true })
  hl("CocSemDefaultLibrary", { italic = true })

  -- CoC Snippets
  hl("CocSnippetVisual", { bg = colors.selection })

  -- CoC Tree view
  hl("CocTreeTitle", { fg = colors.blue, bold = true })
  hl("CocTreeDescription", { fg = colors.fg_dark })
  hl("CocTreeOpenClose", { fg = colors.purple })
  hl("CocTreeSelected", { bg = colors.selection })

  -- CoC Symbols outline
  hl("CocSymbolDefault", { fg = colors.fg })
  hl("CocSymbolFile", { fg = colors.blue })
  hl("CocSymbolModule", { fg = colors.blue, italic = true })
  hl("CocSymbolNamespace", { fg = colors.blue, italic = true })
  hl("CocSymbolPackage", { fg = colors.blue })
  hl("CocSymbolClass", { fg = colors.blue, bold = true })
  hl("CocSymbolMethod", { fg = colors.yellow })
  hl("CocSymbolProperty", { fg = colors.blue })
  hl("CocSymbolField", { fg = colors.blue })
  hl("CocSymbolConstructor", { fg = colors.yellow, bold = true })
  hl("CocSymbolEnum", { fg = colors.blue, bold = true })
  hl("CocSymbolInterface", { fg = colors.blue, italic = true })
  hl("CocSymbolFunction", { fg = colors.yellow })
  hl("CocSymbolVariable", { fg = colors.fg })
  hl("CocSymbolConstant", { fg = colors.cyan })
  hl("CocSymbolString", { fg = colors.cyan })
  hl("CocSymbolNumber", { fg = colors.orange })
  hl("CocSymbolBoolean", { fg = colors.orange })
  hl("CocSymbolArray", { fg = colors.fg })
  hl("CocSymbolObject", { fg = colors.fg })
  hl("CocSymbolKey", { fg = colors.blue })
  hl("CocSymbolNull", { fg = colors.orange })
  hl("CocSymbolEnumMember", { fg = colors.cyan })
  hl("CocSymbolStruct", { fg = colors.blue, bold = true })
  hl("CocSymbolEvent", { fg = colors.yellow })
  hl("CocSymbolOperator", { fg = colors.purple })
  hl("CocSymbolTypeParameter", { fg = colors.blue, italic = true })

  -- CoC Extensions specific
  hl("CocExplorerNormalFloat", { fg = colors.fg, bg = colors.bg_popup })
  hl("CocExplorerNormalFloatBorder", { fg = colors.border, bg = colors.bg_popup })
  hl("CocExplorerSelectUI", { bg = colors.selection })
  hl("CocExplorerSelect", { bg = colors.selection })

  -- CoC Marketplace
  hl("CocMarketplaceTitle", { fg = colors.blue, bold = true })
  hl("CocMarketplaceDescription", { fg = colors.fg })
  hl("CocMarketplaceUrl", { fg = colors.cyan, underline = true })
  hl("CocMarketplaceKeyword", { fg = colors.purple })
  hl("CocMarketplaceVersion", { fg = colors.yellow })
  hl("CocMarketplaceInstalled", { fg = colors.green })
  hl("CocMarketplaceDisabled", { fg = colors.fg_dark })

  -- CoC Yank
  hl("CocYankHighlight", { bg = colors.selection })

  -- CoC Cursors
  hl("CocCursorTransparent", { fg = colors.fg, bg = colors.bg })

  -- CoC Search
  hl("CocSearch", { fg = colors.yellow, bg = colors.search })
  hl("CocMenuSel", { bg = colors.selection })
  hl("CocSelectedText", { bg = colors.selection })

  -- CoC Code actions
  hl("CocCodeLens", { fg = colors.fg_dark, italic = true })
  hl("CocUnusedHighlight", { fg = colors.fg_dark, strikethrough = true })
  hl("CocInlayHint", { fg = colors.fg_dark, italic = true })

  -- CoC References
  hl("CocReferencesFile", { fg = colors.blue })
  hl("CocReferencesLine", { fg = colors.fg })
  hl("CocReferencesLineNumber", { fg = colors.line_number })

  -- CoC Refactor
  hl("CocRefactorRange", { bg = colors.selection })

  -- CoC Diagnostics in location list
  hl("CocDiagnosticError", { fg = colors.error })
  hl("CocDiagnosticWarning", { fg = colors.warning })
  hl("CocDiagnosticInfo", { fg = colors.info })
  hl("CocDiagnosticHint", { fg = colors.hint })

  -- CoC Extensions - Language specific
  -- TypeScript/JavaScript
  hl("CocTsServerError", { fg = colors.error })
  hl("CocTsServerWarning", { fg = colors.warning })
  hl("CocTsServerInfo", { fg = colors.info })
  hl("CocTsServerHint", { fg = colors.hint })

  -- Python
  hl("CocPylspError", { fg = colors.error })
  hl("CocPylspWarning", { fg = colors.warning })
  hl("CocPylspInfo", { fg = colors.info })
  hl("CocPylspHint", { fg = colors.hint })

  -- Rust
  hl("CocRustAnalyzerError", { fg = colors.error })
  hl("CocRustAnalyzerWarning", { fg = colors.warning })
  hl("CocRustAnalyzerInfo", { fg = colors.info })
  hl("CocRustAnalyzerHint", { fg = colors.hint })

  -- Go
  hl("CocGoplsError", { fg = colors.error })
  hl("CocGoplsWarning", { fg = colors.warning })
  hl("CocGoplsInfo", { fg = colors.info })
  hl("CocGoplsHint", { fg = colors.hint })

  -- Additional LSP-related highlights for better integration
  hl("LspFloatWinNormal", { fg = colors.fg, bg = colors.bg_popup })
  hl("LspFloatWinBorder", { fg = colors.border, bg = colors.bg_popup })
  hl("LspSagaRenameBorder", { fg = colors.green })
  hl("LspSagaDefPreviewBorder", { fg = colors.green })
  hl("LspSagaCodeActionBorder", { fg = colors.blue })
  hl("LspSagaFinderSelection", { bg = colors.selection })
  hl("LspSagaCodeActionTitle", { fg = colors.blue })
  hl("LspSagaCodeActionContent", { fg = colors.purple })
  hl("LspSagaSignatureHelpBorder", { fg = colors.red })
  hl("LspSagaHoverBorder", { fg = colors.blue })
  hl("LspSagaBorderTitle", { fg = colors.cyan })

  -- Navic (breadcrumbs)
  hl("NavicIconsFile", { fg = colors.blue })
  hl("NavicIconsModule", { fg = colors.blue, italic = true })
  hl("NavicIconsNamespace", { fg = colors.blue, italic = true })
  hl("NavicIconsPackage", { fg = colors.blue })
  hl("NavicIconsClass", { fg = colors.blue, bold = true })
  hl("NavicIconsMethod", { fg = colors.yellow })
  hl("NavicIconsProperty", { fg = colors.blue })
  hl("NavicIconsField", { fg = colors.blue })
  hl("NavicIconsConstructor", { fg = colors.yellow, bold = true })
  hl("NavicIconsEnum", { fg = colors.blue, bold = true })
  hl("NavicIconsInterface", { fg = colors.blue, italic = true })
  hl("NavicIconsFunction", { fg = colors.yellow })
  hl("NavicIconsVariable", { fg = colors.fg })
  hl("NavicIconsConstant", { fg = colors.cyan })
  hl("NavicIconsString", { fg = colors.cyan })
  hl("NavicIconsNumber", { fg = colors.orange })
  hl("NavicIconsBoolean", { fg = colors.orange })
  hl("NavicIconsArray", { fg = colors.fg })
  hl("NavicIconsObject", { fg = colors.fg })
  hl("NavicIconsKey", { fg = colors.blue })
  hl("NavicIconsNull", { fg = colors.orange })
  hl("NavicIconsEnumMember", { fg = colors.cyan })
  hl("NavicIconsStruct", { fg = colors.blue, bold = true })
  hl("NavicIconsEvent", { fg = colors.yellow })
  hl("NavicIconsOperator", { fg = colors.purple })
  hl("NavicIconsTypeParameter", { fg = colors.blue, italic = true })
  hl("NavicText", { fg = colors.fg })
  hl("NavicSeparator", { fg = colors.fg_dark })

  -- Aerial (symbols outline)
  hl("AerialLine", { bg = colors.cursor_line })
  hl("AerialLineNC", { bg = colors.cursor_line })
  hl("AerialGuide", { fg = colors.border })
  hl("AerialClass", { fg = colors.blue, bold = true })
  hl("AerialClassIcon", { fg = colors.blue, bold = true })
  hl("AerialConstructor", { fg = colors.yellow, bold = true })
  hl("AerialConstructorIcon", { fg = colors.yellow, bold = true })
  hl("AerialEnum", { fg = colors.blue, bold = true })
  hl("AerialEnumIcon", { fg = colors.blue, bold = true })
  hl("AerialEnumMember", { fg = colors.cyan })
  hl("AerialEnumMemberIcon", { fg = colors.cyan })
  hl("AerialField", { fg = colors.blue })
  hl("AerialFieldIcon", { fg = colors.blue })
  hl("AerialFile", { fg = colors.blue })
  hl("AerialFileIcon", { fg = colors.blue })
  hl("AerialFunction", { fg = colors.yellow })
  hl("AerialFunctionIcon", { fg = colors.yellow })
  hl("AerialInterface", { fg = colors.blue, italic = true })
  hl("AerialInterfaceIcon", { fg = colors.blue, italic = true })
  hl("AerialMethod", { fg = colors.yellow })
  hl("AerialMethodIcon", { fg = colors.yellow })
  hl("AerialModule", { fg = colors.blue, italic = true })
  hl("AerialModuleIcon", { fg = colors.blue, italic = true })
  hl("AerialNamespace", { fg = colors.blue, italic = true })
  hl("AerialNamespaceIcon", { fg = colors.blue, italic = true })
  hl("AerialProperty", { fg = colors.blue })
  hl("AerialPropertyIcon", { fg = colors.blue })
  hl("AerialStruct", { fg = colors.blue, bold = true })
  hl("AerialStructIcon", { fg = colors.blue, bold = true })
  hl("AerialTypeParameter", { fg = colors.blue, italic = true })
  hl("AerialTypeParameterIcon", { fg = colors.blue, italic = true })
  hl("AerialVariable", { fg = colors.fg })
  hl("AerialVariableIcon", { fg = colors.fg })

  -- Copilot highlights
  hl("CopilotSuggestion", { fg = colors.fg_dark, italic = true })
  hl("CopilotAnnotation", { fg = colors.fg_dark, italic = true })
end

return M
