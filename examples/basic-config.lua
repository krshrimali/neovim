-- Example configuration for Next Edit Suggestions
-- Copy this to your Neovim config and customize as needed

return {
  "your-username/next-edit-suggestions",
  dependencies = {
    "github/copilot.vim",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("next-edit-suggestions").setup({
      -- Performance settings
      debounce_ms = 100,           -- How long to wait after typing stops
      max_suggestions = 3,         -- Maximum suggestions to show
      cache_size = 500,           -- Cache size for faster responses
      
      -- UI customization
      ui = {
        ghost_text = true,         -- Show inline ghost text
        inline_suggestions = true, -- Show popup for multi-line
        popup_border = "rounded",  -- "single", "double", "rounded", "solid"
        
        -- Keybindings (customize to your preference)
        accept_key = "<Tab>",      -- Accept current suggestion
        dismiss_key = "<Esc>",     -- Dismiss all suggestions
        next_key = "<M-]>",        -- Next suggestion
        prev_key = "<M-[>",        -- Previous suggestion
        
        -- Visual styling
        highlight_group = "CopilotSuggestion",
      },
      
      -- AI configuration
      copilot = {
        enabled = true,
        model = "gpt-4",           -- "gpt-4" or "gpt-3.5-turbo"
        temperature = 0.1,         -- 0.0 = deterministic, 1.0 = creative
        max_tokens = 300,          -- Maximum tokens per suggestion
      },
      
      -- File types where suggestions are enabled
      filetypes = {
        "javascript",
        "typescript", 
        "jsx",
        "tsx",
        "python",
        "lua",
        "rust",
        "go",
        "java",
        "cpp",
        "c",
        "html",
        "css",
        "json",
        "yaml",
      },
    })
    
    -- Optional: Custom highlight colors
    vim.api.nvim_set_hl(0, "CopilotSuggestion", { 
      fg = "#6e6a86",     -- Gray color for suggestions
      italic = true,      -- Italic style
    })
    
    vim.api.nvim_set_hl(0, "CopilotSuggestionBorder", { 
      fg = "#6e6a86",     -- Border color for popups
    })
    
    -- Optional: Custom keymaps (in addition to built-in ones)
    local opts = { noremap = true, silent = true }
    
    -- Normal mode shortcuts
    vim.keymap.set("n", "<leader>ai", ":NextEditToggle<CR>", 
      vim.tbl_extend("force", opts, { desc = "Toggle AI suggestions" }))
    vim.keymap.set("n", "<leader>as", ":NextEditStatus<CR>", 
      vim.tbl_extend("force", opts, { desc = "Show AI status" }))
    
    -- Insert mode alternatives
    vim.keymap.set("i", "<C-Space>", function() 
      require("next-edit-suggestions").request_suggestions() 
    end, vim.tbl_extend("force", opts, { desc = "Trigger suggestions" }))
  end,
  
  -- Load only when entering insert mode (performance optimization)
  event = "InsertEnter",
  
  -- Alternative: Load on specific file types only
  -- ft = { "javascript", "typescript", "python", "lua", "rust" },
}