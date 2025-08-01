local M = {}

-- Import utilities only (remove heavy dependencies)
local utils = require("next-edit-suggestions.utils")

-- Default configuration - simplified and fast
local default_config = {
  -- Performance settings (very fast)
  debounce_ms = 25, -- Ultra-fast response
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
  
  -- Keybindings (non-intrusive)
  keymaps = {
    accept = "<C-y>", -- Like copilot
    dismiss = "<C-e>", -- Like copilot
    next = "<M-]>",
    prev = "<M-[>",
  },
}

-- Plugin state - minimal and fast
local state = {
  config = {},
  enabled = true,
  namespace = vim.api.nvim_create_namespace("next_edit_suggestions"),
  current_suggestions = {},
  last_change = {},
  timers = {},
}

-- Setup function - minimal and fast
function M.setup(opts)
  state.config = vim.tbl_deep_extend("force", default_config, opts or {})
  
  -- Setup highlights
  M.setup_highlights()
  
  -- Setup autocommands (lightweight)
  M.setup_autocommands()
  
  -- Setup keymaps (non-intrusive)
  M.setup_keymaps()
  
  state.enabled = true
  
  -- Debug info
  vim.notify("Next Edit Suggestions: Loaded (ultra-fast mode)", vim.log.levels.INFO)
end

-- Setup highlights - minimal like copilot
function M.setup_highlights()
  -- Virtual text suggestion (like copilot's ghost text)
  vim.api.nvim_set_hl(0, "NextEditSuggestion", { 
    fg = "#6e6a86", 
    italic = true,
    blend = 20
  })
end

-- Setup autocommands - lightweight and fast
function M.setup_autocommands()
  local group = vim.api.nvim_create_augroup("NextEditSuggestions", { clear = true })
  
  -- Only track text changes in insert mode (like copilot)
  vim.api.nvim_create_autocmd("TextChangedI", {
    group = group,
    callback = function()
      if not state.enabled then return end
      
      local filetype = vim.bo.filetype
      if not vim.tbl_contains(state.config.detection.enabled_filetypes, filetype) then
        return
      end
      
      -- Fast symbol change detection
      M.detect_and_suggest()
    end,
  })
  
  -- Clear suggestions when leaving insert mode (like copilot)
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      M.clear_suggestions()
    end,
  })
  
  -- Clear suggestions when changing buffers
  vim.api.nvim_create_autocmd("BufLeave", {
    group = group,
    callback = function()
      M.clear_suggestions()
    end,
  })
end

-- Setup keymaps - non-intrusive like copilot
function M.setup_keymaps()
  local opts = { noremap = true, silent = true }
  
  -- Accept suggestion (insert mode, like copilot)
  vim.keymap.set("i", state.config.keymaps.accept, function()
    return M.accept_suggestion() and "" or state.config.keymaps.accept
  end, vim.tbl_extend("force", opts, { expr = true, desc = "Accept next edit suggestion" }))
  
  -- Dismiss suggestion (insert mode, like copilot)
  vim.keymap.set("i", state.config.keymaps.dismiss, function()
    M.clear_suggestions()
    return ""
  end, vim.tbl_extend("force", opts, { expr = true, desc = "Dismiss next edit suggestions" }))
  
  -- Navigate suggestions (insert mode)
  vim.keymap.set("i", state.config.keymaps.next, function()
    M.next_suggestion()
    return ""
  end, vim.tbl_extend("force", opts, { expr = true, desc = "Next suggestion" }))
  
  vim.keymap.set("i", state.config.keymaps.prev, function()
    M.prev_suggestion()
    return ""
  end, vim.tbl_extend("force", opts, { expr = true, desc = "Previous suggestion" }))
end

-- Fast detection and suggestion (like copilot)
function M.detect_and_suggest()
  -- Cancel any existing timer
  if state.timers.detect then
    state.timers.detect:stop()
  end
  
  -- Ultra-fast debounced detection
  state.timers.detect = vim.defer_fn(function()
    M.analyze_and_suggest()
  end, state.config.debounce_ms)
end

-- Analyze and suggest - very fast implementation
function M.analyze_and_suggest()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line_num = cursor[1] - 1
  local col = cursor[2]
  
  -- Get current word very fast
  local current_line = vim.api.nvim_buf_get_lines(bufnr, line_num, line_num + 1, false)[1]
  if not current_line then return end
  
  local word = utils.get_word_at_position(current_line, col)
  if not word or #word < state.config.detection.min_word_length then
    return
  end
  
  -- Fast symbol detection - only check nearby lines (like copilot)
  local suggestions = M.find_nearby_matches(bufnr, word, line_num, col)
  
  if #suggestions > 0 then
    M.show_virtual_text_suggestions(suggestions)
  end
end

-- Find nearby matches very fast (within 50 lines like copilot)
function M.find_nearby_matches(bufnr, word, current_line, current_col)
  local suggestions = {}
  local range = 25 -- Check 25 lines above and below
  local start_line = math.max(0, current_line - range)
  local end_line = math.min(vim.api.nvim_buf_line_count(bufnr) - 1, current_line + range)
  
  -- Get lines in one call for speed
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line + 1, false)
  
  -- Fast pattern matching
  local pattern = "%f[%w_]" .. vim.pesc(word) .. "%f[^%w_]"
  
  for i, line_content in ipairs(lines) do
    local line_num = start_line + i - 1
    
    -- Skip current line
    if line_num ~= current_line then
      local start_pos = 1
      while true do
        local match_start, match_end = line_content:find(pattern, start_pos)
        if not match_start then break end
        
        table.insert(suggestions, {
          line = line_num,
          col = match_start - 1,
          word = word,
          distance = math.abs(line_num - current_line),
        })
        
        start_pos = match_end + 1
        
        -- Limit suggestions for performance
        if #suggestions >= state.config.max_suggestions then
          break
        end
      end
      
      if #suggestions >= state.config.max_suggestions then
        break
      end
    end
  end
  
  -- Sort by distance (closest first)
  table.sort(suggestions, function(a, b) return a.distance < b.distance end)
  
  return suggestions
end

-- Show virtual text suggestions (like copilot)
function M.show_virtual_text_suggestions(suggestions)
  if not state.config.virtual_text.enabled or #suggestions == 0 then
    return
  end
  
  -- Clear existing suggestions
  M.clear_suggestions()
  
  local bufnr = vim.api.nvim_get_current_buf()
  state.current_suggestions = suggestions
  
  -- Show virtual text for each suggestion
  for i, suggestion in ipairs(suggestions) do
    local virt_text = {
      {state.config.virtual_text.prefix .. "Line " .. (suggestion.line + 1), state.config.virtual_text.hl_group}
    }
    
    vim.api.nvim_buf_set_extmark(bufnr, state.namespace, suggestion.line, suggestion.col, {
      virt_text = virt_text,
      virt_text_pos = "eol",
      priority = state.config.virtual_text.priority,
    })
  end
end

-- Accept current suggestion (like copilot)
function M.accept_suggestion()
  if #state.current_suggestions == 0 then
    return false
  end
  
  local suggestion = state.current_suggestions[1] -- Always accept first/closest
  if not suggestion then
    return false
  end
  
  -- Jump to the suggestion location and apply rename
  vim.api.nvim_win_set_cursor(0, {suggestion.line + 1, suggestion.col})
  
  -- Clear suggestions after accepting
  M.clear_suggestions()
  
  return true
end

-- Navigate to next suggestion
function M.next_suggestion()
  if #state.current_suggestions <= 1 then
    return
  end
  
  -- Cycle through suggestions by jumping to them
  local current_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = current_pos[1] - 1
  
  -- Find next suggestion after current position
  for i, suggestion in ipairs(state.current_suggestions) do
    if suggestion.line > current_line then
      vim.api.nvim_win_set_cursor(0, {suggestion.line + 1, suggestion.col})
      return
    end
  end
  
  -- If no suggestion after current, go to first
  if state.current_suggestions[1] then
    vim.api.nvim_win_set_cursor(0, {state.current_suggestions[1].line + 1, state.current_suggestions[1].col})
  end
end

-- Navigate to previous suggestion
function M.prev_suggestion()
  if #state.current_suggestions <= 1 then
    return
  end
  
  local current_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = current_pos[1] - 1
  
  -- Find previous suggestion before current position
  for i = #state.current_suggestions, 1, -1 do
    local suggestion = state.current_suggestions[i]
    if suggestion.line < current_line then
      vim.api.nvim_win_set_cursor(0, {suggestion.line + 1, suggestion.col})
      return
    end
  end
  
  -- If no suggestion before current, go to last
  local last = state.current_suggestions[#state.current_suggestions]
  if last then
    vim.api.nvim_win_set_cursor(0, {last.line + 1, last.col})
  end
end

-- Clear all suggestions (like copilot)
function M.clear_suggestions()
  local bufnr = vim.api.nvim_get_current_buf()
  
  -- Clear all extmarks
  pcall(vim.api.nvim_buf_clear_namespace, bufnr, state.namespace, 0, -1)
  
  -- Clear state
  state.current_suggestions = {}
  
  -- Cancel any pending timers
  if state.timers.detect then
    state.timers.detect:stop()
    state.timers.detect = nil
  end
end

-- Toggle plugin
function M.toggle()
  state.enabled = not state.enabled
  if not state.enabled then
    M.clear_suggestions()
  end
  vim.notify("Next Edit Suggestions: " .. (state.enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end

-- Get plugin status
function M.status()
  return {
    enabled = state.enabled,
    suggestions_count = #state.current_suggestions,
  }
end

return M