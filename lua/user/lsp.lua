-- Native LSP configuration
-- Optimized for performance with fast completion

local lspconfig = require('lspconfig')
local mason_lspconfig = require('mason-lspconfig')

-- Setup Mason to automatically install LSP servers
mason_lspconfig.setup({
    ensure_installed = {
        "pyright",
        "ruff",
        "rust_analyzer", 
        "lua_ls",
        "clangd",
    },
    automatic_installation = true,
})

-- Ensure servers are setup when installed by Mason
mason_lspconfig.setup_handlers({
    -- Default handler for all servers
    function(server_name)
        lspconfig[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
        })
    end,
    
    -- Custom handlers for specific servers (defined below)
    ["pyright"] = function() end, -- Handled separately
    ["ruff"] = function() end,    -- Handled separately  
    ["rust_analyzer"] = function() end, -- Handled separately
    ["lua_ls"] = function() end,  -- Handled separately
    ["clangd"] = function() end,  -- Handled separately
})

-- LSP keymaps setup (completion handled by blink.cmp)
local on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    
    -- Keybindings
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    -- Use goto-preview for definition to avoid quickfix
    vim.keymap.set('n', 'gd', function()
        require('goto-preview').goto_preview_definition()
    end, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    -- Disable code action icons in insert mode by only enabling in normal and visual modes
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>f', function()
        vim.lsp.buf.format({ async = true })
    end, opts)
    
    -- Diagnostic navigation
    vim.keymap.set('n', '[g', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']g', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
end

-- Common LSP capabilities (enhanced for blink.cmp)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)

-- Diagnostic configuration
vim.diagnostic.config({
    virtual_text = false, -- Disable inline virtual text for performance
    signs = true,
    underline = true,
    update_in_insert = false, -- Don't update diagnostics in insert mode for performance
    severity_sort = true,
    float = {
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
})

-- Configure diagnostic signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Disable code action signs/icons that might appear in insert mode
-- This prevents lightbulb icons from showing up
vim.fn.sign_define("LightBulbSign", { text = "", texthl = "", numhl = "" })
vim.fn.sign_define("CodeActionSign", { text = "", texthl = "", numhl = "" })

-- Python: Pyright for LSP features, Ruff for formatting/diagnostics
lspconfig.pyright.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        python = {
            analysis = {
                -- Optimize for large workspaces
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly", -- Only analyze open files for performance
                typeCheckingMode = "basic", -- Use basic type checking for speed
            },
        },
    },
})

-- Ruff for Python linting and formatting
lspconfig.ruff.setup({
    on_attach = function(client, bufnr)
        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
        on_attach(client, bufnr)
    end,
    capabilities = capabilities,
    init_options = {
        settings = {
            -- Configure ruff for fast operation
            args = {
                "--line-length=88",
            },
        },
    },
})

-- Rust: rust-analyzer
lspconfig.rust_analyzer.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                allFeatures = true,
            },
            checkOnSave = {
                command = "clippy",
            },
        },
    },
})

-- Lua: lua_ls (optimized for Neovim)
lspconfig.lua_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
            },
            diagnostics = {
                globals = { 'vim' },
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
                }
            },
        },
    },
})

-- C/C++: clangd
lspconfig.clangd.setup({
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
})

-- Auto-format on save for supported languages
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = { '*.py', '*.rs', '*.lua', '*.c', '*.cpp', '*.h', '*.hpp' },
    callback = function()
        vim.lsp.buf.format({ timeout_ms = 1000 })
    end,
})

-- Show line diagnostics automatically in hover window
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        local opts = {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = 'rounded',
            source = 'always',
            prefix = ' ',
            scope = 'cursor',
        }
        vim.diagnostic.open_float(nil, opts)
    end
})

-- Completion is handled by blink.cmp