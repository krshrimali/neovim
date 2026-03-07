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
  function() return "%@v:lua.LualineGoBack@  <-  %X %@v:lua.LualineGoForward@  ->  %X" end,
}

-- Clickable breadcrumbs component
_G.LualineBreadcrumbTargets = {}
local breadcrumb_state = { symbols = nil, bufnr = nil, changedtick = nil, display = "" }

function _G.LualineBreadcrumbClick(idx)
  local target = _G.LualineBreadcrumbTargets[idx]
  if not target then return end
  vim.api.nvim_win_set_cursor(0, { target.line + 1, target.col })
  vim.cmd("normal! zz")
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
        table.insert(result, { name = symbol.name, line = sel.start.line, col = sel.start.character })
        if symbol.children then
          find_containing_symbols(symbol.children, cursor_line, cursor_col, result)
        end
      end
    end
  end
  return result
end

-- Async symbol fetching - updates cache without blocking statusline
local function refresh_symbols(bufnr)
  if vim.bo[bufnr].buftype ~= "" then
    breadcrumb_state.symbols = nil
    return
  end
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
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
    local changedtick = vim.b[bufnr].changedtick
    if breadcrumb_state.bufnr ~= bufnr or breadcrumb_state.changedtick ~= changedtick then
      refresh_symbols(bufnr)
    end
  end,
})

-- Also refresh on CursorMoved so breadcrumbs update as you move (uses cached symbols)
vim.api.nvim_create_autocmd("CursorMoved", {
  callback = function() lualine.refresh() end,
})

local function get_breadcrumbs()
  if not breadcrumb_state.symbols then return "" end

  local ok, cursor = pcall(vim.api.nvim_win_get_cursor, 0)
  if not ok then return "" end

  local crumbs = find_containing_symbols(breadcrumb_state.symbols, cursor[1] - 1, cursor[2])
  if #crumbs == 0 then return "" end

  _G.LualineBreadcrumbTargets = {}
  local parts = {}
  for i, crumb in ipairs(crumbs) do
    _G.LualineBreadcrumbTargets[i] = { line = crumb.line, col = crumb.col }
    table.insert(parts, string.format("%%@%s@ %s %%X", bc_click(i), crumb.name))
  end
  return table.concat(parts, " > ")
end

local breadcrumbs = { get_breadcrumbs }

lualine.setup {
  options = {
    globalstatus = true,
    icons_enabled = false,
    theme = "auto", -- Light theme that works well
    component_separators = { left = "|", right = "|" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = { "alpha", "dashboard", "NvimTree" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    lualine_c = {
      nav_buttons,
      { "filename", path = 1 }, -- Relative path
      breadcrumbs,
    },
    lualine_x = { "diagnostics" },
    lualine_y = { "filetype" },
    lualine_z = { "location", "progress" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
}
