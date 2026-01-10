local M = {}

-- Replaced nerd font icons with ASCII characters (consistent with icons.lua)
local kind_icons = {
  Text = "T",
  Method = "m",
  Function = "f",
  Constructor = "c",
  Field = "F",
  Variable = "v",
  Class = "C",
  Interface = "I",
  Module = "M",
  Property = "p",
  Unit = "u",
  Value = "V",
  Enum = "E",
  Keyword = "k",
  Snippet = "s",
  Color = "C",
  File = "f",
  Reference = "r",
  Folder = "d",
  EnumMember = "e",
  Constant = "c",
  Struct = "S",
  Event = "E",
  Operator = "o",
  TypeParameter = "t",
  Buffer = "B",
  Namespace = "N",
}

function M.setup()
  vim.opt.completeopt = { "menu", "menuone", "noinsert", "preview" }

  vim.opt.complete = ".,w,b,u,t,i,kspell"

  vim.opt.pumheight = 15
  vim.opt.pumwidth = 25

  vim.opt.wildmode = "list:longest,full"
  vim.opt.wildmenu = true
  vim.opt.wildoptions = "pum"

  vim.opt.omnifunc = "v:lua.vim.lsp.omnifunc"

  vim.opt.pumblend = 10

  vim.opt.showfulltag = true

  vim.opt.infercase = true
  vim.opt.ignorecase = true
  vim.opt.smartcase = true

  vim.opt.shortmess:remove "c"

  vim.opt.updatetime = 300

  vim.opt.completefunc = "v:lua.require'user.completion'.custom_complete"

  M.setup_highlights()
end

function M.custom_complete(findstart, base)
  if findstart == 1 then
    local line = vim.fn.getline "."
    local start = vim.fn.col "." - 1
    while start > 0 and line:sub(start, start):match "[%w_]" do
      start = start - 1
    end
    return start
  else
    local items = {}

    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local words = {}

    for _, line in ipairs(lines) do
      for word in line:gmatch "[%w_]+" do
        if word:find("^" .. vim.pesc(base)) and word ~= base then words[word] = true end
      end
    end

    for word, _ in pairs(words) do
      table.insert(items, {
        word = word,
        menu = "[Buffer]",
        kind = "B",
      })
    end

    return items
  end
end

function M.setup_highlights()
  vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#504945", fg = "#fbf1c7", bold = true })
  vim.api.nvim_set_hl(0, "Pmenu", { bg = "#282828", fg = "#ebdbb2" })
  vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#3c3836" })
  vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#504945" })

  vim.api.nvim_set_hl(0, "CompletionItemKindText", { fg = "#b8bb26" })
  vim.api.nvim_set_hl(0, "CompletionItemKindMethod", { fg = "#83a598" })
  vim.api.nvim_set_hl(0, "CompletionItemKindFunction", { fg = "#8ec07c" })
  vim.api.nvim_set_hl(0, "CompletionItemKindConstructor", { fg = "#fabd2f" })
  vim.api.nvim_set_hl(0, "CompletionItemKindField", { fg = "#fb4934" })
  vim.api.nvim_set_hl(0, "CompletionItemKindVariable", { fg = "#d3869b" })
  vim.api.nvim_set_hl(0, "CompletionItemKindClass", { fg = "#fe8019" })
end

function M.setup_keymaps()
  local opts = { noremap = true, silent = true }

  vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", opts)

  vim.keymap.set("i", "<C-n>", function()
    if vim.fn.pumvisible() == 1 then
      return "<C-n>"
    else
      return "<C-x><C-n>"
    end
  end, { expr = true, noremap = true })

  vim.keymap.set("i", "<C-p>", function()
    if vim.fn.pumvisible() == 1 then
      return "<C-p>"
    else
      return "<C-x><C-p>"
    end
  end, { expr = true, noremap = true })

  vim.keymap.set("i", "<Tab>", function()
    if vim.fn.pumvisible() == 1 then
      return "<C-n>"
    elseif vim.fn.col "." == 1 or vim.fn.getline("."):sub(vim.fn.col "." - 1, vim.fn.col "." - 1):match "%s" then
      return "<Tab>"
    else
      return "<C-n>"
    end
  end, { expr = true, noremap = true })

  vim.keymap.set("i", "<S-Tab>", function()
    if vim.fn.pumvisible() == 1 then
      return "<C-p>"
    else
      return "<S-Tab>"
    end
  end, { expr = true, noremap = true })

  vim.keymap.set("i", "<CR>", function()
    if vim.fn.pumvisible() == 1 then
      return "<C-y>"
    else
      return "<CR>"
    end
  end, { expr = true, noremap = true })

  vim.keymap.set("i", "<Esc>", function()
    if vim.fn.pumvisible() == 1 then
      return "<C-e><Esc>"
    else
      return "<Esc>"
    end
  end, { expr = true, noremap = true })
end

function M.format_completion_item(item, source)
  if not item then return item end

  local kind = vim.lsp.protocol.CompletionItemKind[item.kind] or "Text"
  local icon = kind_icons[kind] or ""

  local menu_text = ""
  if source == "lsp" then
    menu_text = "[LSP]"
  elseif source == "buffer" then
    menu_text = "[Buf]"
  elseif source == "path" then
    menu_text = "[Path]"
  elseif source == "snippet" then
    menu_text = "[Snip]"
  else
    menu_text = "[" .. (source or "?") .. "]"
  end

  if item.menu then
    item.menu = icon .. " " .. item.menu .. " " .. menu_text
  else
    item.menu = icon .. " " .. menu_text
  end

  return item
end

function M.setup_lsp_completion()
  local orig_omnifunc = vim.lsp.omnifunc

  vim.lsp.omnifunc = function(findstart, base)
    local result = orig_omnifunc(findstart, base)

    if findstart == 0 and type(result) == "table" then
      for i, item in ipairs(result) do
        result[i] = M.format_completion_item(item, "lsp")
      end
    end

    return result
  end
end

function M.setup_autocmds()
  local group = vim.api.nvim_create_augroup("NativeCompletion", { clear = true })

  M.setup_lsp_completion()

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "*",
    callback = function()
      local ft = vim.bo.filetype

      if ft == "python" then
        vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
      elseif ft == "lua" then
        vim.bo.omnifunc = "v:lua.vim.lua.omnifunc"
      elseif ft == "c" or ft == "cpp" then
        vim.bo.omnifunc = "ccomplete#Complete"
      elseif ft == "html" or ft == "xml" then
        vim.bo.omnifunc = "htmlcomplete#CompleteTags"
      elseif ft == "css" then
        vim.bo.omnifunc = "csscomplete#CompleteCSS"
      elseif ft == "javascript" or ft == "typescript" then
        vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
      else
        vim.bo.omnifunc = "syntaxcomplete#Complete"
      end
    end,
  })

  vim.api.nvim_create_autocmd("InsertCharPre", {
    group = group,
    pattern = "*",
    callback = function()
      local char = vim.v.char
      if char:match "[%w_]" then
        local col = vim.fn.col "." - 1
        local line = vim.fn.getline "."
        local before_cursor = line:sub(1, col)

        if before_cursor:match "[%w_]$" and #before_cursor >= 2 then
          vim.defer_fn(function()
            if vim.fn.mode() == "i" and vim.fn.pumvisible() == 0 then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-n>", true, false, true), "n", false)
            end
          end, 0)
        end
      end
    end,
  })

  vim.api.nvim_create_autocmd("TextChangedI", {
    group = group,
    pattern = "*",
    callback = function()
      local col = vim.fn.col "." - 1
      local line = vim.fn.getline "."
      local char_before = line:sub(col, col)

      if char_before == "." or char_before == ":" then
        if vim.bo.omnifunc ~= "" and vim.fn.pumvisible() == 0 then
          vim.defer_fn(function()
            if vim.fn.mode() == "i" then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-x><C-o>", true, false, true), "n", false)
            end
          end, 100)
        end
      end
    end,
  })

  vim.api.nvim_create_autocmd("CompleteChanged", {
    group = group,
    pattern = "*",
    callback = function()
      local completed_item = vim.v.completed_item
      if completed_item and completed_item.word then
        local kind = completed_item.kind or ""
        local menu = completed_item.menu or ""

        if kind ~= "" and not menu:match "^%[" then
          if vim.bo.omnifunc:match "lsp" then
            completed_item.menu = "[LSP] " .. menu
          elseif kind:match "^<" then
            completed_item.menu = "[Buf] " .. menu
          else
            completed_item.menu = "[" .. kind .. "] " .. menu
          end
        end
      end
    end,
  })
end

return M
