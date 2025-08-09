local status_ok, fzf_lua = pcall(require, "fzf-lua")
if not status_ok then
    return
end

-- Setup fzf-lua with performance optimizations
fzf_lua.setup({
    -- Use max-perf profile for absolute best performance
    "max-perf",
    
    -- Global performance settings
    global_resume = true, -- Enable global resume for faster subsequent calls
    global_resume_query = true, -- Resume with query
    file_icon_padding = '', -- Remove padding for performance
    
    -- Global options
    winopts = {
        height = 0.85,
        width = 0.80,
        row = 0.35,
        col = 0.50,
        border = "rounded",
        backdrop = 60,
        preview = {
            default = false, -- Disable preview by default for speed
            border = "rounded",
            wrap = false,
            hidden = true, -- Start with preview hidden
            vertical = "down:45%",
            horizontal = "right:60%",
            layout = "flex",
            flip_columns = 120,
            scrollbar = false, -- Disable scrollbar for performance
            delay = 0, -- No delay
            syntax = true, -- enable syntax in preview
        },
    },
    
    -- Keymaps
    keymap = {
        builtin = {
            ["<F1>"] = "toggle-help",
            ["<F2>"] = "toggle-fullscreen",
            ["<F3>"] = "toggle-preview-wrap",
            ["<F4>"] = "toggle-preview",
            ["<C-d>"] = "preview-page-down",
            ["<C-u>"] = "preview-page-up",
        },
        fzf = {
            ["ctrl-z"] = "abort",
            ["ctrl-u"] = "unix-line-discard",
            ["ctrl-f"] = "half-page-down",
            ["ctrl-b"] = "half-page-up",
            ["ctrl-a"] = "beginning-of-line",
            ["ctrl-e"] = "end-of-line",
            ["alt-a"] = "select-all",
            ["f3"] = "toggle-preview-wrap",
            ["f4"] = "toggle-preview",
            ["esc"] = "abort",
        },
    },
    
    -- FZF options for performance
    fzf_opts = {
        ["--ansi"] = false, -- Disable ANSI; we disable ripgrep colors to avoid escape codes
        ["--info"] = "hidden", -- Hide info for performance
        ["--height"] = "100%",
        ["--layout"] = "reverse",
        ["--border"] = "none",
        ["--highlight-line"] = false, -- Disable for performance
        ["--no-scrollbar"] = true, -- Disable scrollbar
        ["--no-separator"] = true, -- Disable separator
        ["--multi"] = true, -- Enable multi-select
        ["--bind"] = "esc:abort,ctrl-q:select-all+accept", -- Esc aborts; Ctrl+Q selects all and accepts
    },
    


    -- Actions optimized for speed
    actions = {
        files = {
            ["enter"] = function(selected, opts)
                -- Fast file opening without additional processing
                if #selected > 0 then
                    vim.cmd("edit " .. vim.fn.fnameescape(selected[1]))
                end
            end,
            ["ctrl-q"] = function(selected, opts)
                _G.fzf_send_to_qf_all(selected, opts)
            end,
        },
    },
    
    -- File picker optimizations
            files = {
            prompt = "Files> ",
            multiprocess = true,
            git_icons = false, -- Disable for max performance
            file_icons = false, -- Disable for max performance  
            color_icons = false, -- Disable for max performance
            cmd = "fd --type f --hidden --follow --exclude .git",
            -- Fast find options optimized for speed
            find_opts = [[-type f -not -path '*/\.git/*']],
            rg_opts = "--color=never --files --hidden --follow -g '!.git' --no-heading",
            fd_opts = "--color=never --type f --hidden --follow --exclude .git --strip-cwd-prefix",
            -- Performance settings
            cwd_prompt = false, -- Disable for speed
            previewer = 'builtin', -- enable previewer for files picker when requested
            -- Disable path transformations for speed
            path_shorten = false,
        },
    
    -- Oldfiles (recent files) optimizations
    oldfiles = {
        prompt = "Recent> ",
        cwd_only = false,
        stat_file = false, -- Disable file verification for speed
        include_current_session = false,
        file_icons = false, -- Disable for performance
        git_icons = false, -- Disable for performance
        color_icons = false, -- Disable for performance
        previewer = false, -- Disable previewer for instant opening
    },
    
    -- Grep optimizations
    grep = {
        prompt = "Rg> ",
        input_prompt = "Grep For> ",
        multiprocess = true,
        git_icons = false,
        file_icons = true,
        color_icons = true,
        -- Keep ANSI color codes for colorized results
        rg_opts = "--column --line-number --no-heading --color=never --smart-case --max-columns=4096 -e",
        rg_glob = true,
        glob_flag = "--iglob",
        glob_separator = "%s%-%-",
        actions = {
            ["enter"] = function(selected, opts)
                -- Parse the grep result and open the file at the correct line and column
                if #selected > 0 then
                    local line = selected[1]
                    -- Strip ANSI color codes first
                    local clean_line = line:gsub("\27%[[0-9;]*m", "")
                    
                    -- Parse grep result format: filename:line:col:text
                    local filename, lnum, col, text = clean_line:match("([^:]+):(%d+):(%d+):(.*)")
                    if filename and lnum and col then
                        -- Open the file and jump to the line and column
                        vim.cmd("edit " .. vim.fn.fnameescape(filename))
                        vim.api.nvim_win_set_cursor(0, {tonumber(lnum), tonumber(col) - 1})
                    else
                        -- Fallback: try to parse as just filename:line
                        local fname, line_num = clean_line:match("([^:]+):(%d+):")
                        if fname and line_num then
                            vim.cmd("edit " .. vim.fn.fnameescape(fname))
                            vim.api.nvim_win_set_cursor(0, {tonumber(line_num), 0})
                        else
                            -- Last fallback: treat as filename only
                            local file_path = clean_line:match("^%s*(.-)%s*$") -- trim whitespace
                            if file_path and file_path ~= "" then
                                vim.cmd("edit " .. vim.fn.fnameescape(file_path))
                            end
                        end
                    end
                end
            end,
            ["ctrl-q"] = function(selected, opts)
                _G.fzf_send_to_qf_all(selected, opts)
            end,
        },
    },
    
    -- Live grep optimizations
    live_grep = {
        prompt = "LiveGrep> ",
        multiprocess = true,
        git_icons = false,
        file_icons = true,
        color_icons = true,
        rg_opts = "--column --line-number --no-heading --color=never --smart-case --max-columns=4096",
        -- Keep ANSI color codes for colorized results
        exec_empty_query = false,
        actions = {
            ["enter"] = function(selected, opts)
                -- Parse the grep result and open the file at the correct line and column
                if #selected > 0 then
                    local line = selected[1]
                    -- Strip ANSI color codes first
                    local clean_line = line:gsub("\27%[[0-9;]*m", "")
                    
                    -- Parse grep result format: filename:line:col:text
                    local filename, lnum, col, text = clean_line:match("([^:]+):(%d+):(%d+):(.*)")
                    if filename and lnum and col then
                        -- Open the file and jump to the line and column
                        vim.cmd("edit " .. vim.fn.fnameescape(filename))
                        vim.api.nvim_win_set_cursor(0, {tonumber(lnum), tonumber(col) - 1})
                    else
                        -- Fallback: try to parse as just filename:line
                        local fname, line_num = clean_line:match("([^:]+):(%d+):")
                        if fname and line_num then
                            vim.cmd("edit " .. vim.fn.fnameescape(fname))
                            vim.api.nvim_win_set_cursor(0, {tonumber(line_num), 0})
                        else
                            -- Last fallback: treat as filename only
                            local file_path = clean_line:match("^%s*(.-)%s*$") -- trim whitespace
                            if file_path and file_path ~= "" then
                                vim.cmd("edit " .. vim.fn.fnameescape(file_path))
                            end
                        end
                    end
                end
            end,
            ["ctrl-q"] = function(selected, opts)
                _G.fzf_send_to_qf_all(selected, opts)
            end,
        },
    },
    
    -- Buffer optimizations  
    buffers = {
        prompt = "Buffers> ",
        file_icons = false, -- Disable for performance
        color_icons = false, -- Disable for performance
        sort_lastused = true,
        show_unloaded = true,
        cwd_only = false,
        previewer = false, -- Disable previewer for instant opening
        actions = {
            ["ctrl-q"] = function(selected, opts)
                _G.fzf_send_to_qf_all(selected, opts)
            end,
        },
    },
    
    -- Help tags
    helptags = {
        prompt = "Help> ",
    },
    
    -- Git files
    git = {
        files = {
            prompt = "GitFiles> ",
            cmd = "git ls-files --exclude-standard",
            multiprocess = true,
            git_icons = true,
            file_icons = true,
            color_icons = true,
        },
        status = {
            prompt = "GitStatus> ",
            cmd = "git -c color.status=false status -s",
            multiprocess = true,
            file_icons = true,
            git_icons = true,
            color_icons = true,
            previewer = "git_diff",
        },
        commits = {
            prompt = "Commits> ",
            cmd = "git log --color --pretty=format:'%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset'",
            preview = "git show --color {1}",
        },
        bcommits = {
            prompt = "BCommits> ",
            cmd = "git log --color --pretty=format:'%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset' {file}",
            preview = "git show --color {1} -- {file}",
        },
        branches = {
            prompt = "Branches> ",
            cmd = "git branch --all --color",
            preview = "git log --graph --pretty=oneline --abbrev-commit --color {1}",
        },
    },
    
    -- LSP settings
    lsp = {
        prompt_postfix = "> ",
        cwd_only = false,
        async_or_timeout = 5000,
        file_icons = true,
        git_icons = false,
        symbols = {
            async_or_timeout = true,
            symbol_style = 1,
        },
        code_actions = {
            prompt = "Code Actions> ",
            async_or_timeout = 5000,
        },
    },
    
    -- Diagnostics
    diagnostics = {
        prompt = "Diagnostics> ",
        cwd_only = false,
        file_icons = true,
        git_icons = false,
        diag_icons = true,
        actions = {
            ["ctrl-q"] = function(selected, opts)
                _G.fzf_send_to_qf_all(selected, opts)
            end,
        },
    },
    
    -- Quickfix
    quickfix = {
        file_icons = true,
        git_icons = false,
    },
    
    -- Colorschemes
    colorschemes = {
        prompt = "Colorschemes> ",
        live_preview = true,
        winopts = { height = 0.55, width = 0.30 },
    },
    
    -- Keymaps
    keymaps = {
        prompt = "Keymaps> ",
        winopts = { preview = { layout = "vertical" } },
    },
    
    -- Commands
    commands = {
        prompt = "Commands> ",
    },
    
    -- Command history
    command_history = {
        prompt = "History> ",
    },
    
    -- Search history
    search_history = {
        prompt = "Search> ",
    },
    
    -- Marks
    marks = {
        prompt = "Marks> ",
    },
    
    -- Registers
    registers = {
        prompt = "Registers> ",
    },
    
    -- Autocmds
    autocmds = {
        prompt = "Autocmds> ",
    },
    
    -- Highlights
    highlights = {
        prompt = "Highlights> ",
    },
})

-- Register fzf-lua for vim.ui.select
fzf_lua.register_ui_select()

-- Global function for sending ALL results to quickfix
-- How ctrl-q works now:
-- 1. The fzf_opts includes "--bind=ctrl-q:select-all+accept" which automatically
--    selects ALL items when ctrl-q is pressed and then accepts them
-- 2. This means all visible results get passed to the selected parameter
-- 3. The function below parses each item and adds it to the quickfix list
local function send_to_qf(selected, opts)
    local qf_list = {}
    
    -- Now that we have multi-select enabled, selected should contain all items
    print(string.format("Processing %d selected items", #selected))
    
    for _, line in ipairs(selected) do
        -- Strip ANSI color codes first
        local clean_line = line:gsub("\27%[[0-9;]*m", "")
        
        -- Try to parse as grep result first (filename:line:col:text)
        local filename, lnum, col, text = clean_line:match("([^:]+):(%d+):(%d+):(.*)")
        if filename and lnum and col and text then
            table.insert(qf_list, {
                filename = filename,
                lnum = tonumber(lnum),
                col = tonumber(col),
                text = text,
            })
        else
            -- Fallback: treat as file path
            local file_path = clean_line:match("^%s*(.-)%s*$") -- trim whitespace
            if file_path and file_path ~= "" then
                table.insert(qf_list, {
                    filename = file_path,
                    lnum = 1,
                    col = 1,
                    text = "File: " .. file_path,
                })
            end
        end
    end
    if #qf_list > 0 then
        vim.fn.setqflist(qf_list, 'r')
        vim.cmd("copen")
        print(string.format("Sent %d items to quickfix list", #qf_list))
    else
        print("No items to send to quickfix")
    end
end

-- Function that sends all selected results to quickfix
local function send_to_qf_all(selected, opts)
    -- With the --bind="ctrl-q:select-all+accept" option, all items should be selected automatically
    send_to_qf(selected, opts)
end

-- Make the functions available globally
_G.fzf_send_to_qf = send_to_qf
_G.fzf_send_to_qf_all = send_to_qf_all

return fzf_lua