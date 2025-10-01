-- Rust keymaps (commented out - uncomment if you have rust-tools installed)
-- local opts = { noremap = true, silent = true, nowait = true }
-- vim.api.nvim_buf_set_keymap(0, "n", "<leader>Lh", "<cmd>RustToggleInlayHints<Cr>", opts)
-- vim.api.nvim_buf_set_keymap(0, "n", "<leader>Lt", "<cmd>lua _CARGO_TEST()<cr>", opts)
-- vim.api.nvim_buf_set_keymap(0, "n", "<leader>Lm", "<cmd>RustExpandMacro<Cr>", opts)
-- vim.api.nvim_buf_set_keymap(0, "n", "<leader>Lc", "<cmd>RustOpenCargo<Cr>", opts)
-- vim.api.nvim_buf_set_keymap(0, "n", "<leader>Lp", "<cmd>RustParentModule<Cr>", opts)
-- vim.api.nvim_buf_set_keymap(0, "n", "<leader>Ld", "<cmd>RustDebuggables<Cr>", opts)
-- vim.api.nvim_buf_set_keymap(0, "n", "<leader>Lv", "<cmd>RustViewCrateGraph<Cr>", opts)
-- vim.api.nvim_buf_set_keymap(0, "n", "<leader>LR", "<cmd>lua require('rust-tools/workspace_refresh')._reload_workspace_from_cargo_toml()<Cr>", opts)
-- vim.api.nvim_buf_set_keymap(0, "n", "<leader>Lo", "<cmd>RustOpenExternalDocs<Cr>", opts)

local notify_filter = vim.notify
vim.notify = function(msg, ...)
  if msg:match "message with no corresponding" then return end

  notify_filter(msg, ...)
end

vim.api.nvim_set_keymap("n", "<m-d>", "<cmd>RustOpenExternalDocs<Cr>", { noremap = true, silent = true })
