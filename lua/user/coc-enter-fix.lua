-- Fix for CoC Enter key not working properly
local M = {}

function M.setup()
  -- Ensure we override any existing mappings after all plugins load
  vim.defer_fn(function()
    -- Remove any existing Enter mappings first
    pcall(vim.keymap.del, "i", "<CR>")
    pcall(vim.keymap.del, "i", "<C-y>")

    -- Use the vimscript version which works better with CoC
    vim.cmd [[
      " Make <CR> accept selected completion item and trigger auto-import
      inoremap <silent><expr> <CR> coc#pum#visible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
      
      " Use <C-y> to confirm completion  
      inoremap <silent><expr> <C-y> coc#pum#visible() ? coc#_select_confirm() : "\<C-y>"
      
      " Debug: Check if popup is visible
      nnoremap <leader>cp :echo coc#pum#visible()<CR>
    ]]
  end, 100) -- Small delay to ensure CoC is loaded
end

return M
