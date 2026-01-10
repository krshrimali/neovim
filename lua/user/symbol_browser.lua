-- Interactive Symbol Browser
-- Shows LSP document symbols in a navigable floating window
-- Press <leader>ls to open, Enter to jump, q to close

local M = {}

-- State management
local state = {
  float_win = nil,
  float_buf = nil,
  symbols = {},
  source_buf = nil,
  symbol_line_map = {},
}

-- Symbol kind to icon mapping (ASCII only)
local symbol_icons = {
  File = "F",
  Module = "M",
  Namespace = "N",
  Package = "P",
  Class = "C",
  Method = "m",
  Property = "p",
  Field = "f",
  Constructor = "c",
  Enum = "E",
  Interface = "I",
  Function = "F",
  Variable = "v",
  Constant = "C",
  String = "s",
  Number = "#",
  Boolean = "b",
  Array = "A",
  Object = "O",
  Key = "k",
  Null = "N",
  EnumMember = "e",
  Struct = "S",
  Event = "E",
  Operator = "o",
  TypeParameter = "t",
}

-- Get relative file path
local function get_relative_filepath(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == "" then return "[No Name]" end

  local cwd = vim.fn.getcwd()
  if filepath:find(cwd, 1, true) == 1 then
    filepath = filepath:sub(#cwd + 2)
  else
    local home = vim.fn.expand "~"
    if filepath:find(home, 1, true) == 1 then
      filepath = "~" .. filepath:sub(#home + 1)
    else
      filepath = vim.fn.fnamemodify(filepath, ":t")
    end
  end

  return filepath
end

-- Flatten and sort document symbols
local function flatten_symbols(symbols, depth, result)
  depth = depth or 0
  result = result or {}

  if not symbols or type(symbols) ~= "table" then return result end

  for _, symbol in ipairs(symbols) do
    -- Handle both DocumentSymbol and SymbolInformation formats
    local name = symbol.name
    local kind = symbol.kind
    local range = symbol.range or symbol.location and symbol.location.range
    local selection_range = symbol.selectionRange or range

    if name and kind and range then
      table.insert(result, {
        name = name,
        kind = kind,
        depth = depth,
        range = range,
        selection_range = selection_range,
        line = range.start.line,
        col = range.start.character,
      })

      -- Recursively add children
      if symbol.children and type(symbol.children) == "table" then
        flatten_symbols(symbol.children, depth + 1, result)
      end
    end
  end

  return result
end

-- Get LSP document symbols
local function get_document_symbols(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Get LSP clients for this buffer
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  if not clients or #clients == 0 then return nil end

  -- Find a client that supports document symbols
  local client = nil
  for _, c in ipairs(clients) do
    if c.server_capabilities.documentSymbolProvider then
      client = c
      break
    end
  end

  if not client then return nil end

  -- Request document symbols synchronously (with timeout)
  local params = { textDocument = vim.lsp.util.make_text_document_params() }
  local result = vim.lsp.buf_request_sync(bufnr, "textDocument/documentSymbol", params, 2000)

  if not result or vim.tbl_isempty(result) then return nil end

  -- Extract symbols from first response
  for _, res in pairs(result) do
    if res.result and type(res.result) == "table" and #res.result > 0 then return res.result end
  end

  return nil
end

-- Jump to symbol location
local function jump_to_symbol(symbol_index)
  if not symbol_index or not state.symbols[symbol_index] then return end

  local symbol = state.symbols[symbol_index]
  local source_buf = state.source_buf

  -- Close the floating window
  M.close()

  -- Jump to the symbol location in the source buffer
  if source_buf and vim.api.nvim_buf_is_valid(source_buf) then
    -- Find window showing source buffer or use current window
    local win = vim.fn.bufwinid(source_buf)
    if win == -1 then
      win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(win, source_buf)
    else
      vim.api.nvim_set_current_win(win)
    end

    -- Jump to position (LSP uses 0-indexed lines, Vim uses 1-indexed)
    local line = (symbol.selection_range or symbol.range).start.line + 1
    local col = (symbol.selection_range or symbol.range).start.character
    vim.api.nvim_win_set_cursor(win, { line, col })

    -- Center the cursor
    vim.cmd "normal! zz"
  end
end

-- Close the floating window
function M.close()
  if state.float_win and vim.api.nvim_win_is_valid(state.float_win) then
    vim.api.nvim_win_close(state.float_win, true)
  end
  state.float_win = nil
  state.float_buf = nil
  state.symbols = {}
  state.source_buf = nil
  state.symbol_line_map = {}
end

-- Get the symbol index under cursor in the floating window
local function get_symbol_at_cursor()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1 -- 0-indexed
  return state.symbol_line_map[line]
end

-- Get symbol kind name
local function get_kind_name(kind)
  local kinds = {
    [1] = "File",
    [2] = "Module",
    [3] = "Namespace",
    [4] = "Package",
    [5] = "Class",
    [6] = "Method",
    [7] = "Property",
    [8] = "Field",
    [9] = "Constructor",
    [10] = "Enum",
    [11] = "Interface",
    [12] = "Function",
    [13] = "Variable",
    [14] = "Constant",
    [15] = "String",
    [16] = "Number",
    [17] = "Boolean",
    [18] = "Array",
    [19] = "Object",
    [20] = "Key",
    [21] = "Null",
    [22] = "EnumMember",
    [23] = "Struct",
    [24] = "Event",
    [25] = "Operator",
    [26] = "TypeParameter",
  }
  return kinds[kind] or "Unknown"
end

-- Show symbols in a floating window
function M.show()
  -- Close existing window
  M.close()

  local bufnr = vim.api.nvim_get_current_buf()
  local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
  if buftype ~= "" then
    vim.notify("Symbol browser not available for special buffers", vim.log.levels.WARN)
    return
  end

  -- Store source buffer
  state.source_buf = bufnr

  -- Get current cursor position (0-indexed for LSP)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor_pos[1] - 1
  local current_col = cursor_pos[2]

  -- Get LSP document symbols
  local raw_symbols = get_document_symbols(bufnr)
  if not raw_symbols then
    vim.notify("No LSP symbols available for this buffer", vim.log.levels.WARN)
    return
  end

  -- Flatten and sort symbols
  local symbols = flatten_symbols(raw_symbols, 0)
  if #symbols == 0 then
    vim.notify("No symbols found in this buffer", vim.log.levels.WARN)
    return
  end

  -- Sort by line number
  table.sort(symbols, function(a, b) return a.line < b.line end)

  -- Find current symbol (the innermost one containing cursor)
  local current_symbol_idx = nil
  for i, symbol in ipairs(symbols) do
    local range = symbol.range
    local start_line = range.start.line
    local end_line = range["end"].line
    local start_char = range.start.character
    local end_char = range["end"].character

    local in_range = false
    if current_line > start_line and current_line < end_line then
      in_range = true
    elseif current_line == start_line and current_line == end_line then
      in_range = current_col >= start_char and current_col <= end_char
    elseif current_line == start_line then
      in_range = current_col >= start_char
    elseif current_line == end_line then
      in_range = current_col <= end_char
    end

    if in_range then current_symbol_idx = i end
  end

  -- Store symbols for navigation
  state.symbols = symbols

  -- Build display lines
  local lines = {}
  local highlights = {}
  local filepath = get_relative_filepath(bufnr)

  -- Header
  table.insert(
    lines,
    "╭─ Document Symbols ────────────────────────────────────╮"
  )
  table.insert(lines, "│                                                       │")

  -- File path (55 - 8 for "File: " = 47 chars for path)
  local filepath_display = filepath
  if #filepath_display > 47 then filepath_display = "..." .. filepath_display:sub(-(47 - 3)) end
  local filepath_line = string.format("│  File: %-47s│", filepath_display)
  table.insert(lines, filepath_line)
  table.insert(highlights, { line = #lines - 1, col = 9, end_col = 9 + #filepath_display, hl = "Directory" })

  table.insert(lines, "│                                                       │")
  table.insert(lines, string.format("│  %d symbols found:%-33s│", #symbols, ""))
  table.insert(lines, "│                                                       │")

  -- Add symbols
  for i, symbol in ipairs(symbols) do
    local kind_name = get_kind_name(symbol.kind)
    local icon = symbol_icons[kind_name] or "?"
    local indent = string.rep("  ", symbol.depth)
    local symbol_text = string.format("%s%s %s", indent, icon, symbol.name)

    -- Truncate if too long (50 chars)
    if #symbol_text > 50 then symbol_text = symbol_text:sub(1, 47) .. "..." end

    -- Pad to 53 chars
    local pad_len = 53 - #symbol_text
    if pad_len > 0 then symbol_text = symbol_text .. string.rep(" ", pad_len) end

    local line_text = string.format("│  %s│", symbol_text)
    table.insert(lines, line_text)

    -- Map this line to symbol index
    state.symbol_line_map[#lines - 1] = i

    -- Highlight based on kind
    local hl_group = "Function"
    if kind_name == "Class" or kind_name == "Struct" then
      hl_group = "Type"
    elseif kind_name == "Method" or kind_name == "Function" or kind_name == "Constructor" then
      hl_group = "Function"
    elseif kind_name == "Variable" or kind_name == "Field" or kind_name == "Property" then
      hl_group = "Identifier"
    elseif kind_name == "Constant" or kind_name == "Enum" or kind_name == "EnumMember" then
      hl_group = "Constant"
    elseif kind_name == "Interface" or kind_name == "Module" or kind_name == "Namespace" then
      hl_group = "Type"
    end

    local start_col = 3 + #indent
    table.insert(highlights, {
      line = #lines - 1,
      col = start_col,
      end_col = start_col + #icon + 1 + #symbol.name,
      hl = hl_group,
    })
  end

  table.insert(lines, "│                                                       │")
  table.insert(lines, "│  Press <Enter> to jump, 'q' to close                  │")
  table.insert(
    lines,
    "╰───────────────────────────────────────────────────────╯"
  )

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "filetype", "symbol-browser")

  -- Apply highlights
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, -1, hl.hl, hl.line, hl.col, hl.end_col)
  end

  -- Calculate window size
  local width = 57
  local height = math.min(#lines, vim.o.lines - 4)
  local win_width = vim.o.columns
  local win_height = vim.o.lines

  local row = math.floor((win_height - height) / 2)
  local col = math.floor((win_width - width) / 2)

  -- Create floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "none",
    focusable = true,
  })

  -- Set window options
  vim.api.nvim_win_set_option(win, "winblend", 0)
  vim.api.nvim_win_set_option(win, "cursorline", true)

  -- Store state
  state.float_win = win
  state.float_buf = buf

  -- Position cursor on current symbol (or first if not found)
  if #symbols > 0 then
    local target_symbol_idx = current_symbol_idx or 1
    for line_idx, symbol_idx in pairs(state.symbol_line_map) do
      if symbol_idx == target_symbol_idx then
        vim.api.nvim_win_set_cursor(win, { line_idx + 1, 3 })
        break
      end
    end
  end

  -- Keymaps for the floating window
  local opts = { noremap = true, silent = true, buffer = buf }

  -- Close keymaps
  vim.keymap.set("n", "q", M.close, opts)
  vim.keymap.set("n", "<Esc>", M.close, opts)

  -- Jump to symbol on Enter
  vim.keymap.set("n", "<CR>", function()
    local symbol_idx = get_symbol_at_cursor()
    if symbol_idx then
      jump_to_symbol(symbol_idx)
    else
      M.close()
    end
  end, opts)

  -- Navigation
  vim.keymap.set("n", "j", function()
    vim.cmd "normal! j"
    -- Skip non-symbol lines
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    if not state.symbol_line_map[line] then vim.cmd "normal! j" end
  end, opts)

  vim.keymap.set("n", "k", function()
    vim.cmd "normal! k"
    -- Skip non-symbol lines
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    if not state.symbol_line_map[line] then vim.cmd "normal! k" end
  end, opts)

  -- Auto-close on buffer leave
  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
    buffer = buf,
    callback = M.close,
    once = true,
  })
end

-- Toggle symbol browser
function M.toggle()
  if state.float_win and vim.api.nvim_win_is_valid(state.float_win) then
    M.close()
  else
    M.show()
  end
end

return M
