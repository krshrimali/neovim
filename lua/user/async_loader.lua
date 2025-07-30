-- ⚡ Async Configuration Loader
-- Loads non-critical components asynchronously to prevent startup blocking

local M = {}
local uv = vim.loop

-- Queue for async loading
local load_queue = {}
local is_loading = false

-- Priority levels for loading
local PRIORITY = {
    CRITICAL = 1,    -- Must load immediately
    HIGH = 2,        -- Load within 100ms
    MEDIUM = 3,      -- Load within 500ms
    LOW = 4,         -- Load when idle
    BACKGROUND = 5   -- Load in background when system is idle
}

-- Configuration loading registry
local config_registry = {
    -- Critical (load immediately)
    { module = "user.options", priority = PRIORITY.CRITICAL },
    { module = "user.colorscheme", priority = PRIORITY.CRITICAL },
    
    -- High priority (load quickly)
    { module = "user.keymaps", priority = PRIORITY.HIGH, condition = function()
        return vim.fn.argc() == 0 -- Only if no files specified
    end },
    
    -- Medium priority (load when convenient)
    { module = "user.autocommands", priority = PRIORITY.MEDIUM },
    { module = "user.functions", priority = PRIORITY.MEDIUM },
    
    -- Low priority (load when idle)
    { module = "user.colorizer", priority = PRIORITY.LOW },
    { module = "user.surround", priority = PRIORITY.LOW },
    { module = "user.nvim_transparent", priority = PRIORITY.LOW },
    
    -- Background (load when system is idle)
    { module = "user.diagnostics_display", priority = PRIORITY.BACKGROUND },
    { module = "user.terminal", priority = PRIORITY.BACKGROUND },
}

-- Check if system is idle (no recent input)
local last_input_time = vim.loop.hrtime()
local function is_system_idle()
    local current_time = vim.loop.hrtime()
    local idle_time = (current_time - last_input_time) / 1e9 -- Convert to seconds
    return idle_time > 2 -- 2 seconds of no input
end

-- Update last input time on any input
local function track_input()
    last_input_time = vim.loop.hrtime()
end

-- Load a configuration module safely
local function safe_load(module_name)
    local ok, result = pcall(require, module_name)
    if not ok then
        vim.defer_fn(function()
            vim.notify("Failed to load " .. module_name .. ": " .. result, vim.log.levels.WARN)
        end, 100)
        return false
    end
    return true
end

-- Async loader function
local function async_load_config(config)
    if config.condition and not config.condition() then
        return
    end
    
    -- Use vim.defer_fn for non-blocking loading
    local delay = 0
    if config.priority == PRIORITY.HIGH then
        delay = 50
    elseif config.priority == PRIORITY.MEDIUM then
        delay = 100
    elseif config.priority == PRIORITY.LOW then
        delay = 200
    elseif config.priority == PRIORITY.BACKGROUND then
        delay = 500
    end
    
    vim.defer_fn(function()
        -- Additional check for background tasks - only load when idle
        if config.priority == PRIORITY.BACKGROUND and not is_system_idle() then
            -- Reschedule for later
            vim.defer_fn(function()
                async_load_config(config)
            end, 1000)
            return
        end
        
        safe_load(config.module)
    end, delay)
end

-- Process the loading queue
local function process_queue()
    if is_loading then return end
    is_loading = true
    
    -- Sort by priority
    table.sort(load_queue, function(a, b)
        return a.priority < b.priority
    end)
    
    -- Load configurations asynchronously
    for _, config in ipairs(load_queue) do
        if config.priority == PRIORITY.CRITICAL then
            -- Load critical configs immediately
            safe_load(config.module)
        else
            -- Load others asynchronously
            async_load_config(config)
        end
    end
    
    is_loading = false
end

-- Add configuration to loading queue
function M.queue_config(module, priority, condition)
    table.insert(load_queue, {
        module = module,
        priority = priority or PRIORITY.MEDIUM,
        condition = condition
    })
end

-- Load configurations based on file type
function M.load_for_filetype(filetype)
    local ft_configs = {
        lua = { "user.treesitter", "user.coc" },
        python = { "user.coc", "user.treesitter" },
        javascript = { "user.coc", "user.treesitter" },
        typescript = { "user.coc", "user.treesitter" },
        rust = { "user.coc", "user.treesitter" },
        go = { "user.coc", "user.treesitter" },
        c = { "user.coc", "user.treesitter" },
        cpp = { "user.coc", "user.treesitter" },
    }
    
    local configs = ft_configs[filetype] or {}
    for _, config in ipairs(configs) do
        vim.defer_fn(function()
            safe_load(config)
        end, 100)
    end
end

-- Smart preloading based on current context
function M.smart_preload()
    local current_dir = vim.fn.getcwd()
    local is_git_repo = vim.fn.isdirectory(".git") == 1
    local file_count = #vim.fn.glob("*", false, true)
    
    -- Preload git-related plugins if in git repo
    if is_git_repo then
        vim.defer_fn(function()
            vim.cmd("Lazy load gitsigns.nvim")
        end, 300)
    end
    
    -- Preload file management tools for large directories
    if file_count > 50 then
        vim.defer_fn(function()
            vim.cmd("Lazy load fzf-lua")
        end, 200)
    end
end

-- Initialize the async loader
function M.init()
    -- Setup input tracking
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter" }, {
        callback = track_input,
        group = vim.api.nvim_create_augroup("AsyncLoaderInput", { clear = true })
    })
    
    -- Load registry configurations
    for _, config in ipairs(config_registry) do
        M.queue_config(config.module, config.priority, config.condition)
    end
    
    -- Process the queue
    process_queue()
    
    -- Setup filetype-based loading
    vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
            M.load_for_filetype(args.match)
        end,
        group = vim.api.nvim_create_augroup("AsyncLoaderFileType", { clear = true })
    })
    
    -- Smart preloading after startup
    vim.defer_fn(function()
        M.smart_preload()
    end, 1000)
    
    -- Background optimization tasks
    vim.defer_fn(function()
        -- Clean up old cache files
        local cache_dir = vim.fn.stdpath("cache") .. "/startup_cache"
        local files = vim.fn.glob(cache_dir .. "/*", false, true)
        for _, file in ipairs(files) do
            local stat = vim.loop.fs_stat(file)
            if stat and stat.mtime.sec < (os.time() - 7 * 24 * 60 * 60) then -- 7 days old
                vim.fn.delete(file)
            end
        end
    end, 5000)
end

-- Manual trigger for loading specific priority levels
function M.load_priority(priority)
    for _, config in ipairs(load_queue) do
        if config.priority == priority then
            async_load_config(config)
        end
    end
end

-- Force load all remaining configurations
function M.force_load_all()
    for _, config in ipairs(load_queue) do
        safe_load(config.module)
    end
end

return M