require "user.plugins"
require "user.keymaps"
require "user.autocommands"
require "user.colorscheme"
require "user.telescope"
require "user.treesitter"
require "user.comment"
require "user.gitsigns"
require "user.nvim-tree"
require "user.lualine"
require "user.toggleterm"
require "user.whichkey"
require "user.numb"
require "user.colorizer"
require "user.spectre"
require "user.todo-comments"
require "user.git-blame"
require "user.notify"
require "user.registers"
require "user.functions"
require "user.illuminate"
require "user.cybu"
require "user.options"
require "user.bqf"
require "user.dressing"
require "user.auto-session"
require "user.surround"
require "user.bufferline"
require "user.nvim_transparent"
require "user.terminal"
require("goto-preview").setup {}
require "user.oil"
require("oil").setup()
require("neogit").setup {}
require("telescope").load_extension "cmdline"
require "user.autopairs"
require("lsp_signature").setup({})
require "user.indentline"

vim.lsp.enable('rust-analyzer')
vim.lsp.enable('pyright')
vim.lsp.enable('tsserver')
vim.lsp.enable('gopls')
vim.lsp.enable('clangd')
vim.lsp.enable('lua_ls')
require("mason").setup()
require("mason-lspconfig").setup {}
