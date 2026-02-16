-- LSP Server Configurations & Keymaps
-- Configures all language servers and sets up LspAttach autocmd for keymaps

local M = {}

-- Get capabilities for completion
local function get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Blink.cmp capabilities
  local blink_ok, blink = pcall(require, "blink.cmp")
  if blink_ok then capabilities = blink.get_lsp_capabilities(capabilities) end

  -- Prefer UTF-8 position encoding to avoid mixed encoding warnings
  capabilities.general = capabilities.general or {}
  capabilities.general.positionEncodings = { "utf-8", "utf-16" }

  return capabilities
end

-- Setup keymaps on LSP attach (matching CoC keymaps)
local function on_attach(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- Navigation (matching CoC keymaps)
  vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  vim.keymap.set("n", "gy", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)

  -- Hover documentation (matching CoC's K)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

  -- Diagnostics navigation (matching CoC's [g / ]g)
  vim.keymap.set("n", "[g", function() vim.diagnostic.jump { count = -1, float = true } end, opts)

  vim.keymap.set("n", "]g", function() vim.diagnostic.jump { count = 1, float = true } end, opts)

  -- Rename (matching CoC's <leader>rn)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

  -- Format (matching CoC's <leader>f) - both normal and visual mode
  vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format { async = true } end, opts)

  vim.keymap.set("v", "<leader>f", function()
    local start_row, _ = unpack(vim.api.nvim_buf_get_mark(0, "<"))
    local end_row, _ = unpack(vim.api.nvim_buf_get_mark(0, ">"))
    vim.lsp.buf.format {
      async = true,
      range = {
        ["start"] = { start_row, 0 },
        ["end"] = { end_row, 0 },
      },
    }
  end, opts)

  -- Code actions (matching CoC's <leader>a, <leader>ac, <leader>as)
  vim.keymap.set({ "n", "v" }, "<leader>a", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>ac", vim.lsp.buf.code_action, opts)
  vim.keymap.set(
    "n",
    "<leader>as",
    function()
      vim.lsp.buf.code_action {
        context = {
          only = { "source" },
          diagnostics = {},
        },
      }
    end,
    opts
  )

  -- Quickfix (matching CoC's <leader>qf)
  vim.keymap.set("n", "<leader>qf", vim.lsp.buf.code_action, opts)

  -- Signature help (matching CoC's <C-k> in insert mode)
  vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)

  -- Attach nvim-navic for breadcrumbs if available
  if client.server_capabilities.documentSymbolProvider then
    local navic_ok, navic = pcall(require, "nvim-navic")
    if navic_ok then navic.attach(client, bufnr) end
  end

  -- Highlight symbol under cursor (matching CoC behavior)
  -- Disabled by default for performance - uncomment if needed
  -- if client.server_capabilities.documentHighlightProvider then
  --   vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
  --   vim.api.nvim_clear_autocmds { buffer = bufnr, group = "lsp_document_highlight" }
  --   vim.api.nvim_create_autocmd({ "CursorHold" }, {
  --     group = "lsp_document_highlight",
  --     buffer = bufnr,
  --     callback = vim.lsp.buf.document_highlight,
  --   })
  --   vim.api.nvim_create_autocmd({ "CursorMoved" }, {
  --     group = "lsp_document_highlight",
  --     buffer = bufnr,
  --     callback = vim.lsp.buf.clear_references,
  --   })
  -- end
end

-- Server-specific configurations
function M.setup()
  local capabilities = get_capabilities()

  -- Configure common settings for all servers
  vim.lsp.config("*", {
    capabilities = capabilities,
    on_attach = on_attach,
  })

  -- Python: Ruff (linting + formatting)
  vim.lsp.config.ruff = {
    on_attach = function(client, bufnr)
      -- Disable hover in favor of ty
      client.server_capabilities.hoverProvider = false
      on_attach(client, bufnr)
    end,
    init_options = {
      settings = {
        args = { "--line-length=88" },
      },
    },
  }

  -- Python: ty (fast type checker from Astral)
  vim.lsp.config.ty = {
    settings = {
      ty = {
        -- ty language server settings go here
      },
    },
  }

  -- TypeScript/JavaScript
  vim.lsp.config.ts_ls = {
    settings = {
      typescript = {
        suggest = { autoImports = true },
        inlayHints = {
          includeInlayParameterNameHints = "none",
          includeInlayFunctionParameterTypeHints = false,
          includeInlayVariableTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = false,
        },
      },
      javascript = {
        suggest = { autoImports = true },
      },
    },
  }

  -- Rust
  vim.lsp.config.rust_analyzer = {
    on_attach = on_attach, -- Explicitly set on_attach
    settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
        },
        completion = {
          autoimport = { enable = true },
        },
        check = {
          command = "clippy",
        },
      },
    },
  }

  -- C/C++
  vim.lsp.config.clangd = {
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

  -- Go
  vim.lsp.config.gopls = {
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
          shadow = true,
        },
        staticcheck = true,
        gofumpt = true,
      },
    },
  }

  -- Lua (configured for Neovim development)
  -- Note: neodev is set up in init.lua BEFORE this runs
  vim.lsp.config.lua_ls = {
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          -- Don't scan runtime files - neodev handles this and it's slow
          library = {},
          checkThirdParty = false,
          maxPreload = 1000,
          preloadFileSize = 100,
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

  -- Vim
  vim.lsp.config.vimls = {}

  -- Markdown
  vim.lsp.config.marksman = {}

  -- JSON
  vim.lsp.config.jsonls = {
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(),
        validate = { enable = true },
      },
    },
  }

  -- YAML
  vim.lsp.config.yamlls = {
    settings = {
      yaml = {
        schemas = {
          kubernetes = "*.yaml",
          ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*",
          ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
        },
      },
    },
  }

  -- Shell (Bash)
  vim.lsp.config.bashls = {}

  -- TOML
  vim.lsp.config.taplo = {}

  -- CSS
  vim.lsp.config.cssls = {}

  -- HTML
  vim.lsp.config.html = {}

  -- Enable servers on demand based on filetype
  -- This is faster than enabling all servers at once
  local filetype_servers = {
    python = { "ruff", "ty" },
    typescript = { "ts_ls" },
    javascript = { "ts_ls" },
    typescriptreact = { "ts_ls" },
    javascriptreact = { "ts_ls" },
    rust = { "rust_analyzer" },
    c = { "clangd" },
    cpp = { "clangd" },
    go = { "gopls" },
    lua = { "lua_ls" },
    vim = { "vimls" },
    markdown = { "marksman" },
    json = { "jsonls" },
    yaml = { "yamlls" },
    sh = { "bashls" },
    bash = { "bashls" },
    toml = { "taplo" },
    css = { "cssls" },
    html = { "html" },
  }

  -- Enable servers lazily based on current filetype
  vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
      local ft = args.match
      local servers = filetype_servers[ft]
      if servers then
        for _, server in ipairs(servers) do
          pcall(vim.lsp.enable, server)
        end
      end
    end,
  })
end

return M
