-- Hexxa Dark Theme - LSP and CoC Support
-- Diagnostics, completion, and LSP-related highlighting

local M = {}

function M.setup()
  local colors = require("user.themes.hexxa-dark").colors

  -- Helper function to set highlights
  local function hl(group, opts) vim.api.nvim_set_hl(0, group, opts) end

  -- LSP Diagnostics
  hl("DiagnosticError", { fg = colors.error })
  hl("DiagnosticWarn", { fg = colors.warning })
  hl("DiagnosticInfo", { fg = colors.info })
  hl("DiagnosticHint", { fg = colors.hint })
  hl("DiagnosticOk", { fg = colors.green })

  -- LSP Diagnostic Signs
  hl("DiagnosticSignError", { fg = colors.error, bg = colors.bg })
  hl("DiagnosticSignWarn", { fg = colors.warning, bg = colors.bg })
  hl("DiagnosticSignInfo", { fg = colors.info, bg = colors.bg })
  hl("DiagnosticSignHint", { fg = colors.hint, bg = colors.bg })
  hl("DiagnosticSignOk", { fg = colors.green, bg = colors.bg })

  -- LSP Diagnostic Virtual Text
  hl("DiagnosticVirtualTextError", { fg = colors.error, bg = colors.none, italic = true })
  hl("DiagnosticVirtualTextWarn", { fg = colors.warning, bg = colors.none, italic = true })
  hl("DiagnosticVirtualTextInfo", { fg = colors.info, bg = colors.none, italic = true })
  hl("DiagnosticVirtualTextHint", { fg = colors.hint, bg = colors.none, italic = true })
  hl("DiagnosticVirtualTextOk", { fg = colors.green, bg = colors.none, italic = true })

  -- LSP Diagnostic Underlines
  hl("DiagnosticUnderlineError", { sp = colors.error, undercurl = true })
  hl("DiagnosticUnderlineWarn", { sp = colors.warning, undercurl = true })
  hl("DiagnosticUnderlineInfo", { sp = colors.info, undercurl = true })
  hl("DiagnosticUnderlineHint", { sp = colors.hint, undercurl = true })
  hl("DiagnosticUnderlineOk", { sp = colors.green, undercurl = true })

  -- LSP Diagnostic Floating Windows
  hl("DiagnosticFloatingError", { fg = colors.error, bg = colors.bg })
  hl("DiagnosticFloatingWarn", { fg = colors.warning, bg = colors.bg })
  hl("DiagnosticFloatingInfo", { fg = colors.info, bg = colors.bg })
  hl("DiagnosticFloatingHint", { fg = colors.hint, bg = colors.bg })
  hl("DiagnosticFloatingOk", { fg = colors.green, bg = colors.bg })

  -- LSP References
  hl("LspReferenceText", { bg = colors.gray5 })
  hl("LspReferenceRead", { bg = colors.gray5 })
  hl("LspReferenceWrite", { bg = colors.gray5, bold = true })

  -- LSP Signature Help
  hl("LspSignatureActiveParameter", { fg = colors.orange, bold = true })

  -- LSP Code Lens
  hl("LspCodeLens", { fg = colors.gray2, italic = true })
  hl("LspCodeLensSeparator", { fg = colors.gray2 })

  -- LSP Inlay Hints
  hl("LspInlayHint", { fg = colors.gray2, bg = colors.gray7, italic = true })

  -- CoC (Conquer of Completion) specific highlights
  hl("CocErrorSign", { fg = colors.error, bg = colors.bg })
  hl("CocWarningSign", { fg = colors.warning, bg = colors.bg })
  hl("CocInfoSign", { fg = colors.info, bg = colors.bg })
  hl("CocHintSign", { fg = colors.hint, bg = colors.bg })

  hl("CocErrorFloat", { fg = colors.error, bg = colors.bg })
  hl("CocWarningFloat", { fg = colors.warning, bg = colors.bg })
  hl("CocInfoFloat", { fg = colors.info, bg = colors.bg })
  hl("CocHintFloat", { fg = colors.hint, bg = colors.bg })

  hl("CocErrorHighlight", { sp = colors.error, undercurl = true })
  hl("CocWarningHighlight", { sp = colors.warning, undercurl = true })
  hl("CocInfoHighlight", { sp = colors.info, undercurl = true })
  hl("CocHintHighlight", { sp = colors.hint, undercurl = true })

  hl("CocErrorVirtualText", { fg = colors.error, italic = true })
  hl("CocWarningVirtualText", { fg = colors.warning, italic = true })
  hl("CocInfoVirtualText", { fg = colors.info, italic = true })
  hl("CocHintVirtualText", { fg = colors.hint, italic = true })

  -- CoC Floating Windows
  hl("CocFloating", { fg = colors.fg_alt, bg = colors.bg })
  hl("CocFloatingBorder", { fg = colors.border, bg = colors.bg })
  hl("CocFloatingDividingLine", { fg = colors.border })

  -- CoC Menu
  hl("CocMenuSel", { fg = colors.fg, bg = colors.gray5 })
  hl("CocSelectedText", { fg = colors.lime, bold = true })

  -- CoC List
  hl("CocListMode", { fg = colors.lime, bold = true })
  hl("CocListPath", { fg = colors.cyan })
  hl("CocHighlightText", { bg = colors.selection })
  hl("CocHighlightRead", { bg = colors.gray5 })
  hl("CocHighlightWrite", { bg = colors.gray5, bold = true })

  -- CoC Search
  hl("CocSearch", { fg = colors.orange, bold = true })

  -- CoC Git
  hl("CocGitAddedSign", { fg = colors.git_add })
  hl("CocGitChangeRemovedSign", { fg = colors.orange })
  hl("CocGitChangedSign", { fg = colors.git_change })
  hl("CocGitRemovedSign", { fg = colors.git_delete })
  hl("CocGitTopRemovedSign", { fg = colors.git_delete })

  -- CoC Explorer (if used)
  hl("CocExplorerNormalFloat", { fg = colors.fg_alt, bg = colors.bg })
  hl("CocExplorerNormalFloatBorder", { fg = colors.border, bg = colors.bg })
  hl("CocExplorerSelectUI", { fg = colors.lime, bold = true })
  hl("CocExplorerIndentLine", { fg = colors.gray2 })
  hl("CocExplorerBufferRoot", { fg = colors.lime, bold = true })
  hl("CocExplorerFileRoot", { fg = colors.lime, bold = true })
  hl("CocExplorerBufferFullPath", { fg = colors.gray2 })
  hl("CocExplorerFileFullPath", { fg = colors.gray2 })
  hl("CocExplorerBufferReadonly", { fg = colors.orange })
  hl("CocExplorerBufferModified", { fg = colors.orange })
  hl("CocExplorerBufferNameVisible", { fg = colors.cyan })
  hl("CocExplorerFileReadonly", { fg = colors.orange })
  hl("CocExplorerFileModified", { fg = colors.orange })
  hl("CocExplorerFileHidden", { fg = colors.gray2 })
  hl("CocExplorerHelpLine", { fg = colors.gray2 })

  -- Completion Menu (nvim-cmp style, if used alongside CoC)
  hl("CmpItemAbbr", { fg = colors.fg_alt })
  hl("CmpItemAbbrDeprecated", { fg = colors.gray2, strikethrough = true })
  hl("CmpItemAbbrMatch", { fg = colors.orange, bold = true })
  hl("CmpItemAbbrMatchFuzzy", { fg = colors.orange, bold = true })
  hl("CmpItemKind", { fg = colors.pink })
  hl("CmpItemMenu", { fg = colors.gray2, italic = true })

  -- Completion Item Kinds
  hl("CmpItemKindText", { fg = colors.fg_alt })
  hl("CmpItemKindMethod", { fg = colors.lime })
  hl("CmpItemKindFunction", { fg = colors.lime })
  hl("CmpItemKindConstructor", { fg = colors.cyan })
  hl("CmpItemKindField", { fg = colors.fg_alt })
  hl("CmpItemKindVariable", { fg = colors.fg_alt })
  hl("CmpItemKindClass", { fg = colors.cyan })
  hl("CmpItemKindInterface", { fg = colors.cyan })
  hl("CmpItemKindModule", { fg = colors.cyan })
  hl("CmpItemKindProperty", { fg = colors.fg_alt })
  hl("CmpItemKindUnit", { fg = colors.blue })
  hl("CmpItemKindValue", { fg = colors.blue })
  hl("CmpItemKindEnum", { fg = colors.cyan })
  hl("CmpItemKindKeyword", { fg = colors.orange })
  hl("CmpItemKindSnippet", { fg = colors.green })
  hl("CmpItemKindColor", { fg = colors.pink })
  hl("CmpItemKindFile", { fg = colors.cyan })
  hl("CmpItemKindReference", { fg = colors.cyan })
  hl("CmpItemKindFolder", { fg = colors.cyan })
  hl("CmpItemKindEnumMember", { fg = colors.blue })
  hl("CmpItemKindConstant", { fg = colors.blue })
  hl("CmpItemKindStruct", { fg = colors.cyan })
  hl("CmpItemKindEvent", { fg = colors.pink })
  hl("CmpItemKindOperator", { fg = colors.orange })
  hl("CmpItemKindTypeParameter", { fg = colors.cyan })

  -- LSP Progress
  hl("LspProgressTitle", { fg = colors.lime, bold = true })
  hl("LspProgressMessage", { fg = colors.fg_alt })
  hl("LspProgressSpinner", { fg = colors.cyan })

  -- LSP Hover
  hl("LspHover", { fg = colors.fg_alt, bg = colors.bg })
  hl("LspHoverBorder", { fg = colors.border, bg = colors.bg })

  -- LSP Saga (if used)
  hl("LspSagaNormal", { fg = colors.fg_alt, bg = colors.bg })
  hl("LspSagaBorder", { fg = colors.border, bg = colors.bg })
  hl("LspSagaTitle", { fg = colors.lime, bold = true })
  hl("LspSagaCodeActionTitle", { fg = colors.orange, bold = true })
  hl("LspSagaCodeActionContent", { fg = colors.fg_alt })
  hl("LspSagaCodeActionTruncateLine", { fg = colors.gray2 })
  hl("LspSagaShTruncateLine", { fg = colors.gray2 })
  hl("LspSagaDocTruncateLine", { fg = colors.gray2 })
  hl("LspSagaLineTruncateLine", { fg = colors.gray2 })
  hl("LspSagaFinderSelection", { fg = colors.lime, bold = true })
  hl("LspSagaLspFinderBorder", { fg = colors.border })
  hl("LspSagaAutoPreview", { fg = colors.gray2 })
  hl("LspSagaDefPreviewBorder", { fg = colors.border })
  hl("LspSagaHoverBorder", { fg = colors.border })
  hl("LspSagaRenameBorder", { fg = colors.border })
  hl("LspSagaDiagnosticBorder", { fg = colors.border })
  hl("LspSagaDiagnosticTruncateLine", { fg = colors.gray2 })
  hl("LspSagaDiagnosticHeader", { fg = colors.lime, bold = true })
  hl("LspSagaSignatureHelpBorder", { fg = colors.border })
  hl("LspSagaCodeActionBorder", { fg = colors.border })

  -- Goto Preview (if used)
  hl("GotoPreviewNormal", { fg = colors.fg_alt, bg = colors.bg })
  hl("GotoPreviewBorder", { fg = colors.border, bg = colors.bg })
  hl("GotoPreviewTitle", { fg = colors.lime, bold = true })
  hl("GotoPreviewCursor", { fg = colors.bg, bg = colors.cyan })
  hl("GotoPreviewCursorLine", { bg = colors.gray5 })

  -- Lightbulb (code actions)
  hl("LightBulbSign", { fg = colors.orange })
  hl("LightBulbFloatWin", { fg = colors.orange, bg = colors.bg })
  hl("LightBulbVirtualText", { fg = colors.orange })

  -- LSP Document Symbols
  hl("LspDocumentSymbolName", { fg = colors.fg_alt })
  hl("LspDocumentSymbolDetail", { fg = colors.gray2 })
  hl("LspDocumentSymbolKind", { fg = colors.pink })
  hl("LspDocumentSymbolFile", { fg = colors.cyan })
  hl("LspDocumentSymbolModule", { fg = colors.cyan })
  hl("LspDocumentSymbolNamespace", { fg = colors.cyan })
  hl("LspDocumentSymbolPackage", { fg = colors.cyan })
  hl("LspDocumentSymbolClass", { fg = colors.cyan })
  hl("LspDocumentSymbolMethod", { fg = colors.lime })
  hl("LspDocumentSymbolProperty", { fg = colors.fg_alt })
  hl("LspDocumentSymbolField", { fg = colors.fg_alt })
  hl("LspDocumentSymbolConstructor", { fg = colors.cyan })
  hl("LspDocumentSymbolEnum", { fg = colors.cyan })
  hl("LspDocumentSymbolInterface", { fg = colors.cyan })
  hl("LspDocumentSymbolFunction", { fg = colors.lime })
  hl("LspDocumentSymbolVariable", { fg = colors.fg_alt })
  hl("LspDocumentSymbolConstant", { fg = colors.blue })
  hl("LspDocumentSymbolString", { fg = colors.green })
  hl("LspDocumentSymbolNumber", { fg = colors.blue })
  hl("LspDocumentSymbolBoolean", { fg = colors.blue })
  hl("LspDocumentSymbolArray", { fg = colors.fg_alt })
  hl("LspDocumentSymbolObject", { fg = colors.fg_alt })
  hl("LspDocumentSymbolKey", { fg = colors.cyan })
  hl("LspDocumentSymbolNull", { fg = colors.blue })
  hl("LspDocumentSymbolEnumMember", { fg = colors.blue })
  hl("LspDocumentSymbolStruct", { fg = colors.cyan })
  hl("LspDocumentSymbolEvent", { fg = colors.pink })
  hl("LspDocumentSymbolOperator", { fg = colors.orange })
  hl("LspDocumentSymbolTypeParameter", { fg = colors.cyan })

  -- LSP Workspace Symbols
  hl("LspWorkspaceSymbolName", { fg = colors.fg_alt })
  hl("LspWorkspaceSymbolDetail", { fg = colors.gray2 })
  hl("LspWorkspaceSymbolKind", { fg = colors.pink })
  hl("LspWorkspaceSymbolFile", { fg = colors.cyan })

  -- LSP Call Hierarchy
  hl("LspCallHierarchyName", { fg = colors.lime })
  hl("LspCallHierarchyDetail", { fg = colors.gray2 })
  hl("LspCallHierarchyKind", { fg = colors.pink })

  -- LSP Type Hierarchy
  hl("LspTypeHierarchyName", { fg = colors.cyan })
  hl("LspTypeHierarchyDetail", { fg = colors.gray2 })
  hl("LspTypeHierarchyKind", { fg = colors.pink })

  -- Aerial (symbol outline, if used)
  hl("AerialNormal", { fg = colors.fg_alt, bg = colors.bg })
  hl("AerialBorder", { fg = colors.border, bg = colors.bg })
  hl("AerialLine", { bg = colors.gray5 })
  hl("AerialGuide", { fg = colors.gray2 })
  hl("AerialClass", { fg = colors.cyan })
  hl("AerialClassIcon", { fg = colors.cyan })
  hl("AerialConstructor", { fg = colors.cyan })
  hl("AerialConstructorIcon", { fg = colors.cyan })
  hl("AerialEnum", { fg = colors.cyan })
  hl("AerialEnumIcon", { fg = colors.cyan })
  hl("AerialFunction", { fg = colors.lime })
  hl("AerialFunctionIcon", { fg = colors.lime })
  hl("AerialInterface", { fg = colors.cyan })
  hl("AerialInterfaceIcon", { fg = colors.cyan })
  hl("AerialMethod", { fg = colors.lime })
  hl("AerialMethodIcon", { fg = colors.lime })
  hl("AerialModule", { fg = colors.cyan })
  hl("AerialModuleIcon", { fg = colors.cyan })
  hl("AerialNamespace", { fg = colors.cyan })
  hl("AerialNamespaceIcon", { fg = colors.cyan })
  hl("AerialPackage", { fg = colors.cyan })
  hl("AerialPackageIcon", { fg = colors.cyan })
  hl("AerialProperty", { fg = colors.fg_alt })
  hl("AerialPropertyIcon", { fg = colors.fg_alt })
  hl("AerialStruct", { fg = colors.cyan })
  hl("AerialStructIcon", { fg = colors.cyan })
  hl("AerialVariable", { fg = colors.fg_alt })
  hl("AerialVariableIcon", { fg = colors.fg_alt })

  -- Navic (breadcrumbs, if used)
  hl("NavicIconsFile", { fg = colors.cyan })
  hl("NavicIconsModule", { fg = colors.cyan })
  hl("NavicIconsNamespace", { fg = colors.cyan })
  hl("NavicIconsPackage", { fg = colors.cyan })
  hl("NavicIconsClass", { fg = colors.cyan })
  hl("NavicIconsMethod", { fg = colors.lime })
  hl("NavicIconsProperty", { fg = colors.fg_alt })
  hl("NavicIconsField", { fg = colors.fg_alt })
  hl("NavicIconsConstructor", { fg = colors.cyan })
  hl("NavicIconsEnum", { fg = colors.cyan })
  hl("NavicIconsInterface", { fg = colors.cyan })
  hl("NavicIconsFunction", { fg = colors.lime })
  hl("NavicIconsVariable", { fg = colors.fg_alt })
  hl("NavicIconsConstant", { fg = colors.blue })
  hl("NavicIconsString", { fg = colors.green })
  hl("NavicIconsNumber", { fg = colors.blue })
  hl("NavicIconsBoolean", { fg = colors.blue })
  hl("NavicIconsArray", { fg = colors.fg_alt })
  hl("NavicIconsObject", { fg = colors.fg_alt })
  hl("NavicIconsKey", { fg = colors.cyan })
  hl("NavicIconsNull", { fg = colors.blue })
  hl("NavicIconsEnumMember", { fg = colors.blue })
  hl("NavicIconsStruct", { fg = colors.cyan })
  hl("NavicIconsEvent", { fg = colors.pink })
  hl("NavicIconsOperator", { fg = colors.orange })
  hl("NavicIconsTypeParameter", { fg = colors.cyan })
  hl("NavicText", { fg = colors.fg_alt })
  hl("NavicSeparator", { fg = colors.gray2 })

  -- Fidget (LSP progress, if used)
  hl("FidgetTitle", { fg = colors.lime, bold = true })
  hl("FidgetTask", { fg = colors.fg_alt })
  hl("FidgetSpinner", { fg = colors.cyan })

  -- LSP Signature
  hl("LspSignatureActiveParameter", { fg = colors.orange, bold = true })

  -- Error Lens (if used)
  hl("ErrorLensErrorText", { fg = colors.error, italic = true })
  hl("ErrorLensWarningText", { fg = colors.warning, italic = true })
  hl("ErrorLensInfoText", { fg = colors.info, italic = true })
  hl("ErrorLensHintText", { fg = colors.hint, italic = true })

  -- Winbar (breadcrumbs in winbar)
  hl("WinBar", { fg = colors.fg_dim, bg = colors.bg })
  hl("WinBarNC", { fg = colors.gray2, bg = colors.bg })
end

return M
