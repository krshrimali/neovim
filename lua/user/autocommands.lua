-- Auto-open simple tree when starting Neovim (replaced nvim-tree)
-- vim.api.nvim_create_autocmd({ "VimEnter" }, {
--   callback = function()
--     -- Only open tree if no file was specified on the command line
--     if vim.fn.argc() == 0 then
--       require("user.simple_tree").open_workspace()
--     end
--   end,
-- })

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

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function() vim.cmd "set formatoptions-=cro" end,
})

vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  callback = function() vim.highlight.on_yank { higroup = "Visual", timeout = 200 } end,
})
