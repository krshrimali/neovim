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
  -- Virtual lines highlights (slightly dimmed for readability)
  vim.api.nvim_set_hl(0, "CocVirtualLineError", { fg = "#f38ba8", italic = true })
  vim.api.nvim_set_hl(0, "CocVirtualLineWarn", { fg = "#fab387", italic = true })
  vim.api.nvim_set_hl(0, "CocVirtualLineInfo", { fg = "#89b4fa", italic = true })
  vim.api.nvim_set_hl(0, "CocVirtualLineHint", { fg = "#94e2d5", italic = true })
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

  -- Render virtual lines
  for lnum, line_diags in pairs(diag_by_line) do
    -- Sort by severity (Error > Warning > Info > Hint)
    table.sort(line_diags, function(a, b)
      local order = { Error = 1, Warning = 2, Information = 3, Hint = 4 }
      return (order[a.severity] or 5) < (order[b.severity] or 5)
    end)

    -- Create virtual lines for each diagnostic
    local virt_lines = {}
    for i, diag in ipairs(line_diags) do
      local msg = format_message(diag, max_width)
      local hl = get_virtual_line_hl(diag.severity)

      -- Add indentation for better readability
      local indent = "  "
      if i > 1 then indent = "  " end -- Same indent for all

      table.insert(virt_lines, { { indent .. msg, hl } })
    end

    -- Set virtual lines (below the line with the diagnostic)
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
