-- Native LSP configuration
-- Optimized for performance with fast completion
-- Pyright for navigation/definitions, Ruff for diagnostics/linting

local lspconfig = require "lspconfig"
-- local mason_lspconfig = require('mason-lspconfig')

-- Prevent duplicate LSP server instances
-- Common LSP capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { "documentation", "detail", "additionalTextEdits" },
}
capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
capabilities.textDocument.completion.completionItem.deprecatedSupport = true
capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
capabilities.textDocument.completion.completionItem.preselectSupport = true

local navic = require "nvim-navic"

-- LSP keymaps setup (completion handled by blink.cmp)
local on_attach = function(client, bufnr)
  navic.attach(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- Keybindings
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set("n", "<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
  vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>f", function()
    -- Add error handling for formatting
    local success, err = pcall(vim.lsp.buf.format, { async = true })
    if not success then vim.notify("Formatting failed: " .. tostring(err), vim.log.levels.ERROR) end
  end, opts)
  vim.keymap.set({ "n", "v" }, "<leader>lf", function()
    local mode = vim.api.nvim_get_mode().mode
    local success, err

    if mode == "v" or mode == "V" or mode == "\22" then -- Visual modes
      -- Format selection
      success, err = pcall(vim.lsp.buf.format, {
        async = true,
        range = {
          start = vim.api.nvim_buf_get_mark(0, "<"),
          ["end"] = vim.api.nvim_buf_get_mark(0, ">"),
        },
      })
    else
      -- Format entire file
      success, err = pcall(vim.lsp.buf.format, { async = true })
    end

    if not success then vim.notify("Formatting failed: " .. tostring(err), vim.log.levels.ERROR) end
  end, opts)

  -- Diagnostic navigation
  vim.keymap.set("n", "[g", function() vim.diagnostic.jump { count = -1, float = true } end, opts)
  vim.keymap.set("n", "]g", function() vim.diagnostic.jump { count = 1, float = true } end, opts)
  vim.keymap.set("n", "<leader>De", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "<leader>Q", vim.diagnostic.setloclist, opts)
end

-- -- Diagnostic configuration
vim.diagnostic.config {
  virtual_text = false, -- Disable inline virtual text for performance
  signs = true,
  underline = true,
  update_in_insert = false, -- Don't update diagnostics in insert mode for performance
  severity_sort = true,
  float = {
    border = "rounded",
    header = "",
    prefix = "",
  },
}

-- Python: Pyright for LSP features (navigation, completion, hover)
lspconfig.pyright.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        -- Keep type checking for navigation but diagnostics will be filtered
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly", -- Only analyze open files for performance
        typeCheckingMode = "basic", -- Use basic type checking for speed
      },
    },
  },
}

-- Ruff for Python linting, formatting, and diagnostics
lspconfig.ruff.setup {
  on_attach = function(client, bufnr)
    -- Disable hover in favor of Pyright
    client.server_capabilities.hoverProvider = false
    -- Disable completion in favor of Pyright
    client.server_capabilities.completionProvider = false
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  single_file_support = true,
  init_options = {
    settings = {
      -- Configure ruff for fast operation
      args = {
        "--line-length=88",
      },
    },
  },
}

-- Rust: rust-analyzer
lspconfig.rust_analyzer.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
    },
  },
}

-- Lua: lua_ls (optimized for Neovim)
lspconfig.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
        },
      },
    },
  },
}

-- C/C++: clangd
lspconfig.clangd.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
}

-- NOTE: Disabled auto-format for now.
-- Auto-format on save for supported languages
-- vim.api.nvim_create_autocmd('BufWritePre', {
--     pattern = { '*.py', '*.rs', '*.lua', '*.c', '*.cpp', '*.h', '*.hpp' },
--     callback = function()
--         -- Add error handling and timeout
--         local success, err = pcall(function()
--             vim.lsp.buf.format({
--                 timeout_ms = 1000,
--                 async = false -- Make it synchronous for save operations
--             })
--         end)
--         if not success then
--             vim.notify("Auto-format failed: " .. tostring(err), vim.log.levels.WARN)
--         end
--     end,
-- })

-- Show line diagnostics on cursor hold (less aggressive)
-- vim.api.nvim_create_autocmd("CursorHold", {
--     callback = function()
--         -- Only show diagnostics if there are any on the current line
--         local line_diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
--
--         if #line_diagnostics > 0 then
--             local opts = {
--                 focusable = false,
--                 close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
--                 border = 'rounded',
--                 source = 'always',
--                 prefix = ' ',
--                 scope = 'cursor',
--             }
--             vim.diagnostic.open_float(nil, opts)
--         end
--     end
-- })
--
-- Completion is handled by blink.cmp
