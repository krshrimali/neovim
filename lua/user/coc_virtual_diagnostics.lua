-- CoC Virtual Diagnostics Plugin
-- Provides virtual lines and virtual text for CoC diagnostics
-- Optimized for performance with caching and debouncing

local M = {}

-- State management
local state = {
  virtual_lines_enabled = false,
  virtual_text_enabled = false,
  namespace = vim.api.nvim_create_namespace "coc_virtual_diagnostics",
  virtual_lines_ns = vim.api.nvim_create_namespace "coc_virtual_lines",
  virtual_text_ns = vim.api.nvim_create_namespace "coc_virtual_text",
  cache = {}, -- Cache diagnostics per buffer
  timer = nil,
  debounce_ms = 100,
}

-- Diagnostic severity to highlight group mapping
local severity_hl = {
  Error = "DiagnosticVirtualTextError",
  Warning = "DiagnosticVirtualTextWarn",
  Information = "DiagnosticVirtualTextInfo",
  Hint = "DiagnosticVirtualTextHint",
}

local severity_prefix = {
  Error = "✘",
  Warning = "▲",
  Information = "ℹ",
  Hint = "➤",
}

-- Setup custom highlight groups for virtual lines
local function setup_highlights()
  -- Virtual lines highlights (dimmed and italic for clear distinction from code)
  vim.api.nvim_set_hl(0, "CocVirtualLineError", { fg = "#f38ba8", bg = "NONE", italic = true, blend = 50 })
  vim.api.nvim_set_hl(0, "CocVirtualLineWarn", { fg = "#fab387", bg = "NONE", italic = true, blend = 50 })
  vim.api.nvim_set_hl(0, "CocVirtualLineInfo", { fg = "#89b4fa", bg = "NONE", italic = true, blend = 50 })
  vim.api.nvim_set_hl(0, "CocVirtualLineHint", { fg = "#94e2d5", bg = "NONE", italic = true, blend = 50 })
end

-- Get diagnostics from CoC for the current buffer
local function get_coc_diagnostics(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Check if CoC is ready
  if vim.fn.exists "*CocAction" == 0 then return {} end

  -- Get diagnostics from CoC
  local diagnostics = vim.fn.CocAction "diagnosticList"
  if type(diagnostics) ~= "table" then return {} end

  -- Filter diagnostics for the current buffer
  local buf_name = vim.api.nvim_buf_get_name(bufnr)
  local filtered = {}

  for _, diag in ipairs(diagnostics) do
    if diag.file == buf_name then
      table.insert(filtered, {
        lnum = diag.lnum - 1, -- CoC is 1-indexed, Neovim API is 0-indexed
        col = diag.col - 1,
        severity = diag.severity,
        message = diag.message,
        source = diag.source or "coc",
      })
    end
  end

  return filtered
end

-- Format diagnostic message for display
local function format_message(diag, max_width)
  max_width = max_width or 80
  local prefix = severity_prefix[diag.severity] or "●"
  local source = diag.source and ("[" .. diag.source .. "]") or ""
  local message = diag.message

  -- Truncate if too long
  local full_msg = string.format("%s %s %s", prefix, source, message)
  if #full_msg > max_width then full_msg = full_msg:sub(1, max_width - 3) .. "..." end

  return full_msg
end

-- Get highlight group for severity
local function get_virtual_line_hl(severity)
  local hl_map = {
    Error = "CocVirtualLineError",
    Warning = "CocVirtualLineWarn",
    Information = "CocVirtualLineInfo",
    Hint = "CocVirtualLineHint",
  }
  return hl_map[severity] or "CocVirtualLineInfo"
end

-- Clear all virtual diagnostics for a buffer
local function clear_virtual_diagnostics(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then return end

  -- Clear virtual lines
  vim.api.nvim_buf_clear_namespace(bufnr, state.virtual_lines_ns, 0, -1)

  -- Clear virtual text
  vim.api.nvim_buf_clear_namespace(bufnr, state.virtual_text_ns, 0, -1)
end

-- Render virtual lines for diagnostics
local function render_virtual_lines(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then return end

  -- Clear existing virtual lines
  vim.api.nvim_buf_clear_namespace(bufnr, state.virtual_lines_ns, 0, -1)

  if not state.virtual_lines_enabled then return end

  local diagnostics = get_coc_diagnostics(bufnr)
  if #diagnostics == 0 then return end

  -- Get window width for wrapping
  local win = vim.fn.bufwinid(bufnr)
  local win_width = win ~= -1 and vim.api.nvim_win_get_width(win) or 80
  local max_width = math.min(win_width - 10, 100) -- Leave some padding

  -- Group diagnostics by line
  local diag_by_line = {}
  for _, diag in ipairs(diagnostics) do
    local lnum = diag.lnum
    if not diag_by_line[lnum] then diag_by_line[lnum] = {} end
    table.insert(diag_by_line[lnum], diag)
  end

  -- Render virtual lines in tree structure below the line
  for lnum, line_diags in pairs(diag_by_line) do
    -- Sort by severity (Error > Warning > Info > Hint)
    table.sort(line_diags, function(a, b)
      local order = { Error = 1, Warning = 2, Information = 3, Hint = 4 }
      return (order[a.severity] or 5) < (order[b.severity] or 5)
    end)

    -- Create tree-structured virtual lines
    local virt_lines = {}
    for i, diag in ipairs(line_diags) do
      local msg = format_message(diag, max_width)
      local hl = get_virtual_line_hl(diag.severity)

      -- Tree structure: first item uses ├─, last item uses └─, middle items use ├─
      local prefix
      if #line_diags == 1 then
        prefix = "  └─ "
      elseif i == #line_diags then
        prefix = "  └─ "
      else
        prefix = "  ├─ "
      end

      table.insert(virt_lines, { { prefix .. msg, hl } })
    end

    -- Set virtual lines below the line with the diagnostic
    pcall(vim.api.nvim_buf_set_extmark, bufnr, state.virtual_lines_ns, lnum, 0, {
      virt_lines = virt_lines,
      virt_lines_above = false,
    })
  end
end

-- Render virtual text for diagnostics
local function render_virtual_text(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then return end

  -- Clear existing virtual text
  vim.api.nvim_buf_clear_namespace(bufnr, state.virtual_text_ns, 0, -1)

  if not state.virtual_text_enabled then return end

  local diagnostics = get_coc_diagnostics(bufnr)
  if #diagnostics == 0 then return end

  -- Group diagnostics by line
  local diag_by_line = {}
  for _, diag in ipairs(diagnostics) do
    local lnum = diag.lnum
    if not diag_by_line[lnum] then diag_by_line[lnum] = {} end
    table.insert(diag_by_line[lnum], diag)
  end

  -- Render virtual text
  for lnum, line_diags in pairs(diag_by_line) do
    -- Sort by severity
    table.sort(line_diags, function(a, b)
      local order = { Error = 1, Warning = 2, Information = 3, Hint = 4 }
      return (order[a.severity] or 5) < (order[b.severity] or 5)
    end)

    -- Show only the first (most severe) diagnostic as virtual text
    local diag = line_diags[1]
    local prefix = severity_prefix[diag.severity] or "●"
    local msg = diag.message

    -- Truncate message if too long
    local max_len = 60
    if #msg > max_len then msg = msg:sub(1, max_len - 3) .. "..." end

    local virt_text = string.format(" %s %s", prefix, msg)
    local hl = severity_hl[diag.severity] or "DiagnosticVirtualTextInfo"

    -- Set virtual text (at the end of the line)
    pcall(vim.api.nvim_buf_set_extmark, bufnr, state.virtual_text_ns, lnum, 0, {
      virt_text = { { virt_text, hl } },
      virt_text_pos = "eol",
    })
  end
end

-- Update virtual diagnostics (debounced)
local function update_virtual_diagnostics(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Cancel previous timer
  if state.timer then
    state.timer:stop()
    state.timer = nil
  end

  -- Debounce updates
  state.timer = vim.defer_fn(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then return end

    -- Update based on enabled features
    if state.virtual_lines_enabled then render_virtual_lines(bufnr) end

    if state.virtual_text_enabled then render_virtual_text(bufnr) end

    state.timer = nil
  end, state.debounce_ms)
end

-- Toggle virtual lines
function M.toggle_virtual_lines()
  state.virtual_lines_enabled = not state.virtual_lines_enabled

  if state.virtual_lines_enabled then
    vim.notify("Virtual lines enabled", vim.log.levels.INFO)
    update_virtual_diagnostics()
  else
    vim.notify("Virtual lines disabled", vim.log.levels.INFO)
    clear_virtual_diagnostics()
  end
end

-- Toggle virtual text
function M.toggle_virtual_text()
  state.virtual_text_enabled = not state.virtual_text_enabled

  if state.virtual_text_enabled then
    vim.notify("Virtual text enabled", vim.log.levels.INFO)
    update_virtual_diagnostics()
  else
    vim.notify("Virtual text disabled", vim.log.levels.INFO)
    clear_virtual_diagnostics()
  end
end

-- Refresh diagnostics manually
function M.refresh() update_virtual_diagnostics() end

-- Show diagnostics for current line in a floating window
function M.show_line_diagnostics()
  -- Check if CoC is ready
  if vim.fn.exists "*CocAction" == 0 then
    vim.notify("CoC is not available", vim.log.levels.WARN)
    return
  end

  -- Get all diagnostics and filter by current line
  local bufnr = vim.api.nvim_get_current_buf()
  local lnum = vim.api.nvim_win_get_cursor(0)[1] -- 1-indexed
  local all_diags = get_coc_diagnostics(bufnr)

  local line_diags = {}
  for _, diag in ipairs(all_diags) do
    if diag.lnum == lnum - 1 then -- get_coc_diagnostics returns 0-indexed
      table.insert(line_diags, {
        severity = diag.severity,
        message = diag.message,
        source = diag.source,
      })
    end
  end

  if #line_diags == 0 then
    vim.notify("No diagnostics on current line", vim.log.levels.INFO)
    return
  end

  -- Normalize severity to number if it's a string
  local function normalize_severity(sev)
    if type(sev) == "number" then
      return sev
    elseif type(sev) == "string" then
      local str_to_num = { Error = 0, Warning = 1, Information = 2, Hint = 3 }
      return str_to_num[sev] or 2
    end
    return 2 -- default to Info
  end

  -- Sort by severity (lower number = higher severity in CoC)
  table.sort(line_diags, function(a, b)
    local sev_a = normalize_severity(a.severity)
    local sev_b = normalize_severity(b.severity)
    return sev_a < sev_b
  end)

  -- Build content for floating window
  local lines = {}
  local highlights = {}

  -- Severity mapping (CoC uses numbers: 0=Error, 1=Warning, 2=Info, 3=Hint)
  local severity_map = {
    [0] = { name = "Error", hl = "CocVirtualLineError", prefix = "✘" },
    [1] = { name = "Warning", hl = "CocVirtualLineWarn", prefix = "▲" },
    [2] = { name = "Information", hl = "CocVirtualLineInfo", prefix = "ℹ" },
    [3] = { name = "Hint", hl = "CocVirtualLineHint", prefix = "➤" },
  }

  for i, diag in ipairs(line_diags) do
    local sev_num = normalize_severity(diag.severity)
    local sev = severity_map[sev_num] or severity_map[2]
    local source = diag.source and ("[" .. diag.source .. "]") or ""

    -- Add header line
    local header = string.format("%s %s %s", sev.prefix, sev.name, source)
    table.insert(lines, header)
    table.insert(highlights, { line = #lines - 1, hl_group = sev.hl })

    -- Add message lines (support multi-line messages)
    local msg_lines = vim.split(diag.message, "\n")
    for _, msg_line in ipairs(msg_lines) do
      table.insert(lines, "  " .. msg_line)
    end

    -- Add separator between diagnostics
    if i < #line_diags then table.insert(lines, "") end
  end

  -- Create a buffer for the floating window
  local float_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(float_bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(float_bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(float_bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(float_bufnr, "filetype", "diagnostic")

  -- Calculate window size
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  width = math.min(width + 4, vim.o.columns - 10)
  local height = math.min(#lines, vim.o.lines - 10)

  -- Create floating window
  local win_opts = {
    relative = "cursor",
    row = 1,
    col = 0,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    focusable = true,
  }

  local ok, float_win = pcall(vim.api.nvim_open_win, float_bufnr, true, win_opts)
  if not ok then
    vim.notify("Failed to create window: " .. tostring(float_win), vim.log.levels.ERROR)
    return
  end

  -- Apply highlights
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(float_bufnr, -1, hl.hl_group, hl.line, 0, -1)
  end

  -- Set up keymaps to close the window
  local close_keys = { "q", "<Esc>" }
  for _, key in ipairs(close_keys) do
    vim.api.nvim_buf_set_keymap(
      float_bufnr,
      "n",
      key,
      string.format(":lua vim.api.nvim_win_close(%d, true)<CR>", float_win),
      { noremap = true, silent = true }
    )
  end

  -- Auto-close on buffer leave only (not cursor move)
  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = float_bufnr,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(float_win) then vim.api.nvim_win_close(float_win, true) end
    end,
  })
end

-- Setup the plugin
function M.setup(opts)
  opts = opts or {}

  -- Setup highlights
  setup_highlights()

  -- Set initial state from opts
  state.virtual_lines_enabled = opts.virtual_lines_enabled or false
  state.virtual_text_enabled = opts.virtual_text_enabled or false
  state.debounce_ms = opts.debounce_ms or 100

  -- Auto-refresh on CoC diagnostic updates
  vim.api.nvim_create_autocmd("User", {
    pattern = "CocDiagnosticChange",
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      update_virtual_diagnostics(bufnr)
    end,
  })

  -- Refresh on buffer enter
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      -- Small delay to ensure CoC has updated diagnostics
      vim.defer_fn(function() update_virtual_diagnostics(bufnr) end, 50)
    end,
  })

  -- Clear on buffer leave/delete
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    callback = function(args) clear_virtual_diagnostics(args.buf) end,
  })

  -- Refresh on cursor hold (when idle)
  vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      update_virtual_diagnostics(bufnr)
    end,
  })

  -- Re-apply highlights on colorscheme change
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function() setup_highlights() end,
  })
end

-- Get current state (for debugging)
function M.get_state() return state end

return M
