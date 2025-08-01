-- Next Edit Suggestions - Minimal and Working
local M = {}

-- Simple state
local state = {
  enabled = true,
  suggestions = {},
  current_index = 1,
  namespace = vim.api.nvim_create_namespace("next_edit_suggestions"),
}

-- Setup function
function M.setup(opts)
  opts = opts or {}
  
  -- Set up highlights
  vim.api.nvim_set_hl(0, "NextEditSuggestion", { 
    fg = "#61afef", 
    italic = true,
    underline = true
  })
  
  -- Set up autocommands
  local group = vim.api.nvim_create_augroup("NextEditSuggestions", { clear = true })
  
  -- Detect changes in insert mode
  vim.api.nvim_create_autocmd("TextChangedI", {
    group = group,
    callback = function()
      vim.defer_fn(function()
        M.detect_changes()
      end, 100)
    end,
  })
  
  -- Clear on insert leave
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      M.clear_suggestions()
    end,
  })
  
  -- Set up simple keymaps that don't conflict
  vim.keymap.set("n", "<leader>n", function()
    if #state.suggestions > 0 then
      M.go_to_next()
    end
  end, { desc = "Go to next edit suggestion" })
  
  vim.keymap.set("n", "<leader>p", function()
    if #state.suggestions > 0 then
      M.go_to_prev()
    end
  end, { desc = "Go to previous edit suggestion" })
  
  vim.keymap.set("n", "<leader>c", function()
    M.clear_suggestions()
  end, { desc = "Clear edit suggestions" })
  
  -- Add Tab support in normal mode when suggestions are active
  vim.keymap.set("n", "<Tab>", function()
    if #state.suggestions > 0 then
      M.go_to_next()
    else
      -- Fallback to normal Tab behavior
      return "<Tab>"
    end
  end, { expr = true, desc = "Navigate suggestions or normal tab" })
  
  print("Next Edit Suggestions loaded")
end

-- Detect symbol changes
function M.detect_changes()
  if not state.enabled then return end
  
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line_num = cursor[1] - 1
  local col = cursor[2]
  
  -- Get current line
  local lines = vim.api.nvim_buf_get_lines(bufnr, line_num, line_num + 1, false)
  if #lines == 0 then return end
  
  local line = lines[1]
  
  -- Find word at cursor
  local word_start = col
  local word_end = col
  
  -- Find start of word
  while word_start > 0 and line:sub(word_start, word_start):match("[%w_]") do
    word_start = word_start - 1
  end
  word_start = word_start + 1
  
  -- Find end of word
  while word_end <= #line and line:sub(word_end + 1, word_end + 1):match("[%w_]") do
    word_end = word_end + 1
  end
  
  local word = line:sub(word_start, word_end)
  
  -- Only process valid identifiers
  if not word or #word < 2 or not word:match("^[%a_][%w_]*$") then
    M.clear_suggestions()
    return
  end
  
  -- Find all occurrences of this word
  M.find_occurrences(bufnr, word, line_num)
end

-- Find all occurrences of a word
function M.find_occurrences(bufnr, word, current_line)
  local all_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local occurrences = {}
  
  -- Pattern to match whole word only
  local pattern = "%f[%w_]" .. vim.pesc(word) .. "%f[^%w_]"
  
  for line_idx, line_content in ipairs(all_lines) do
    local line_num = line_idx - 1
    
    -- Skip current line
    if line_num ~= current_line then
      local start_pos = 1
      while true do
        local match_start, match_end = line_content:find(pattern, start_pos)
        if not match_start then break end
        
        table.insert(occurrences, {
          line = line_num,
          col = match_start - 1,
          word = word,
          content = line_content:sub(math.max(1, match_start - 10), math.min(#line_content, match_end + 10))
        })
        
        start_pos = match_end + 1
      end
    end
  end
  
  if #occurrences > 0 then
    M.show_suggestions(occurrences)
  else
    M.clear_suggestions()
  end
end

-- Show suggestions
function M.show_suggestions(suggestions)
  M.clear_suggestions()
  
  state.suggestions = suggestions
  state.current_index = 1
  
  local bufnr = vim.api.nvim_get_current_buf()
  
  -- Highlight all occurrences
  for i, suggestion in ipairs(suggestions) do
    vim.api.nvim_buf_set_extmark(bufnr, state.namespace, suggestion.line, suggestion.col, {
      end_col = suggestion.col + #suggestion.word,
      hl_group = "NextEditSuggestion",
    })
  end
  
  -- Show message
  vim.notify(string.format("Found %d occurrences. Use <leader>n/p to navigate, <leader>c to clear", #suggestions))
end

-- Clear suggestions
function M.clear_suggestions()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, state.namespace, 0, -1)
  state.suggestions = {}
  state.current_index = 1
end

-- Go to next suggestion
function M.go_to_next()
  if #state.suggestions == 0 then return end
  
  state.current_index = state.current_index + 1
  if state.current_index > #state.suggestions then
    state.current_index = 1
  end
  
  local suggestion = state.suggestions[state.current_index]
  vim.api.nvim_win_set_cursor(0, {suggestion.line + 1, suggestion.col})
  
  vim.notify(string.format("Suggestion %d/%d: %s", state.current_index, #state.suggestions, suggestion.content))
end

-- Go to previous suggestion
function M.go_to_prev()
  if #state.suggestions == 0 then return end
  
  state.current_index = state.current_index - 1
  if state.current_index < 1 then
    state.current_index = #state.suggestions
  end
  
  local suggestion = state.suggestions[state.current_index]
  vim.api.nvim_win_set_cursor(0, {suggestion.line + 1, suggestion.col})
  
  vim.notify(string.format("Suggestion %d/%d: %s", state.current_index, #state.suggestions, suggestion.content))
end

-- Toggle plugin
function M.toggle()
  state.enabled = not state.enabled
  if not state.enabled then
    M.clear_suggestions()
  end
  vim.notify("Next Edit Suggestions: " .. (state.enabled and "enabled" or "disabled"))
end

return M