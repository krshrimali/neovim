local M = {}

-- Import submodules
local copilot = require("next-edit-suggestions.copilot")
local ui = require("next-edit-suggestions.ui")
local cache = require("next-edit-suggestions.cache")
local utils = require("next-edit-suggestions.utils")

-- Default configuration
local default_config = {
  debounce_ms = 100,
  max_suggestions = 5,
  cache_size = 1000,
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
  copilot = {
    enabled = true,
    model = "gpt-4",
    temperature = 0.1,
    max_tokens = 500,
  },
  filetypes = {
    "javascript", "typescript", "jsx", "tsx", "python", "lua", 
    "rust", "go", "java", "cpp", "c", "html", "css", "json", "yaml"
  },
}

-- Plugin state
local state = {
  config = {},
  active = false,
  current_suggestions = {},
  current_index = 1,
  timer = nil,
  namespace = vim.api.nvim_create_namespace("next-edit-suggestions"),
}

-- Setup function
function M.setup(opts)
  state.config = vim.tbl_deep_extend("force", default_config, opts or {})
  
  -- Initialize submodules
  copilot.setup(state.config.copilot)
  ui.setup(state.config.ui, state.namespace)
  cache.setup(state.config.cache_size)
  
  -- Setup highlights
  M.setup_highlights()
  
  -- Setup autocommands
  M.setup_autocommands()
  
  -- Setup keymaps
  M.setup_keymaps()
  
  -- Setup commands and integrations
  local commands = require("next-edit-suggestions.commands")
  commands.setup()
  commands.setup_keymaps()
  commands.setup_autocommands()
  commands.setup_integrations()
  
  state.active = true
end

-- Setup highlights
function M.setup_highlights()
  vim.api.nvim_set_hl(0, "CopilotSuggestion", { 
    fg = "#6e6a86", 
    italic = true 
  })
  vim.api.nvim_set_hl(0, "CopilotSuggestionBorder", { 
    fg = "#6e6a86" 
  })
end

-- Setup autocommands
function M.setup_autocommands()
  local group = vim.api.nvim_create_augroup("NextEditSuggestions", { clear = true })
  
  -- Trigger suggestions on text change in insert mode
  vim.api.nvim_create_autocmd({ "TextChangedI", "CursorMovedI" }, {
    group = group,
    callback = function()
      if not state.active then return end
      
      local filetype = vim.bo.filetype
      if not vim.tbl_contains(state.config.filetypes, filetype) then
        return
      end
      
      M.request_suggestions()
    end,
  })
  
  -- Clear suggestions when leaving insert mode
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      M.clear_suggestions()
    end,
  })
  
  -- Handle buffer changes
  vim.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave" }, {
    group = group,
    callback = function()
      M.clear_suggestions()
    end,
  })
end

-- Setup keymaps
function M.setup_keymaps()
  local opts = { noremap = true, silent = true }
  
  -- Accept suggestion
  vim.keymap.set("i", state.config.ui.accept_key, function()
    M.accept_suggestion()
  end, opts)
  
  -- Dismiss suggestions
  vim.keymap.set("i", state.config.ui.dismiss_key, function()
    M.clear_suggestions()
  end, opts)
  
  -- Navigate suggestions
  vim.keymap.set("i", state.config.ui.next_key, function()
    M.next_suggestion()
  end, opts)
  
  vim.keymap.set("i", state.config.ui.prev_key, function()
    M.prev_suggestion()
  end, opts)
end

-- Request suggestions with debouncing
function M.request_suggestions()
  if state.timer then
    state.timer:stop()
  end
  
  state.timer = vim.defer_fn(function()
    M.get_suggestions()
  end, state.config.debounce_ms)
end

-- Get suggestions from Copilot
function M.get_suggestions()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local col = cursor[2]
  
  -- Get context
  local context = utils.get_context(bufnr, line, col)
  
  -- Check cache first
  local cache_key = cache.generate_key(context)
  local cached_suggestions = cache.get(cache_key)
  
  if cached_suggestions then
    M.display_suggestions(cached_suggestions)
    return
  end
  
  -- Request from Copilot
  copilot.get_suggestions(context, function(suggestions)
    if suggestions and #suggestions > 0 then
      -- Cache the suggestions
      cache.set(cache_key, suggestions)
      
      -- Display suggestions
      M.display_suggestions(suggestions)
    end
  end)
end

-- Display suggestions
function M.display_suggestions(suggestions)
  if not suggestions or #suggestions == 0 then
    return
  end
  
  state.current_suggestions = suggestions
  state.current_index = 1
  
  -- Display using UI module
  ui.show_suggestions(suggestions[1])
end

-- Accept current suggestion
function M.accept_suggestion()
  if #state.current_suggestions == 0 then
    return false
  end
  
  local suggestion = state.current_suggestions[state.current_index]
  if suggestion then
    ui.accept_suggestion(suggestion)
    M.clear_suggestions()
    return true
  end
  
  return false
end

-- Navigate to next suggestion
function M.next_suggestion()
  if #state.current_suggestions <= 1 then
    return
  end
  
  state.current_index = state.current_index + 1
  if state.current_index > #state.current_suggestions then
    state.current_index = 1
  end
  
  ui.show_suggestions(state.current_suggestions[state.current_index])
end

-- Navigate to previous suggestion
function M.prev_suggestion()
  if #state.current_suggestions <= 1 then
    return
  end
  
  state.current_index = state.current_index - 1
  if state.current_index < 1 then
    state.current_index = #state.current_suggestions
  end
  
  ui.show_suggestions(state.current_suggestions[state.current_index])
end

-- Clear all suggestions
function M.clear_suggestions()
  state.current_suggestions = {}
  state.current_index = 1
  ui.clear_suggestions()
  
  if state.timer then
    state.timer:stop()
    state.timer = nil
  end
end

-- Toggle plugin
function M.toggle()
  state.active = not state.active
  if not state.active then
    M.clear_suggestions()
  end
  print("Next Edit Suggestions: " .. (state.active and "enabled" or "disabled"))
end

-- Get plugin status
function M.status()
  return {
    active = state.active,
    suggestions_count = #state.current_suggestions,
    current_index = state.current_index,
    cache_stats = cache.get_stats(),
  }
end

return M