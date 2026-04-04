-- LSP Handlers Configuration
-- Customizes hover, signature help, and diagnostic floats with rounded borders

local M = {}

function M.setup()
  -- Hover with rounded borders (matching CoC style)
  vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
    config = vim.tbl_deep_extend("force", config or {}, {
      border = "rounded",
      max_width = 120,
      max_height = 35,
      focusable = true,
    })
    return vim.lsp.handlers.hover(err, result, ctx, config)
  end

  -- Signature help with rounded borders
  vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
    config = vim.tbl_deep_extend("force", config or {}, {
      border = "rounded",
      max_width = 100,
      max_height = 15,
      focusable = false,
    })
    return vim.lsp.handlers.signature_help(err, result, ctx, config)
  end
end

return M
