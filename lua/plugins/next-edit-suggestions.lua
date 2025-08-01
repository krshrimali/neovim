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
      
             -- Keybindings (CoC-safe, non-intrusive)
       keymaps = {
         accept = "<C-l>", -- Safe from CoC conflicts
         dismiss = "<C-h>", -- Safe from CoC conflicts
         next = "<M-]>",
         prev = "<M-[>",
       },
    })
  end,
  -- Load only in insert mode for maximum performance
  event = "InsertEnter",
}