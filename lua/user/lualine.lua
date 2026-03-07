-- Simplified Lualine Configuration
local status_ok, lualine = pcall(require, "lualine")
if not status_ok then return end

-- Clickable jump navigation for statusline
function _G.LualineGoBack()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-o>", true, false, true), "n", false)
end
function _G.LualineGoForward()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-i>", true, false, true), "n", false)
end

local nav_buttons = {
  function() return "%@v:lua.LualineGoBack@ \u{2190} %X %@v:lua.LualineGoForward@ \u{2192} %X" end,
}

-- Clickable breadcrumbs component
_G.LualineBreadcrumbTargets = {}
local breadcrumb_state = { symbols = nil, bufnr = nil, changedtick = nil, display = "" }

-- LSP symbol kind number to name
local kind_names = {
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

-- Collect all symbols of a given kind from the symbol tree
local function collect_symbols_by_kind(symbols, target_kind, result, parent_name)
  result = result or {}
  if not symbols or type(symbols) ~= "table" then return result end
  for _, symbol in ipairs(symbols) do
    if symbol.kind == target_kind then
      local sel = symbol.selectionRange or symbol.range
      if sel then
        local display = symbol.name
        if parent_name then display = parent_name .. "." .. symbol.name end
        table.insert(result, { name = display, line = sel.start.line, col = sel.start.character })
      end
    end
    if symbol.children then collect_symbols_by_kind(symbol.children, target_kind, result, symbol.name) end
  end
  return result
end

-- Show a floating picker menu for a list of items
local function show_picker(title, items, on_select)
  if #items == 0 then return end

  local lines = {}
  for _, item in ipairs(items) do
    table.insert(lines, item.name)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local width = 10
  for _, line in ipairs(lines) do
    width = math.max(width, #line + 4)
  end
  width = math.min(width, 60)
  local height = math.min(#lines, 20)

  local editor_w = vim.o.columns
  local editor_h = vim.o.lines
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((editor_h - height) / 2) - 2,
    col = math.floor((editor_w - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
  })
  vim.wo[win].cursorline = true

  local closed = false
  local function close()
    if closed then return end
    if vim.api.nvim_win_is_valid(win) then
      closed = true
      vim.api.nvim_win_close(win, true)
    end
  end

  local function select()
    if closed or not vim.api.nvim_win_is_valid(win) then return end
    local idx = vim.api.nvim_win_get_cursor(win)[1]
    close()
    on_select(items[idx])
  end

  local kopts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set("n", "<CR>", select, kopts)
  vim.keymap.set("n", "<LeftMouse>", function()
    if closed or not vim.api.nvim_win_is_valid(win) then return end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<LeftMouse>", true, false, true), "n", false)
    vim.schedule(select)
  end, kopts)
  vim.keymap.set("n", "q", close, kopts)
  vim.keymap.set("n", "<Esc>", close, kopts)

  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, { buffer = buf, callback = close, once = true })
end

-- Click handler: show all symbols of same kind in a floating picker
function _G.LualineBreadcrumbClick(idx)
  local target = _G.LualineBreadcrumbTargets[idx]
  if not target then return end

  if target.kind == "directory" then
    -- Show sibling entries in the parent directory
    local dir = target.dir
    if not dir then return end
    local entries = vim.fn.readdir(dir)
    local items = {}
    for _, entry in ipairs(entries) do
      if entry:sub(1, 1) ~= "." then
        local full = dir .. "/" .. entry
        table.insert(items, { name = entry, path = full })
      end
    end
    show_picker("Directory: " .. vim.fn.fnamemodify(dir, ":t"), items, function(item)
      local stat = vim.uv.fs_stat(item.path)
      if stat and stat.type == "directory" then
        local ok, fzf = pcall(require, "fzf-lua")
        if ok then
          fzf.files { cwd = item.path }
        else
          vim.cmd("edit " .. vim.fn.fnameescape(item.path))
        end
      else
        vim.cmd("edit " .. vim.fn.fnameescape(item.path))
      end
    end)
    return
  end

  -- Symbol breadcrumb: find all symbols of the same kind
  if not breadcrumb_state.symbols or not target.symbol_kind then return end
  local siblings = collect_symbols_by_kind(breadcrumb_state.symbols, target.symbol_kind)
  if #siblings == 0 then return end

  local kind_name = kind_names[target.symbol_kind] or "Symbol"
  show_picker(kind_name .. "s", siblings, function(item)
    vim.api.nvim_win_set_cursor(0, { item.line + 1, item.col })
    vim.cmd "normal! zz"
  end)
end

local function bc_click(idx)
  _G["LualineBcClick" .. idx] = function() _G.LualineBreadcrumbClick(idx) end
  return "v:lua.LualineBcClick" .. idx
end

local function find_containing_symbols(symbols, cursor_line, cursor_col, result)
  result = result or {}
  if not symbols or type(symbols) ~= "table" then return result end
  for _, symbol in ipairs(symbols) do
    local range = symbol.range or (symbol.location and symbol.location.range)
    if range then
      local s_line, e_line = range.start.line, range["end"].line
      local s_col, e_col = range.start.character, range["end"].character
      local in_range = false
      if cursor_line > s_line and cursor_line < e_line then
        in_range = true
      elseif cursor_line == s_line and cursor_line == e_line then
        in_range = cursor_col >= s_col and cursor_col <= e_col
      elseif cursor_line == s_line then
        in_range = cursor_col >= s_col
      elseif cursor_line == e_line then
        in_range = cursor_col <= e_col
      end
      if in_range then
        local sel = symbol.selectionRange or range
        table.insert(result, {
          name = symbol.name,
          line = sel.start.line,
          col = sel.start.character,
          symbol_kind = symbol.kind,
        })
        if symbol.children then find_containing_symbols(symbol.children, cursor_line, cursor_col, result) end
      end
    end
  end
  return result
end

-- Async symbol fetching - updates cache without blocking statusline
local function refresh_symbols(bufnr)
  if vim.bo[bufnr].buftype ~= "" then return end
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  for _, c in ipairs(clients) do
    if c.server_capabilities.documentSymbolProvider then
      local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
      c:request("textDocument/documentSymbol", params, function(err, result)
        if not err and result then
          breadcrumb_state.symbols = result
          breadcrumb_state.bufnr = bufnr
          breadcrumb_state.changedtick = vim.b[bufnr].changedtick
          -- Trigger lualine refresh
          lualine.refresh()
        end
      end, bufnr)
      return
    end
  end
  breadcrumb_state.symbols = nil
end

-- Refresh symbols on cursor hold, buffer enter, and after text changes
vim.api.nvim_create_autocmd({ "CursorHold", "BufEnter", "TextChanged", "InsertLeave" }, {
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.bo[bufnr].buftype ~= "" then return end
    local changedtick = vim.b[bufnr].changedtick
    if breadcrumb_state.bufnr ~= bufnr or breadcrumb_state.changedtick ~= changedtick then refresh_symbols(bufnr) end
  end,
})

-- Also refresh on CursorMoved so breadcrumbs update as you move (uses cached symbols)
vim.api.nvim_create_autocmd("CursorMoved", {
  callback = function()
    if vim.bo.buftype ~= "" then return end
    lualine.refresh()
  end,
})

local last_breadcrumb_output = ""

local function get_breadcrumbs()
  -- Don't recalculate when inside floating/special buffers (preserves state)
  if vim.bo.buftype ~= "" then return last_breadcrumb_output end

  local ok, cursor = pcall(vim.api.nvim_win_get_cursor, 0)
  if not ok then return last_breadcrumb_output end

  _G.LualineBreadcrumbTargets = {}
  local parts = {}
  local idx = 0

  -- Add directory breadcrumbs from file path
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath ~= "" then
    local rel = vim.fn.fnamemodify(filepath, ":.")
    local dir_parts = {}
    for part in rel:gmatch "[^/]+" do
      table.insert(dir_parts, part)
    end
    -- Add directory segments (all but last which is the filename)
    local current_path = vim.fn.getcwd()
    for i = 1, #dir_parts - 1 do
      current_path = current_path .. "/" .. dir_parts[i]
      idx = idx + 1
      _G.LualineBreadcrumbTargets[idx] = { kind = "directory", dir = current_path }
      table.insert(parts, string.format("%%@%s@ %s %%X", bc_click(idx), dir_parts[i]))
    end
  end

  -- Add symbol breadcrumbs from LSP
  if breadcrumb_state.symbols then
    local crumbs = find_containing_symbols(breadcrumb_state.symbols, cursor[1] - 1, cursor[2])
    for _, crumb in ipairs(crumbs) do
      idx = idx + 1
      _G.LualineBreadcrumbTargets[idx] = {
        kind = "symbol",
        line = crumb.line,
        col = crumb.col,
        symbol_kind = crumb.symbol_kind,
      }
      table.insert(parts, string.format("%%@%s@ %s %%X", bc_click(idx), crumb.name))
    end
  end

  if #parts == 0 then
    last_breadcrumb_output = ""
    return ""
  end

  last_breadcrumb_output = table.concat(parts, " \u{203a}")
  return last_breadcrumb_output
end

local breadcrumbs = { get_breadcrumbs }

-- Clickable git log viewer
function _G.LualineGitLog()
  local handle = io.popen("git log --oneline --no-decorate -20 2>/dev/null")
  if not handle then return end
  local output = handle:read("*a")
  handle:close()
  if output == "" then return end

  local entries = {}
  for line in output:gmatch("[^\n]+") do
    local hash, msg = line:match("^(%S+)%s+(.+)$")
    if hash then table.insert(entries, { hash = hash, name = hash .. "  " .. msg }) end
  end
  if #entries == 0 then return end

  show_picker("Git Log (recent)", entries, function(item)
    vim.cmd("new")
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "git"

    local diff_handle = io.popen("git show --stat --patch " .. item.hash .. " 2>/dev/null")
    if diff_handle then
      local diff = diff_handle:read("*a")
      diff_handle:close()
      local lines = {}
      for l in diff:gmatch("[^\n]+") do table.insert(lines, l) end
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end
    vim.bo[buf].modifiable = false
    vim.api.nvim_buf_set_name(buf, "git://" .. item.hash)
  end)
end

-- Macro recording indicator
local function macro_recording()
  local reg = vim.fn.reg_recording()
  if reg ~= "" then return "REC @" .. reg end
  return ""
end

-- Search count indicator
local function search_count()
  if vim.v.hlsearch == 0 then return "" end
  local ok, result = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 250 })
  if not ok or result.total == 0 then return "" end
  return string.format("[%d/%d]", result.current, result.total)
end

-- LSP server names
local function lsp_status()
  local clients = vim.lsp.get_clients { bufnr = 0 }
  if #clients == 0 then return "" end
  local names = {}
  for _, c in ipairs(clients) do
    table.insert(names, c.name)
  end
  return table.concat(names, ", ")
end

lualine.setup {
  options = {
    globalstatus = true,
    icons_enabled = false,
    theme = "auto",
    component_separators = { left = "\u{2502}", right = "\u{2502}" },
    section_separators = { left = "\u{2590}", right = "\u{258c}" },
    disabled_filetypes = { "alpha", "dashboard", "NvimTree" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      {
        "branch",
        fmt = function(str) return "%@v:lua.LualineGitLog@ " .. str .. " %X" end,
      },
      { "diff", symbols = { added = "+", modified = "~", removed = "-" } },
    },
    lualine_c = {
      nav_buttons,
      {
        "filename",
        path = 1,
        symbols = { modified = " [+]", readonly = " [-]", unnamed = "[No Name]" },
      },
      breadcrumbs,
    },
    lualine_x = {
      { macro_recording, color = { fg = "#ff9e64", gui = "bold" } },
      { search_count, color = { fg = "#7aa2f7" } },
      "diagnostics",
      { lsp_status, color = { fg = "#9ece6a" } },
    },
    lualine_y = { "filetype" },
    lualine_z = { "location", "progress" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { { "filename", path = 1 } },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
}
