-- ⚡ INTELLIGENT PLUGIN PRELOADER
-- Learns usage patterns and preloads plugins before they're needed
-- Uses machine learning-like approach to predict plugin usage

local M = {}

-- Usage tracking and prediction
local usage_data = {
    patterns = {},
    predictions = {},
    context_cache = {},
    last_update = 0,
}

-- Plugin categories for intelligent grouping
local plugin_categories = {
    lsp = { "coc.nvim", "goto-preview", "outline.nvim" },
    git = { "gitsigns.nvim", "neogit", "git-blame.nvim" },
    file_management = { "fzf-lua", "nvim-tree.lua", "registers.nvim" },
    editing = { "Comment.nvim", "nvim-treesitter", "nvim-spider" },
    ui = { "which-key.nvim", "todo-comments.nvim", "nvim-notify" },
    terminal = { "toggleterm.nvim" },
    search = { "nvim-spectre" },
}

-- Context detection functions
local context_detectors = {
    -- File type context
    filetype = function()
        return vim.bo.filetype or "unknown"
    end,
    
    -- Project type context
    project_type = function()
        local cwd = vim.fn.getcwd()
        
        -- Check for common project indicators
        if vim.fn.filereadable(cwd .. "/package.json") == 1 then
            return "javascript"
        elseif vim.fn.filereadable(cwd .. "/Cargo.toml") == 1 then
            return "rust"
        elseif vim.fn.filereadable(cwd .. "/go.mod") == 1 then
            return "go"
        elseif vim.fn.filereadable(cwd .. "/requirements.txt") == 1 or vim.fn.filereadable(cwd .. "/pyproject.toml") == 1 then
            return "python"
        elseif vim.fn.filereadable(cwd .. "/Makefile") == 1 then
            return "c_cpp"
        elseif vim.fn.isdirectory(cwd .. "/.git") == 1 then
            return "git_project"
        else
            return "generic"
        end
    end,
    
    -- Time of day context
    time_context = function()
        local hour = tonumber(os.date("%H"))
        if hour >= 9 and hour <= 17 then
            return "work_hours"
        elseif hour >= 18 and hour <= 23 then
            return "evening"
        else
            return "night"
        end
    end,
    
    -- File size context
    file_size_context = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname == "" then return "no_file" end
        
        local stat = vim.loop.fs_stat(bufname)
        if not stat then return "no_file" end
        
        if stat.size > 100 * 1024 then
            return "large_file"
        elseif stat.size > 10 * 1024 then
            return "medium_file"
        else
            return "small_file"
        end
    end,
    
    -- Git context
    git_context = function()
        if vim.fn.isdirectory(".git") == 1 then
            -- Check if there are uncommitted changes
            local status = vim.fn.system("git status --porcelain 2>/dev/null")
            if status and status ~= "" then
                return "git_dirty"
            else
                return "git_clean"
            end
        else
            return "no_git"
        end
    end,
}

-- Get current context
local function get_current_context()
    local context = {}
    for name, detector in pairs(context_detectors) do
        local ok, result = pcall(detector)
        if ok then
            context[name] = result
        end
    end
    return context
end

-- Generate context key for caching
local function context_key(context)
    local keys = {}
    for k, v in pairs(context) do
        table.insert(keys, k .. ":" .. tostring(v))
    end
    table.sort(keys)
    return table.concat(keys, "|")
end

-- Load usage data from cache
local function load_usage_data()
    local cache_file = vim.fn.stdpath("cache") .. "/startup_cache/usage_patterns.json"
    if vim.fn.filereadable(cache_file) == 1 then
        local ok, content = pcall(vim.fn.readfile, cache_file)
        if ok then
            local data_ok, data = pcall(vim.json.decode, table.concat(content, "\n"))
            if data_ok and data then
                usage_data.patterns = data.patterns or {}
                usage_data.predictions = data.predictions or {}
                usage_data.last_update = data.last_update or 0
            end
        end
    end
end

-- Save usage data to cache
local function save_usage_data()
    local cache_dir = vim.fn.stdpath("cache") .. "/startup_cache"
    vim.fn.mkdir(cache_dir, "p")
    
    local cache_file = cache_dir .. "/usage_patterns.json"
    local data = {
        patterns = usage_data.patterns,
        predictions = usage_data.predictions,
        last_update = os.time(),
    }
    
    local ok, json_str = pcall(vim.json.encode, data)
    if ok then
        vim.fn.writefile(vim.split(json_str, "\n"), cache_file)
    end
end

-- Record plugin usage
local function record_plugin_usage(plugin_name)
    local context = get_current_context()
    local ctx_key = context_key(context)
    
    -- Initialize pattern tracking
    if not usage_data.patterns[ctx_key] then
        usage_data.patterns[ctx_key] = {}
    end
    
    if not usage_data.patterns[ctx_key][plugin_name] then
        usage_data.patterns[ctx_key][plugin_name] = 0
    end
    
    -- Increment usage count
    usage_data.patterns[ctx_key][plugin_name] = usage_data.patterns[ctx_key][plugin_name] + 1
    
    -- Update predictions
    update_predictions(ctx_key)
    
    -- Save data periodically
    if os.time() - usage_data.last_update > 300 then -- Every 5 minutes
        save_usage_data()
    end
end

-- Update predictions based on usage patterns
local function update_predictions(ctx_key)
    if not usage_data.patterns[ctx_key] then return end
    
    local total_usage = 0
    for _, count in pairs(usage_data.patterns[ctx_key]) do
        total_usage = total_usage + count
    end
    
    if total_usage == 0 then return end
    
    -- Calculate probabilities
    usage_data.predictions[ctx_key] = {}
    for plugin, count in pairs(usage_data.patterns[ctx_key]) do
        usage_data.predictions[ctx_key][plugin] = count / total_usage
    end
end

-- Get predicted plugins for current context
local function get_predicted_plugins()
    local context = get_current_context()
    local ctx_key = context_key(context)
    
    -- Check cache first
    if usage_data.context_cache[ctx_key] then
        local cache_time = usage_data.context_cache[ctx_key].time
        if os.time() - cache_time < 60 then -- Cache for 1 minute
            return usage_data.context_cache[ctx_key].plugins
        end
    end
    
    local predicted = {}
    
    -- Use learned patterns
    if usage_data.predictions[ctx_key] then
        for plugin, probability in pairs(usage_data.predictions[ctx_key]) do
            if probability > 0.3 then -- 30% threshold
                table.insert(predicted, { plugin = plugin, probability = probability })
            end
        end
    end
    
    -- Add context-based predictions
    local context_predictions = get_context_based_predictions(context)
    for _, pred in ipairs(context_predictions) do
        table.insert(predicted, pred)
    end
    
    -- Sort by probability
    table.sort(predicted, function(a, b)
        return a.probability > b.probability
    end)
    
    -- Cache results
    usage_data.context_cache[ctx_key] = {
        plugins = predicted,
        time = os.time(),
    }
    
    return predicted
end

-- Context-based predictions (rule-based fallback)
local function get_context_based_predictions(context)
    local predictions = {}
    
    -- File type based predictions
    local ft = context.filetype
    if ft and ft ~= "unknown" then
        local programming_fts = {
            "lua", "python", "javascript", "typescript", "rust", "go",
            "c", "cpp", "java", "php", "ruby", "vim", "sh", "zsh", "bash"
        }
        
        if vim.tbl_contains(programming_fts, ft) then
            table.insert(predictions, { plugin = "coc.nvim", probability = 0.8 })
            table.insert(predictions, { plugin = "nvim-treesitter", probability = 0.7 })
            table.insert(predictions, { plugin = "Comment.nvim", probability = 0.6 })
        end
    end
    
    -- Project type based predictions
    local project = context.project_type
    if project == "git_project" then
        table.insert(predictions, { plugin = "gitsigns.nvim", probability = 0.7 })
        table.insert(predictions, { plugin = "neogit", probability = 0.5 })
    end
    
    -- File size based predictions
    local file_size = context.file_size_context
    if file_size == "large_file" then
        -- Avoid heavy plugins for large files
    else
        table.insert(predictions, { plugin = "fzf-lua", probability = 0.6 })
        table.insert(predictions, { plugin = "which-key.nvim", probability = 0.4 })
    end
    
    return predictions
end

-- Preload predicted plugins
local function preload_plugins()
    local predicted = get_predicted_plugins()
    
    for i, pred in ipairs(predicted) do
        if i > 5 then break end -- Limit to top 5 predictions
        
        if pred.probability > 0.5 then
            -- High probability - preload immediately
            vim.defer_fn(function()
                vim.cmd("Lazy load " .. pred.plugin)
            end, 100 * i)
        elseif pred.probability > 0.3 then
            -- Medium probability - preload with delay
            vim.defer_fn(function()
                vim.cmd("Lazy load " .. pred.plugin)
            end, 500 + (100 * i))
        end
    end
end

-- Setup usage tracking
local function setup_usage_tracking()
    -- Track plugin loading
    vim.api.nvim_create_autocmd("User", {
        pattern = "LazyLoad",
        callback = function(event)
            record_plugin_usage(event.data)
        end,
    })
    
    -- Track context changes
    local last_context = get_current_context()
    local function check_context_change()
        local current_context = get_current_context()
        if context_key(current_context) ~= context_key(last_context) then
            last_context = current_context
            -- Preload for new context
            vim.defer_fn(preload_plugins, 200)
        end
    end
    
    vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "DirChanged" }, {
        callback = check_context_change,
    })
end

-- Initialize intelligent preloader
function M.init()
    -- Load historical usage data
    load_usage_data()
    
    -- Setup usage tracking
    setup_usage_tracking()
    
    -- Initial preloading
    vim.defer_fn(function()
        preload_plugins()
    end, 1000)
    
    -- Periodic optimization
    vim.defer_fn(function()
        -- Clean old context cache
        for ctx_key, cache in pairs(usage_data.context_cache) do
            if os.time() - cache.time > 300 then -- 5 minutes old
                usage_data.context_cache[ctx_key] = nil
            end
        end
        
        -- Save usage data
        save_usage_data()
    end, 60000) -- Every minute
end

-- Manual preloading for specific category
function M.preload_category(category)
    local plugins = plugin_categories[category]
    if plugins then
        for i, plugin in ipairs(plugins) do
            vim.defer_fn(function()
                vim.cmd("Lazy load " .. plugin)
            end, 50 * i)
        end
    end
end

-- Get usage statistics
function M.get_stats()
    local stats = {
        total_patterns = vim.tbl_count(usage_data.patterns),
        total_predictions = vim.tbl_count(usage_data.predictions),
        cache_entries = vim.tbl_count(usage_data.context_cache),
        last_update = usage_data.last_update,
    }
    
    return stats
end

-- Reset usage data
function M.reset_data()
    usage_data.patterns = {}
    usage_data.predictions = {}
    usage_data.context_cache = {}
    save_usage_data()
end

return M