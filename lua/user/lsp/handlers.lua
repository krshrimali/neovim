-- LSP Handlers Configuration
-- Customizes hover, signature help, and diagnostic floats with rounded borders

local M = {}

function M.setup()
  -- Hover with rounded borders (matching CoC style)
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover,
    {
      border = "rounded",
      title = " Documentation ",
      max_width = 120,
      max_height = 35,
      focusable = true,
    }
  )

  -- Signature help with rounded borders
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    {
      border = "rounded",
      title = " Signature ",
      max_width = 100,
      max_height = 15,
      focusable = false,
    }
  )

  -- Custom handler for references to use quickfix instead of location list
  vim.lsp.handlers["textDocument/references"] = vim.lsp.with(
    vim.lsp.handlers["textDocument/references"],
    {
      -- Use qflist for better integration
      on_list = function(options)
        vim.fn.setqflist({}, ' ', options)
        vim.cmd('copen')
      end,
    }
  )
end

return M
