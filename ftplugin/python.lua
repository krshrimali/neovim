vim.opt.foldmethod = "indent"

-- Configure ruff for formatting
vim.opt_local.formatprg = "ruff format -"

-- Set up keymaps for Python-specific actions
local opts = { noremap = true, silent = true, buffer = true }

-- Format current buffer with ruff
vim.keymap.set("n", "<leader>rf", function()
    vim.cmd("silent! %!ruff format -")
end, vim.tbl_extend("force", opts, { desc = "Format with ruff" }))

-- Run ruff check on current file
vim.keymap.set("n", "<leader>rc", function()
    vim.cmd("!ruff check " .. vim.fn.expand("%"))
end, vim.tbl_extend("force", opts, { desc = "Check with ruff" }))

-- Auto-format on save (optional, can be disabled if not desired)
vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = 0,
    callback = function()
        if vim.g.ruff_format_on_save ~= false then
            vim.lsp.buf.format({ async = false })
        end
    end,
    desc = "Format Python file with ruff on save"
})
