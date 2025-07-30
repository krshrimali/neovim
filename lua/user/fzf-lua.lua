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
            ["alt-a"] = "toggle-all",
            ["f3"] = "toggle-preview-wrap",
            ["f4"] = "toggle-preview",
        },
    },
    
    -- FZF options for performance
    fzf_opts = {
        ["--ansi"] = false, -- Disable ANSI for performance
        ["--info"] = "hidden", -- Hide info for performance
        ["--height"] = "100%",
        ["--layout"] = "reverse",
        ["--border"] = "none",
        ["--highlight-line"] = false, -- Disable for performance
        ["--no-scrollbar"] = true, -- Disable scrollbar
        ["--no-separator"] = true, -- Disable separator
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
        },
    },
    
    -- File picker optimizations
    files = {
        prompt = "Files❯ ",
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
        previewer = false, -- Disable previewer for instant opening
        -- Disable path transformations for speed
        path_shorten = false,
    },
    
    -- Oldfiles (recent files) optimizations
    oldfiles = {
        prompt = "Recent❯ ",
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
        prompt = "Rg❯ ",
        input_prompt = "Grep For❯ ",
        multiprocess = true,
        git_icons = false,
        file_icons = true,
        color_icons = true,
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
        rg_glob = true,
        glob_flag = "--iglob",
        glob_separator = "%s%-%-",
    },
    
    -- Live grep optimizations
    live_grep = {
        prompt = "LiveGrep❯ ",
        multiprocess = true,
        git_icons = false,
        file_icons = true,
        color_icons = true,
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096",
        -- Performance: disable some features for speed
        exec_empty_query = false,
    },
    
    -- Buffer optimizations  
    buffers = {
        prompt = "Buffers❯ ",
        file_icons = false, -- Disable for performance
        color_icons = false, -- Disable for performance
        sort_lastused = true,
        show_unloaded = true,
        cwd_only = false,
        previewer = false, -- Disable previewer for instant opening
    },
    
    -- Help tags
    helptags = {
        prompt = "Help❯ ",
    },
    
    -- Git files
    git = {
        files = {
            prompt = "GitFiles❯ ",
            cmd = "git ls-files --exclude-standard",
            multiprocess = true,
            git_icons = true,
            file_icons = true,
            color_icons = true,
        },
        status = {
            prompt = "GitStatus❯ ",
            cmd = "git -c color.status=false status -s",
            multiprocess = true,
            file_icons = true,
            git_icons = true,
            color_icons = true,
            previewer = "git_diff",
        },
        commits = {
            prompt = "Commits❯ ",
            cmd = "git log --color --pretty=format:'%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset'",
            preview = "git show --color {1}",
        },
        bcommits = {
            prompt = "BCommits❯ ",
            cmd = "git log --color --pretty=format:'%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset' {file}",
            preview = "git show --color {1} -- {file}",
        },
        branches = {
            prompt = "Branches❯ ",
            cmd = "git branch --all --color",
            preview = "git log --graph --pretty=oneline --abbrev-commit --color {1}",
        },
    },
    
    -- LSP settings
    lsp = {
        prompt_postfix = "❯ ",
        cwd_only = false,
        async_or_timeout = 5000,
        file_icons = true,
        git_icons = false,
        symbols = {
            async_or_timeout = true,
            symbol_style = 1,
        },
        code_actions = {
            prompt = "Code Actions❯ ",
            async_or_timeout = 5000,
        },
    },
    
    -- Diagnostics
    diagnostics = {
        prompt = "Diagnostics❯ ",
        cwd_only = false,
        file_icons = true,
        git_icons = false,
        diag_icons = true,
    },
    
    -- Quickfix
    quickfix = {
        file_icons = true,
        git_icons = false,
    },
    
    -- Colorschemes
    colorschemes = {
        prompt = "Colorschemes❯ ",
        live_preview = true,
        winopts = { height = 0.55, width = 0.30 },
    },
    
    -- Keymaps
    keymaps = {
        prompt = "Keymaps❯ ",
        winopts = { preview = { layout = "vertical" } },
    },
    
    -- Commands
    commands = {
        prompt = "Commands❯ ",
    },
    
    -- Command history
    command_history = {
        prompt = "History❯ ",
    },
    
    -- Search history
    search_history = {
        prompt = "Search❯ ",
    },
    
    -- Marks
    marks = {
        prompt = "Marks❯ ",
    },
    
    -- Registers
    registers = {
        prompt = "Registers❯ ",
    },
    
    -- Autocmds
    autocmds = {
        prompt = "Autocmds❯ ",
    },
    
    -- Highlights
    highlights = {
        prompt = "Highlights❯ ",
    },
})

-- Register fzf-lua for vim.ui.select
fzf_lua.register_ui_select()

return fzf_lua