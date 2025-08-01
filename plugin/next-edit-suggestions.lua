-- next-edit-suggestions.lua
-- Plugin initialization file

-- Prevent loading if already loaded or vim version is too old
if vim.g.loaded_next_edit_suggestions == 1 or vim.fn.has("nvim-0.8") == 0 then
  return
end

vim.g.loaded_next_edit_suggestions = 1

-- Create default highlight groups if they don't exist
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("NextEditSuggestionsHighlights", { clear = true }),
  callback = function()
    -- Set default highlights
    vim.api.nvim_set_hl(0, "CopilotSuggestion", { 
      default = true,
      fg = "#6e6a86", 
      italic = true 
    })
    vim.api.nvim_set_hl(0, "CopilotSuggestionBorder", { 
      default = true,
      fg = "#6e6a86" 
    })
  end,
})

-- Set initial highlights
vim.api.nvim_set_hl(0, "CopilotSuggestion", { 
  default = true,
  fg = "#6e6a86", 
  italic = true 
})
vim.api.nvim_set_hl(0, "CopilotSuggestionBorder", { 
  default = true,
  fg = "#6e6a86" 
})

-- Global commands (available even before setup)
vim.api.nvim_create_user_command("NextEditSetup", function(opts)
  local config = {}
  
  -- Parse simple config from command line
  if opts.args and opts.args ~= "" then
    local config_str = opts.args
    local ok, parsed = pcall(loadstring("return " .. config_str))
    if ok and type(parsed) == "table" then
      config = parsed
    end
  end
  
  require("next-edit-suggestions").setup(config)
  vim.notify("Next Edit Suggestions: Plugin initialized", vim.log.levels.INFO)
end, {
  desc = "Initialize Next Edit Suggestions with optional config",
  nargs = "?",
})

-- Auto-setup if plugin is required directly
local group = vim.api.nvim_create_augroup("NextEditSuggestionsAutoSetup", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  once = true,
  callback = function()
    -- Check if plugin should auto-initialize
    if vim.g.next_edit_suggestions_auto_setup ~= false then
      -- Small delay to ensure other plugins are loaded
      vim.defer_fn(function()
        -- Only auto-setup if not already done
        if not vim.g.loaded_next_edit_suggestions_setup then
          local ok, _ = pcall(require, "next-edit-suggestions")
          if ok then
            -- Auto-setup with default config
            require("next-edit-suggestions").setup()
            vim.g.loaded_next_edit_suggestions_setup = 1
          end
        end
      end, 100)
    end
  end,
})