-- ⚡ MINIMAL STARTUP MODE
-- Ultra-fast startup with progressive enhancement
-- Load only absolute essentials, enhance progressively

local M = {}

-- Minimal mode state
local minimal_mode = {
    enabled = false,
    enhancement_level = 0,
    loaded_features = {},
}

-- Feature levels for progressive enhancement
local ENHANCEMENT_LEVELS = {
    BARE = 0,        -- Only vim essentials
    BASIC = 1,       -- + basic UI (colorscheme, statusline)
    ENHANCED = 2,    -- + file management (fzf, tree)
    FULL = 3,        -- + LSP, treesitter, git
    COMPLETE = 4,    -- + all plugins and features
}

-- Feature registry by enhancement level
local feature_registry = {
    [ENHANCEMENT_LEVELS.BARE] = {
        -- Absolute minimum - just vim
        configs = {},
        plugins = {},
    },
    
    [ENHANCEMENT_LEVELS.BASIC] = {
        -- Basic UI essentials
        configs = {
            "user.colorscheme",
            "user.options",
            "user.keymaps",
        },
        plugins = {
            "decay",
            "nvim-notify",
            "lualine.nvim",
        },
    },
    
    [ENHANCEMENT_LEVELS.ENHANCED] = {
        -- File management and navigation
        configs = {
            "user.functions",
            "user.autocommands",
        },
        plugins = {
            "fzf-lua",
            "nvim-spider",
            "registers.nvim",
        },
    },
    
    [ENHANCEMENT_LEVELS.FULL] = {
        -- Development features
        configs = {
            "user.coc",
            "user.treesitter",
            "user.gitsigns",
        },
        plugins = {
            "coc.nvim",
            "nvim-treesitter",
            "gitsigns.nvim",
            "Comment.nvim",
        },
    },
    
    [ENHANCEMENT_LEVELS.COMPLETE] = {
        -- All remaining features
        configs = {
            "user.diagnostics_display",
            "user.terminal",
            "user.todo-comments",
            "user.spectre",
        },
        plugins = {
            "toggleterm.nvim",
            "nvim-spectre",
            "todo-comments.nvim",
            "which-key.nvim",
        },
    },
}

-- Check if we should start in minimal mode
local function should_use_minimal_mode()
    -- Use minimal mode if:
    -- 1. NVIM_MINIMAL environment variable is set
    -- 2. Starting with large files
    -- 3. SSH session
    -- 4. Low memory system
    
    if vim.env.NVIM_MINIMAL then
        return true
    end
    
    if vim.env.SSH_TTY then
        return true
    end
    
    -- Check for large files
    if vim.fn.argc() > 0 then
        for i = 0, vim.fn.argc() - 1 do
            local file = vim.fn.argv(i)
            local stat = vim.loop.fs_stat(file)
            if stat and stat.size > 100 * 1024 then -- 100KB
                return true
            end
        end
    end
    
    -- Check available memory (simplified)
    local meminfo = vim.fn.system("cat /proc/meminfo 2>/dev/null | grep MemAvailable")
    if meminfo and meminfo ~= "" then
        local mem_kb = tonumber(meminfo:match("(%d+)"))
        if mem_kb and mem_kb < 1024 * 1024 then -- Less than 1GB available
            return true
        end
    end
    
    return false
end

-- Load features for a specific enhancement level
local function load_enhancement_level(level)
    if minimal_mode.enhancement_level >= level then
        return -- Already loaded
    end
    
    local features = feature_registry[level]
    if not features then return end
    
    -- Load configurations
    for _, config in ipairs(features.configs) do
        if not minimal_mode.loaded_features[config] then
            local ok, _ = pcall(require, config)
            if ok then
                minimal_mode.loaded_features[config] = true
            end
        end
    end
    
    -- Load plugins (trigger lazy loading)
    for _, plugin in ipairs(features.plugins) do
        if not minimal_mode.loaded_features[plugin] then
            vim.defer_fn(function()
                local ok, _ = pcall(vim.cmd, "Lazy load " .. plugin)
                if ok then
                    minimal_mode.loaded_features[plugin] = true
                end
            end, 50)
        end
    end
    
    minimal_mode.enhancement_level = level
    
    -- Trigger enhancement event
    vim.api.nvim_exec_autocmds("User", { 
        pattern = "MinimalModeEnhanced",
        data = { level = level }
    })
end

-- Progressive enhancement based on usage
local function setup_progressive_enhancement()
    -- Enhance to BASIC level after initial startup
    vim.defer_fn(function()
        load_enhancement_level(ENHANCEMENT_LEVELS.BASIC)
    end, 100)
    
    -- Enhance to ENHANCED level when user starts interacting
    vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "CmdlineEnter" }, {
        callback = function()
            load_enhancement_level(ENHANCEMENT_LEVELS.ENHANCED)
        end,
        once = true,
    })
    
    -- Enhance to FULL level when opening programming files
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "lua", "python", "javascript", "typescript", "rust", "go", "c", "cpp" },
        callback = function()
            load_enhancement_level(ENHANCEMENT_LEVELS.FULL)
        end,
        once = true,
    })
    
    -- Enhance to COMPLETE level after being idle for a while
    vim.defer_fn(function()
        load_enhancement_level(ENHANCEMENT_LEVELS.COMPLETE)
    end, 3000)
end

-- Manual enhancement commands
local function setup_enhancement_commands()
    vim.api.nvim_create_user_command("MinimalEnhance", function(opts)
        local level = tonumber(opts.args) or ENHANCEMENT_LEVELS.COMPLETE
        load_enhancement_level(level)
        vim.notify("Enhanced to level " .. level, vim.log.levels.INFO)
    end, {
        nargs = "?",
        desc = "Enhance minimal mode to specified level",
    })
    
    vim.api.nvim_create_user_command("MinimalStatus", function()
        vim.notify(string.format(
            "Minimal Mode: %s | Level: %d | Features: %d",
            minimal_mode.enabled and "ON" or "OFF",
            minimal_mode.enhancement_level,
            vim.tbl_count(minimal_mode.loaded_features)
        ), vim.log.levels.INFO)
    end, {
        desc = "Show minimal mode status",
    })
    
    vim.api.nvim_create_user_command("MinimalReset", function()
        minimal_mode.enhancement_level = 0
        minimal_mode.loaded_features = {}
        vim.notify("Reset to minimal mode", vim.log.levels.INFO)
    end, {
        desc = "Reset to minimal mode",
    })
end

-- Initialize minimal mode
function M.init()
    minimal_mode.enabled = should_use_minimal_mode()
    
    if minimal_mode.enabled then
        -- Start with absolute minimum
        minimal_mode.enhancement_level = ENHANCEMENT_LEVELS.BARE
        
        -- Setup progressive enhancement
        setup_progressive_enhancement()
        
        -- Setup commands
        setup_enhancement_commands()
        
        -- Notify user
        vim.defer_fn(function()
            vim.notify("⚡ Minimal mode enabled - enhancing progressively", vim.log.levels.INFO)
        end, 500)
        
        return true
    else
        -- Normal startup - load everything
        vim.defer_fn(function()
            load_enhancement_level(ENHANCEMENT_LEVELS.COMPLETE)
        end, 100)
        
        return false
    end
end

-- Check if minimal mode is enabled
function M.is_enabled()
    return minimal_mode.enabled
end

-- Get current enhancement level
function M.get_level()
    return minimal_mode.enhancement_level
end

-- Force enhancement to specific level
function M.enhance_to(level)
    load_enhancement_level(level)
end

-- Get loaded features
function M.get_loaded_features()
    return vim.tbl_keys(minimal_mode.loaded_features)
end

return M