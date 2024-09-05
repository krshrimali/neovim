local function disable_diagnostics_for_large_python_files()
  -- Define the maximum allowed file size (in bytes)
  local max_file_size = 100 * 1024 -- > 100 KB

  local file = vim.fn.expand('%:p')
  if file == '' then
    return
  end
  local file_size = vim.fn.getfsize(file)
  if file_size == -1 then
    return
  end
  local filetype = vim.bo.filetype
  if filetype == '' then
    return
  end

  vim.notify("File path: " .. file, vim.log.levels.INFO)
  vim.notify("File size: " .. file_size, vim.log.levels.INFO)
  vim.notify("File type: " .. filetype, vim.log.levels.INFO)

  if file_size == nil then
    return
  end

  -- Disable diagnostics if the file is a Python file and its size exceeds the limit.
  if filetype == 'python' and file_size > max_filesize then
    vim.lsp.handlers['textDocument/publishDiagnostics'] = function() end
    if vim.fn.exists(":LspStop") == 2 then
      vim.cmd("LspStop")
    end
  end

end

vim.api.nvim_create_autocmd({"BufReadPost", "BufNewFile"}, {
  callback = function()
    vim.defer_fn(disable_diagnostics_for_large_python_files, 0)
  end
})
