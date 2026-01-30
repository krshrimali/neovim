-- Floating Breadcrumbs Navigation (Helix-inspired)
-- Shows file path + symbol hierarchy in a floating window
-- Press <space>lb to open, Enter to jump, q to close

local M = {}

-- State management
local state = {
  win = nil,
  buf = nil,
  items = {},
  source_win = nil,
  source_buf = nil,
  item_line_map = {},
}

-- Item kinds
local ItemKind = {
  Directory = "dir",
  File = "file",
  Symbol = "symbol",
}

-- Symbol kind icons (ASCII only for compatibility)
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
  Function = "fn",
  Variable = "v",
  Constant = "C",
  String = "s",
  Number = "#",
  Boolean = "b",
  Array = "[]",
  Object = "{}",
  Key = "k",
  Null = "N",
  EnumMember = "e",
  Struct = "S",
  Event = "E",
  Operator = "o",
  TypeParameter = "t",
}

-- Get symbol kind name from LSP kind number
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

-- Get directory path items from cwd to file
local function get_path_items(filepath)
  local items = {}
  local cwd = vim.fn.getcwd()

  if filepath == "" or not filepath then
    return items
  end

  -- Normalize paths
  cwd = vim.fn.fnamemodify(cwd, ":p"):gsub("/$", "")
  filepath = vim.fn.fnamemodify(filepath, ":p")

  -- Check if file is under cwd
  local relative_path
  if filepath:find(cwd, 1, true) == 1 then
    relative_path = filepath:sub(#cwd + 2)
  else
    -- File is outside cwd, show from home or root
    local home = vim.fn.expand("~")
    if filepath:find(home, 1, true) == 1 then
      relative_path = "~" .. filepath:sub(#home + 1)
      cwd = home
    else
      relative_path = filepath
      cwd = ""
    end
  end

  -- Split path into components
  local parts = {}
  for part in relative_path:gmatch("[^/]+") do
    table.insert(parts, part)
  end

  -- Add directory items (all but last which is the file)
  local current_path = cwd
  for i = 1, #parts - 1 do
    current_path = current_path .. "/" .. parts[i]
    table.insert(items, {
      name = parts[i],
      kind = ItemKind.Directory,
      path = current_path,
      depth = i - 1,
    })
  end

  -- Add file item
  if #parts > 0 then
    table.insert(items, {
      name = parts[#parts],
      kind = ItemKind.File,
      path = filepath,
      depth = #parts - 1,
    })
  end

  return items
end

-- Find symbols containing cursor position (breadcrumb path)
local function find_containing_symbols(symbols, cursor_line, cursor_col, depth, result)
  depth = depth or 0
  result = result or {}

  if not symbols or type(symbols) ~= "table" then
    return result
  end

  for _, symbol in ipairs(symbols) do
    local range = symbol.range or (symbol.location and symbol.location.range)
    if range then
      local start_line = range.start.line
      local end_line = range["end"].line
      local start_char = range.start.character
      local end_char = range["end"].character

      -- Check if cursor is within this symbol's range
      local in_range = false
      if cursor_line > start_line and cursor_line < end_line then
        in_range = true
      elseif cursor_line == start_line and cursor_line == end_line then
        in_range = cursor_col >= start_char and cursor_col <= end_char
      elseif cursor_line == start_line then
        in_range = cursor_col >= start_char
      elseif cursor_line == end_line then
        in_range = cursor_col <= end_char
      end

      if in_range then
        table.insert(result, {
          name = symbol.name,
          kind = ItemKind.Symbol,
          symbol_kind = symbol.kind,
          range = range,
          selection_range = symbol.selectionRange or range,
          depth = depth,
        })

        -- Recursively check children
        if symbol.children and type(symbol.children) == "table" then
          find_containing_symbols(symbol.children, cursor_line, cursor_col, depth + 1, result)
        end
      end
    end
  end

  return result
end

-- Get LSP document symbols synchronously
local function get_document_symbols(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if not clients or #clients == 0 then
    return nil
  end

  local client = nil
  for _, c in ipairs(clients) do
    if c.server_capabilities.documentSymbolProvider then
      client = c
      break
    end
  end

  if not client then
    return nil
  end

  local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
  local result = vim.lsp.buf_request_sync(bufnr, "textDocument/documentSymbol", params, 2000)

  if not result or vim.tbl_isempty(result) then
    return nil
  end

  for _, res in pairs(result) do
    if res.result and type(res.result) == "table" then
      return res.result
    end
  end

  return nil
end

-- Close the floating window
function M.close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
  state.buf = nil
  state.items = {}
  state.source_win = nil
  state.source_buf = nil
  state.item_line_map = {}
end

-- Handle item selection
local function select_item(item)
  if not item then
    return
  end

  local source_win = state.source_win
  local source_buf = state.source_buf

  M.close()

  if item.kind == ItemKind.Directory then
    -- Open file picker at this directory
    local ok, fzf = pcall(require, "fzf-lua")
    if ok then
      fzf.files({ cwd = item.path })
    else
      vim.cmd("edit " .. vim.fn.fnameescape(item.path))
    end
  elseif item.kind == ItemKind.File then
    -- Already viewing this file, just close
    if source_win and vim.api.nvim_win_is_valid(source_win) then
      vim.api.nvim_set_current_win(source_win)
    end
  elseif item.kind == ItemKind.Symbol then
    -- Jump to symbol location and select the entire range
    if source_win and vim.api.nvim_win_is_valid(source_win) then
      vim.api.nvim_set_current_win(source_win)
    end

    if source_buf and vim.api.nvim_buf_is_valid(source_buf) then
      local win = vim.api.nvim_get_current_win()
      if vim.api.nvim_win_get_buf(win) ~= source_buf then
        vim.api.nvim_win_set_buf(win, source_buf)
      end

      local range = item.range
      if range then
        local start_line = range.start.line + 1
        local start_col = range.start.character
        local end_line = range["end"].line + 1
        local end_col = range["end"].character

        -- Move to start position
        vim.api.nvim_win_set_cursor(win, { start_line, start_col })

        -- Enter visual mode and select to end
        vim.cmd("normal! v")
        vim.api.nvim_win_set_cursor(win, { end_line, math.max(0, end_col - 1) })

        -- Center the view
        vim.cmd("normal! zz")
      end
    end
  end
end

-- Show the floating breadcrumbs window
function M.show()
  M.close()

  local bufnr = vim.api.nvim_get_current_buf()
  local buftype = vim.bo[bufnr].buftype
  if buftype ~= "" then
    vim.notify("Breadcrumbs not available for special buffers", vim.log.levels.WARN)
    return
  end

  state.source_win = vim.api.nvim_get_current_win()
  state.source_buf = bufnr

  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_line = cursor[1] - 1 -- 0-indexed for LSP
  local cursor_col = cursor[2]

  -- Build breadcrumb items
  local items = {}

  -- 1. Add path items (directories + file)
  local path_items = get_path_items(filepath)
  for _, item in ipairs(path_items) do
    table.insert(items, item)
  end

  -- 2. Add symbol items from LSP
  local raw_symbols = get_document_symbols(bufnr)
  if raw_symbols then
    local symbol_items = find_containing_symbols(raw_symbols, cursor_line, cursor_col)
    local path_depth = #path_items
    for _, item in ipairs(symbol_items) do
      item.depth = path_depth + item.depth
      table.insert(items, item)
    end
  end

  if #items == 0 then
    vim.notify("No breadcrumbs available", vim.log.levels.WARN)
    return
  end

  state.items = items

  -- Build display lines
  local lines = {}
  local highlights = {}

  for i, item in ipairs(items) do
    local indent = string.rep("  ", item.depth)
    local icon, label

    if item.kind == ItemKind.Directory then
      icon = "d"
      label = item.name .. "/"
    elseif item.kind == ItemKind.File then
      icon = "f"
      label = item.name
    else
      local kind_name = get_kind_name(item.symbol_kind)
      icon = symbol_icons[kind_name] or "?"
      label = item.name
    end

    local line = string.format("%s%s %s", indent, icon, label)
    table.insert(lines, line)
    state.item_line_map[i] = i

    -- Determine highlight group
    local hl_group = "Normal"
    if item.kind == ItemKind.Directory then
      hl_group = "Directory"
    elseif item.kind == ItemKind.File then
      hl_group = "Title"
    else
      local kind_name = get_kind_name(item.symbol_kind)
      if kind_name == "Class" or kind_name == "Struct" or kind_name == "Interface" then
        hl_group = "Type"
      elseif kind_name == "Function" or kind_name == "Method" or kind_name == "Constructor" then
        hl_group = "Function"
      elseif kind_name == "Variable" or kind_name == "Field" or kind_name == "Property" then
        hl_group = "Identifier"
      elseif kind_name == "Constant" or kind_name == "Enum" or kind_name == "EnumMember" then
        hl_group = "Constant"
      elseif kind_name == "Module" or kind_name == "Namespace" or kind_name == "Package" then
        hl_group = "Include"
      end
    end

    table.insert(highlights, {
      line = i - 1,
      col = #indent,
      end_col = #line,
      hl = hl_group,
    })
  end

  -- Calculate window dimensions
  local max_width = 0
  for _, line in ipairs(lines) do
    max_width = math.max(max_width, #line)
  end
  local width = math.min(math.max(max_width + 4, 40), 80)
  local height = math.min(#lines, 20)

  local editor_width = vim.o.columns
  local editor_height = vim.o.lines
  local row = math.floor((editor_height - height) / 2) - 2
  local col = math.floor((editor_width - width) / 2)

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "breadcrumbs"

  -- Apply highlights
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, -1, hl.hl, hl.line, hl.col, hl.end_col)
  end

  -- Create floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Breadcrumbs ",
    title_pos = "center",
    footer = " <CR>:jump  q:close ",
    footer_pos = "center",
  })

  vim.wo[win].cursorline = true
  vim.wo[win].winblend = 0

  state.win = win
  state.buf = buf

  -- Position cursor at the deepest item (last one)
  vim.api.nvim_win_set_cursor(win, { #items, 0 })

  -- Keymaps
  local opts = { noremap = true, silent = true, buffer = buf }

  vim.keymap.set("n", "q", M.close, opts)
  vim.keymap.set("n", "<Esc>", M.close, opts)
  vim.keymap.set("n", "<C-c>", M.close, opts)

  vim.keymap.set("n", "<CR>", function()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line_num = cursor_pos[1]
    local item = state.items[line_num]
    select_item(item)
  end, opts)

  vim.keymap.set("n", "l", function()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line_num = cursor_pos[1]
    local item = state.items[line_num]
    select_item(item)
  end, opts)

  -- Jump to parent (go up in the hierarchy)
  vim.keymap.set("n", "h", function()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local current_line = cursor_pos[1]
    if current_line > 1 then
      vim.api.nvim_win_set_cursor(0, { current_line - 1, 0 })
    end
  end, opts)

  -- Auto-close on leave
  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
    buffer = buf,
    callback = M.close,
    once = true,
  })
end

-- Toggle breadcrumbs
function M.toggle()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    M.close()
  else
    M.show()
  end
end

return M
