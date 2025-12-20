-- Main LSP Configuration
-- Orchestrates all LSP components and sets up the complete LSP system

local M = {}

function M.setup()
  -- 1. Setup Mason for LSP server management
  require "user.lsp.mason-setup"

  -- 2. Setup LSP handlers (borders, floats)
  require("user.lsp.handlers").setup()

  -- 3. Setup diagnostics configuration (signs, highlights)
  require("user.lsp.diagnostics").setup()

  -- 4. Setup virtual diagnostics plugin (custom)
  require("user.lsp.virtual_diagnostics").setup {
    virtual_lines_enabled = false, -- Disabled by default (toggle with <leader>ll)
    virtual_text_enabled = false, -- Disabled by default (toggle with <leader>lv)
    debounce_ms = 100,
  }

  -- 5. Setup neodev for Lua LSP enhancements (MUST be before lua_ls)
  local neodev_ok, neodev = pcall(require, "neodev")
  if neodev_ok then
    neodev.setup {
      library = {
        enabled = true,
        runtime = true,
        types = true,
        plugins = true,
      },
    }
  end

  -- 6. Setup completion (blink.cmp)
  require("user.lsp.blink").setup()

  -- 7. Setup commands (:Format, :OR, etc.)
  require("user.lsp.commands").setup()

  -- 8. Configure all language servers
  require("user.lsp.servers").setup()

  -- 9. Setup fidget for LSP progress notifications
  local fidget_ok, fidget = pcall(require, "fidget")
  if fidget_ok then
    fidget.setup {
      notification = {
        window = {
          winblend = 0,
          border = "rounded",
        },
      },
    }
  end
end

return M
