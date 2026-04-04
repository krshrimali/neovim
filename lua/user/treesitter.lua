-- Neovim 0.12+ built-in treesitter configuration
-- Highlighting is enabled by default; this file handles disabling for specific cases
-- and configuring indent.

-- Filetypes where treesitter highlighting should be disabled
local disabled_hl_langs = { markdown = true, css = true, html = true }

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
  callback = function(args)
    local buf = args.buf
    local ft = args.match

    -- Disable for specific filetypes
    if disabled_hl_langs[ft] then
      vim.treesitter.stop(buf)
      return
    end

    -- Disable for terminal buffers
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
    if buftype == "terminal" then
      vim.treesitter.stop(buf)
      return
    end

    -- Disable for very large files (>500KB)
    local max_filesize = 500 * 1024
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
    if ok and stats and stats.size > max_filesize then
      vim.treesitter.stop(buf)
      return
    end
  end,
})

-- Enable treesitter-based indentation, except for these filetypes
local disabled_indent_langs =
  { python = true, css = true, rust = true, cpp = true, yaml = true, json = true, html = true, javascript = true }

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserTreesitterIndent", { clear = true }),
  callback = function(args)
    local ft = args.match
    if not disabled_indent_langs[ft] then vim.bo[args.buf].indentexpr = "v:lua.require'vim.treesitter'.indentexpr()" end
  end,
})
