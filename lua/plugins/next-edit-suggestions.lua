return {
  "github/copilot.vim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    -- Enable Copilot
    vim.g.copilot_enabled = true
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
    
    -- Setup the next-edit-suggestions plugin
    require("next-edit-suggestions").setup({
      -- Performance optimizations
      debounce_ms = 100,
      max_suggestions = 5,
      cache_size = 1000,
      
      -- UI configuration (Cursor-like)
      ui = {
        ghost_text = true,
        inline_suggestions = true,
        popup_border = "rounded",
        highlight_group = "CopilotSuggestion",
        accept_key = "<Tab>",
        dismiss_key = "<Esc>",
        next_key = "<M-]>",
        prev_key = "<M-[>",
      },
      
      -- Copilot integration
      copilot = {
        enabled = true,
        model = "gpt-4",
        temperature = 0.1,
        max_tokens = 500,
      },
      
      -- File type support
      filetypes = {
        "javascript", "typescript", "jsx", "tsx", "python", "lua", 
        "rust", "go", "java", "cpp", "c", "html", "css", "json", "yaml"
      },
    })
  end,
  event = "InsertEnter",
}