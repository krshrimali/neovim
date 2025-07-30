-- ⚡ ULTRA-FAST STARTUP INIT.LUA
-- Only load absolute essentials immediately, defer everything else
-- Integrates all advanced startup optimization systems

-- Performance tracking (disabled in production)
local startup_time = vim.fn.reltime()

-- Essential immediate loads (UI-critical only)
require "user.plugins"  -- Plugin manager (lazy.nvim)
require "user.options"  -- Core vim options

-- Initialize optimization systems
local optimization_systems = {
    { module = "user.startup_cache", name = "Startup Cache" },
    { module = "user.minimal_mode", name = "Minimal Mode" },
    { module = "user.async_loader", name = "Async Loader" },
    { module = "user.intelligent_preloader", name = "Intelligent Preloader" },
}

-- Smart conditional loading based on context
local function smart_load()
    local argc = vim.fn.argc()
    local is_stdin = vim.fn.getline(1) ~= ""
    local is_directory = argc > 0 and vim.fn.isdirectory(vim.fn.argv(0)) == 1
    
    -- Check if minimal mode should be used
    local minimal_mode = require("user.minimal_mode")
    local is_minimal = minimal_mode.init()
    
    if is_minimal then
        -- Minimal mode handles its own loading
        return
    end
    
    -- Normal startup path
    -- Load keymaps immediately only if interactive
    if argc == 0 or not is_stdin then
        require "user.keymaps"
    else
        -- Defer keymaps for file opening
        vim.defer_fn(function()
            require "user.keymaps"
        end, 10)
    end
    
    -- Colorscheme - load immediately for UI consistency
    require "user.colorscheme"
    
    -- Defer non-critical immediate configs
    vim.defer_fn(function()
        -- Only load if we have files to work with
        if argc > 0 or vim.bo.filetype ~= "" then
            require "user.autocommands"
        end
    end, 50)
end

-- Initialize optimization systems
local function init_optimization_systems()
    for _, system in ipairs(optimization_systems) do
        local ok, module = pcall(require, system.module)
        if ok and module.init then
            local init_ok, result = pcall(module.init)
            if not init_ok then
                vim.defer_fn(function()
                    vim.notify("Failed to initialize " .. system.name .. ": " .. tostring(result), vim.log.levels.WARN)
                end, 100)
            end
        end
    end
end

-- Execute smart loading
smart_load()

-- Initialize optimization systems
init_optimization_systems()

-- Ultra-fast essential configs (load immediately)
local essential_configs = {
    "user.colorizer",    -- Syntax highlighting colors
    "user.functions",    -- Core functions
    "user.nvim_transparent", -- UI transparency
}

for _, config in ipairs(essential_configs) do
    local ok, _ = pcall(require, config)
    if not ok then
        vim.defer_fn(function()
            require(config)
        end, 100)
    end
end

-- Progressive loading system - load heavier configs progressively
local progressive_configs = {
    { module = "user.surround", delay = 150 },
    { module = "user.diagnostics_display", delay = 200 },
    { module = "user.terminal", delay = 300 },
}

for _, config in ipairs(progressive_configs) do
    vim.defer_fn(function()
        require(config.module)
    end, config.delay)
end

-- Buffer browser setup (lazy loaded on keymap)
vim.keymap.set("n", "<leader>bb", function()
    require("user.buffer_browser").open_buffer_browser()
end, { desc = "Buffer Browser", silent = true })

vim.keymap.set("n", "<leader>bs", function()
    require("user.buffer_browser").toggle_sidebar()
end, { desc = "Buffer Sidebar", silent = true })

-- Advanced optimization commands
vim.api.nvim_create_user_command("StartupStats", function()
    local cache = require("user.startup_cache")
    local preloader = require("user.intelligent_preloader")
    local minimal = require("user.minimal_mode")
    
    local stats = {
        startup_time = vim.fn.reltimestr(vim.fn.reltime(startup_time)) .. "ms",
        minimal_mode = minimal.is_enabled() and "ON" or "OFF",
        enhancement_level = minimal.get_level(),
        preloader_stats = preloader.get_stats(),
        loaded_features = vim.tbl_count(minimal.get_loaded_features()),
    }
    
    print("⚡ STARTUP OPTIMIZATION STATS ⚡")
    print("Startup Time: " .. stats.startup_time)
    print("Minimal Mode: " .. stats.minimal_mode)
    print("Enhancement Level: " .. stats.enhancement_level)
    print("Loaded Features: " .. stats.loaded_features)
    print("Preloader: " .. vim.inspect(stats.preloader_stats))
end, { desc = "Show startup optimization statistics" })

vim.api.nvim_create_user_command("OptimizeNow", function()
    local preloader = require("user.intelligent_preloader")
    preloader.preload_category("editing")
    preloader.preload_category("file_management")
    vim.notify("⚡ Optimization triggered", vim.log.levels.INFO)
end, { desc = "Trigger immediate optimization" })

-- Smart startup completion callback
vim.defer_fn(function()
    -- Only calculate startup time in debug mode
    if vim.env.NVIM_DEBUG then
        local elapsed = vim.fn.reltimestr(vim.fn.reltime(startup_time))
        print(string.format("⚡ Startup completed in %sms", elapsed))
    end
    
    -- Trigger post-startup optimizations
    vim.api.nvim_exec_autocmds("User", { pattern = "StartupComplete" })
    
    -- Show brief success message
    vim.defer_fn(function()
        if not vim.env.NVIM_MINIMAL then
            vim.notify("⚡ Ultra-fast startup complete", vim.log.levels.INFO, { timeout = 1000 })
        end
    end, 100)
end, 500)
