-- Minimal LSP setup specifically for goto-preview
-- This allows goto-preview to work with vim.lsp while keeping COC.nvim for other features

local M = {}

-- Configure goto-preview to use vim.lsp
function M.setup()
  -- Only set up LSP servers that goto-preview needs
  -- We'll use a minimal configuration to avoid conflicts with COC
  
  local ok, lspconfig = pcall(require, 'lspconfig')
  if not ok then
    vim.notify("nvim-lspconfig not found, goto-preview will use COC fallback", vim.log.levels.WARN)
    return
  end
  
  -- Ensure vim.lsp doesn't interfere with COC globally
  vim.lsp.handlers["textDocument/hover"] = function() end
  vim.lsp.handlers["textDocument/signatureHelp"] = function() end
  
  -- Disable automatic LSP completion
  vim.g.completion_enable_auto_popup = 0
  
  -- Minimal LSP setup - only for goto-preview functionality
  -- NOTE: These language servers need to be installed separately:
  -- - pyright: npm install -g pyright
  -- - typescript-language-server: npm install -g typescript-language-server
  -- - rust-analyzer: Install via rustup component add rust-analyzer  
  -- - lua-language-server: Install via your package manager or from releases
  local servers = {
    'pyright',      -- Python
    'ts_ls',        -- TypeScript/JavaScript (formerly tsserver)
    'rust_analyzer', -- Rust
    'lua_ls',       -- Lua
  }
  
  -- Minimal capabilities - only what goto-preview needs
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  
  -- Explicitly disable completion capabilities to avoid conflicts with COC
  capabilities.textDocument.completion = nil
  capabilities.textDocument.hover = nil
  capabilities.textDocument.signatureHelp = nil
  capabilities.textDocument.documentSymbol = nil
  capabilities.textDocument.formatting = nil
  capabilities.textDocument.rangeFormatting = nil
  capabilities.textDocument.codeAction = nil
  capabilities.textDocument.rename = nil
  
  -- Disable most LSP features to avoid conflicts with COC
  local on_attach = function(client, bufnr)
    -- Disable most LSP features since COC handles them
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    client.server_capabilities.documentHighlightProvider = false
    client.server_capabilities.codeActionProvider = false
    client.server_capabilities.completionProvider = false
    client.server_capabilities.hoverProvider = false
    client.server_capabilities.signatureHelpProvider = false
    client.server_capabilities.renameProvider = false
    
    -- Ensure vim.lsp doesn't set omnifunc (let COC handle completion)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', '')
    
    -- Disable LSP completion entirely for this buffer
    vim.api.nvim_buf_set_option(bufnr, 'completefunc', '')
    
    -- Only keep what goto-preview needs
    -- client.server_capabilities.definitionProvider = true
    -- client.server_capabilities.referencesProvider = true
    -- client.server_capabilities.implementationProvider = true
    -- client.server_capabilities.typeDefinitionProvider = true
  end
  
  -- Set up each server with minimal config
  for _, server in ipairs(servers) do
    local config = {
      on_attach = on_attach,
      capabilities = capabilities,
      -- Minimal settings to avoid conflicts
      settings = {},
      -- Silent startup - don't show errors if language server isn't installed
      autostart = true,
      single_file_support = true,
    }
    
    -- Server-specific minimal configurations
    if server == 'lua_ls' then
      config.settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          diagnostics = { enable = false }, -- Let COC handle diagnostics
          workspace = { 
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      }
    elseif server == 'pyright' then
      config.settings = {
        python = {
          analysis = {
            diagnosticMode = "off", -- Let COC handle diagnostics
          }
        }
      }
    elseif server == 'ts_ls' then
      config.settings = {
        typescript = {
          diagnostics = { enable = false }, -- Let COC handle diagnostics
        },
        javascript = {
          diagnostics = { enable = false }, -- Let COC handle diagnostics
        }
      }
    end
    
    -- Setup server with error handling
    local setup_ok, _ = pcall(lspconfig[server].setup, config)
    if not setup_ok then
      vim.notify(string.format("Failed to setup %s language server for goto-preview", server), vim.log.levels.DEBUG)
    end
  end
  
  -- Configure goto-preview to use vim.lsp
  require('goto-preview').setup({
    width = 120,
    height = 25,
    default_mappings = false, -- We'll set up our own mappings
    debug = false,
    opacity = nil,
    resizing_mappings = false,
    post_open_hook = nil,
    post_close_hook = nil,
    references = {
      telescope = false, -- Use default LSP references
    },
    focus_on_open = true,
    dismiss_on_move = false,
    force_close = true,
    bufhidden = "wipe",
    stack_floating_preview_windows = true,
    preview_window_title = { enable = true, position = "left" },
  })
end

return M