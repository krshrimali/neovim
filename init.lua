-- require "user.hot-reload"
require "user.keymaps"
require "user.plugins"
require "user.autocommands"
require "user.colorscheme"
require "user.cmp"
-- require "user.navic"
-- require "user.lsp-inlayhints"
require "user.lsp"
require "user.telescope"
require "user.treesitter"
require "user.comment"
require "user.gitsigns"
require "user.nvim-tree"
require "user.lualine"
require "user.toggleterm"
-- require "user.impatient"
-- require "user.indentline"
require "user.alpha"
require "user.whichkey"
-- require "user.hop"
-- require "user.matchup"
require "user.numb"
-- require "user.dial"
require "user.colorizer"
require "user.spectre"
require "user.neoscroll"
require "user.todo-comments"
-- require "user.bookmark"
-- require "user.symbol-outline"
-- require "user.git-blame"
-- require "user.gist"
require "user.notify"
-- require "user.ts-context"
require "user.registers"
-- require "user.sniprun"
require "user.functions"
require "user.illuminate"
-- require "user.lir"
require "user.cybu"
require "user.winbar"
require "user.options"
require "user.nvim-webdev-icons"
-- require "user.bfs"
require "user.bqf"
-- require "user.crates"
require "user.dressing"
-- require "user.tabout"
-- require "user.fidget"
-- require "user.browse"
require "user.auto-session"
-- require "user.jaq"
require "user.surround"
-- require "user.harpoon"
-- require "user.lab"
require "user.vim-slash"
-- require "user.bufferline"
require "user.nvim_transparent"
-- require "user.fold"
-- require "user.fold_preview"
-- require "user.bracketed"
-- require "user.feline"
-- require "user.modicator"
-- require "user.dap"
-- require "user.copilot"
require "user.terminal"
require("goto-preview").setup {}
require("gitlinker").setup {}
-- require "treesj".setup({})
require("nvim-surround").setup()
require("alpha").setup(require("alpha.themes.dashboard").config)
-- require("project_nvim").setup {}
require("neoclip").setup()
-- require "fold-preview".setup({})
require "user.oil"
require("oil").setup()
require("ufo").setup {
  provider_selector = function(bufnr, filetype, buftype)
    return { "treesitter", "indent" }
  end,
}
require("neogit").setup {}
-- require "gitlinker".setup({})
require("telescope").load_extension "cmdline"
-- require "user.finecmdline"
require("aerial").setup {}
require "user.ufo"
require("mason").setup({})
-- require("mason-lspconfig").setup({})
require "user.statuscol"

-- TODO: @krshrimali - look at these plugins and see if they are really useful
require "user.autopairs"
-- require("hoverhints").setup({})
-- require("neoscopes").setup({})

-- TODO: @krshrimali: testing without using these plugins for 7 days and checking if I really need them
-- require "user.project"
-- require "user.zen-mode"
require "user.noice"
