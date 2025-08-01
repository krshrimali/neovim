-- Next Edit Suggestions - Minimal and Working
local M = {}

-- Simple state
local state = {
  enabled = true,
  suggestions = {},
  current_index = 1,
  namespace = vim.api.nvim_create_namespace("next_edit_suggestions"),
  last_buffer_content = {},
  last_cursor_pos = {1, 0},
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
  
  -- Save buffer state on insert enter
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function()
      M.save_buffer_state()
    end,
  })
  
  -- Detect changes in insert mode
  vim.api.nvim_create_autocmd("TextChangedI", {
    group = group,
    callback = function()
      vim.defer_fn(function()
        M.detect_changes()
      end, 50)
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

-- Save buffer state
function M.save_buffer_state()
  local bufnr = vim.api.nvim_get_current_buf()
  state.last_buffer_content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  state.last_cursor_pos = vim.api.nvim_win_get_cursor(0)
end

-- Detect symbol changes
function M.detect_changes()
  if not state.enabled then return end
  
  local bufnr = vim.api.nvim_get_current_buf()
  local current_content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local cursor = vim.api.nvim_win_get_cursor(0)
  
  -- Find what changed by comparing with saved state
  local changed_symbols = M.find_changed_symbols(state.last_buffer_content, current_content, cursor)
  
  if #changed_symbols > 0 then
    -- Use the most recently changed symbol
    local symbol_info = changed_symbols[1]
    M.find_occurrences(bufnr, symbol_info.old_word, symbol_info.line)
  else
    M.clear_suggestions()
  end
  
  -- Update saved state
  state.last_buffer_content = current_content
  state.last_cursor_pos = cursor
end

-- Find changed symbols by comparing old and new content
function M.find_changed_symbols(old_lines, new_lines, cursor)
  local changed = {}
  local cursor_line = cursor[1] - 1
  local cursor_col = cursor[2]
  
  -- Compare line by line
  for i = 1, math.max(#old_lines, #new_lines) do
    local old_line = old_lines[i] or ""
    local new_line = new_lines[i] or ""
    
    if old_line ~= new_line then
      -- Find what symbols changed on this line
      local line_changes = M.find_symbol_changes_in_line(old_line, new_line, i - 1)
      for _, change in ipairs(line_changes) do
        table.insert(changed, change)
      end
    end
  end
  
  -- Sort by proximity to cursor
  table.sort(changed, function(a, b)
    local dist_a = math.abs(a.line - cursor_line) + math.abs(a.col - cursor_col)
    local dist_b = math.abs(b.line - cursor_line) + math.abs(b.col - cursor_col)
    return dist_a < dist_b
  end)
  
  return changed
end

-- Find symbol changes within a single line
function M.find_symbol_changes_in_line(old_line, new_line, line_num)
  local changes = {}
  
  -- Extract all identifiers from both lines
  local old_words = M.extract_identifiers(old_line)
  local new_words = M.extract_identifiers(new_line)
  
  -- Find words that disappeared (were renamed/deleted)
  for _, old_word in ipairs(old_words) do
    local found_in_new = false
    for _, new_word in ipairs(new_words) do
      if old_word.word == new_word.word and math.abs(old_word.col - new_word.col) < 5 then
        found_in_new = true
        break
      end
    end
    
    if not found_in_new and #old_word.word >= 2 then
      table.insert(changes, {
        old_word = old_word.word,
        line = line_num,
        col = old_word.col,
        type = "removed"
      })
    end
  end
  
  return changes
end

-- Extract all identifiers from a line with their positions
function M.extract_identifiers(line)
  local identifiers = {}
  local pos = 1
  
  while pos <= #line do
    -- Find start of identifier
    local start_pos = line:find("[%a_][%w_]*", pos)
    if not start_pos then break end
    
    -- Find end of identifier
    local end_pos = start_pos
    while end_pos <= #line and line:sub(end_pos, end_pos):match("[%w_]") do
      end_pos = end_pos + 1
    end
    end_pos = end_pos - 1
    
    local word = line:sub(start_pos, end_pos)
    
    -- Only include valid identifiers (not keywords)
    if M.is_valid_identifier(word) then
      table.insert(identifiers, {
        word = word,
        col = start_pos - 1,
        start_pos = start_pos,
        end_pos = end_pos
      })
    end
    
    pos = end_pos + 1
  end
  
  return identifiers
end

-- Check if a word is a valid identifier (not a keyword)
function M.is_valid_identifier(word)
  if not word or #word < 2 then return false end
  if not word:match("^[%a_][%w_]*$") then return false end
  
  -- Common keywords to ignore
  local keywords = {
    "if", "else", "for", "while", "do", "end", "then", "function", "local", "return",
    "true", "false", "nil", "and", "or", "not", "in", "break", "repeat", "until",
    "let", "const", "var", "function", "return", "if", "else", "for", "while", "do",
    "class", "extends", "import", "export", "from", "as", "default", "async", "await",
    "try", "catch", "finally", "throw", "new", "this", "super", "static", "public",
    "private", "protected", "void", "int", "string", "bool", "float", "double"
  }
  
  for _, keyword in ipairs(keywords) do
    if word:lower() == keyword then
      return false
    end
  end
  
  return true
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