-- CoC Breadcrumbs Plugin (On-Demand Only)
-- Press <leader>lb to show breadcrumbs in a floating window
-- No background processing - only calculates when requested

local M = {}

-- State management
local state = {
  float_win = nil,
  float_buf = nil,
  symbols = {}, -- Store symbols with their positions
  source_buf = nil, -- Original buffer
}

-- Symbol kind to icon mapping
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
  Null = "n",
  EnumMember = "e",
  Struct = "S",
  Event = "E",
  Operator = "o",
  TypeParameter = "t",
  -- Control flow (if supported by LSP)
  If = "?",
  For = "⟳",
  While = "⟳",
  Switch = "⟳",
  Case = "→",
  Condition = "?",
  Statement = "•",
}

-- Check if CoC is available and ready
local function is_coc_ready()
  if vim.fn.exists "*CocAction" == 0 then return false end

  local ready = vim.fn.CocHasProvider and vim.fn.CocHasProvider "documentSymbol" == 1
  if not ready then ready = vim.fn.exists "*coc#rpc#ready" == 1 and vim.fn["coc#rpc#ready"]() == 1 end

  return ready
end

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

-- Get control flow structures from Treesitter AST
local function get_treesitter_context(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Check if treesitter is available
  local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
  if not ok then return {} end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local col = cursor[2]

  -- Get parser
  local parser_ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not parser_ok or not parser then return {} end

  local tree_ok, tree = pcall(parser.parse, parser)
  if not tree_ok or not tree or not tree[1] then return {} end

  local root = tree[1]:root()

  -- Control flow node types by language
  local control_flow_types = {
    -- Python
    "if_statement",
    "for_statement",
    "while_statement",
    "with_statement",
    "try_statement",
    -- JavaScript/TypeScript
    "if_statement",
    "for_statement",
    "for_in_statement",
    "while_statement",
    "switch_statement",
    "try_statement",
    -- Lua
    "if_statement",
    "for_statement",
    "while_statement",
    -- Rust
    "if_expression",
    "for_expression",
    "while_expression",
    "match_expression",
    "loop_expression",
    -- C/C++
    "if_statement",
    "for_statement",
    "while_statement",
    "switch_statement",
    -- Go
    "if_statement",
    "for_statement",
    "switch_statement",
  }

  local control_nodes = {}

  -- Find all control flow nodes containing cursor
  local function find_containing_nodes(node)
    if not node then return end

    local start_row, start_col, end_row, end_col = node:range()

    -- Check if cursor is inside this node
    local in_range = false
    if line > start_row and line < end_row then
      in_range = true
    elseif line == start_row and line == end_row then
      in_range = col >= start_col and col <= end_col
    elseif line == start_row then
      in_range = col >= start_col
    elseif line == end_row then
      in_range = col <= end_col
    end

    if in_range then
      local node_type = node:type()

      -- Check if this is a control flow node
      for _, cf_type in ipairs(control_flow_types) do
        if node_type == cf_type then
          table.insert(control_nodes, {
            node = node,
            type = node_type,
            start_row = start_row,
            start_col = start_col,
          })
          break
        end
      end

      -- Recurse to children
      for child in node:iter_children() do
        find_containing_nodes(child)
      end
    end
  end

  find_containing_nodes(root)

  -- Sort by depth (start_row)
  table.sort(control_nodes, function(a, b) return a.start_row < b.start_row end)

  -- Extract condition text from nodes
  local results = {}
  for _, cf_node in ipairs(control_nodes) do
    local node = cf_node.node
    local node_type = cf_node.type

    -- Try to get condition/expression text
    local condition_text = nil
    local kind = "Statement"

    if node_type:match "if" then
      kind = "If"
      -- Try to find condition node
      for child in node:iter_children() do
        if child:type():match "condition" or child:type() == "parenthesized_expression" then
          condition_text = vim.treesitter.get_node_text(child, bufnr)
          -- Clean up condition text
          condition_text = condition_text:gsub("^%(", ""):gsub("%)$", ""):gsub("\n", " ")
          if #condition_text > 30 then condition_text = condition_text:sub(1, 27) .. "..." end
          break
        end
      end
    elseif node_type:match "for" then
      kind = "For"
      -- Try to get iterator/range
      for child in node:iter_children() do
        local child_type = child:type()
        if child_type:match "clause" or child_type:match "iterator" or child_type == "range" then
          condition_text = vim.treesitter.get_node_text(child, bufnr)
          condition_text = condition_text:gsub("\n", " ")
          if #condition_text > 30 then condition_text = condition_text:sub(1, 27) .. "..." end
          break
        end
      end
    elseif node_type:match "while" then
      kind = "While"
      for child in node:iter_children() do
        if child:type():match "condition" or child:type() == "parenthesized_expression" then
          condition_text = vim.treesitter.get_node_text(child, bufnr)
          condition_text = condition_text:gsub("^%(", ""):gsub("%)$", ""):gsub("\n", " ")
          if #condition_text > 30 then condition_text = condition_text:sub(1, 27) .. "..." end
          break
        end
      end
    elseif node_type:match "switch" or node_type:match "match" then
      kind = "Switch"
      -- Get the expression being matched
      for child in node:iter_children() do
        if child:type():match "value" or child:type():match "condition" or child:type():match "subject" then
          condition_text = vim.treesitter.get_node_text(child, bufnr)
          condition_text = condition_text:gsub("\n", " ")
          if #condition_text > 30 then condition_text = condition_text:sub(1, 27) .. "..." end
          break
        end
      end
    end

    if not condition_text then condition_text = kind:lower() end

    table.insert(results, {
      name = condition_text,
      kind = kind,
      line = cf_node.start_row,
      col = cf_node.start_col,
    })
  end

  return results
end

-- Get symbol hierarchy from CoC (only when requested)
local function get_coc_symbols(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not is_coc_ready() then return {} end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local col = cursor[2]

  local ok, symbols = pcall(vim.fn.CocAction, "documentSymbols")
  if not ok or type(symbols) ~= "table" or #symbols == 0 then return {} end

  local containing_symbols = {}

  local function check_symbol_contains(symbol, depth)
    depth = depth or 0
    if not symbol or not symbol.range then return end

    local range = symbol.range
    local start_line = range.start.line
    local end_line = range["end"].line
    local start_char = range.start.character
    local end_char = range["end"].character

    local in_range = false
    if line > start_line and line < end_line then
      in_range = true
    elseif line == start_line and line == end_line then
      in_range = col >= start_char and col <= end_char
    elseif line == start_line then
      in_range = col >= start_char
    elseif line == end_line then
      in_range = col <= end_char
    end

    if in_range then
      table.insert(containing_symbols, {
        name = symbol.text or symbol.name or "unknown",
        kind = symbol.kind or "Unknown",
        depth = depth,
        range = range,
        -- Store line and column for navigation
        line = range.start.line,
        col = range.start.character,
      })

      if symbol.children and type(symbol.children) == "table" then
        for _, child in ipairs(symbol.children) do
          check_symbol_contains(child, depth + 1)
        end
      end
    end
  end

  for _, symbol in ipairs(symbols) do
    check_symbol_contains(symbol, 0)
  end

  table.sort(containing_symbols, function(a, b) return a.depth < b.depth end)

  return containing_symbols
end

-- Merge CoC symbols and Treesitter context
local function get_combined_symbols(bufnr)
  local lsp_symbols = get_coc_symbols(bufnr)
  local ts_context = get_treesitter_context(bufnr)

  -- Combine both lists, sorted by line number
  local combined = {}

  -- Add all symbols
  for _, sym in ipairs(lsp_symbols) do
    table.insert(combined, sym)
  end

  for _, ctx in ipairs(ts_context) do
    table.insert(combined, ctx)
  end

  -- Sort by line number to get proper hierarchy
  table.sort(combined, function(a, b) return a.line < b.line end)

  -- Assign proper depth based on nesting
  for i, sym in ipairs(combined) do
    if i == 1 then
      sym.depth = 0
    else
      sym.depth = i - 1
    end
  end

  return combined
end

-- Jump to symbol location
local function jump_to_symbol(symbol_index)
  if not symbol_index or not state.symbols[symbol_index] then return end

  local symbol = state.symbols[symbol_index]
  local source_buf = state.source_buf

  -- Close the floating window
  if state.float_win and vim.api.nvim_win_is_valid(state.float_win) then
    vim.api.nvim_win_close(state.float_win, true)
  end

  -- Jump to the symbol location in the source buffer
  if source_buf and vim.api.nvim_buf_is_valid(source_buf) then
    -- Find window showing source buffer or use current window
    local win = vim.fn.bufwinid(source_buf)
    if win == -1 then
      -- Buffer not visible, use current window
      win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(win, source_buf)
    else
      vim.api.nvim_set_current_win(win)
    end

    -- Jump to position (line is 0-indexed in LSP, 1-indexed in Vim)
    vim.api.nvim_win_set_cursor(win, { symbol.line + 1, symbol.col })

    -- Center the cursor
    vim.cmd "normal! zz"
  end

  -- Clear state
  state.float_win = nil
  state.float_buf = nil
  state.symbols = {}
  state.source_buf = nil
end

-- Close the floating window
local function close_float()
  if state.float_win and vim.api.nvim_win_is_valid(state.float_win) then
    vim.api.nvim_win_close(state.float_win, true)
  end
  state.float_win = nil
  state.float_buf = nil
  state.symbols = {}
  state.source_buf = nil
end

-- Get the symbol index under cursor in the floating window
local function get_symbol_at_cursor()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1 -- 0-indexed

  -- Find which symbol corresponds to this line
  -- We'll store a mapping when creating the window
  if state.symbol_line_map and state.symbol_line_map[line] then return state.symbol_line_map[line] end

  return nil
end

-- Show breadcrumbs in a floating window
function M.show()
  -- Close existing window
  close_float()

  local bufnr = vim.api.nvim_get_current_buf()
  local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
  if buftype ~= "" then
    vim.notify("Breadcrumbs not available for special buffers", vim.log.levels.WARN)
    return
  end

  -- Store source buffer
  state.source_buf = bufnr

  -- Get data (combine LSP symbols and Treesitter context)
  local filepath = get_relative_filepath(bufnr)
  local symbols = get_combined_symbols(bufnr)

  -- Store symbols for navigation
  state.symbols = symbols
  state.symbol_line_map = {}

  -- Build display lines
  local lines = {}
  local highlights = {}

  -- Header
  table.insert(
    lines,
    "╭─ Breadcrumbs ─────────────────────────────────────────╮"
  )
  table.insert(lines, "│                                                       │")

  -- File path (55 - 8 for "File: " = 47 chars for path)
  local filepath_display = filepath
  if #filepath_display > 47 then filepath_display = "..." .. filepath_display:sub(-(47 - 3)) end
  local filepath_line = string.format("│  File: %-47s│", filepath_display)
  table.insert(lines, filepath_line)
  table.insert(highlights, { line = #lines - 1, col = 9, end_col = 9 + #filepath_display, hl = "Directory" })

  if #symbols > 0 then
    table.insert(lines, "│                                                       │")
    table.insert(lines, "│  Symbol Hierarchy:                                    │")
    table.insert(lines, "│                                                       │")

    local display_width = vim.fn.strdisplaywidth

    for i, symbol in ipairs(symbols) do
      local icon = symbol_icons[symbol.kind] or "•"
      local indent = string.rep("  ", symbol.depth)
      local arrow = i > 1 and "↳ " or "  "
      local symbol_text = string.format("%s%s%s %s", indent, arrow, icon, symbol.name)

      -- Truncate display width if too long (53 chars)
      if display_width(symbol_text) > 53 then
        -- Truncate with strcharpart (cpdisplay) to avoid splitting Unicode
        local len = 0
        local truncated = ""
        for c in symbol_text:gmatch "." do
          local w = display_width(c)
          if len + w > 50 then break end
          truncated = truncated .. c
          len = len + w
        end
        symbol_text = truncated .. "..."
      end

      -- Pad to 53 display columns (add spaces at right)
      local pad_len = 53 - display_width(symbol_text)
      if pad_len > 0 then symbol_text = symbol_text .. string.rep(" ", pad_len) end

      local line_text = string.format("│  %s│", symbol_text)
      table.insert(lines, line_text)

      -- Map this line to symbol index for clickability
      state.symbol_line_map[#lines - 1] = i

      -- Highlight kind
      local hl_group = "Function"
      if symbol.kind == "Class" or symbol.kind == "Struct" then
        hl_group = "Type"
      elseif symbol.kind == "Method" or symbol.kind == "Function" then
        hl_group = "Function"
      elseif symbol.kind == "Variable" or symbol.kind == "Field" or symbol.kind == "Property" then
        hl_group = "Identifier"
      elseif
        symbol.kind == "If"
        or symbol.kind == "For"
        or symbol.kind == "While"
        or symbol.kind == "Switch"
        or symbol.kind == "Condition"
      then
        hl_group = "Conditional"
      elseif symbol.kind == "Statement" then
        hl_group = "Statement"
      end

      local start_col = 3 + #indent + #arrow
      table.insert(highlights, {
        line = #lines - 1,
        col = start_col,
        end_col = start_col + #icon + 1 + #symbol.name,
        hl = hl_group,
      })
    end
  else
    table.insert(lines, "│                                                       │")
    table.insert(lines, "│  No symbols at cursor position                        │")
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

  -- Apply highlights
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, -1, hl.hl, hl.line, hl.col, hl.end_col)
  end

  -- Calculate window size
  local width = 57
  local height = #lines
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

  -- Position cursor on first symbol line (if symbols exist)
  if #symbols > 0 then
    -- Find the first line that has a symbol (should be line 6 typically)
    for line_idx, symbol_idx in pairs(state.symbol_line_map) do
      if symbol_idx == 1 then
        vim.api.nvim_win_set_cursor(win, { line_idx + 1, 0 }) -- +1 because Vim uses 1-indexed lines
        break
      end
    end
  end

  -- Keymaps for the floating window
  local opts = { noremap = true, silent = true, buffer = buf }

  -- Close keymaps
  vim.keymap.set("n", "q", close_float, opts)
  vim.keymap.set("n", "<Esc>", close_float, opts)

  -- Jump to symbol on Enter
  vim.keymap.set("n", "<CR>", function()
    local symbol_idx = get_symbol_at_cursor()
    if symbol_idx then
      jump_to_symbol(symbol_idx)
    else
      close_float()
    end
  end, opts)

  -- Auto-close on buffer leave
  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
    buffer = buf,
    callback = close_float,
    once = true,
  })
end

-- Toggle breadcrumbs
function M.toggle()
  if state.float_win and vim.api.nvim_win_is_valid(state.float_win) then
    close_float()
  else
    M.show()
  end
end

return M
