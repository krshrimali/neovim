local M = {}

local uv = vim.loop
local telescope = require('telescope')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

-- Cache directory
local cache_dir = vim.fn.stdpath('cache') .. '/fast_picker'
local recent_files_cache = cache_dir .. '/recent_files.txt'
local find_files_cache = cache_dir .. '/find_files.txt'

-- Ensure cache directory exists
local function ensure_cache_dir()
    if vim.fn.isdirectory(cache_dir) == 0 then
        vim.fn.mkdir(cache_dir, 'p')
    end
end

-- Read lines from file
local function read_file_lines(filepath)
    local file = io.open(filepath, 'r')
    if not file then
        return {}
    end
    
    local lines = {}
    for line in file:lines() do
        if line and line ~= '' and vim.fn.filereadable(line) == 1 then
            table.insert(lines, line)
        end
    end
    file:close()
    return lines
end

-- Write lines to file
local function write_file_lines(filepath, lines)
    ensure_cache_dir()
    local file = io.open(filepath, 'w')
    if not file then
        return false
    end
    
    for _, line in ipairs(lines) do
        file:write(line .. '\n')
    end
    file:close()
    return true
end

-- Update recent files cache
local function update_recent_files_cache()
    local recent_files = {}
    
    -- Get oldfiles from vim
    for _, file in ipairs(vim.v.oldfiles or {}) do
        if vim.fn.filereadable(file) == 1 then
            table.insert(recent_files, file)
            if #recent_files >= 100 then -- Limit to 100 recent files
                break
            end
        end
    end
    
    write_file_lines(recent_files_cache, recent_files)
    return recent_files
end

-- Update find files cache
local function update_find_files_cache()
    -- Use rg to find files and cache them
    local cwd = vim.fn.getcwd()
    local cmd = { 'rg', '--files', '--iglob', '!.git', '--hidden' }
    local files = {}
    
    local job = vim.fn.jobstart(cmd, {
        cwd = cwd,
        stdout_buffered = true,
        on_stdout = function(_, data)
            for _, line in ipairs(data) do
                if line and line ~= '' then
                    -- Convert relative path to absolute
                    local full_path
                    if vim.fn.fnamemodify(line, ':p') == line then
                        full_path = line
                    else
                        full_path = cwd .. '/' .. line
                    end
                    
                    if vim.fn.filereadable(full_path) == 1 then
                        table.insert(files, full_path)
                    end
                end
            end
        end,
        on_exit = function(_, exit_code)
            if exit_code == 0 then
                write_file_lines(find_files_cache, files)
            end
        end
    })
    
    -- Wait for job to complete (with timeout)
    vim.fn.jobwait({job}, 5000)
    return files
end

-- Check if cache is stale (older than 5 minutes)
local function is_cache_stale(cache_file)
    local stat = uv.fs_stat(cache_file)
    if not stat then
        return true
    end
    
    local now = os.time()
    local cache_time = stat.mtime.sec
    return (now - cache_time) > 300 -- 5 minutes
end

-- Background cache update
local function background_update_cache(cache_file, update_func)
    vim.defer_fn(function()
        update_func()
    end, 100) -- Update after 100ms
end

-- Generic picker function
local function create_picker(title, cache_file, update_func, opts)
    opts = opts or {}
    
    -- Try to read from cache first
    local cached_files = read_file_lines(cache_file)
    
    -- If cache is empty or stale, update in background
    if #cached_files == 0 or is_cache_stale(cache_file) then
        background_update_cache(cache_file, update_func)
        
        -- If no cache exists, do synchronous update for first time
        if #cached_files == 0 then
            cached_files = update_func()
        end
    end
    
    -- Create telescope picker
    pickers.new(opts, {
        prompt_title = title,
        finder = finders.new_table({
            results = cached_files,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = vim.fn.fnamemodify(entry, ':~:.'),
                    ordinal = entry,
                    path = entry,
                }
            end
        }),
        sorter = conf.file_sorter(opts),
        previewer = conf.file_previewer(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    vim.cmd('edit ' .. vim.fn.fnameescape(selection.path))
                end
            end)
            return true
        end,
    }):find()
end

-- Recent files picker
function M.recent_files(opts)
    opts = opts or {}
    create_picker('Recent Files (Cached)', recent_files_cache, update_recent_files_cache, opts)
end

-- Find files picker
function M.find_files(opts)
    opts = opts or {}
    create_picker('Find Files (Cached)', find_files_cache, update_find_files_cache, opts)
end

-- Initialize caches on first load
local function init_caches()
    -- Create initial caches if they don't exist
    if vim.fn.filereadable(recent_files_cache) == 0 then
        background_update_cache(recent_files_cache, update_recent_files_cache)
    end
    
    if vim.fn.filereadable(find_files_cache) == 0 then
        background_update_cache(find_files_cache, update_find_files_cache)
    end
end

-- Auto-update recent files when files are opened
local function setup_auto_update()
    local group = vim.api.nvim_create_augroup('FastPickerAutoUpdate', { clear = true })
    
    -- Update recent files cache when a file is opened
    vim.api.nvim_create_autocmd({'BufReadPost', 'BufNewFile'}, {
        group = group,
        callback = function()
            local file = vim.fn.expand('%:p')
            if file and file ~= '' and vim.fn.filereadable(file) == 1 then
                -- Add to recent files cache
                vim.defer_fn(function()
                    local recent = read_file_lines(recent_files_cache)
                    -- Remove if already exists
                    for i, f in ipairs(recent) do
                        if f == file then
                            table.remove(recent, i)
                            break
                        end
                    end
                    -- Add to front
                    table.insert(recent, 1, file)
                    -- Limit to 100 files
                    if #recent > 100 then
                        local trimmed = {}
                        for i = 1, 100 do
                            trimmed[i] = recent[i]
                        end
                        recent = trimmed
                    end
                    write_file_lines(recent_files_cache, recent)
                end, 500)
            end
        end
    })
    
    -- Periodically update find files cache
    local timer = uv.new_timer()
    timer:start(60000, 300000, function() -- First update after 1 min, then every 5 min
        if is_cache_stale(find_files_cache) then
            background_update_cache(find_files_cache, update_find_files_cache)
        end
    end)
end

-- Setup function
function M.setup()
    ensure_cache_dir()
    init_caches()
    setup_auto_update()
end

return M