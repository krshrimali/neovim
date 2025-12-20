-- Native Neovim Completion Configuration (vim.lsp.completion)
-- Neovim 0.11+ built-in LSP completion
-- See: https://neovim.io/doc/user/lsp.html#vim.lsp.completion

local M = {}

-- Track auto-completion state
_G.native_autocomplete_enabled = true

function M.setup()
  -- Native completion will be enabled per-buffer in the on_attach callback
  -- This is just a placeholder for consistency with the old blink.cmp structure
end

-- This function should be called in the LSP on_attach callback
function M.enable_for_buffer(client, bufnr)
  if not _G.native_autocomplete_enabled then
    return
  end

  -- Enable native LSP completion with auto-trigger
  -- Available in Neovim 0.11+
  local ok, err = pcall(function()
    vim.lsp.completion.enable(true, client.id, bufnr, {
      autotrigger = true,
    })
  end)

  if not ok then
    vim.notify("Failed to enable native completion: " .. tostring(err), vim.log.levels.WARN)
  end

  -- Set up completion-related keymaps for this buffer
  M.setup_keymaps(bufnr)
end

function M.setup_keymaps(bufnr)
  local opts = { buffer = bufnr, silent = true }

  -- Tab to navigate completion menu (if visible) or insert tab
  vim.keymap.set("i", "<Tab>", function()
    if vim.fn.pumvisible() == 1 then
      return "<C-n>"
    else
      return "<Tab>"
    end
  end, { buffer = bufnr, expr = true, silent = true })

  -- Shift-Tab to navigate backwards in completion menu
  vim.keymap.set("i", "<S-Tab>", function()
    if vim.fn.pumvisible() == 1 then
      return "<C-p>"
    else
      return "<S-Tab>"
    end
  end, { buffer = bufnr, expr = true, silent = true })

  -- Enter to accept completion
  vim.keymap.set("i", "<CR>", function()
    if vim.fn.pumvisible() == 1 then
      return "<C-y>"
    else
      return "<CR>"
    end
  end, { buffer = bufnr, expr = true, silent = true })

  -- Ctrl-Space to manually trigger completion
  vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", opts)

  -- Ctrl-y to accept completion (explicit)
  vim.keymap.set("i", "<C-y>", "<C-y>", opts)

  -- Ctrl-e to close completion menu
  vim.keymap.set("i", "<C-e>", "<C-e>", opts)
end

-- Toggle auto-completion (matching CoC's <leader>tc)
function M.toggle_autocomplete()
  _G.native_autocomplete_enabled = not _G.native_autocomplete_enabled

  if _G.native_autocomplete_enabled then
    vim.notify("Auto-completion enabled (will apply to new buffers)", vim.log.levels.INFO)
  else
    vim.notify("Auto-completion disabled (use C-Space or C-x C-o to trigger)", vim.log.levels.INFO)
  end

  -- Note: This only affects new buffers. Already attached buffers will keep their state.
  -- To fully toggle, would need to re-attach LSP to all buffers
end

return M
