-- Simplified Options - Inspired by Helix
local opt = vim.opt

-- General
opt.backup = false
opt.swapfile = false
opt.undofile = true
opt.writebackup = false
opt.clipboard = "unnamedplus"

-- Over SSH, neovim would use xclip (present here) which writes to the *forwarded*
-- remote X clipboard, not your local machine. Force OSC 52 so yanks tunnel through
-- the terminal (zellij passes it through) to the local system clipboard.
if vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil then
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    -- Paste from nvim's own unnamed register instead of querying the terminal
    -- over OSC 52. The OSC 52 read (ESC]52;c;?) blocks waiting for a terminal
    -- reply that most terminals/zellij never send, hanging on "Waiting for
    -- OSC 52 response". Copy still tunnels out; paste stays local and instant.
    local function paste()
      return { vim.fn.split(vim.fn.getreg "", "\n"), vim.fn.getregtype "" }
    end
    vim.g.clipboard = {
      name = "OSC 52",
      copy = { ["+"] = osc52.copy "+", ["*"] = osc52.copy "*" },
      paste = { ["+"] = paste, ["*"] = paste },
    }
  end
end
opt.fileencoding = "utf-8"
opt.mouse = "a"
opt.mousemodel = "popup_setpos"
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

-- Completion
opt.completeopt = { "menuone", "noselect" }
opt.shortmess:append "c"

-- Folding (disabled)
opt.foldenable = false
opt.foldmethod = "manual"

-- Diff
opt.diffopt:append "linematch:60"

-- Misc
opt.fillchars = { eob = " ", vert = " " }
opt.whichwrap:append "<>[]hl"
opt.iskeyword:append "-"

-- Disable nerd fonts
vim.g.use_nerd_fonts = false

-- Auto-reload files
vim.api.nvim_create_autocmd({ "FocusGained" }, {
  callback = function() vim.cmd "checktime" end,
})

-- Terminal signcolumn
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function() vim.opt_local.signcolumn = "no" end,
})
