require("Navigator").setup()

-- vim.keymap.set({'n', 'v', 'o'}, '<m-k>', require('tree-climber').goto_parent, keyopts)
vim.keymap.set('n', "<A-h>", require('Navigator').left())
vim.keymap.set('n', "<A-l>", require('Navigator').right())
vim.keymap.set('n', "<A-k>", require('Navigator').up())
vim.keymap.set('n', "<A-j>", require('Navigator').down())
vim.keymap.set('n', "<A-p>", require('Navigator').previous())
