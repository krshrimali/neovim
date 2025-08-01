return {
  "your-username/next-edit-suggestions",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- Optional: GitHub Copilot for enhanced suggestions
    -- "github/copilot.vim",
  },
  config = function()
    -- Setup the next-edit-suggestions plugin
    require("next-edit-suggestions").setup({
      -- Performance optimizations
      debounce_ms = 50, -- Very fast response (50ms)
      max_suggestions = 10, -- Show up to 10 related edits
      cache_size = 1000,
      
      -- UI configuration (Cursor-like next edit suggestions)
      ui = {
        show_related_edits = true,
        highlight_matches = true,
        popup_border = "rounded",
        highlight_group = "NextEditSuggestion",
        accept_key = "<CR>", -- Enter to accept current suggestion
        dismiss_key = "<leader>x", -- Leader+x to dismiss (avoid ESC conflict)
        next_key = "<Tab>", -- Tab to go to next suggestion
        prev_key = "<S-Tab>", -- Shift+Tab to go to previous
        apply_all_key = "<leader>a", -- Apply all suggestions at once
      },
      
      -- Detection settings
      detection = {
        min_word_length = 2,
        track_symbol_changes = true,
        ignore_comments = true,
        ignore_strings = true,
      },
      
      -- File type support
      filetypes = {
        "javascript", "typescript", "jsx", "tsx", "python", "lua", 
        "rust", "go", "java", "cpp", "c", "html", "css", "json", "yaml"
      },
    })
  end,
  -- Load when text changes (not just insert mode)
  event = { "TextChanged", "TextChangedI" },
}