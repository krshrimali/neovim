local M = {}

-- Import submodules
local copilot = require("next-edit-suggestions.copilot")
local ui = require("next-edit-suggestions.ui")
local cache = require("next-edit-suggestions.cache")
local utils = require("next-edit-suggestions.utils")

-- Default configuration
local default_config = {
  debounce_ms = 100, -- Fast response for better UX
  max_suggestions = 10, -- More suggestions for related edits
  cache_size = 1000,
  ui = {
    show_related_edits = true,
    highlight_matches = true,
    popup_border = "rounded",
    highlight_group = "NextEditSuggestion",
    accept_key = "<CR>", -- Enter to accept (in normal mode)
    dismiss_key = "<leader>x", -- Leader+x to dismiss (avoid ESC conflict)
    next_key = "<Tab>", -- Tab to go to next
    prev_key = "<S-Tab>", -- Shift+Tab to go to previous
    apply_all_key = "<leader>a", -- Apply all suggestions
  },
  detection = {
    min_word_length = 2,
    track_symbol_changes = true,
    ignore_comments = true,
    ignore_strings = true,
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
  undo_stack = {}, -- Track applied changes for undo
  applied_suggestions = {}, -- Track which suggestions were applied
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
  -- Main suggestion highlight
  vim.api.nvim_set_hl(0, "NextEditSuggestion", { 
    fg = "#6e6a86", 
    italic = true 
  })
  
  -- Border highlight
  vim.api.nvim_set_hl(0, "NextEditSuggestionBorder", { 
    fg = "#6e6a86" 
  })
  
  -- Current suggestion highlight (bright yellow)
  vim.api.nvim_set_hl(0, "NextEditSuggestionCurrent", { 
    bg = "#3e4451",
    fg = "#e5c07b",
    bold = true
  })
  
  -- Other suggestions highlight (dimmer)
  vim.api.nvim_set_hl(0, "NextEditSuggestionOther", { 
    bg = "#2c323c",
    fg = "#abb2bf"
  })
  
  -- Applied suggestions highlight (green)
  vim.api.nvim_set_hl(0, "NextEditSuggestionApplied", { 
    bg = "#2d5016",
    fg = "#98c379",
    bold = true
  })
end

-- Setup autocommands
function M.setup_autocommands()
  local group = vim.api.nvim_create_augroup("NextEditSuggestions", { clear = true })
  
  -- Track text changes to detect symbol renames
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    callback = function()
      if not state.active then return end
      
      local filetype = vim.bo.filetype
      if not vim.tbl_contains(state.config.filetypes, filetype) then
        return
      end
      
      -- Detect if a symbol was renamed and suggest related changes
      M.detect_symbol_changes()
    end,
  })
  
  -- Clear suggestions when changing buffers
  vim.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave" }, {
    group = group,
    callback = function()
      M.clear_suggestions()
    end,
  })
  
  -- Track cursor position for context
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = group,
    callback = function()
      -- Update current position context
      M.update_cursor_context()
    end,
  })
end

-- Setup keymaps
function M.setup_keymaps()
  local opts = { noremap = true, silent = true }
  
  -- Accept current suggestion (only in normal mode to avoid conflicts)
  vim.keymap.set("n", state.config.ui.accept_key, function()
    M.accept_suggestion()
  end, opts)
  
  -- Dismiss suggestions (only in normal mode)
  vim.keymap.set("n", state.config.ui.dismiss_key, function()
    M.clear_suggestions()
  end, opts)
  
  -- Navigate suggestions with auto-apply on Tab
  vim.keymap.set("n", state.config.ui.next_key, function()
    M.next_suggestion_with_apply()
  end, opts)
  
  vim.keymap.set("n", state.config.ui.prev_key, function()
    M.prev_suggestion()
  end, opts)
  
  -- Apply all suggestions
  vim.keymap.set("n", state.config.ui.apply_all_key, function()
    M.apply_all_suggestions()
  end, opts)
  
  -- Undo last applied suggestion
  vim.keymap.set("n", "<leader>u", function()
    M.undo_last_suggestion()
  end, vim.tbl_extend("force", opts, { desc = "Undo last suggestion" }))
end

-- Detect symbol changes and suggest related edits
function M.detect_symbol_changes()
  if state.timer then
    state.timer:stop()
  end
  
  state.timer = vim.defer_fn(function()
    M.analyze_recent_changes()
  end, state.config.debounce_ms)
end

-- Analyze recent changes to detect symbol renames
function M.analyze_recent_changes()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local col = cursor[2]
  
  -- Get the word that was just changed
  local current_word = utils.get_word_under_cursor(bufnr, line, col)
  if not current_word or #current_word < 2 then
    return
  end
  
  -- Check if this looks like a variable/symbol rename
  local change_info = M.detect_symbol_rename(bufnr, line, col, current_word)
  if not change_info then
    return
  end
  
  -- Find all related occurrences of the old symbol
  local related_edits = M.find_related_edits(bufnr, change_info)
  if #related_edits > 0 then
    M.display_edit_suggestions(related_edits, change_info)
  end
end

-- Detect if a symbol was renamed
function M.detect_symbol_rename(bufnr, line, col, new_name)
  -- Get previous buffer state (simplified - would need proper diff tracking)
  local current_line = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1] or ""
  
  -- Simple heuristic: if we're on a word that looks like an identifier
  if not new_name:match("^[%a_][%w_]*$") then
    return nil
  end
  
  -- For now, assume any identifier change is a potential rename
  -- In a real implementation, we'd track the previous state
  return {
    old_name = nil, -- Would be tracked from previous state
    new_name = new_name,
    line = line,
    col = col,
    type = "variable" -- Could be "function", "class", etc.
  }
end

-- Find related edits that should be suggested (optimized with chunked processing)
function M.find_related_edits(bufnr, change_info)
  local related_edits = {}
  local new_name = change_info.new_name
  local current_line = change_info.line
  local total_lines = vim.api.nvim_buf_line_count(bufnr)
  
  -- Process in chunks for better performance
  local chunk_size = 50
  local processed_lines = 0
  
  -- Start with nearby lines first (within 20 lines)
  local nearby_range = 20
  local start_nearby = math.max(0, current_line - nearby_range)
  local end_nearby = math.min(total_lines - 1, current_line + nearby_range)
  
  -- Process nearby lines first
  local nearby_lines = vim.api.nvim_buf_get_lines(bufnr, start_nearby, end_nearby + 1, false)
  for i, line_content in ipairs(nearby_lines) do
    local line_num = start_nearby + i - 1
    
    -- Skip the line where the change was made
    if line_num ~= current_line then
      local matches = M.find_identifier_matches(line_content, new_name, line_num)
      for _, match in ipairs(matches) do
        match.distance = math.abs(line_num - current_line)
        match.priority = "nearby"
        table.insert(related_edits, match)
      end
    end
  end
  
  -- Process remaining lines in chunks (async-like with vim.schedule)
  local function process_chunk(start_line, end_line)
    if start_line >= total_lines then
      -- Finished processing, sort by distance
      table.sort(related_edits, function(a, b)
        if a.priority ~= b.priority then
          return a.priority == "nearby"
        end
        return a.distance < b.distance
      end)
      
      -- Limit to max suggestions
      local max_suggestions = state.config.max_suggestions or 10
      if #related_edits > max_suggestions then
        for i = max_suggestions + 1, #related_edits do
          related_edits[i] = nil
        end
      end
      
      -- Display results if we found any
      if #related_edits > 0 then
        M.display_edit_suggestions(related_edits, change_info)
      end
      return
    end
    
    local chunk_end = math.min(end_line, total_lines - 1)
    local chunk_lines = vim.api.nvim_buf_get_lines(bufnr, start_line, chunk_end + 1, false)
    
    for i, line_content in ipairs(chunk_lines) do
      local line_num = start_line + i - 1
      
      -- Skip already processed nearby lines and the change line
      if (line_num < start_nearby or line_num > end_nearby) and line_num ~= current_line then
        local matches = M.find_identifier_matches(line_content, new_name, line_num)
        for _, match in ipairs(matches) do
          match.distance = math.abs(line_num - current_line)
          match.priority = "distant"
          table.insert(related_edits, match)
        end
      end
    end
    
    -- Schedule next chunk
    vim.schedule(function()
      process_chunk(chunk_end + 1, chunk_end + chunk_size)
    end)
  end
  
  -- Start processing distant chunks
  if start_nearby > 0 or end_nearby < total_lines - 1 then
    vim.schedule(function()
      process_chunk(0, start_nearby - 1)
    end)
    vim.schedule(function()
      process_chunk(end_nearby + 1, end_nearby + chunk_size)
    end)
  else
    -- Only nearby lines exist, process immediately
    table.sort(related_edits, function(a, b) return a.distance < b.distance end)
    if #related_edits > 0 then
      M.display_edit_suggestions(related_edits, change_info)
    end
  end
  
  return related_edits
end

-- Find identifier matches in a line
function M.find_identifier_matches(line_content, identifier, line_num)
  local matches = {}
  local pattern = "%f[%w_]" .. vim.pesc(identifier) .. "%f[^%w_]"
  
  local start_pos = 1
  while true do
    local match_start, match_end = line_content:find(pattern, start_pos)
    if not match_start then break end
    
    table.insert(matches, {
      line = line_num,
      col_start = match_start - 1,
      col_end = match_end,
      text = identifier,
      type = "rename_suggestion"
    })
    
    start_pos = match_end + 1
  end
  
  return matches
end

-- Display edit suggestions (for next edits)
function M.display_edit_suggestions(related_edits, change_info)
  if not related_edits or #related_edits == 0 then
    return
  end
  
  state.current_suggestions = related_edits
  state.current_index = 1
  
  -- Display using UI module with edit context
  ui.show_edit_suggestions(related_edits, change_info)
end

-- Legacy function for backward compatibility
function M.display_suggestions(suggestions)
  if not suggestions or #suggestions == 0 then
    return
  end
  
  -- Convert to edit suggestions format
  M.display_edit_suggestions(suggestions, nil)
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

-- Navigate to next suggestion with auto-apply
function M.next_suggestion_with_apply()
  if #state.current_suggestions == 0 then
    return
  end
  
  -- Apply current suggestion first
  if state.current_index <= #state.current_suggestions then
    local current_suggestion = state.current_suggestions[state.current_index]
    if current_suggestion and not state.applied_suggestions[state.current_index] then
      M.apply_suggestion_with_undo(current_suggestion, state.current_index)
    end
  end
  
  -- Move to next suggestion
  if #state.current_suggestions > 1 then
    state.current_index = state.current_index + 1
    if state.current_index > #state.current_suggestions then
      state.current_index = 1
    end
    
    -- Update UI to highlight next suggestion
    ui.update_current_suggestion(state.current_index)
  else
    -- Only one suggestion, clear after applying
    M.clear_suggestions()
  end
end

-- Navigate to next suggestion (without auto-apply)
function M.next_suggestion()
  if #state.current_suggestions <= 1 then
    return
  end
  
  state.current_index = state.current_index + 1
  if state.current_index > #state.current_suggestions then
    state.current_index = 1
  end
  
  ui.update_current_suggestion(state.current_index)
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

-- Update cursor context for tracking changes
function M.update_cursor_context()
  -- Store current cursor position and context for change detection
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  
  state.last_cursor_pos = {
    line = cursor[1] - 1,
    col = cursor[2],
    bufnr = bufnr,
  }
end

-- Apply all suggestions at once
function M.apply_all_suggestions()
  if #state.current_suggestions == 0 then
    vim.notify("No suggestions to apply", vim.log.levels.WARN)
    return
  end
  
  local bufnr = vim.api.nvim_get_current_buf()
  local applied_count = 0
  
  -- Sort suggestions by line number (descending) to avoid offset issues
  local sorted_suggestions = vim.deepcopy(state.current_suggestions)
  table.sort(sorted_suggestions, function(a, b) return a.line > b.line end)
  
  for _, suggestion in ipairs(sorted_suggestions) do
    if M.apply_single_edit(bufnr, suggestion) then
      applied_count = applied_count + 1
    end
  end
  
  M.clear_suggestions()
  vim.notify(string.format("Applied %d edit suggestions", applied_count), vim.log.levels.INFO)
  
  -- Trigger user event
  vim.api.nvim_exec_autocmds("User", { pattern = "NextEditSuggestionsApplied" })
end

-- Apply a single edit suggestion with undo support
function M.apply_suggestion_with_undo(suggestion, index)
  local bufnr = vim.api.nvim_get_current_buf()
  
  if suggestion.type ~= "rename_suggestion" then
    return false
  end
  
  -- Get current line content
  local current_lines = vim.api.nvim_buf_get_lines(bufnr, suggestion.line, suggestion.line + 1, false)
  if #current_lines == 0 then
    return false
  end
  
  local line_content = current_lines[1]
  local old_text = line_content:sub(suggestion.col_start + 1, suggestion.col_end)
  
  -- Store undo information
  local undo_info = {
    bufnr = bufnr,
    line = suggestion.line,
    col_start = suggestion.col_start,
    col_end = suggestion.col_end,
    old_text = old_text,
    new_text = suggestion.text,
    original_line = line_content,
  }
  
  -- Apply the edit
  local new_line = line_content:sub(1, suggestion.col_start) .. 
                   suggestion.text .. 
                   line_content:sub(suggestion.col_end + 1)
  
  vim.api.nvim_buf_set_lines(bufnr, suggestion.line, suggestion.line + 1, false, {new_line})
  
  -- Track the change
  table.insert(state.undo_stack, undo_info)
  state.applied_suggestions[index] = true
  
  -- Update highlights to show applied change
  ui.mark_suggestion_applied(index)
  
  vim.notify(string.format("Applied: %s → %s (Line %d)", old_text, suggestion.text, suggestion.line + 1), vim.log.levels.INFO)
  return true
end

-- Apply a single edit suggestion (legacy function)
function M.apply_single_edit(bufnr, suggestion)
  return M.apply_suggestion_with_undo(suggestion, 1)
end

-- Undo the last applied suggestion
function M.undo_last_suggestion()
  if #state.undo_stack == 0 then
    vim.notify("No suggestions to undo", vim.log.levels.WARN)
    return
  end
  
  local undo_info = table.remove(state.undo_stack)
  
  -- Restore the original line
  vim.api.nvim_buf_set_lines(undo_info.bufnr, undo_info.line, undo_info.line + 1, false, {undo_info.original_line})
  
  vim.notify(string.format("Undone: %s → %s (Line %d)", undo_info.new_text, undo_info.old_text, undo_info.line + 1), vim.log.levels.INFO)
  
  -- Update UI if suggestions are still active
  if #state.current_suggestions > 0 then
    ui.refresh_suggestions()
  end
end

-- Clear all suggestions
function M.clear_suggestions()
  state.current_suggestions = {}
  state.current_index = 1
  state.applied_suggestions = {} -- Reset applied suggestions
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