return {
  "your-username/next-edit-suggestions",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Only minimal dependency
  },
  config = function()
    -- Setup the ultra-fast next-edit-suggestions plugin
    require("next-edit-suggestions").setup({
      -- Ultra-fast performance
      debounce_ms = 25, -- Lightning fast (25ms)
      max_suggestions = 5, -- Keep it focused
      
      -- Virtual text settings (like copilot)
      virtual_text = {
        enabled = true,
        prefix = "💡 ",
        hl_group = "NextEditSuggestion",
        priority = 100,
      },
      
      -- Detection settings
      detection = {
        min_word_length = 2,
        enabled_filetypes = {
          "javascript", "typescript", "jsx", "tsx", "python", "lua", 
          "rust", "go", "java", "cpp", "c"
        },
      },
      
             -- Keybindings (Cursor/VSCode style with intelligent CoC handling)
       keymaps = {
         accept = "<Tab>", -- Like Cursor/VSCode - intelligently handles CoC
         dismiss = "<Esc>", -- Like Cursor/VSCode
         next = "<Tab>", -- Same as accept
         prev = "<S-Tab>", -- Shift+Tab for previous
       },
    })
  end,
  -- Load only in insert mode for maximum performance
  event = "InsertEnter",
}