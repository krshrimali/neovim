local M = {}

-- Module state
local state = {
  config = {},
  namespace = nil,
  current_extmark = nil,
  popup_win = nil,
  popup_buf = nil,
  ghost_text_extmark = nil,
}

-- Setup UI module
function M.setup(config, namespace)
  state.config = config or {}
  state.namespace = namespace
end

-- Show suggestions with Cursor-like UI
function M.show_suggestions(suggestion)
  if not suggestion then
    return
  end
  
  M.clear_suggestions()
  
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local col = cursor[2]
  
  if state.config.ghost_text then
    M.show_ghost_text(suggestion, bufnr, line, col)
  end
  
  if state.config.inline_suggestions and #suggestion.lines > 1 then
    M.show_popup_suggestion(suggestion, bufnr, line, col)
  end
end

-- Show ghost text (inline suggestion like Cursor)
function M.show_ghost_text(suggestion, bufnr, line, col)
  local text = suggestion.text
  
  -- For single-line suggestions, show as ghost text
  if suggestion.type == "inline" or #suggestion.lines == 1 then
    -- Get the current line content
    local current_line = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1] or ""
    
    -- Extract the completion part after cursor
    local completion = text
    if text:find(vim.pesc(current_line:sub(col + 1))) then
      -- If suggestion contains current text after cursor, extract only the new part
      local after_cursor = current_line:sub(col + 1)
      if text:sub(1, #after_cursor) == after_cursor then
        completion = text:sub(#after_cursor + 1)
      end
    end
    
    if completion and completion ~= "" then
      state.ghost_text_extmark = vim.api.nvim_buf_set_extmark(bufnr, state.namespace, line, col, {
        virt_text = {{completion, state.config.highlight_group}},
        virt_text_pos = "inline",
        hl_mode = "combine",
      })
    end
  else
    -- For multi-line suggestions, show first line as ghost text
    local first_line = suggestion.lines[1] or ""
    if first_line ~= "" then
      state.ghost_text_extmark = vim.api.nvim_buf_set_extmark(bufnr, state.namespace, line, col, {
        virt_text = {{first_line, state.config.highlight_group}},
        virt_text_pos = "inline",
        hl_mode = "combine",
      })
    end
  end
end

-- Show popup suggestion for multi-line suggestions
function M.show_popup_suggestion(suggestion, bufnr, line, col)
  if #suggestion.lines <= 1 then
    return
  end
  
  -- Create popup buffer
  state.popup_buf = vim.api.nvim_create_buf(false, true)
  
  -- Set buffer content
  vim.api.nvim_buf_set_lines(state.popup_buf, 0, -1, false, suggestion.lines)
  
  -- Set buffer options
  vim.api.nvim_buf_set_option(state.popup_buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(state.popup_buf, "filetype", vim.bo[bufnr].filetype)
  
  -- Calculate popup position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local win_config = {
    relative = "cursor",
    row = 1,
    col = 0,
    width = math.min(80, math.max(unpack(vim.tbl_map(function(l) return #l end, suggestion.lines)))),
    height = math.min(10, #suggestion.lines),
    style = "minimal",
    border = state.config.popup_border or "rounded",
    focusable = false,
  }
  
  -- Create popup window
  state.popup_win = vim.api.nvim_open_win(state.popup_buf, false, win_config)
  
  -- Set window highlights
  vim.api.nvim_win_set_option(state.popup_win, "winhl", "Normal:CopilotSuggestion,FloatBorder:CopilotSuggestionBorder")
  
  -- Add suggestion indicator
  vim.api.nvim_buf_set_extmark(state.popup_buf, state.namespace, 0, 0, {
    virt_text = {{"󰧑 Copilot", "CopilotSuggestionBorder"}},
    virt_text_pos = "right_align",
  })
end

-- Accept current suggestion
function M.accept_suggestion(suggestion)
  if not suggestion then
    return false
  end
  
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local col = cursor[2]
  
  if suggestion.type == "inline" then
    -- Insert inline suggestion
    local current_line = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1] or ""
    local new_line = current_line:sub(1, col) .. suggestion.text .. current_line:sub(col + 1)
    
    vim.api.nvim_buf_set_lines(bufnr, line, line + 1, false, {new_line})
    
    -- Move cursor to end of inserted text
    vim.api.nvim_win_set_cursor(0, {line + 1, col + #suggestion.text})
  else
    -- Insert multi-line suggestion
    local current_line = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1] or ""
    local before_cursor = current_line:sub(1, col)
    local after_cursor = current_line:sub(col + 1)
    
    -- Prepare new lines
    local new_lines = {}
    for i, suggestion_line in ipairs(suggestion.lines) do
      if i == 1 then
        table.insert(new_lines, before_cursor .. suggestion_line)
      elseif i == #suggestion.lines then
        table.insert(new_lines, suggestion_line .. after_cursor)
      else
        table.insert(new_lines, suggestion_line)
      end
    end
    
    -- Replace current line with new lines
    vim.api.nvim_buf_set_lines(bufnr, line, line + 1, false, new_lines)
    
    -- Move cursor to end of suggestion
    local last_line_idx = line + #new_lines - 1
    local last_line = new_lines[#new_lines]
    local new_col = #last_line - #after_cursor
    vim.api.nvim_win_set_cursor(0, {last_line_idx + 1, new_col})
  end
  
  return true
end

-- Clear all suggestions
function M.clear_suggestions()
  local bufnr = vim.api.nvim_get_current_buf()
  
  -- Clear ghost text
  if state.ghost_text_extmark then
    vim.api.nvim_buf_del_extmark(bufnr, state.namespace, state.ghost_text_extmark)
    state.ghost_text_extmark = nil
  end
  
  -- Clear popup
  if state.popup_win and vim.api.nvim_win_is_valid(state.popup_win) then
    vim.api.nvim_win_close(state.popup_win, true)
    state.popup_win = nil
  end
  
  if state.popup_buf and vim.api.nvim_buf_is_valid(state.popup_buf) then
    vim.api.nvim_buf_delete(state.popup_buf, {force = true})
    state.popup_buf = nil
  end
  
  -- Clear any other extmarks
  vim.api.nvim_buf_clear_namespace(bufnr, state.namespace, 0, -1)
end

-- Show suggestion counter (like Cursor)
function M.show_suggestion_counter(current, total)
  if total <= 1 then
    return
  end
  
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  
  local counter_text = string.format("%d/%d", current, total)
  
  vim.api.nvim_buf_set_extmark(bufnr, state.namespace, line, 0, {
    virt_text = {{counter_text, "CopilotSuggestionBorder"}},
    virt_text_pos = "right_align",
    priority = 100,
  })
end

-- Show loading indicator
function M.show_loading()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local col = cursor[2]
  
  state.ghost_text_extmark = vim.api.nvim_buf_set_extmark(bufnr, state.namespace, line, col, {
    virt_text = {{"󰔟 Loading...", "CopilotSuggestionBorder"}},
    virt_text_pos = "inline",
    hl_mode = "combine",
  })
end

-- Hide loading indicator
function M.hide_loading()
  if state.ghost_text_extmark then
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_del_extmark(bufnr, state.namespace, state.ghost_text_extmark)
    state.ghost_text_extmark = nil
  end
end

-- Create floating window for settings/status
function M.show_status_window(status)
  local buf = vim.api.nvim_create_buf(false, true)
  
  local lines = {
    "Next Edit Suggestions Status",
    "═══════════════════════════",
    "",
    "Active: " .. (status.active and "✓" or "✗"),
    "Suggestions: " .. status.suggestions_count,
    "Current: " .. status.current_index,
    "",
    "Cache Stats:",
    "  Size: " .. (status.cache_stats.size or 0),
    "  Hits: " .. (status.cache_stats.hits or 0),
    "  Misses: " .. (status.cache_stats.misses or 0),
    "",
    "Press <Esc> to close",
  }
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = math.floor(vim.o.lines / 2) - 7,
    col = math.floor(vim.o.columns / 2) - 15,
    width = 30,
    height = #lines,
    style = "minimal",
    border = "rounded",
  })
  
  vim.api.nvim_win_set_option(win, "winhl", "Normal:Normal,FloatBorder:CopilotSuggestionBorder")
  
  -- Close on escape
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, {buffer = buf, nowait = true})
  
  return win
end

-- Animate suggestion appearance (subtle fade-in effect)
function M.animate_suggestion(suggestion, bufnr, line, col)
  -- This could be enhanced with more sophisticated animations
  -- For now, just show the suggestion normally
  M.show_ghost_text(suggestion, bufnr, line, col)
end

return M