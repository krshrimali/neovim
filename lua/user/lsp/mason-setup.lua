-- Mason LSP Server Manager Configuration
-- Auto-installs all LSP servers for your languages

-- Setup Mason
require("mason").setup {
  ui = {
    border = "rounded",
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
}

-- Setup mason-lspconfig for automatic server installation
require("mason-lspconfig").setup {
  -- Automatically install these LSP servers
  ensure_installed = {
    -- Python
    "ruff", -- Python linting/formatting (fast Rust-based)
    "ty", -- Python type checking (fast type checker from Astral)

    -- JavaScript/TypeScript
    "ts_ls", -- TypeScript/JavaScript language server

    -- Rust
    "rust_analyzer", -- Rust language server

    -- C/C++
    "clangd", -- C/C++ language server

    -- Go
    "gopls", -- Go language server

    -- Lua
    "lua_ls", -- Lua language server

    -- Vim
    "vimls", -- Vim language server

    -- Markdown
    "marksman", -- Markdown language server

    -- JSON
    "jsonls", -- JSON language server

    -- YAML
    "yamlls", -- YAML language server

    -- Shell
    "bashls", -- Bash language server

    -- TOML
    "taplo", -- TOML language server

    -- CSS
    "cssls", -- CSS language server

    -- HTML
    "html", -- HTML language server
  },

  -- Automatically install servers when they're configured
  automatic_installation = true,
}
