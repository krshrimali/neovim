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
    -- winopts = {
    --     height = 0.85,
    --     width = 0.80,
    --     row = 0.35,
    --     col = 0.50,
    --     border = "rounded",
    --     backdrop = 60,
    --     preview = {
    --         default = false, -- Disable preview by default for speed
    --         border = "rounded",
    --         wrap = false,
    --         hidden = true, -- Start with preview hidden
    --         vertical = "down:45%",
    --         horizontal = "right:60%",
    --         layout = "flex",
    --         flip_columns = 120,
    --         scrollbar = false, -- Disable scrollbar for performance
    --         delay = 0, -- No delay
    --     },
    -- },

    winopts = {
        border = "rounded",
    },
    
    -- Global fzf options that apply to ALL pickers
    fzf_opts = {
        ["--multi"] = true, -- Enable multi-select for all pickers
        ["--bind"] = "ctrl-q:select-all+accept", -- Ctrl+Q selects all and accepts for quickfix
        ["--layout"] = "reverse",
        ["--info"] = "inline",
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
            ["esc"] = "abort",
            ["ctrl-u"] = "unix-line-discard",
            ["ctrl-f"] = "half-page-down",
            ["ctrl-b"] = "half-page-up",
            ["ctrl-a"] = "beginning-of-line",
            ["ctrl-e"] = "end-of-line",
            ["alt-a"] = "select-all",
            ["f3"] = "toggle-preview-wrap",
            ["f4"] = "toggle-preview",
            ["Esc"] = "abort"
        },
    },
    -- -- FZF options for performance
    -- fzf_opts = {
    --     ["--ansi"] = false, -- Disable ANSI since we're using --color=never in ripgrep
    --     ["--info"] = "hidden", -- Hide info for performance
    --     ["--height"] = "100%",
    --     ["--layout"] = "reverse",
    --     ["--border"] = "none",
    --     ["--highlight-line"] = false, -- Disable for performance
    --     ["--no-scrollbar"] = true, -- Disable scrollbar
    --     ["--no-separator"] = true, -- Disable separator
    --     ["--multi"] = true, -- Enable multi-select
    --     ["--bind"] = "ctrl-q:select-all+accept", -- Ctrl+Q selects all and accepts
    -- },
    -- 
    --
    --
    -- -- Actions optimized for speed
    -- actions = {
    --     files = {
    --         ["enter"] = function(selected, opts)
    --             -- Fast file opening without additional processing
    --             if #selected > 0 then
    --                 vim.cmd("edit " .. vim.fn.fnameescape(selected[1]))
    --             end
    --         end,
    --         ["ctrl-q"] = function(selected, opts)
    --             _G.fzf_send_to_qf_all(selected, opts)
    --         end,
    --     },
    -- },

    files = {
        multiprocess = true,
        previewer = true,
        git_icons = false,
        file_icons = false,
        color_icons = false,
        actions = {
            ["ctrl-q"] = _G.fzf_send_to_quickfix,
        },
        -- git_icons = false, -- Disable for max performance
        -- file_icons = false, -- Disable for max performance  
        -- color_icons = false, -- Disable for max performance
        -- cmd = "fd --type f --hidden --follow --exclude .git",
        -- -- Fast find options optimized for speed
        -- find_opts = [[-type f -not -path '*/\.git/*']],
        -- rg_opts = "--files --hidden --follow -g '!.git' --no-heading",
        -- fd_opts = "--type f --hidden --follow --exclude .git --strip-cwd-prefix",
        -- -- Performance settings
        -- cwd_prompt = false, -- Disable for speed
        -- previewer = false, -- Disable previewer for instant opening
        -- -- Disable path transformations for speed
        -- path_shorten = false,
    },

    -- -- File picker optimizations
    -- files = {
    --     prompt = "Files> ",
    --     multiprocess = true,
    --     git_icons = false, -- Disable for max performance
    --     file_icons = false, -- Disable for max performance  
    --     color_icons = false, -- Disable for max performance
    --     cmd = "fd --type f --hidden --follow --exclude .git",
    --     -- Fast find options optimized for speed
    --     find_opts = [[-type f -not -path '*/\.git/*']],
    --     rg_opts = "--color=never --files --hidden --follow -g '!.git' --no-heading",
    --     fd_opts = "--color=never --type f --hidden --follow --exclude .git --strip-cwd-prefix",
    --     -- Performance settings
    --     cwd_prompt = false, -- Disable for speed
    --     previewer = false, -- Disable previewer for instant opening
    --     -- Disable path transformations for speed
    --     path_shorten = false,
    -- },
    -- 
    -- -- Oldfiles (recent files) optimizations
    -- oldfiles = {
    --     prompt = "Recent> ",
    --     cwd_only = false,
    --     stat_file = false, -- Disable file verification for speed
    --     include_current_session = false,
    --     file_icons = false, -- Disable for performance
    --     git_icons = false, -- Disable for performance
    --     color_icons = false, -- Disable for performance
    --     previewer = false, -- Disable previewer for instant opening
    -- },
    -- 
    -- -- Grep optimizations
    grep = {
        prompt = "Rg> ",
        -- input_prompt = "Grep For> ",
        multiprocess = true,
        actions = {
            ["ctrl-q"] = _G.fzf_send_to_quickfix,
        },
    },
    --     git_icons = false,
    --     file_icons = true,
    --     color_icons = true,
    --     fn_transform = function(x)
    --         -- Strip ANSI color codes from the output
    --         return x:gsub("\27%[[0-9;]*m", "")
    --     end,
    --     rg_opts = "--column --line-number --no-heading --color=never --smart-case --max-columns=4096 -e",
    --     rg_glob = true,
    --     glob_flag = "--iglob",
    --     glob_separator = "%s%-%-",
    --     actions = {
    --         ["enter"] = function(selected, opts)
    --             -- Parse the grep result and open the file at the correct line and column
    --             if #selected > 0 then
    --                 local line = selected[1]
    --                 -- Strip ANSI color codes first
    --                 local clean_line = line:gsub("\27%[[0-9;]*m", "")
    --                 
    --                 -- Parse grep result format: filename:line:col:text
    --                 local filename, lnum, col, text = clean_line:match("([^:]+):(%d+):(%d+):(.*)")
    --                 if filename and lnum and col then
    --                     -- Open the file and jump to the line and column
    --                     vim.cmd("edit " .. vim.fn.fnameescape(filename))
    --                     vim.api.nvim_win_set_cursor(0, {tonumber(lnum), tonumber(col) - 1})
    --                 else
    --                     -- Fallback: try to parse as just filename:line
    --                     local fname, line_num = clean_line:match("([^:]+):(%d+):")
    --                     if fname and line_num then
    --                         vim.cmd("edit " .. vim.fn.fnameescape(fname))
    --                         vim.api.nvim_win_set_cursor(0, {tonumber(line_num), 0})
    --                     else
    --                         -- Last fallback: treat as filename only
    --                         local file_path = clean_line:match("^%s*(.-)%s*$") -- trim whitespace
    --                         if file_path and file_path ~= "" then
    --                             vim.cmd("edit " .. vim.fn.fnameescape(file_path))
    --                         end
    --                     end
    --                 end
    --             end
    --         end,
    --         ["ctrl-q"] = function(selected, opts)
    --             _G.fzf_send_to_qf_all(selected, opts)
    --         end,
    --     },
    -- },
    -- 
    -- -- Live grep optimizations
    live_grep = {
        -- prompt = "LiveGrep> ",
        multiprocess = true,
        -- git_icons = false,
        -- file_icons = false,
        -- color_icons = false,
        -- rg_opts = "--column --line-number --no-heading --smart-case --max-columns=4096",
        -- -- Performance: disable some features for speed
        -- fn_transform = function(x)
        --     -- Strip ANSI color codes from the output
        --     return x:gsub("\27%[[0-9;]*m", "")
        -- end,
        exec_empty_query = false,
        actions = {
            ["ctrl-q"] = _G.fzf_send_to_quickfix,
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
        previewer = true, -- Disable previewer for instant opening
        actions = {
            ["ctrl-q"] = _G.fzf_send_to_quickfix,
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
            actions = {
                ["ctrl-q"] = _G.fzf_send_to_quickfix,
            },
        },
        status = {
            prompt = "GitStatus> ",
            cmd = "git -c color.status=false status -s",
            multiprocess = true,
            file_icons = true,
            git_icons = true,
            color_icons = true,
            previewer = "git_diff",
            actions = {
                ["ctrl-q"] = _G.fzf_send_to_quickfix,
            },
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
            actions = {
                ["ctrl-q"] = _G.fzf_send_to_quickfix,
            },
        },
        code_actions = {
            prompt = "Code Actions> ",
            async_or_timeout = 5000,
        },
        references = {
            actions = {
                ["ctrl-q"] = _G.fzf_send_to_quickfix,
            },
        },
        definitions = {
            actions = {
                ["ctrl-q"] = _G.fzf_send_to_quickfix,
            },
        },
        implementations = {
            actions = {
                ["ctrl-q"] = _G.fzf_send_to_quickfix,
            },
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
            ["ctrl-q"] = _G.fzf_send_to_quickfix,
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
    --     git_icons = false,
    --     file_icons = true,
    --     color_icons = true,
    --     rg_opts = "--column --line-number --no-heading --color=never --smart-case --max-columns=4096",
    --     -- Performance: disable some features for speed
    --     fn_transform = function(x)
    --         -- Strip ANSI color codes from the output
    --         return x:gsub("\27%[[0-9;]*m", "")
    --     end,
    --     exec_empty_query = false,
    --     actions = {
    --         ["enter"] = function(selected, opts)
    --             -- Parse the grep result and open the file at the correct line and column
    --             if #selected > 0 then
    --                 local line = selected[1]
    --                 -- Strip ANSI color codes first
    --                 local clean_line = line:gsub("\27%[[0-9;]*m", "")
    --                 
    --                 -- Parse grep result format: filename:line:col:text
    --                 local filename, lnum, col, text = clean_line:match("([^:]+):(%d+):(%d+):(.*)")
    --                 if filename and lnum and col then
    --                     -- Open the file and jump to the line and column
    --                     vim.cmd("edit " .. vim.fn.fnameescape(filename))
    --                     vim.api.nvim_win_set_cursor(0, {tonumber(lnum), tonumber(col) - 1})
    --                 else
    --                     -- Fallback: try to parse as just filename:line
    --                     local fname, line_num = clean_line:match("([^:]+):(%d+):")
    --                     if fname and line_num then
    --                         vim.cmd("edit " .. vim.fn.fnameescape(fname))
    --                         vim.api.nvim_win_set_cursor(0, {tonumber(line_num), 0})
    --                     else
    --                         -- Last fallback: treat as filename only
    --                         local file_path = clean_line:match("^%s*(.-)%s*$") -- trim whitespace
    --                         if file_path and file_path ~= "" then
    --                             vim.cmd("edit " .. vim.fn.fnameescape(file_path))
    --                         end
    --                     end
    --                 end
    --             end
    --         end,
    --         ["ctrl-q"] = function(selected, opts)
    --             _G.fzf_send_to_qf_all(selected, opts)
    --         end,
    --     },
    -- },
    -- 
    -- -- Buffer optimizations  
    -- buffers = {
    --     prompt = "Buffers> ",
    --     file_icons = false, -- Disable for performance
    --     color_icons = false, -- Disable for performance
    --     sort_lastused = true,
    --     show_unloaded = true,
    --     cwd_only = false,
    --     previewer = false, -- Disable previewer for instant opening
    --     actions = {
    --         ["ctrl-q"] = function(selected, opts)
    --             _G.fzf_send_to_qf_all(selected, opts)
    --         end,
    --     },
    -- },
    -- 
    -- -- Help tags
    -- helptags = {
    --     prompt = "Help> ",
    -- },
    -- 
    -- -- Git files
    -- git = {
    --     files = {
    --         prompt = "GitFiles> ",
    --         cmd = "git ls-files --exclude-standard",
    --         multiprocess = true,
    --         git_icons = true,
    --         file_icons = true,
    --         color_icons = true,
    --     },
    --     status = {
    --         prompt = "GitStatus> ",
    --         cmd = "git -c color.status=false status -s",
    --         multiprocess = true,
    --         file_icons = true,
    --         git_icons = true,
    --         color_icons = true,
    --         previewer = "git_diff",
    --     },
    --     commits = {
    --         prompt = "Commits> ",
    --         cmd = "git log --color --pretty=format:'%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset'",
    --         preview = "git show --color {1}",
    --     },
    --     bcommits = {
    --         prompt = "BCommits> ",
    --         cmd = "git log --color --pretty=format:'%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset' {file}",
    --         preview = "git show --color {1} -- {file}",
    --     },
    --     branches = {
    --         prompt = "Branches> ",
    --         cmd = "git branch --all --color",
    --         preview = "git log --graph --pretty=oneline --abbrev-commit --color {1}",
    --     },
    -- },
    -- 
    -- -- LSP settings
    -- lsp = {
    --     prompt_postfix = "> ",
    --     cwd_only = false,
    --     async_or_timeout = 5000,
    --     file_icons = true,
    --     git_icons = false,
    --     symbols = {
    --         async_or_timeout = true,
    --         symbol_style = 1,
    --     },
    --     code_actions = {
    --         prompt = "Code Actions> ",
    --         async_or_timeout = 5000,
    --     },
    -- },
    -- 
    -- -- Diagnostics
    -- diagnostics = {
    --     prompt = "Diagnostics> ",
    --     cwd_only = false,
    --     file_icons = true,
    --     git_icons = false,
    --     diag_icons = true,
    --     actions = {
    --         ["ctrl-q"] = function(selected, opts)
    --             _G.fzf_send_to_qf_all(selected, opts)
    --         end,
    --     },
    -- },
    -- 
    -- -- Quickfix
    -- quickfix = {
    --     file_icons = true,
    --     git_icons = false,
    -- },
    -- 
    -- -- Colorschemes
    -- colorschemes = {
    --     prompt = "Colorschemes> ",
    --     live_preview = true,
    --     winopts = { height = 0.55, width = 0.30 },
    -- },
    -- 
    -- -- Keymaps
    -- keymaps = {
    --     prompt = "Keymaps> ",
    --     winopts = { preview = { layout = "vertical" } },
    -- },
    -- 
    -- -- Commands
    -- commands = {
    --     prompt = "Commands> ",
    -- },
    -- 
    -- -- Command history
    -- command_history = {
    --     prompt = "History> ",
    -- },
    -- 
    -- -- Search history
    -- search_history = {
    --     prompt = "Search> ",
    -- },
    -- 
    -- -- Marks
    -- marks = {
    --     prompt = "Marks> ",
    -- },
    -- 
    -- -- Registers
    -- registers = {
    --     prompt = "Registers> ",
    -- },
    -- 
    -- -- Autocmds
    -- autocmds = {
    --     prompt = "Autocmds> ",
    -- },
    -- 
    -- -- Highlights
    -- highlights = {
    --     prompt = "Highlights> ",
    -- },
})

-- Register fzf-lua for vim.ui.select
fzf_lua.register_ui_select()

-- Simplified and robust quickfix function for ALL fzf pickers
local function send_to_quickfix(selected, opts)
    if not selected or #selected == 0 then
        print("No items selected for quickfix")
        return
    end
    
    local qf_list = {}
    
    for _, line in ipairs(selected) do
        if line and line ~= "" then
            -- Strip ANSI color codes
            local clean_line = line:gsub("\27%[[0-9;]*m", "")
            
            -- Try different parsing patterns
            local filename, lnum, col, text
            
            -- Pattern 1: grep/ripgrep format (file:line:col:text)
            filename, lnum, col, text = clean_line:match("([^:]+):(%d+):(%d+):(.*)")
            
            if not filename then
                -- Pattern 2: simple format (file:line:text)
                filename, lnum, text = clean_line:match("([^:]+):(%d+):(.*)")
                col = 1
            end
            
            if not filename then
                -- Pattern 3: just filename
                filename = clean_line:match("^%s*(.-)%s*$") -- trim whitespace
                lnum, col, text = 1, 1, "File: " .. filename
            end
            
            -- Add to quickfix list if we have a valid filename
            if filename and filename ~= "" then
                table.insert(qf_list, {
                    filename = filename,
                    lnum = tonumber(lnum) or 1,
                    col = tonumber(col) or 1,
                    text = text or filename,
                })
            end
        end
    end
    
    if #qf_list > 0 then
        -- Replace quickfix list and open it
        vim.fn.setqflist(qf_list, 'r')
        vim.cmd("copen")
        print(string.format("Added %d items to quickfix list", #qf_list))
    else
        print("No valid items to add to quickfix")
    end
end

-- Make the function available globally
_G.fzf_send_to_quickfix = send_to_quickfix

return fzf_lua
