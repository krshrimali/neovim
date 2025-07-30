-- ⚡ OPTIMIZED AUTOCOMMANDS
-- Smart grouping and conditional execution for faster startup

-- Create augroups for better organization and performance
local startup_group = vim.api.nvim_create_augroup("StartupOptimized", { clear = true })
local ui_group = vim.api.nvim_create_augroup("UIOptimized", { clear = true })
local file_group = vim.api.nvim_create_augroup("FileOptimized", { clear = true })
local git_group = vim.api.nvim_create_augroup("GitOptimized", { clear = true })

-- ⚡ STARTUP OPTIMIZATIONS
-- Only run essential autocommands immediately

-- Smart tree opening - only if no files specified
vim.api.nvim_create_autocmd("VimEnter", {
    group = startup_group,
    callback = function()
        -- Defer tree opening to avoid blocking startup
        vim.defer_fn(function()
            if vim.fn.argc() == 0 and vim.bo.filetype == "" then
                require("user.simple_tree").open_workspace()
            end
        end, 100)
    end,
})

-- ⚡ UI OPTIMIZATIONS
-- Defer UI-related autocommands

vim.defer_fn(function()
    -- Alpha status line handling
    vim.api.nvim_create_autocmd("User", {
        group = ui_group,
        pattern = "AlphaReady",
        callback = function()
            vim.cmd("set laststatus=0 | autocmd BufUnload <buffer> set laststatus=3")
        end,
    })
    
    -- Quick close for special filetypes
    vim.api.nvim_create_autocmd("FileType", {
        group = ui_group,
        pattern = {
            "qf", "help", "man", "lspinfo", "spectre_panel", "lir",
            "DressingSelect", "tsplayground", "Markdown",
        },
        callback = function()
            vim.cmd([[
                nnoremap <silent> <buffer> q :close<CR> 
                nnoremap <silent> <buffer> <esc> :close<CR> 
                set nobuflisted
            ]])
        end,
    })
    
    -- Terminal optimizations
    vim.api.nvim_create_autocmd("TermOpen", {
        group = ui_group,
        callback = function()
            vim.opt_local.signcolumn = "no"
        end,
    })
end, 200)

-- ⚡ FILE OPTIMIZATIONS
-- Smart file-related autocommands with conditions

local function is_large_file(buf)
    buf = buf or 0
    local max_filesize = 50 * 1024 -- 50KB
    local filename = vim.api.nvim_buf_get_name(buf)
    if filename == "" then return false end
    
    local ok, stats = pcall(vim.loop.fs_stat, filename)
    return ok and stats and stats.size > max_filesize
end

-- Defer file-related autocommands
vim.defer_fn(function()
    -- Format options - only for non-large files
    vim.api.nvim_create_autocmd("FileType", {
        group = file_group,
        callback = function()
            if not is_large_file() then
                vim.opt_local.formatoptions:remove({ "c", "r", "o" })
            end
        end,
    })
    
    -- Language-specific settings - only when needed
    vim.api.nvim_create_autocmd("FileType", {
        group = file_group,
        pattern = { "c", "cpp" },
        callback = function()
            if not is_large_file() then
                vim.opt_local.shiftwidth = 4
                vim.opt_local.tabstop = 4
                vim.opt_local.expandtab = true
            end
        end,
    })
    
    -- Highlight on yank - only for interactive sessions
    if vim.fn.argc() == 0 then
        vim.api.nvim_create_autocmd("TextYankPost", {
            group = file_group,
            callback = function()
                vim.highlight.on_yank({ timeout = 200 })
            end,
        })
    end
end, 300)

-- ⚡ GIT OPTIMIZATIONS
-- Only load git-related autocommands if in git repo

vim.defer_fn(function()
    if vim.fn.isdirectory(".git") == 1 then
        -- Git-specific autocommands only in git repos
        vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
            group = git_group,
            callback = function()
                -- Trigger git signs loading
                vim.defer_fn(function()
                    vim.cmd("Lazy load gitsigns.nvim")
                end, 100)
            end,
            once = true, -- Only run once
        })
    end
end, 500)

-- ⚡ SMART PLUGIN LOADING
-- Load plugins based on context and usage patterns

local function smart_plugin_load()
    local ft = vim.bo.filetype
    local filename = vim.api.nvim_buf_get_name(0)
    
    -- Programming language detection
    local programming_fts = {
        "lua", "python", "javascript", "typescript", "rust", "go",
        "c", "cpp", "java", "php", "ruby", "vim", "sh", "zsh", "bash"
    }
    
    if vim.tbl_contains(programming_fts, ft) and not is_large_file() then
        -- Load LSP and treesitter for programming files
        vim.defer_fn(function()
            vim.cmd("Lazy load coc.nvim")
            vim.cmd("Lazy load nvim-treesitter")
        end, 200)
    end
    
    -- Load todo-comments for code files
    if vim.tbl_contains(programming_fts, ft) then
        vim.defer_fn(function()
            vim.cmd("Lazy load todo-comments.nvim")
        end, 300)
    end
end

-- Smart loading based on file type
vim.api.nvim_create_autocmd("FileType", {
    group = startup_group,
    callback = smart_plugin_load,
})

-- ⚡ PERFORMANCE MONITORING
-- Optional performance tracking (only in debug mode)

if vim.env.NVIM_DEBUG then
    vim.defer_fn(function()
        vim.api.nvim_create_autocmd("User", {
            pattern = "LazyLoad",
            callback = function(event)
                print("⚡ Loaded plugin: " .. event.data)
            end,
        })
    end, 1000)
end

-- ⚡ CLEANUP AND MAINTENANCE
-- Background cleanup tasks

vim.defer_fn(function()
    -- Clean up old swap files
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
            local swap_dir = vim.fn.stdpath("state") .. "/swap"
            if vim.fn.isdirectory(swap_dir) == 1 then
                local files = vim.fn.glob(swap_dir .. "/*", false, true)
                for _, file in ipairs(files) do
                    local stat = vim.loop.fs_stat(file)
                    if stat and stat.mtime.sec < (os.time() - 24 * 60 * 60) then -- 1 day old
                        vim.fn.delete(file)
                    end
                end
            end
        end,
        once = true,
    })
end, 2000)

-- ⚡ STARTUP COMPLETION SIGNAL
-- Signal when startup optimizations are complete

vim.defer_fn(function()
    vim.api.nvim_exec_autocmds("User", { pattern = "StartupOptimizationComplete" })
    
    if vim.env.NVIM_DEBUG then
        print("⚡ Startup optimizations completed")
    end
end, 1000)

