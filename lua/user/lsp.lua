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

-- LSP keymaps and autocompletion setup
local on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    
    -- Enable fast native completion
    if client.supports_method('textDocument/completion') then
        vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end
    
    -- Keybindings
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
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

-- Common LSP capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()

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

-- Configure completion behavior
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.supports_method('textDocument/completion') then
            -- Enable completion with optimized settings
            vim.lsp.completion.enable(true, client.id, args.buf, {
                autotrigger = true,
                convert = function(item)
                    -- Optimize completion items for performance
                    return item
                end
            })
        end
    end,
})

-- Completion keymaps
vim.keymap.set('i', '<C-Space>', '<C-x><C-o>', { silent = true, desc = 'LSP completion' })
vim.keymap.set('i', '<Tab>', function()
    if vim.fn.pumvisible() == 1 then
        return '<C-n>'
    else
        return '<Tab>'
    end
end, { expr = true, silent = true })
vim.keymap.set('i', '<S-Tab>', function()
    if vim.fn.pumvisible() == 1 then
        return '<C-p>'
    else
        return '<S-Tab>'
    end
end, { expr = true, silent = true })
vim.keymap.set('i', '<CR>', function()
    if vim.fn.pumvisible() == 1 then
        return '<C-y>'
    else
        return '<CR>'
    end
end, { expr = true, silent = true })