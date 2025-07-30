-- ⚡ Ultra-Fast FZF-Lua Configuration
-- Minimal configuration for maximum startup speed

local M = {}

-- Only setup the most essential features
require("fzf-lua").setup({
    -- Minimal UI for speed
    winopts = {
        height = 0.6,
        width = 0.8,
        preview = {
            hidden = "hidden", -- Disable preview by default for speed
            vertical = "down:45%",
            horizontal = "right:50%",
        },
    },
    
    -- Fast file operations
    files = {
        prompt = "Files❯ ",
        cmd = "find . -type f -not -path '*/\\.git/*' -not -path '*/node_modules/*'",
        git_icons = false, -- Disable for speed
        file_icons = false, -- Disable for speed
        color_icons = false, -- Disable for speed
    },
    
    -- Fast grep
    grep = {
        prompt = "Grep❯ ",
        cmd = "rg --column --line-number --no-heading --color=always --smart-case",
        git_icons = false,
        file_icons = false,
        color_icons = false,
    },
    
    -- Fast buffer switching
    buffers = {
        prompt = "Buffers❯ ",
        file_icons = false,
        color_icons = false,
        git_icons = false,
    },
    
    -- Minimal oldfiles
    oldfiles = {
        prompt = "Recent❯ ",
        file_icons = false,
        color_icons = false,
        git_icons = false,
    },
    
    -- Fast help
    helptags = {
        prompt = "Help❯ ",
    },
    
    -- Disable heavy features
    previewers = {
        builtin = {
            syntax = false, -- Disable syntax highlighting in preview
            treesitter = { enable = false }, -- Disable treesitter in preview
        },
    },
    
    -- Fast defaults
    defaults = {
        git_icons = false,
        file_icons = false,
        color_icons = false,
    },
})

return M