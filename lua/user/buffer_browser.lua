-- Standalone Buffer Browser Utility
-- No external dependencies required
local M = {}

-- Function to sort buffers by recently opened (MRU - Most Recently Used)
M.get_sorted_buffers = function()
  local buffers = {}
  local buf_list = vim.api.nvim_list_bufs()
  
  for _, buf in ipairs(buf_list) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" then
        table.insert(buffers, {
          bufnr = buf,
          name = name,
          lastused = vim.fn.getbufinfo(buf)[1].lastused or 0
        })
      end
    end
  end
  
  -- Sort by lastused (most recent first)
  table.sort(buffers, function(a, b)
    return a.lastused > b.lastused
  end)
  
  return buffers
end

-- Enhanced buffer browser with custom sidebar
M.open_buffer_browser = function()
  local buffers = M.get_sorted_buffers()
  
  if #buffers == 0 then
    vim.notify("No buffers available", vim.log.levels.INFO)
    return
  end
  
  -- Create a floating window for buffer selection with increased height
  local width = math.floor(vim.o.columns * 0.4)
  local height = math.min(#buffers + 6, math.floor(vim.o.lines * 0.9))  -- Increased from 0.8 to 0.9 and added more padding
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  -- Create buffer for the menu
  local buf = vim.api.nvim_create_buf(false, true)
  
  -- Prepare buffer content
  local lines = { "📁 Buffer Browser (Recently Used)" }
  table.insert(lines, string.rep("─", width - 2))
  
  for i, buffer in ipairs(buffers) do
    local filename = vim.fn.fnamemodify(buffer.name, ":t")
    local dir = vim.fn.fnamemodify(buffer.name, ":h:t")
    local indicator = buffer.bufnr == vim.api.nvim_get_current_buf() and "●" or " "
    local modified = vim.bo[buffer.bufnr].modified and "[+]" or "   "
    local line = string.format("%s %d. %s%s (%s)", indicator, i, filename, modified, dir)
    table.insert(lines, line)
  end
  
  -- Add help section
  table.insert(lines, "")
  table.insert(lines, "Keys: <CR>=open, d=delete, s=split, v=vsplit, q=quit")
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Create floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Buffer Browser ",
    title_pos = "center"
  })
  
  -- Set buffer options
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
  vim.wo[win].cursorline = true
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  
  -- Set up keymaps for the buffer browser
  local opts = { buffer = buf, silent = true }
  
  -- Close with q or Escape
  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, opts)
  
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, opts)
  
  -- Select buffer with Enter
  vim.keymap.set("n", "<CR>", function()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    if line > 2 and line <= #buffers + 2 then
      local buffer = buffers[line - 2]
      vim.api.nvim_win_close(win, true)
      vim.api.nvim_set_current_buf(buffer.bufnr)
    end
  end, opts)
  
  -- Delete buffer with 'd'
  vim.keymap.set("n", "d", function()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    if line > 2 and line <= #buffers + 2 then
      local buffer = buffers[line - 2]
      vim.api.nvim_buf_delete(buffer.bufnr, { force = false })
      vim.api.nvim_win_close(win, true)
      -- Reopen the browser with updated list
      vim.defer_fn(M.open_buffer_browser, 50)
    end
  end, opts)
  
  -- Split horizontally with 's'
  vim.keymap.set("n", "s", function()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    if line > 2 and line <= #buffers + 2 then
      local buffer = buffers[line - 2]
      vim.api.nvim_win_close(win, true)
      vim.cmd("split")
      vim.api.nvim_set_current_buf(buffer.bufnr)
    end
  end, opts)
  
  -- Split vertically with 'v'
  vim.keymap.set("n", "v", function()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    if line > 2 and line <= #buffers + 2 then
      local buffer = buffers[line - 2]
      vim.api.nvim_win_close(win, true)
      vim.cmd("vsplit")
      vim.api.nvim_set_current_buf(buffer.bufnr)
    end
  end, opts)
  
  -- Number keys for quick selection
  for i = 1, math.min(9, #buffers) do
    vim.keymap.set("n", tostring(i), function()
      local buffer = buffers[i]
      vim.api.nvim_win_close(win, true)
      vim.api.nvim_set_current_buf(buffer.bufnr)
    end, opts)
  end
  
  -- Position cursor on first buffer
  if #buffers > 0 then
    vim.api.nvim_win_set_cursor(win, { 3, 0 })
  end
end

-- Global state for sidebar management
M._sidebar_state = {
  win = nil,
  buf = nil,
  is_open = false,
  width = 30  -- Store the sidebar width
}

-- Function to refresh sidebar content
M.refresh_sidebar = function()
  if not M._sidebar_state.is_open or not M._sidebar_state.win or not vim.api.nvim_win_is_valid(M._sidebar_state.win) then
    return
  end
  
  local buffers = M.get_sorted_buffers()
  if #buffers == 0 then
    return
  end
  
  -- Update buffer content
  local lines = { "📁 Buffers (Recent)" }
  table.insert(lines, string.rep("─", 25))
  table.insert(lines, "Keys: <CR>=open, d=delete")
  table.insert(lines, "r=refresh, +=wider, -=narrower")
  table.insert(lines, string.rep("─", 25))
  
  for i, buffer in ipairs(buffers) do
    local filename = vim.fn.fnamemodify(buffer.name, ":t")
    local indicator = buffer.bufnr == vim.api.nvim_get_current_buf() and "●" or " "
    local modified = vim.bo[buffer.bufnr].modified and "+" or " "
    local line = string.format("%s%s %s", indicator, modified, filename)
    table.insert(lines, line)
  end
  
  -- Update the buffer content
  vim.bo[M._sidebar_state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(M._sidebar_state.buf, 0, -1, false, lines)
  vim.bo[M._sidebar_state.buf].modifiable = false
  
  -- Store buffers for keymap access
  M._sidebar_state.buffers = buffers
end

-- Function to create a sidebar buffer browser (persistent)
M.toggle_sidebar = function()
  -- If sidebar is open, close it
  if M._sidebar_state.is_open and M._sidebar_state.win and vim.api.nvim_win_is_valid(M._sidebar_state.win) then
    -- Store the current width before closing
    M._sidebar_state.width = vim.api.nvim_win_get_width(M._sidebar_state.win)
    vim.api.nvim_win_close(M._sidebar_state.win, true)
    M._sidebar_state.is_open = false
    M._sidebar_state.win = nil
    M._sidebar_state.buf = nil
    return
  end
  
  -- Create new sidebar
  local buffers = M.get_sorted_buffers()
  
  if #buffers == 0 then
    vim.notify("No buffers available", vim.log.levels.INFO)
    return
  end
  
  -- Create a new buffer for the sidebar
  local buf = vim.api.nvim_create_buf(false, true)
  M._sidebar_state.buf = buf
  
  -- Prepare content
  local lines = { "📁 Buffers (Recent)" }
  table.insert(lines, string.rep("─", 25))
  table.insert(lines, "Keys: <CR>=open, d=delete")
  table.insert(lines, "r=refresh, +=wider, -=narrower")
  table.insert(lines, string.rep("─", 25))
  
  for i, buffer in ipairs(buffers) do
    local filename = vim.fn.fnamemodify(buffer.name, ":t")
    local indicator = buffer.bufnr == vim.api.nvim_get_current_buf() and "●" or " "
    local modified = vim.bo[buffer.bufnr].modified and "+" or " "
    local line = string.format("%s%s %s", indicator, modified, filename)
    table.insert(lines, line)
  end
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- Create sidebar window (left side) with preserved width
  vim.cmd("topleft " .. M._sidebar_state.width .. "vnew")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  
  -- Store window reference
  M._sidebar_state.win = win
  M._sidebar_state.is_open = true
  M._sidebar_state.buffers = buffers
  
  -- Set buffer options
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false
  vim.wo[win].cursorline = true
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].wrap = false
  vim.wo[win].winfixwidth = true  -- Fix the width to prevent automatic resizing
  
  -- Set up keymaps for the sidebar
  local opts = { buffer = buf, silent = true }
  
  -- Close with q
  vim.keymap.set("n", "q", function()
    M.toggle_sidebar() -- Use toggle to properly clean up state
  end, opts)
  
  -- Refresh with r
  vim.keymap.set("n", "r", function()
    M.refresh_sidebar()
  end, opts)
  
  -- Resize sidebar with + and -
  vim.keymap.set("n", "+", function()
    if M._sidebar_state.win and vim.api.nvim_win_is_valid(M._sidebar_state.win) then
      M._sidebar_state.width = M._sidebar_state.width + 5
      vim.api.nvim_win_set_width(M._sidebar_state.win, M._sidebar_state.width)
    end
  end, opts)
  
  vim.keymap.set("n", "-", function()
    if M._sidebar_state.win and vim.api.nvim_win_is_valid(M._sidebar_state.win) then
      M._sidebar_state.width = math.max(15, M._sidebar_state.width - 5)  -- Minimum width of 15
      vim.api.nvim_win_set_width(M._sidebar_state.win, M._sidebar_state.width)
    end
  end, opts)
  
  -- Select buffer with Enter
  vim.keymap.set("n", "<CR>", function()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    if line > 5 and line <= #M._sidebar_state.buffers + 5 then
      local buffer = M._sidebar_state.buffers[line - 5]
      -- Switch to previous window and open buffer
      vim.cmd("wincmd p")
      vim.api.nvim_set_current_buf(buffer.bufnr)
      -- Refresh sidebar to update current buffer indicator
      M.refresh_sidebar()
    end
  end, opts)
  
  -- Delete buffer with 'd'
  vim.keymap.set("n", "d", function()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    if line > 5 and line <= #M._sidebar_state.buffers + 5 then
      local buffer = M._sidebar_state.buffers[line - 5]
      vim.api.nvim_buf_delete(buffer.bufnr, { force = false })
      -- Refresh the sidebar content
      M.refresh_sidebar()
    end
  end, opts)
  
  -- Position cursor on first buffer
  if #buffers > 0 then
    vim.api.nvim_win_set_cursor(win, { 6, 0 })
  end
  
  -- Set up autocommands to refresh sidebar when buffers change
  local augroup = vim.api.nvim_create_augroup("BufferSidebar", { clear = true })
  
  vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "BufDelete", "BufWritePost" }, {
    group = augroup,
    callback = function()
      -- Small delay to ensure buffer operations are complete
      vim.defer_fn(function()
        M.refresh_sidebar()
        -- Ensure width is maintained after buffer operations
        if M._sidebar_state.win and vim.api.nvim_win_is_valid(M._sidebar_state.win) then
          vim.api.nvim_win_set_width(M._sidebar_state.win, M._sidebar_state.width)
        end
      end, 10)
    end,
  })
  
  -- Clean up autocommands when sidebar is closed
  vim.api.nvim_create_autocmd("WinClosed", {
    group = augroup,
    pattern = tostring(win),
    callback = function()
      -- Store the width before cleanup
      if vim.api.nvim_win_is_valid(M._sidebar_state.win) then
        M._sidebar_state.width = vim.api.nvim_win_get_width(M._sidebar_state.win)
      end
      M._sidebar_state.is_open = false
      M._sidebar_state.win = nil
      M._sidebar_state.buf = nil
      vim.api.nvim_del_augroup_by_id(augroup)
    end,
  })
end

return M