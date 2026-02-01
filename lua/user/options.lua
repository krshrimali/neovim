-- Simplified Options - Inspired by Helix
local opt = vim.opt

-- General
opt.backup = false
opt.swapfile = false
opt.undofile = true
opt.writebackup = false
opt.clipboard = "unnamedplus"
opt.fileencoding = "utf-8"
opt.mouse = "a"
opt.title = true
opt.autoread = true

-- UI
opt.termguicolors = true
opt.number = true
opt.relativenumber = false
opt.signcolumn = "yes"
opt.cursorline = true
opt.showmode = false
opt.cmdheight = 0
opt.laststatus = 3
opt.pumheight = 10
opt.wrap = true
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Search
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Indentation
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Performance
opt.timeoutlen = 300
opt.updatetime = 400
opt.lazyredraw = true

-- Completion
opt.completeopt = { "menuone", "noselect" }
opt.shortmess:append "c"

-- Folding (disabled)
opt.foldenable = false
opt.foldmethod = "manual"

-- Misc
opt.fillchars = { eob = " ", vert = " " }
opt.whichwrap:append "<>[]hl"
opt.iskeyword:append "-"

-- Disable nerd fonts
vim.g.use_nerd_fonts = false

-- Auto-reload files
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  callback = function() vim.cmd "checktime" end,
})

-- Terminal signcolumn
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function() vim.opt_local.signcolumn = "no" end,
})
