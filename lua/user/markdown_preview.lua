local M = {}

-- Function to find glow binary path
local function find_glow_path()
    -- Try common paths in order of preference
    local paths = {
        "/nix/profiles/shrimali/default/bin/glow", -- Nix user profile
        "/usr/local/bin/glow", -- System install
        "/usr/bin/glow", -- Package manager install
        "glow", -- PATH fallback
    }
    
    for _, path in ipairs(paths) do
        if path == "glow" then
            -- Check if glow is in PATH
            local result = vim.fn.system("which glow 2>/dev/null")
            if vim.v.shell_error == 0 then
                return vim.trim(result)
            end
        else
            -- Check if file exists
            if vim.fn.executable(path) == 1 then
                return path
            end
        end
    end
    
    return "glow" -- fallback to PATH
end

function M.setup()
    local glow_path = find_glow_path()
    
    require("glow").setup({
        glow_path = glow_path,
        install_path = "~/.local/bin", -- fallback installation path
        border = "shadow", -- floating window border
        style = "dark", -- filled automatically with your current editor background
        pager = false,
        width = 120,
        height = 100,
        width_ratio = 0.8, -- maximum width of the Glow window compared to the nvim window size (overrides `width`)
        height_ratio = 0.8,
    })
    
    -- Store the glow path for use in custom functions
    M.glow_path = glow_path
end

-- Function to open markdown preview in vertical split
function M.preview_vertical_split()
    local current_file = vim.api.nvim_buf_get_name(0)
    
    if current_file == "" or not current_file:match("%.md$") then
        vim.notify("Not a markdown file", vim.log.levels.WARN)
        return
    end
    
    -- Create vertical split and switch to it
    vim.cmd("vsplit")
    local preview_win = vim.api.nvim_get_current_win()
    
    -- Create a new buffer for the preview
    local preview_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(preview_win, preview_buf)
    
    -- Set buffer options
    vim.api.nvim_buf_set_option(preview_buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(preview_buf, "swapfile", false)
    vim.api.nvim_buf_set_option(preview_buf, "filetype", "markdown")
    vim.api.nvim_buf_set_name(preview_buf, "glow://preview")
    
    -- Run glow command and capture output
    local glow_cmd = (M.glow_path or "glow") .. " " .. vim.fn.shellescape(current_file)
    local output = vim.fn.system(glow_cmd)
    
    if vim.v.shell_error ~= 0 then
        vim.notify("Glow command failed: " .. output, vim.log.levels.ERROR)
        return
    end
    
    -- Split output into lines and set buffer content
    local lines = vim.split(output, "\n")
    vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)
    
    -- Set buffer as readonly
    vim.api.nvim_buf_set_option(preview_buf, "readonly", true)
    vim.api.nvim_buf_set_option(preview_buf, "modifiable", false)
    
    -- Stay in the preview window (focus transferred)
    vim.api.nvim_set_current_win(preview_win)
end

-- Function to toggle markdown preview
function M.toggle_preview()
    -- Check if there's already a preview buffer open
    local preview_buf = nil
    local preview_win = nil
    
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_name = vim.api.nvim_buf_get_name(buf)
        if buf_name:match("glow://preview") then
            preview_buf = buf
            preview_win = win
            break
        end
    end
    
    if preview_buf and preview_win then
        -- Close the preview window and buffer
        vim.api.nvim_win_close(preview_win, false)
        vim.api.nvim_buf_delete(preview_buf, { force = true })
    else
        -- Open glow preview in vertical split
        M.preview_vertical_split()
    end
end

-- Function to open floating window preview with focus
function M.preview_floating()
    local current_file = vim.api.nvim_buf_get_name(0)
    
    if current_file == "" or not current_file:match("%.md$") then
        vim.notify("Not a markdown file", vim.log.levels.WARN)
        return
    end
    
    -- Use the glow.nvim plugin for floating window
    vim.cmd("Glow")
    
    -- The glow plugin should handle focus, but let's ensure it
    vim.schedule(function()
        -- Find the glow window and focus it
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if buf_name:match("glow://") then
                vim.api.nvim_set_current_win(win)
                break
            end
        end
    end)
end

-- Function to refresh existing preview
function M.refresh_preview()
    -- Find existing preview buffer
    local preview_buf = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_name = vim.api.nvim_buf_get_name(buf)
        if buf_name:match("glow://preview") then
            preview_buf = buf
            break
        end
    end
    
    if preview_buf then
        local current_file = vim.api.nvim_buf_get_name(0)
        if current_file ~= "" and current_file:match("%.md$") then
            -- Update the preview content
            local glow_cmd = (M.glow_path or "glow") .. " " .. vim.fn.shellescape(current_file)
            local output = vim.fn.system(glow_cmd)
            
            if vim.v.shell_error == 0 then
                local lines = vim.split(output, "\n")
                vim.api.nvim_buf_set_option(preview_buf, "modifiable", true)
                vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)
                vim.api.nvim_buf_set_option(preview_buf, "modifiable", false)
            end
        end
    end
end

-- Set up keymaps for markdown files
function M.setup_keymaps()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
            local opts = { desc = "Markdown Preview", buffer = true, silent = true }
            
            -- Floating window preview with focus
            vim.keymap.set("n", "<leader>mp", function() M.preview_floating() end, vim.tbl_extend("force", opts, { desc = "Markdown Preview (Float)" }))
            
            -- Preview in vertical split with focus
            vim.keymap.set("n", "<leader>mv", function() M.preview_vertical_split() end, vim.tbl_extend("force", opts, { desc = "Markdown Preview (Vertical Split)" }))
            
            -- Toggle preview
            vim.keymap.set("n", "<leader>mt", function() M.toggle_preview() end, vim.tbl_extend("force", opts, { desc = "Toggle Markdown Preview" }))
            
            -- Refresh preview
            vim.keymap.set("n", "<leader>mr", function() M.refresh_preview() end, vim.tbl_extend("force", opts, { desc = "Refresh Markdown Preview" }))
            
            -- Auto-refresh on save
            vim.api.nvim_create_autocmd("BufWritePost", {
                buffer = 0,
                callback = function()
                    M.refresh_preview()
                end,
            })
        end,
    })
end

return M