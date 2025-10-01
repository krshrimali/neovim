local opts = { noremap = true, silent = true, nowait = true }

-- Go keymaps
vim.api.nvim_buf_set_keymap(0, "n", "<leader>Ci", "<cmd>GoInstallDeps<Cr>", opts)
vim.api.nvim_buf_set_keymap(0, "n", "<leader>Cf", "<cmd>GoMod tidy<cr>", opts)
vim.api.nvim_buf_set_keymap(0, "n", "<leader>Ca", "<cmd>GoTestAdd<Cr>", opts)
vim.api.nvim_buf_set_keymap(0, "n", "<leader>CA", "<cmd>GoTestsAll<Cr>", opts)
vim.api.nvim_buf_set_keymap(0, "n", "<leader>Ce", "<cmd>GoTestsExp<Cr>", opts)
vim.api.nvim_buf_set_keymap(0, "n", "<leader>Cg", "<cmd>GoGenerate<Cr>", opts)
vim.api.nvim_buf_set_keymap(0, "n", "<leader>CG", "<cmd>GoGenerate %<Cr>", opts)
vim.api.nvim_buf_set_keymap(0, "n", "<leader>Cc", "<cmd>GoCmt<Cr>", opts)
vim.api.nvim_buf_set_keymap(0, "n", "<leader>Ct", "<cmd>lua require('dap-go').debug_test()<cr>", opts)
