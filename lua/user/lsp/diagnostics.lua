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

  -- Theme-aware highlights (adapt to light/dark background)
  local is_light = vim.o.background == "light"
  local hl = vim.api.nvim_set_hl

  -- Diagnostic colors
  local err = is_light and "#af3029" or "#f38ba8"
  local warn = is_light and "#bc5215" or "#fab387"
  local info = is_light and "#205ea6" or "#89dceb"
  local hint = is_light and "#24837b" or "#94e2d5"
  local float_bg = is_light and "#f2f0e5" or "#1e1e2e"
  local dim = is_light and "#878580" or "#6c7086"

  -- Diagnostic signs
  hl(0, "DiagnosticSignError", { fg = err, bold = true })
  hl(0, "DiagnosticSignWarn", { fg = warn, bold = true })
  hl(0, "DiagnosticSignInfo", { fg = info })
  hl(0, "DiagnosticSignHint", { fg = hint })

  -- Diagnostic underlines
  hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = err })
  hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = warn })
  hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = info })
  hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = hint })

  -- Diagnostic virtual text
  hl(0, "DiagnosticVirtualTextError", { fg = err, italic = true })
  hl(0, "DiagnosticVirtualTextWarn", { fg = warn, italic = true })
  hl(0, "DiagnosticVirtualTextInfo", { fg = info, italic = true })
  hl(0, "DiagnosticVirtualTextHint", { fg = hint, italic = true })

  -- Diagnostic floating window
  hl(0, "DiagnosticFloatingError", { fg = err, bg = float_bg })
  hl(0, "DiagnosticFloatingWarn", { fg = warn, bg = float_bg })
  hl(0, "DiagnosticFloatingInfo", { fg = info, bg = float_bg })
  hl(0, "DiagnosticFloatingHint", { fg = hint, bg = float_bg })

  -- Virtual line highlights (for virtual diagnostics plugin)
  hl(0, "LspVirtualLineError", { fg = err, italic = true })
  hl(0, "LspVirtualLineWarn", { fg = warn, italic = true })
  hl(0, "LspVirtualLineInfo", { fg = info, italic = true })
  hl(0, "LspVirtualLineHint", { fg = hint, italic = true })

  -- Unused/unnecessary code - gray out
  hl(0, "DiagnosticUnnecessary", { fg = dim, strikethrough = true })

  -- Deprecated symbols - strikethrough
  hl(0, "DiagnosticDeprecated", { strikethrough = true, sp = warn })

  -- Current search match (distinct from other matches)
  hl(0, "CurSearch", { fg = is_light and "#100f0f" or "#1e1e2e", bg = is_light and "#d0a215" or "#f9e2af", bold = true })
  hl(0, "Search", { fg = is_light and "#100f0f" or "#1e1e2e", bg = is_light and "#e8cca7" or "#f5c2e7" })

  -- Window split separator
  hl(0, "WinSeparator", { fg = is_light and "#b7b5ac" or "#45475a" })

  -- Floating windows
  hl(0, "NormalFloat", { bg = float_bg })
  hl(0, "FloatBorder", { fg = is_light and "#5171a5" or "#89b4fa", bg = float_bg })
  hl(0, "FloatTitle", { fg = is_light and "#100f0f" or "#cdd6f4", bg = float_bg, bold = true })

  -- Matching parentheses
  hl(0, "MatchParen", { fg = is_light and "#bc5215" or "#f9e2af", bold = true, underline = true })

  -- Dimmed punctuation
  hl(0, "@punctuation.bracket", { fg = is_light and "#9e9a90" or "#7f849c" })
  hl(0, "@punctuation.delimiter", { fg = is_light and "#9e9a90" or "#7f849c" })

  -- Visual selection
  hl(0, "Visual", { bg = is_light and "#d0cec7" or "#45475a" })

  -- LSP inlay hints
  hl(0, "LspInlayHint", { fg = is_light and "#878580" or "#6c7086", italic = true })
end

return M
