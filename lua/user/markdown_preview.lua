local M = {}

function M.setup()
    require("glow").setup({
        glow_path = "", -- will use glow from PATH
        install_path = "~/.local/bin", -- fallback installation path
        border = "shadow", -- floating window border
        style = "dark", -- filled automatically with your current editor background
        pager = false,
        width = 120,
        height = 100,
        width_ratio = 0.8, -- maximum width of the Glow window compared to the nvim window size (overrides `width`)
        height_ratio = 0.8,
    })
end

-- Function to open markdown preview in vertical split
function M.preview_vertical_split()
    -- Save current window
    local current_win = vim.api.nvim_get_current_win()
    
    -- Create vertical split
    vim.cmd("vsplit")
    
    -- Run Glow in the new split
    vim.cmd("Glow")
    
    -- Go back to original window
    vim.api.nvim_set_current_win(current_win)
end

-- Function to toggle markdown preview
function M.toggle_preview()
    -- Check if there's already a Glow buffer open
    local glow_buf = nil
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local buf_name = vim.api.nvim_buf_get_name(buf)
        if buf_name:match("glow://") then
            glow_buf = buf
            break
        end
    end
    
    if glow_buf then
        -- Close the glow buffer
        vim.api.nvim_buf_delete(glow_buf, { force = true })
    else
        -- Open glow preview
        M.preview_vertical_split()
    end
end

-- Set up keymaps for markdown files
function M.setup_keymaps()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
            local opts = { desc = "Markdown Preview", buffer = true, silent = true }
            
            -- Basic preview (floating window)
            vim.keymap.set("n", "<leader>mp", "<cmd>Glow<cr>", vim.tbl_extend("force", opts, { desc = "Markdown Preview (Float)" }))
            
            -- Preview in vertical split
            vim.keymap.set("n", "<leader>mv", function() M.preview_vertical_split() end, vim.tbl_extend("force", opts, { desc = "Markdown Preview (Vertical Split)" }))
            
            -- Toggle preview
            vim.keymap.set("n", "<leader>mt", function() M.toggle_preview() end, vim.tbl_extend("force", opts, { desc = "Toggle Markdown Preview" }))
        end,
    })
end

return M