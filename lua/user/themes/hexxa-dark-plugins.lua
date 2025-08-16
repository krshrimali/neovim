-- Hexxa Dark Theme - Plugin Support
-- Styling for various Neovim plugins

local M = {}

function M.setup()
  local colors = require("user.themes.hexxa-dark").colors

  -- Helper function to set highlights
  local function hl(group, opts) vim.api.nvim_set_hl(0, group, opts) end

  -- FZF-Lua
  hl("FzfLuaNormal", { fg = colors.fg_alt, bg = colors.bg })
  hl("FzfLuaBorder", { fg = colors.border, bg = colors.bg })
  hl("FzfLuaTitle", { fg = colors.lime, bg = colors.bg, bold = true })
  hl("FzfLuaPreviewNormal", { fg = colors.fg_alt, bg = colors.bg })
  hl("FzfLuaPreviewBorder", { fg = colors.border, bg = colors.bg })
  hl("FzfLuaCursor", { fg = colors.bg, bg = colors.cyan })
  hl("FzfLuaCursorLine", { bg = colors.gray5 })
  hl("FzfLuaSearch", { fg = colors.orange, bold = true })
  hl("FzfLuaScrollBorderEmpty", { fg = colors.border })
  hl("FzfLuaScrollBorderFull", { fg = colors.active_border })
  hl("FzfLuaScrollFloatEmpty", { fg = colors.border })
  hl("FzfLuaScrollFloatFull", { fg = colors.active_border })
  hl("FzfLuaHelpNormal", { fg = colors.fg_alt, bg = colors.bg })
  hl("FzfLuaHelpBorder", { fg = colors.border, bg = colors.bg })

  -- FZF-Lua file icons and types
  hl("FzfLuaPathColNr", { fg = colors.gray2 })
  hl("FzfLuaPathLineNr", { fg = colors.blue })
  hl("FzfLuaTabTitle", { fg = colors.lime, bold = true })
  hl("FzfLuaTabMarker", { fg = colors.orange })
  hl("FzfLuaBufName", { fg = colors.cyan })
  hl("FzfLuaBufNr", { fg = colors.blue })
  hl("FzfLuaBufLineNr", { fg = colors.gray2 })
  hl("FzfLuaBufFlagCur", { fg = colors.lime })
  hl("FzfLuaBufFlagAlt", { fg = colors.orange })
  hl("FzfLuaHeaderBind", { fg = colors.pink })
  hl("FzfLuaHeaderText", { fg = colors.fg_alt })
  hl("FzfLuaDirPart", { fg = colors.gray2 })
  hl("FzfLuaFilePart", { fg = colors.fg_alt })

  -- Lualine (status line)
  hl("lualine_a_normal", { fg = colors.bg, bg = colors.lime, bold = true })
  hl("lualine_a_insert", { fg = colors.bg, bg = colors.green, bold = true })
  hl("lualine_a_visual", { fg = colors.bg, bg = colors.orange, bold = true })
  hl("lualine_a_replace", { fg = colors.bg, bg = colors.red, bold = true })
  hl("lualine_a_command", { fg = colors.bg, bg = colors.pink, bold = true })
  hl("lualine_a_terminal", { fg = colors.bg, bg = colors.cyan, bold = true })
  hl("lualine_a_inactive", { fg = colors.gray2, bg = colors.bg })

  hl("lualine_b_normal", { fg = colors.fg_alt, bg = colors.gray7 })
  hl("lualine_b_insert", { fg = colors.fg_alt, bg = colors.gray7 })
  hl("lualine_b_visual", { fg = colors.fg_alt, bg = colors.gray7 })
  hl("lualine_b_replace", { fg = colors.fg_alt, bg = colors.gray7 })
  hl("lualine_b_command", { fg = colors.fg_alt, bg = colors.gray7 })
  hl("lualine_b_terminal", { fg = colors.fg_alt, bg = colors.gray7 })
  hl("lualine_b_inactive", { fg = colors.gray2, bg = colors.bg })

  hl("lualine_c_normal", { fg = colors.fg_dim, bg = colors.bg })
  hl("lualine_c_insert", { fg = colors.fg_dim, bg = colors.bg })
  hl("lualine_c_visual", { fg = colors.fg_dim, bg = colors.bg })
  hl("lualine_c_replace", { fg = colors.fg_dim, bg = colors.bg })
  hl("lualine_c_command", { fg = colors.fg_dim, bg = colors.bg })
  hl("lualine_c_terminal", { fg = colors.fg_dim, bg = colors.bg })
  hl("lualine_c_inactive", { fg = colors.gray2, bg = colors.bg })

  -- GitSigns
  hl("GitSignsAdd", { fg = colors.git_add })
  hl("GitSignsChange", { fg = colors.git_change })
  hl("GitSignsDelete", { fg = colors.git_delete })
  hl("GitSignsTopdelete", { fg = colors.git_delete })
  hl("GitSignsChangedelete", { fg = colors.orange })
  hl("GitSignsUntracked", { fg = colors.gray2 })
  hl("GitSignsAddNr", { fg = colors.git_add })
  hl("GitSignsChangeNr", { fg = colors.git_change })
  hl("GitSignsDeleteNr", { fg = colors.git_delete })
  hl("GitSignsTopdeleteNr", { fg = colors.git_delete })
  hl("GitSignsChangedeleteNr", { fg = colors.orange })
  hl("GitSignsUntrackedNr", { fg = colors.gray2 })
  hl("GitSignsAddLn", { bg = "#2A4A3A" })
  hl("GitSignsChangeLn", { bg = "#2A3A4A" })
  hl("GitSignsDeleteLn", { bg = "#4A2A2A" })
  hl("GitSignsTopDeleteLn", { bg = "#4A2A2A" })
  hl("GitSignsChangeDeleteLn", { bg = "#4A3A2A" })
  hl("GitSignsUntrackedLn", { bg = "#2A2A2A" })
  hl("GitSignsAddPreview", { fg = colors.git_add })
  hl("GitSignsDeletePreview", { fg = colors.git_delete })
  hl("GitSignsCurrentLineBlame", { fg = colors.gray2, italic = true })

  -- Bufferline
  hl("BufferLineIndicatorSelected", { fg = colors.active_border })
  hl("BufferLineFill", { bg = colors.bg })
  hl("BufferLineBackground", { fg = colors.gray2, bg = colors.bg })
  hl("BufferLineBufferSelected", { fg = colors.fg, bg = colors.bg, bold = true })
  hl("BufferLineBufferVisible", { fg = colors.fg_dim, bg = colors.bg })
  hl("BufferLineCloseButton", { fg = colors.gray2, bg = colors.bg })
  hl("BufferLineCloseButtonSelected", { fg = colors.red, bg = colors.bg })
  hl("BufferLineCloseButtonVisible", { fg = colors.gray2, bg = colors.bg })
  hl("BufferLineModified", { fg = colors.orange, bg = colors.bg })
  hl("BufferLineModifiedSelected", { fg = colors.orange, bg = colors.bg })
  hl("BufferLineModifiedVisible", { fg = colors.orange, bg = colors.bg })
  hl("BufferLineSeparator", { fg = colors.border, bg = colors.bg })
  hl("BufferLineSeparatorSelected", { fg = colors.border, bg = colors.bg })
  hl("BufferLineSeparatorVisible", { fg = colors.border, bg = colors.bg })
  hl("BufferLineTab", { fg = colors.gray2, bg = colors.bg })
  hl("BufferLineTabSelected", { fg = colors.fg, bg = colors.bg, bold = true })
  hl("BufferLineTabClose", { fg = colors.red, bg = colors.bg })
  hl("BufferLineDuplicate", { fg = colors.gray2, bg = colors.bg, italic = true })
  hl("BufferLineDuplicateSelected", { fg = colors.fg, bg = colors.bg, italic = true })
  hl("BufferLineDuplicateVisible", { fg = colors.fg_dim, bg = colors.bg, italic = true })

  -- Nvim-Tree / File Explorer
  hl("NvimTreeNormal", { fg = colors.fg_alt, bg = colors.bg })
  hl("NvimTreeNormalNC", { fg = colors.fg_alt, bg = colors.bg })
  hl("NvimTreeRootFolder", { fg = colors.lime, bold = true })
  hl("NvimTreeGitDirty", { fg = colors.orange })
  hl("NvimTreeGitNew", { fg = colors.git_add })
  hl("NvimTreeGitDeleted", { fg = colors.git_delete })
  hl("NvimTreeGitStaged", { fg = colors.green })
  hl("NvimTreeGitMerge", { fg = colors.pink })
  hl("NvimTreeGitRenamed", { fg = colors.cyan })
  hl("NvimTreeGitIgnored", { fg = colors.gray2 })
  hl("NvimTreeIndentMarker", { fg = colors.gray2 })
  hl("NvimTreeImageFile", { fg = colors.pink })
  hl("NvimTreeSpecialFile", { fg = colors.orange, underline = true })
  hl("NvimTreeSymlink", { fg = colors.cyan })
  hl("NvimTreeFolderName", { fg = colors.cyan })
  hl("NvimTreeFolderIcon", { fg = colors.cyan })
  hl("NvimTreeOpenedFolderName", { fg = colors.cyan, bold = true })
  hl("NvimTreeEmptyFolderName", { fg = colors.gray2 })
  hl("NvimTreeOpenedFile", { fg = colors.lime })
  hl("NvimTreeCursorLine", { bg = colors.gray5 })
  hl("NvimTreeWindowPicker", { fg = colors.bg, bg = colors.lime, bold = true })
  hl("NvimTreeLiveFilterPrefix", { fg = colors.orange, bold = true })
  hl("NvimTreeLiveFilterValue", { fg = colors.lime, bold = true })

  -- Which-Key
  hl("WhichKey", { fg = colors.lime })
  hl("WhichKeyGroup", { fg = colors.cyan })
  hl("WhichKeyDesc", { fg = colors.fg_alt })
  hl("WhichKeySeperator", { fg = colors.gray2 })
  hl("WhichKeySeparator", { fg = colors.gray2 })
  hl("WhichKeyFloat", { bg = colors.bg })
  hl("WhichKeyBorder", { fg = colors.border, bg = colors.bg })
  hl("WhichKeyValue", { fg = colors.green })

  -- Notify
  hl("NotifyERRORBorder", { fg = colors.error })
  hl("NotifyWARNBorder", { fg = colors.warning })
  hl("NotifyINFOBorder", { fg = colors.info })
  hl("NotifyDEBUGBorder", { fg = colors.gray2 })
  hl("NotifyTRACEBorder", { fg = colors.hint })
  hl("NotifyERRORIcon", { fg = colors.error })
  hl("NotifyWARNIcon", { fg = colors.warning })
  hl("NotifyINFOIcon", { fg = colors.info })
  hl("NotifyDEBUGIcon", { fg = colors.gray2 })
  hl("NotifyTRACEIcon", { fg = colors.hint })
  hl("NotifyERRORTitle", { fg = colors.error })
  hl("NotifyWARNTitle", { fg = colors.warning })
  hl("NotifyINFOTitle", { fg = colors.info })
  hl("NotifyDEBUGTitle", { fg = colors.gray2 })
  hl("NotifyTRACETitle", { fg = colors.hint })
  hl("NotifyERRORBody", { fg = colors.fg_alt, bg = colors.bg })
  hl("NotifyWARNBody", { fg = colors.fg_alt, bg = colors.bg })
  hl("NotifyINFOBody", { fg = colors.fg_alt, bg = colors.bg })
  hl("NotifyDEBUGBody", { fg = colors.fg_alt, bg = colors.bg })
  hl("NotifyTRACEBody", { fg = colors.fg_alt, bg = colors.bg })

  -- Comment.nvim
  hl("CommentNvimCommentedCode", { fg = colors.comment, italic = true })

  -- Todo Comments
  hl("TodoBgFIX", { fg = colors.bg, bg = colors.error, bold = true })
  hl("TodoBgHACK", { fg = colors.bg, bg = colors.warning, bold = true })
  hl("TodoBgNOTE", { fg = colors.bg, bg = colors.info, bold = true })
  hl("TodoBgPERF", { fg = colors.bg, bg = colors.pink, bold = true })
  hl("TodoBgTODO", { fg = colors.bg, bg = colors.orange, bold = true })
  hl("TodoBgWARN", { fg = colors.bg, bg = colors.warning, bold = true })
  hl("TodoFgFIX", { fg = colors.error })
  hl("TodoFgHACK", { fg = colors.warning })
  hl("TodoFgNOTE", { fg = colors.info })
  hl("TodoFgPERF", { fg = colors.pink })
  hl("TodoFgTODO", { fg = colors.orange })
  hl("TodoFgWARN", { fg = colors.warning })
  hl("TodoSignFIX", { fg = colors.error })
  hl("TodoSignHACK", { fg = colors.warning })
  hl("TodoSignNOTE", { fg = colors.info })
  hl("TodoSignPERF", { fg = colors.pink })
  hl("TodoSignTODO", { fg = colors.orange })
  hl("TodoSignWARN", { fg = colors.warning })

  -- Illuminate (word highlighting)
  hl("IlluminatedWordText", { bg = colors.gray5 })
  hl("IlluminatedWordRead", { bg = colors.gray5 })
  hl("IlluminatedWordWrite", { bg = colors.gray5 })

  -- Indent Blankline
  hl("IndentBlanklineChar", { fg = colors.gray2 })
  hl("IndentBlanklineContextChar", { fg = colors.gray3 })
  hl("IndentBlanklineContextStart", { sp = colors.gray3, underline = true })
  hl("IndentBlanklineSpaceChar", { fg = colors.gray2 })
  hl("IndentBlanklineSpaceCharBlankline", { fg = colors.gray2 })

  -- Colorizer
  hl("ColorizerNvimColorColumn", { bg = colors.gray7 })

  -- Alpha (dashboard)
  hl("AlphaShortcut", { fg = colors.orange })
  hl("AlphaHeader", { fg = colors.lime })
  hl("AlphaHeaderLabel", { fg = colors.cyan })
  hl("AlphaFooter", { fg = colors.gray2, italic = true })
  hl("AlphaButtons", { fg = colors.fg_alt })

  -- Dashboard
  hl("DashboardShortCut", { fg = colors.orange })
  hl("DashboardHeader", { fg = colors.lime })
  hl("DashboardCenter", { fg = colors.fg_alt })
  hl("DashboardFooter", { fg = colors.gray2, italic = true })

  -- Telescope (if used)
  hl("TelescopeNormal", { fg = colors.fg_alt, bg = colors.bg })
  hl("TelescopeBorder", { fg = colors.border, bg = colors.bg })
  hl("TelescopeTitle", { fg = colors.lime, bold = true })
  hl("TelescopeSelection", { fg = colors.fg, bg = colors.gray5 })
  hl("TelescopeSelectionCaret", { fg = colors.lime, bg = colors.gray5 })
  hl("TelescopeMultiSelection", { fg = colors.orange, bg = colors.gray5 })
  hl("TelescopeMatching", { fg = colors.orange, bold = true })
  hl("TelescopePromptNormal", { fg = colors.fg_alt, bg = colors.bg })
  hl("TelescopePromptBorder", { fg = colors.border, bg = colors.bg })
  hl("TelescopePromptTitle", { fg = colors.lime, bold = true })
  hl("TelescopePromptPrefix", { fg = colors.orange })
  hl("TelescopeResultsNormal", { fg = colors.fg_alt, bg = colors.bg })
  hl("TelescopeResultsBorder", { fg = colors.border, bg = colors.bg })
  hl("TelescopeResultsTitle", { fg = colors.cyan, bold = true })
  hl("TelescopePreviewNormal", { fg = colors.fg_alt, bg = colors.bg })
  hl("TelescopePreviewBorder", { fg = colors.border, bg = colors.bg })
  hl("TelescopePreviewTitle", { fg = colors.green, bold = true })

  -- Neogit (if used)
  hl("NeogitBranch", { fg = colors.cyan })
  hl("NeogitRemote", { fg = colors.pink })
  hl("NeogitHunkHeader", { fg = colors.fg_alt, bg = colors.gray7 })
  hl("NeogitHunkHeaderHighlight", { fg = colors.fg, bg = colors.gray5 })
  hl("NeogitDiffContextHighlight", { bg = colors.gray7 })
  hl("NeogitDiffDeleteHighlight", { fg = colors.git_delete, bg = "#4A2A2A" })
  hl("NeogitDiffAddHighlight", { fg = colors.git_add, bg = "#2A4A3A" })
  hl("NeogitCommitViewHeader", { fg = colors.lime, bold = true })
  hl("NeogitNotificationInfo", { fg = colors.info })
  hl("NeogitNotificationWarning", { fg = colors.warning })
  hl("NeogitNotificationError", { fg = colors.error })

  -- Trouble (diagnostics)
  hl("TroubleText", { fg = colors.fg_alt })
  hl("TroubleCount", { fg = colors.pink, bg = colors.gray7 })
  hl("TroubleNormal", { fg = colors.fg_alt, bg = colors.bg })
  hl("TroubleTextInformation", { fg = colors.info })
  hl("TroubleTextWarning", { fg = colors.warning })
  hl("TroubleTextError", { fg = colors.error })
  hl("TroubleTextHint", { fg = colors.hint })
  hl("TroubleSource", { fg = colors.gray2 })
  hl("TroubleCode", { fg = colors.gray2 })
  hl("TroubleFile", { fg = colors.cyan })
  hl("TroubleLocation", { fg = colors.gray2 })
  hl("TroubleSignError", { fg = colors.error })
  hl("TroubleSignWarning", { fg = colors.warning })
  hl("TroubleSignInformation", { fg = colors.info })
  hl("TroubleSignHint", { fg = colors.hint })
  hl("TroubleSignOther", { fg = colors.pink })

  -- Cybu (buffer switcher)
  hl("CybuFocus", { fg = colors.lime, bold = true })
  hl("CybuAdjacent", { fg = colors.fg_alt })
  hl("CybuBackground", { fg = colors.gray2 })
  hl("CybuBorder", { fg = colors.border })

  -- Registers
  hl("RegistersNormal", { fg = colors.fg_alt, bg = colors.bg })
  hl("RegistersBorder", { fg = colors.border, bg = colors.bg })
  hl("RegistersTitle", { fg = colors.lime, bold = true })
  hl("RegistersHighlight", { fg = colors.orange, bold = true })

  -- Spectre (search and replace)
  hl("SpectreSearch", { fg = colors.orange, bold = true })
  hl("SpectreReplace", { fg = colors.green, bold = true })
  hl("SpectreFile", { fg = colors.cyan })
  hl("SpectreBorder", { fg = colors.border })
  hl("SpectreDir", { fg = colors.gray2 })
  hl("SpectreHeader", { fg = colors.lime, bold = true })

  -- Dressing (UI improvements)
  hl("DressingSelectText", { fg = colors.fg_alt })
  hl("DressingSelectBorder", { fg = colors.border })
  hl("DressingInputText", { fg = colors.fg_alt })
  hl("DressingInputBorder", { fg = colors.border })

  -- BQF (better quickfix)
  hl("BqfPreviewBorder", { fg = colors.border })
  hl("BqfPreviewTitle", { fg = colors.lime, bold = true })
  hl("BqfPreviewThumb", { bg = colors.gray3 })
  hl("BqfPreviewSbar", { bg = colors.gray2 })
  hl("BqfPreviewCursor", { fg = colors.bg, bg = colors.cyan })
  hl("BqfPreviewCursorLine", { bg = colors.gray5 })
  hl("BqfPreviewRange", { bg = colors.selection })
  hl("BqfSign", { fg = colors.cyan })

  -- Numb (line number preview)
  hl("NumbFloat", { fg = colors.fg_alt, bg = colors.bg })
  hl("NumbBorder", { fg = colors.border, bg = colors.bg })
  hl("NumbCursorLineNr", { fg = colors.lime, bold = true })

  -- Terminal colors
  vim.g.terminal_color_0 = colors.bg
  vim.g.terminal_color_1 = colors.red
  vim.g.terminal_color_2 = colors.green
  vim.g.terminal_color_3 = colors.orange
  vim.g.terminal_color_4 = colors.blue
  vim.g.terminal_color_5 = colors.pink
  vim.g.terminal_color_6 = colors.cyan
  vim.g.terminal_color_7 = colors.fg_alt
  vim.g.terminal_color_8 = colors.gray2
  vim.g.terminal_color_9 = colors.red
  vim.g.terminal_color_10 = colors.green
  vim.g.terminal_color_11 = colors.orange
  vim.g.terminal_color_12 = colors.blue
  vim.g.terminal_color_13 = colors.pink
  vim.g.terminal_color_14 = colors.cyan
  vim.g.terminal_color_15 = colors.fg
end

return M
