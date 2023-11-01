local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
  return
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end

local tabnine_status_ok, _ = pcall(require, "user.tabnine")
if not tabnine_status_ok then
  return
end

local buffer_fts = {
  "markdown",
  "toml",
  "yaml",
  "json",
  -- "cpp",
  -- "py",
  -- "c"
}

local function contains(t, value)
  for _, v in pairs(t) do
    if v == value then
      return true
    end
  end
  return false
end

local compare = require "cmp.config.compare"

require("luasnip/loaders/from_vscode").lazy_load()

-- local check_backspace = function()
--   local col = vim.fn.col "." - 1
--   return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
-- end

local check_backspace = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

-- local icons = require "user.icons"

-- local kind_icons = icons.kind

vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
vim.api.nvim_set_hl(0, "CmpItemKindTabnine", { fg = "#CA42F0" })
vim.api.nvim_set_hl(0, "CmpItemKindEmoji", { fg = "#FDE030" })
vim.api.nvim_set_hl(0, "CmpItemKindCrate", { fg = "#F64D00" })

vim.g.cmp_active = true

cmp.setup {
  enabled = function()
    local buftype = vim.api.nvim_buf_get_option(0, "buftype")
    if buftype == "prompt" then
      return false
    end
    return vim.g.cmp_active
  end,
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = cmp.mapping.preset.insert {
    -- ["<C-m>"] = cmp.mapping(function(fallback)
    --   local suggestion = require("copilot.suggestion")
    --   if suggestion.is_visible() then
    --     suggestion.accept()
    --   elseif cmp.visible() then
    --       cmp.confirm({ select = true })
    --   elseif luasnip.expand_or_jumpable() then
    --     luasnip.expand_or_jump()
    --   elseif check_backspace() then
    --     cmp.complete()
    --     fallback()
    --   else
    --     fallback()
    --   end
    -- end, { "i", "c" }
    -- ),
    ["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
    ["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
    ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
    ["<C-Space>"] = cmp.mapping(
      cmp.mapping.complete {
        config = {
          sources = { { name = "copilot", group_index = 1, keyword_length = 0 }, { name = "buffer", group_index = 2 } },
        },
      },
      { "i", "c" }
    ),
    ["<m-o>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    -- ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ["<C-c>"] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
    ["<m-j>"] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
    ["<m-k>"] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
    ["<m-c>"] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
    ["<S-CR>"] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    -- ["<CR>"] = cmp.mapping.confirm { select = false },
    ["<CR>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        -- local confirm_opts = vim.deepcopy(confirm_opts) -- avoid mutating the original opts below
        local confirm_opts = vim.deepcopy { behavior = cmp.ConfirmBehavior.Replace, select = false }
        local is_insert_mode = function()
          return vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
        end
        if is_insert_mode() then -- prevent overwriting brackets
          confirm_opts.behavior = cmp.ConfirmBehavior.Insert
        end
        local entry = cmp.get_selected_entry()
        local is_copilot = entry and entry.source.name == "copilot"
        -- if is_copilot then
        --   confirm_opts.behavior = cmp.ConfirmBehavior.Replace
        --   confirm_opts.select = true
        -- end
        if cmp.confirm(confirm_opts) then
          return -- success, exit early
        end
      end
      fallback() -- if not exited early, always fallback
    end),
    ["<Right>"] = cmp.mapping.confirm { select = true },
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.jumpable(1) then
        luasnip.jump(1)
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif luasnip.expandable() then
        luasnip.expand()
      elseif check_backspace() then
        -- cmp.complete()
        fallback()
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
    -- ["<S-Tab>"] = cmp.mapping(function(fallback)
    --   if cmp.visible() then
    --     cmp.select_prev_item()
    --   elseif luasnip.jumpable(-1) then
    --     luasnip.jump(-1)
    --   else
    --     fallback()
    --   end
    -- end, {
    --   "i",
    --   "s",
    -- }),
  },
  formatting = {
    fields = { "abbr", "menu", "kind" },
    format = function(entry, vim_item)
      -- Kind icons
      -- vim_item.kind = kind_icons[vim_item.kind]

      -- if entry.source.name == "cmp_tabnine" then
      --   vim_item.kind = icons.misc.Robot
      --   vim_item.kind_hl_group = "CmpItemKindTabnine"
      -- end
      -- if entry.source.name == "copilot" then
      --   vim_item.kind = icons.git.Octoface
      --   vim_item.kind_hl_group = "CmpItemKindCopilot"
      -- end

      -- if entry.source.name == "emoji" then
      --   vim_item.kind = icons.misc.Smiley
      --   vim_item.kind_hl_group = "CmpItemKindEmoji"
      -- end

      -- if entry.source.name == "crates" then
      --   vim_item.kind = icons.misc.Package
      --   vim_item.kind_hl_group = "CmpItemKindCrate"
      -- end

      -- if entry.source.name == "lab.quick_data" then
      --   vim_item.kind = icons.misc.CircuitBoard
      --   vim_item.kind_hl_group = "CmpItemKindConstant"
      -- end

      -- NOTE: order matters
      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        nvim_lua = "[Nvim]",
        luasnip = "[Snippet]",
        buffer = "[Buffer]",
        path = "[Path]",
        emoji = "[Emoji]",
        -- nvim_lsp = "",
        -- nvim_lua = "",
        -- luasnip = "",
        -- buffer = "",
        -- path = "",
        -- emoji = "",
      })[entry.source.name]
      return vim_item
    end,
  },
  sources = {
    { name = "crates", group_index = 1 },
    -- {
    --   name = "copilot",
    --   -- keyword_length = 0,
    --   -- trigger_characters = {
    --   --   {
    --   --     ".",
    --   --     ":",
    --   --     "(",
    --   --     "'",
    --   --     '"',
    --   --     "[",
    --   --     ",",
    --   --     "#",
    --   --     "*",
    --   --     "@",
    --   --     "|",
    --   --     "=",
    --   --     "-",
    --   --     "{",
    --   --     "/",
    --   --     "\\",
    --   --     "+",
    --   --     "?",
    --   --     " ",
    --   --   },
    --   -- },
    -- },
    { name = "nvim_lsp", group_index = 2 },
    { name = "nvim_lua", group_index = 2 },
    { name = "luasnip", group_index = 2 },
    {
      name = "buffer",
      group_index = 2,
      keyword_length = 4,
      filter = function(entry, ctx)
        if not contains(buffer_fts, ctx.prev_context.filetype) then
          return true
        end
      end,
    },
    -- { name = "cmp_tabnine", group_index = 2 },
    { name = "path", group_index = 2 },
    { name = "emoji", group_index = 2 },
    { name = "lab.quick_data", keyword_length = 4, group_index = 2 },
  },
  sorting = {
    priority_weight = 2,
    comparators = {
      -- require("copilot_cmp.comparators").prioritize,
      -- require("copilot_cmp.comparators").score,
      compare.offset,
      compare.exact,
      -- compare.scopes,
      compare.score,
      compare.recently_used,
      compare.locality,
      -- compare.kind,
      compare.sort_text,
      compare.length,
      compare.order,
      -- require("copilot_cmp.comparators").prioritize,
      -- require("copilot_cmp.comparators").score,
    },
  },
  confirm_opts = {
    behavior = cmp.ConfirmBehavior.Replace,
    select = false,
  },
  window = {
    documentaton = true,
    documentation = {
      border = "rounded",
      -- winhighlight = "NormalFloat:Pmenu,NormalFloat:Pmenu,CursorLine:PmenuSel,Search:None",
      winhighlight = "NormalFloat:Pmenu,NormalFloat:Pmenu,CursorLine:Pmenu,Search:None",
      -- winhighlight = "NormalFloat, No"
    },
    -- documentation = false,
    completion = {
      border = "rounded",
      winhighlight = "NormalFloat:Pmenu,NormalFloat:Pmenu,CursorLine:PmenuSel,Search:None",
      -- winhighlight = "NormalFloat:Pmenu,NormalFloat:Pmenu,CursorLine:PmenuSel,Search:None",
    },
  },
  duplicates = {
    buffer = 1,
    path = 1,
    nvim_lsp = 0,
    luasnip = 1,
  },
  duplicates_default = 0,
  experimental = {
    ghost_text = false,
  },
  -- completion = {
  --   autocomplete = {
  --     cmp.TriggerEvent.TextChanged,
  --     cmp.TriggerEvent.InsertEnter,
  --   },
  --   completeopt = "menuone,noinsert,noselect",
  --   keyword_length=0,
  -- },
}
