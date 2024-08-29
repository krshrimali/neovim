local status_ok, bigfile = pcall(require, "bigfile")
if not status_ok then
  return
end

bigfile.setup {
    -- detect long python files
    pattern = function(bufnr, _)
        -- you can't use `nvim_buf_line_count` because this runs on BufReadPre
        local file_contents = vim.fn.readfile(vim.api.nvim_buf_get_name(bufnr))
        local file_length = #file_contents
        local filetype = vim.filetype.match({ buf = bufnr })
        if file_length > 5000 and filetype == "python" then
            return true
        end
        return false
    end,
    filesize = 2,
    features = { -- features to disable
        "indent_blankline",
        "illuminate",
        -- "lsp",
        "treesitter",
        -- "syntax",
        -- "matchparen",
        "vimopts",
        "filetype",
    },
}
