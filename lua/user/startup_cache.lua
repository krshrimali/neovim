-- ⚡ Startup Cache System
-- Caches frequently used configurations for ultra-fast subsequent startups

local M = {}

-- Cache directory
local cache_dir = vim.fn.stdpath("cache") .. "/startup_cache"
local cache_file = cache_dir .. "/config_cache.json"

-- Ensure cache directory exists
vim.fn.mkdir(cache_dir, "p")

-- Cache key generation based on config files
local function generate_cache_key()
    local config_files = {
        vim.fn.stdpath("config") .. "/init.lua",
        vim.fn.stdpath("config") .. "/lua/user/plugins.lua",
        vim.fn.stdpath("config") .. "/lua/user/options.lua",
    }
    
    local hash_input = ""
    for _, file in ipairs(config_files) do
        local stat = vim.loop.fs_stat(file)
        if stat then
            hash_input = hash_input .. file .. tostring(stat.mtime.sec)
        end
    end
    
    return vim.fn.sha256(hash_input):sub(1, 16)
end

-- Load cached configuration
function M.load_cached_config()
    if not vim.loop.fs_stat(cache_file) then
        return nil
    end
    
    local ok, content = pcall(vim.fn.readfile, cache_file)
    if not ok then return nil end
    
    local cache_ok, cache_data = pcall(vim.json.decode, table.concat(content, "\n"))
    if not cache_ok then return nil end
    
    local current_key = generate_cache_key()
    if cache_data.key ~= current_key then
        return nil -- Cache is stale
    end
    
    return cache_data
end

-- Save configuration to cache
function M.save_to_cache(data)
    local cache_data = {
        key = generate_cache_key(),
        timestamp = os.time(),
        data = data
    }
    
    local ok, json_str = pcall(vim.json.encode, cache_data)
    if ok then
        vim.fn.writefile(vim.split(json_str, "\n"), cache_file)
    end
end

-- Cached option loading
function M.load_cached_options()
    local cached = M.load_cached_config()
    if cached and cached.data.options then
        -- Apply cached options directly
        for k, v in pairs(cached.data.options) do
            if vim.opt[k] then
                vim.opt[k] = v
            end
        end
        return true
    end
    return false
end

-- Cache current options
function M.cache_options()
    local options_to_cache = {
        "number", "relativenumber", "cursorline", "wrap", "expandtab",
        "shiftwidth", "tabstop", "ignorecase", "smartcase", "hlsearch",
        "termguicolors", "signcolumn", "updatetime", "timeoutlen"
    }
    
    local cached_options = {}
    for _, opt in ipairs(options_to_cache) do
        cached_options[opt] = vim.opt[opt]:get()
    end
    
    M.save_to_cache({ options = cached_options })
end

-- Precompile frequently used modules
function M.precompile_modules()
    local modules_to_precompile = {
        "user.functions",
        "user.colorizer",
        "user.keymaps",
    }
    
    for _, module in ipairs(modules_to_precompile) do
        local ok, _ = pcall(require, module)
        if ok then
            -- Module is now in package.loaded cache
        end
    end
end

-- Smart plugin loading based on file type
function M.smart_plugin_load(filetype)
    local ft_plugins = {
        lua = { "nvim-treesitter" },
        python = { "coc.nvim", "nvim-treesitter" },
        javascript = { "coc.nvim", "nvim-treesitter" },
        typescript = { "coc.nvim", "nvim-treesitter" },
        rust = { "coc.nvim", "nvim-treesitter" },
        go = { "coc.nvim", "nvim-treesitter" },
        c = { "coc.nvim", "nvim-treesitter" },
        cpp = { "coc.nvim", "nvim-treesitter" },
    }
    
    local plugins = ft_plugins[filetype] or {}
    for _, plugin in ipairs(plugins) do
        vim.defer_fn(function()
            pcall(vim.cmd, "Lazy load " .. plugin)
        end, 100)
    end
end

-- Initialize cache system
function M.init()
    -- Try to load cached options for ultra-fast startup
    if not M.load_cached_options() then
        -- Cache options for next startup
        vim.defer_fn(function()
            M.cache_options()
        end, 1000)
    end
    
    -- Precompile modules in background
    vim.defer_fn(function()
        M.precompile_modules()
    end, 2000)
    
    -- Setup filetype-based smart loading
    vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
            M.smart_plugin_load(args.match)
        end,
    })
end

return M