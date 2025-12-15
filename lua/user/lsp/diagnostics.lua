-- LSP Diagnostics Configuration
-- Matches CoC diagnostic signs (E/W/I/H) and Catppuccin colors

local M = {}

function M.setup()
  -- Define diagnostic signs (matching CoC)
  local signs = {
    { name = "DiagnosticSignError", text = "E" },
    { name = "DiagnosticSignWarn", text = "W" },
    { name = "DiagnosticSignInfo", text = "I" },
    { name = "DiagnosticSignHint", text = "H" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, {
      texthl = sign.name,
      text = sign.text,
      numhl = "",
    })
  end

  -- Configure diagnostic behavior (matching CoC)
  vim.diagnostic.config {
    -- Virtual text disabled (using custom virtual diagnostics plugin instead)
    virtual_text = false,

    -- Show signs in the sign column
    signs = true,

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
  ]]
end

return M
