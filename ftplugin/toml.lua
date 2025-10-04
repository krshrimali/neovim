vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  pattern = { "Cargo.toml" },
  callback = function()
    local opts = { noremap = true, silent = true, nowait = true }

    -- Cargo/Crates keymaps
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>Lt", "<cmd>lua require('crates').toggle()<CR>", opts)
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>Lu", "<cmd>lua require('crates').update_crate()<CR>", opts)
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>LU", "<cmd>lua require('crates').upgrade_crate()<CR>", opts)
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>La", "<cmd>lua require('crates').update_all_crates()<CR>", opts)
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>LA", "<cmd>lua require('crates').upgrade_all_crates()<CR>", opts)
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>Lh", "<cmd>lua require('crates').open_homepage()<CR>", opts)
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>Lr", "<cmd>lua require('crates').open_repository()<CR>", opts)
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>Ld", "<cmd>lua require('crates').open_documentation()<CR>", opts)
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>Lc", "<cmd>lua require('crates').open_crates_io()<CR>", opts)
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>Li", "<cmd>lua require('crates').show_popup()<CR>", opts)
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>Lv", "<cmd>lua require('crates').show_versions_popup()<CR>", opts)
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>Lf", "<cmd>lua require('crates').show_features_popup()<CR>", opts)
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>LD", "<cmd>lua require('crates').show_dependencies_popup()<CR>", opts)
  end,
})
