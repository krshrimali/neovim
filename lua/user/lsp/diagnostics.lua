-- LSP Diagnostics Configuration
-- Matches CoC diagnostic signs (E/W/I/H) and Catppuccin colors

local M = {}

function M.setup()
  -- Configure diagnostic behavior (matching CoC)
  vim.diagnostic.config {
    -- Virtual text disabled (using custom virtual diagnostics plugin instead)
    virtual_text = false,

    -- Show signs in the sign column with custom text
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "E",
        [vim.diagnostic.severity.WARN] = "W",
        [vim.diagnostic.severity.INFO] = "I",
        [vim.diagnostic.severity.HINT] = "H",
      },
    },

    -- Underline diagnostics
    underline = true,

    -- Don't update diagnostics in insert mode
    update_in_insert = false,

    -- Sort by severity (errors first)
    severity_sort = true,

    -- Float window configuration (matching CoC style)
    float = {
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
      focusable = true,
      max_width = 100,
      max_height = 25,
    },
  }

  -- Catppuccin-style diagnostic highlights
  vim.cmd [[
    " Diagnostic signs (Catppuccin Mocha colors)
    highlight DiagnosticSignError guifg=#f38ba8 guibg=NONE gui=bold
    highlight DiagnosticSignWarn guifg=#fab387 guibg=NONE gui=bold
    highlight DiagnosticSignInfo guifg=#89dceb guibg=NONE
    highlight DiagnosticSignHint guifg=#94e2d5 guibg=NONE

    " Diagnostic underlines
    highlight DiagnosticUnderlineError gui=undercurl guisp=#f38ba8
    highlight DiagnosticUnderlineWarn gui=undercurl guisp=#fab387
    highlight DiagnosticUnderlineInfo gui=undercurl guisp=#89dceb
    highlight DiagnosticUnderlineHint gui=undercurl guisp=#94e2d5

    " Diagnostic virtual text (for custom plugin)
    highlight DiagnosticVirtualTextError guifg=#f38ba8 gui=italic
    highlight DiagnosticVirtualTextWarn guifg=#fab387 gui=italic
    highlight DiagnosticVirtualTextInfo guifg=#89dceb gui=italic
    highlight DiagnosticVirtualTextHint guifg=#94e2d5 gui=italic

    " Diagnostic floating window
    highlight DiagnosticFloatingError guifg=#f38ba8 guibg=#1e1e2e
    highlight DiagnosticFloatingWarn guifg=#fab387 guibg=#1e1e2e
    highlight DiagnosticFloatingInfo guifg=#89dceb guibg=#1e1e2e
    highlight DiagnosticFloatingHint guifg=#94e2d5 guibg=#1e1e2e

    " Custom virtual line highlights (for virtual diagnostics plugin)
    highlight LspVirtualLineError guifg=#f38ba8 gui=italic
    highlight LspVirtualLineWarn guifg=#fab387 gui=italic
    highlight LspVirtualLineInfo guifg=#89b4fa gui=italic
    highlight LspVirtualLineHint guifg=#94e2d5 gui=italic

    " Unused/unnecessary code - gray out
    highlight DiagnosticUnnecessary guifg=#6c7086 gui=strikethrough

    " Deprecated symbols - strikethrough
    highlight DiagnosticDeprecated gui=strikethrough guisp=#fab387

  ]]

  -- Theme-aware highlights (adapt to light/dark background)
  local is_light = vim.o.background == "light"

  local hl = vim.api.nvim_set_hl

  -- Current search match (distinct from other matches)
  hl(
    0,
    "CurSearch",
    { fg = is_light and "#100f0f" or "#1e1e2e", bg = is_light and "#d0a215" or "#f9e2af", bold = true }
  )
  hl(0, "Search", { fg = is_light and "#100f0f" or "#1e1e2e", bg = is_light and "#e8cca7" or "#f5c2e7" })

  -- Window split separator
  hl(0, "WinSeparator", { fg = is_light and "#b7b5ac" or "#45475a", bg = "NONE" })

  -- Floating windows
  local float_bg = is_light and "#f2f0e5" or "#1e1e2e"
  hl(0, "NormalFloat", { bg = float_bg })
  hl(0, "FloatBorder", { fg = is_light and "#5171a5" or "#89b4fa", bg = float_bg })
  hl(0, "FloatTitle", { fg = is_light and "#100f0f" or "#cdd6f4", bg = float_bg, bold = true })

  -- Matching parentheses
  hl(0, "MatchParen", { fg = is_light and "#bc5215" or "#f9e2af", bold = true, underline = true })

  -- Dimmed punctuation
  local dim = is_light and "#9e9a90" or "#7f849c"
  hl(0, "@punctuation.bracket", { fg = dim })
  hl(0, "@punctuation.delimiter", { fg = dim })

  -- Visual selection
  hl(0, "Visual", { bg = is_light and "#d0cec7" or "#45475a" })

  -- LSP inlay hints
  hl(0, "LspInlayHint", { fg = is_light and "#878580" or "#6c7086", italic = true })
end

return M
