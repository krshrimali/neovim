local options = {
  pumblend = 0,
  backup = false, -- creates a backup file
  clipboard = "unnamedplus", -- allows neovim to access the system clipboard
  cmdheight = 0, -- more space in the neovim command line for displaying messages
  completeopt = { "menuone", "noselect" }, -- mostly just for cmp
  conceallevel = 0, -- so that `` is visible in markdown files
  fileencoding = "utf-8", -- the encoding written to a file
  hlsearch = true, -- highlight all matches on previous search pattern
  ignorecase = true, -- ignore case in search patterns
  mouse = "a", -- allow the mouse to be used in neovim
  pumheight = 10, -- pop up menu height
  showmode = false, -- we don't need to see things like -- INSERT -- anymore
  showtabline = 0, -- always show tabs
  smartcase = true, -- smart case
  smartindent = true, -- make indenting smarter again
  splitbelow = true, -- force all horizontal splits to go below current window
  splitright = true, -- force all vertical splits to go to the right of current window
  swapfile = false, -- creates a swapfile
  termguicolors = true, -- set term gui colors (most terminals support this)
  timeoutlen = 300, -- time to wait for a mapped sequence to complete (in milliseconds) - reduced for faster response
  undofile = true, -- enable persistent undo
  updatetime = 250, -- balanced for LSP responsiveness (4000ms default)
  writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
  expandtab = true, -- convert tabs to spaces
  shiftwidth = 4, -- the number of spaces inserted for each indentation
  tabstop = 4, -- insert 2 spaces for a tab
  cursorline = false, -- disable for better performance
  number = true, -- set numbered lines
  laststatus = 3,
  showcmd = true,
  ruler = false,
  relativenumber = false, -- set relative numbered lines
  numberwidth = 4, -- set number column width to 2 {default 4}
  signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
  wrap = true, -- display lines as one long line
  sidescrolloff = 8,
  guifont = "monospace:h17", -- the font used in graphical neovim applications
  title = true,
}
vim.opt.fillchars = vim.opt.fillchars + "eob: "
vim.opt.fillchars:append {
  stl = " ",
}
vim.opt.fillchars:append "fold:•"

vim.opt.shortmess:append "c"

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.cmd "set whichwrap+=<,>,[,],h,l"
vim.cmd [[set iskeyword+=-]]
vim.cmd "set sessionoptions-=folds"
vim.cmd [[autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o]] -- this seem to work

vim.filetype.add {
  extension = {
    conf = "dosini",
  },
}

vim.cmd [[autocmd TermOpen * setlocal signcolumn=no]]
vim.cmd [[let g:python_recommended_style = 0]]

vim.opt.foldmethod = "manual" -- Changed from expr for better performance
-- vim.wo.foldexpr = "nvim_treesitter#foldexpr()" -- Disabled for performance

vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1e222a" })
vim.opt.whichwrap:append "<>[]hl"

vim.g.transparent_enabled = true
vim.g.use_nerd_fonts = false

vim.o.foldcolumn = "1" -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = false
vim.opt.lazyredraw = true -- Don't redraw while executing macros
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

vim.api.nvim_command "highlight VertSplit guifg=fg guibg=bg"
vim.api.nvim_exec(
  [[
    autocmd FileType c,cpp setlocal shiftwidth=4 tabstop=4 expandtab
]],
  false
)

vim.g.tabby_inline_completion_keybinding_accept = "<M-y>" -- Disabled to avoid conflict with other keybindings
vim.opt.foldenable = false
vim.g.vim_ai_async_chat = 1
