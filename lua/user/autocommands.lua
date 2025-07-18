vim.api.nvim_create_autocmd({ "User" }, {
  pattern = { "AlphaReady" },
  callback = function()
    vim.cmd [[
      set laststatus=0 | autocmd BufUnload <buffer> set laststatus=3
    ]]
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = {
    -- "Jaq",
    "qf",
    "help",
    "man",
    "lspinfo",
    "spectre_panel",
    "lir",
    "DressingSelect",
    "tsplayground",
    "Markdown",
  },
  callback = function()
    vim.cmd [[
      nnoremap <silent> <buffer> q :close<CR> 
      nnoremap <silent> <buffer> <esc> :close<CR> 
      set nobuflisted
    ]]
  end,
})

-- vim.api.nvim_create_autocmd({ "BufEnter" }, {
--   pattern = { "" },
--   callback = function()
--     local buf_ft = vim.bo.filetype
--     if buf_ft == "" or buf_ft == nil then
--       vim.cmd [[
--       nnoremap <silent> <buffer> q :close<CR> 
--       nnoremap <silent> <buffer> <c-j> j<CR> 
--       nnoremap <silent> <buffer> <c-k> k<CR> 
--       set nobuflisted 
--     ]]
--     end
--   end,
-- })

-- vim.api.nvim_create_autocmd({ "BufEnter" }, {
--   pattern = { "" },
--   callback = function()
--     local get_project_dir = function()
--       local cwd = vim.fn.getcwd()
--       local project_dir = vim.split(cwd, "/")
--       local project_name = project_dir[#project_dir]
--       return project_name
--     end

--     vim.opt.titlestring = get_project_dir() .. " - nvim"
--   end,
-- })

-- vim.api.nvim_create_autocmd({ "BufEnter" }, {
--   pattern = { "term://*" },
--   callback = function()
--     vim.cmd "set cmdheight=1"
--   end,
-- })

-- vim.api.nvim_create_autocmd({ "FileType" }, {
--   pattern = { "gitcommit", "markdown" },
--   callback = function()
--     vim.opt_local.wrap = true
--     vim.opt_local.spell = true
--   end,
-- })

-- vim.api.nvim_create_autocmd({ "FileType" }, {
--   pattern = { "lir" },
--   callback = function()
--     vim.opt_local.number = false
--     vim.opt_local.relativenumber = false
--   end,
-- })

-- vim.cmd "autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif"

-- vim.api.nvim_create_autocmd({ "CmdWinEnter" }, {
--   callback = function()
--     vim.cmd "quit"
--   end,
-- })

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function()
    vim.cmd "set formatoptions-=cro"
  end,
})

vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 200 }
  end,
})

-- vim.api.nvim_create_autocmd({ "VimEnter" }, {
--   callback = function()
--     vim.cmd "hi link illuminatedWord LspReferenceText"
--   end,
-- })

-- vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
--   pattern = { "*" },
--   callback = function()
--     vim.cmd "checktime"
--   end,
-- })

-- vim.api.nvim_create_autocmd({ "CursorHold" }, {
--   callback = function()
--     local status_ok, luasnip = pcall(require, "luasnip")
--     if not status_ok then
--       return
--     end
--     if luasnip.expand_or_jumpable() then
--       -- ask maintainer for option to make this silent
--       -- luasnip.unlink_current()
--       vim.cmd [[silent! lua require("luasnip").unlink_current()]]
--     end
--   end,
-- })

-- See: https://github.com/j-hui/fidget.nvim/issues/86
-- vim.api.nvim_create_autocmd("VimLeavePre", { command = [[silent! FidgetClose]] })

-- vim.api.nvim_create_autocmd(
--   { "BufWritePost", "BufEnter" },
--   { command = [[set nofoldenable foldmethod=manual foldlevelstart=99]] }
-- )

-- vim.api.nvim_create_autocmd({ "InsertEnter" }, {
--   callback = function()
--     vim.schedule(function()
--       local cmp = require "cmp"
--       cmp.complete {
--         config = { sources = { name = "buffer" }, { name = "copilot" } },
--       }
--     end)
--   end,
-- })

-- vim.cmd([[
-- autocmd CursorHold * call v:lua.s_on_insert_enter()
-- ]])

-- function s_on_insert_enter()
--   vim.schedule(function()
--     local cmp = require('cmp')
--     cmp.complete({
--       config = {
--         sources = {
--           { name = 'buffer' },
--           -- { name = 'copilot' },
--         }
--       }
--     })
--   end)
-- end

-- Open nvim-tree when nvim starts with no arguments
-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function()
--     if vim.fn.argc() == 0 and vim.fn.line2byte(vim.fn.line("$") + 1) == -1 then
--       -- Use vim.schedule to ensure nvim-tree is loaded and give time for other plugins
--       vim.schedule(function()
--         -- Give more time for plugins to load
--         vim.defer_fn(function()
--           local status_ok, nvim_tree = pcall(require, "nvim-tree.api")
--           if status_ok and nvim_tree then
--             nvim_tree.tree.toggle()
--           end
--         end, 100)
--       end)
--     end
--   end,
-- })

-- Autocommands for opening goto definition in horizontal and vertical splits
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "<leader>lgv", "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>", opts)
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "<leader>lgh", "<cmd>split | lua vim.lsp.buf.definition()<CR>", opts)
  end,
})
