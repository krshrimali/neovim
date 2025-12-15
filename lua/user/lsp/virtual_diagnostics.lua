-- Native LSP Virtual Diagnostics Plugin
-- Port of coc_virtual_diagnostics.lua for vim.diagnostic
-- Provides virtual lines and virtual text for LSP diagnostics
-- Optimized for performance with caching and debouncing

local M = {}

-- State management
local state = {
  virtual_lines_enabled = false,
  virtual_text_enabled = false,
  namespace = vim.api.nvim_create_namespace "lsp_virtual_diagnostics",
  virtual_lines_ns = vim.api.nvim_create_namespace "lsp_virtual_lines",
  virtual_text_ns = vim.api.nvim_create_namespace "lsp_virtual_text",
  timer = nil,
  debounce_ms = 100,
}

-- Diagnostic severity to highlight group mapping
local severity_hl = {
  [vim.diagnostic.severity.ERROR] = "DiagnosticVirtualTextError",
  [vim.diagnostic.severity.WARN] = "DiagnosticVirtualTextWarn",
  [vim.diagnostic.severity.INFO] = "DiagnosticVirtualTextInfo",
  [vim.diagnostic.severity.HINT] = "DiagnosticVirtualTextHint",
}

local severity_prefix = {
  [vim.diagnostic.severity.ERROR] = "✘",
  [vim.diagnostic.severity.WARN] = "▲",
  [vim.diagnostic.severity.INFO] = "ℹ",
  [vim.diagnostic.severity.HINT] = "➤",
}

-- Setup custom highlight groups for virtual lines
local function setup_highlights()
  -- Virtual lines highlights (dimmed and italic for clear distinction from code)
  vim.api.nvim_set_hl(0, "LspVirtualLineError", { fg = "#f38ba8", italic = true })
  vim.api.nvim_set_hl(0, "LspVirtualLineWarn", { fg = "#fab387", italic = true })
  vim.api.nvim_set_hl(0, "LspVirtualLineInfo", { fg = "#89b4fa", italic = true })
  vim.api.nvim_set_hl(0, "LspVirtualLineHint", { fg = "#94e2d5", italic = true })
end

-- Get diagnostics for buffer
local function get_diagnostics(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return vim.diagnostic.get(bufnr)
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
    [vim.diagnostic.severity.ERROR] = "LspVirtualLineError",
    [vim.diagnostic.severity.WARN] = "LspVirtualLineWarn",
    [vim.diagnostic.severity.INFO] = "LspVirtualLineInfo",
    [vim.diagnostic.severity.HINT] = "LspVirtualLineHint",
  }
  return hl_map[severity] or "LspVirtualLineInfo"
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

  local diagnostics = get_diagnostics(bufnr)
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
    table.sort(line_diags, function(a, b) return a.severity < b.severity end)

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

  local diagnostics = get_diagnostics(bufnr)
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
    table.sort(line_diags, function(a, b) return a.severity < b.severity end)

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
  vim.diagnostic.open_float(nil, {
    border = "rounded",
    focusable = true,
    source = "always",
    prefix = function(diagnostic, i, total)
      local prefix_map = {
        [vim.diagnostic.severity.ERROR] = "✘ Error",
        [vim.diagnostic.severity.WARN] = "▲ Warning",
        [vim.diagnostic.severity.INFO] = "ℹ Info",
        [vim.diagnostic.severity.HINT] = "➤ Hint",
      }
      return prefix_map[diagnostic.severity] .. ": ", ""
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

  -- Auto-refresh on LSP diagnostic updates
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    callback = function(args) update_virtual_diagnostics(args.buf) end,
  })

  -- Refresh on buffer enter
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    callback = function(args)
      -- Small delay to ensure LSP has updated diagnostics
      vim.defer_fn(function() update_virtual_diagnostics(args.buf) end, 50)
    end,
  })

  -- Clear on buffer leave/delete
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    callback = function(args) clear_virtual_diagnostics(args.buf) end,
  })

  -- Refresh on cursor hold (when idle)
  vim.api.nvim_create_autocmd("CursorHold", {
    callback = function(args) update_virtual_diagnostics(args.buf) end,
  })

  -- Re-apply highlights on colorscheme change
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function() setup_highlights() end,
  })
end

-- Get current state (for debugging)
function M.get_state() return state end

return M
