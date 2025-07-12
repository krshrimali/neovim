require "user.plugins"
require "user.keymaps"
require "user.autocommands"
require "user.colorscheme"
-- require "user.cmp"
-- require "user.lsp"
require "user.telescope"
require "user.treesitter"
require "user.comment"
require "user.gitsigns"
require "user.nvim-tree"
require "user.lualine"
require "user.toggleterm"
require "user.alpha"
require "user.whichkey"
require "user.numb"
require "user.colorizer"
require "user.spectre"
require "user.todo-comments"
require "user.git-blame"
require "user.notify"
-- require "user.ts-context"
require "user.registers"
require "user.functions"
require "user.illuminate"
-- require "user.lir"
require "user.cybu"
-- require "user.winbar"
require "user.options"
require "user.nvim-webdev-icons"
-- require "user.bfs"
require "user.bqf"
require "user.dressing"
require "user.auto-session"
require "user.surround"
require "user.vim-slash"
require "user.bufferline"
require "user.nvim_transparent"
-- require "user.copilot"
require "user.terminal"
require "user.gitlinker"
require("goto-preview").setup {}
require("alpha").setup(require("alpha.themes.dashboard").config)
require "user.oil"
require("oil").setup()
require("neogit").setup {}
require("telescope").load_extension "cmdline"

-- TODO: @krshrimali - look at these plugins and see if they are really useful
require "user.autopairs"

-- TODO: @krshrimali: testing without using these plugins for 7 days and checking if I really need them
-- require "user.project"
-- require "user.disable_diagnostics"
require("lsp_signature").setup({})
-- require("breadcrumbs").setup()
-- require("user.guard")
-- require("user.lspsaga")
require "user.indentline"

vim.lsp.enable('rust-analyzer')
vim.lsp.enable('pyright')
vim.lsp.enable('tsserver')
vim.lsp.enable('gopls')
vim.lsp.enable('clangd')
vim.lsp.enable('lua_ls')
require("mason").setup()
require("mason-lspconfig").setup {}
