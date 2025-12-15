-- https://raw.githubusercontent.com/neoclide/coc.nvim/master/doc/coc-example-config.lua
-- Some servers have issues with backup files, see #649
vim.opt.backup = false
vim.opt.writebackup = false

-- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
-- delays and poor user experience
vim.opt.updatetime = 300

-- Always show the signcolumn, otherwise it would shift the text each time
-- diagnostics appeared/became resolved
vim.opt.signcolumn = "yes"

local keyset = vim.keymap.set
-- Autocomplete
function _G.check_back_space()
  local col = vim.fn.col "." - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match "%s" ~= nil
end

-- Use Tab to cycle and navigate through completions
local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

-- Make <CR> to accept selected completion item or notify coc.nvim to format
-- Since C-y works, make Enter do exactly the same thing when popup is visible
-- When popup is not visible, still call coc#on_enter() for auto-imports
vim.cmd [[
  function! SmartEnter()
    if pumvisible()
      return "\<C-y>"
    else
      return "\<CR>\<c-r>=coc#on_enter()\<CR>"
    endif
  endfunction
  
  inoremap <silent><expr> <CR> SmartEnter()
]]

-- Use <c-j> to trigger snippets
keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")

-- Completion toggle state (false = disabled by default)
_G.coc_completion_enabled = false

-- Function to toggle auto-completion
_G.toggle_coc_completion = function()
  _G.coc_completion_enabled = not _G.coc_completion_enabled
  if _G.coc_completion_enabled then
    -- Enable auto-completion
    vim.fn.CocAction("updateConfig", "suggest.autoTrigger", "always")
    vim.notify("Auto-completion enabled", vim.log.levels.INFO)
  else
    -- Disable auto-completion
    vim.fn.CocAction("updateConfig", "suggest.autoTrigger", "none")
    vim.notify("Auto-completion disabled", vim.log.levels.INFO)
  end
end

-- Toggle completion with <leader>tc
keyset("n", "<leader>tc", "<cmd>lua _G.toggle_coc_completion()<CR>", { silent = true, noremap = true })

-- Manual completion trigger with Ctrl+Space (one-time trigger only)
keyset("i", "<c-space>", "coc#refresh()", { silent = true, expr = true })

-- Since Enter doesn't work, make C-y the primary accept key
-- C-y will accept the completion and trigger auto-imports
keyset("i", "<C-y>", [[pumvisible() ? "\<C-y>" : "\<C-y>"]], opts)

-- Use `[g` and `]g` to navigate diagnostics
-- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", { silent = true })
keyset("n", "]g", "<Plug>(coc-diagnostic-next)", { silent = true })

-- GoTo code navigation
keyset("n", "gd", "<Plug>(coc-definition)", { silent = true })
keyset("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
keyset("n", "gi", "<Plug>(coc-implementation)", { silent = true })
keyset("n", "gr", "<Plug>(coc-references)", { silent = true })

-- Use K to show documentation in preview window
-- Press K again to focus the documentation window
-- Press q to close it
function _G.show_docs()
  local cw = vim.fn.expand "<cword>"
  if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
    vim.api.nvim_command("h " .. cw)
  elseif vim.api.nvim_eval "coc#rpc#ready()" then
    -- Get all floating windows from CoC
    local has_float = vim.fn["coc#float#has_float"]()

    if has_float == 1 then
      -- If float window exists, try to jump to it
      local winids = vim.fn["coc#float#get_float_win_list"]()
      if winids and #winids > 0 then
        -- Find the first visible floating window
        for _, winid in ipairs(winids) do
          if vim.api.nvim_win_is_valid(winid) then
            vim.api.nvim_set_current_win(winid)
            -- Set up q to close when in the float window
            local bufnr = vim.api.nvim_win_get_buf(winid)
            vim.keymap.set(
              "n",
              "q",
              function() vim.api.nvim_win_close(winid, true) end,
              { buffer = bufnr, silent = true, noremap = true, nowait = true }
            )
            return
          end
        end
      end
    end

    -- No float window exists, show hover
    vim.fn.CocActionAsync "doHover"
  else
    vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
  end
end
keyset("n", "K", "<CMD>lua _G.show_docs()<CR>", { silent = true })

-- Setup enhanced highlight groups for better visuals
vim.cmd [[
  " ============ Completion Menu ============
  " Main completion popup background
  highlight CocFloating guibg=#1e1e2e guifg=#cdd6f4

  " Completion menu borders
  highlight CocMenuBorder guifg=#89b4fa guibg=#1e1e2e
  highlight CocHoverBorder guifg=#f5c2e7 guibg=#1e1e2e
  highlight CocSignatureBorder guifg=#a6e3a1 guibg=#1e1e2e

  " Selected item in completion menu (current selection)
  highlight CocMenuSel guibg=#313244 guifg=#cdd6f4 gui=bold

  " Matched characters in completion (the part you typed)
  highlight CocSearch guifg=#f9e2af gui=bold

  " Completion item kinds with color coding
  highlight CocSymbolClass guifg=#89b4fa
  highlight CocSymbolFunction guifg=#a6e3a1
  highlight CocSymbolMethod guifg=#a6e3a1
  highlight CocSymbolVariable guifg=#cdd6f4
  highlight CocSymbolInterface guifg=#94e2d5
  highlight CocSymbolConstant guifg=#fab387
  highlight CocSymbolEnum guifg=#f5c2e7

  " Ghost text / inline preview
  highlight CocInlinePreview guifg=#6c7086 gui=italic
  highlight CocVirtualText guifg=#6c7086 gui=italic

  " ============ Diagnostics ============
  " Diagnostic signs in the gutter
  highlight CocErrorSign guifg=#f38ba8 guibg=NONE gui=bold
  highlight CocWarningSign guifg=#fab387 guibg=NONE gui=bold
  highlight CocInfoSign guifg=#89dceb guibg=NONE
  highlight CocHintSign guifg=#94e2d5 guibg=NONE

  " Diagnostic underlines in the code
  highlight CocErrorHighlight gui=undercurl guisp=#f38ba8
  highlight CocWarningHighlight gui=undercurl guisp=#fab387
  highlight CocInfoHighlight gui=undercurl guisp=#89dceb
  highlight CocHintHighlight gui=undercurl guisp=#94e2d5

  " Diagnostic floating window border
  highlight CocDiagnosticBorder guifg=#f38ba8 guibg=#1e1e2e

  " Diagnostic virtual text (if enabled)
  highlight CocErrorVirtualText guifg=#f38ba8 gui=italic
  highlight CocWarningVirtualText guifg=#fab387 gui=italic
  highlight CocInfoVirtualText guifg=#89dceb gui=italic
  highlight CocHintVirtualText guifg=#94e2d5 gui=italic

  " Diagnostic text in floating windows
  highlight CocErrorFloat guifg=#f38ba8 guibg=#1e1e2e
  highlight CocWarningFloat guifg=#fab387 guibg=#1e1e2e
  highlight CocInfoFloat guifg=#89dceb guibg=#1e1e2e
  highlight CocHintFloat guifg=#94e2d5 guibg=#1e1e2e

  " ============ Other UI Elements ============
  " Hover documentation
  highlight CocFloatingBorder guifg=#89b4fa guibg=#1e1e2e

  " Current function in statusline
  highlight CocStatuslineFunction guifg=#a6e3a1

  " Scrollbar in floating windows
  highlight CocScrollbar guifg=#585b70

  " Highlighted symbol (when cursor on symbol)
  highlight CocHighlightText guibg=#313244 gui=NONE
  highlight CocHighlightRead guibg=#313244 gui=NONE
  highlight CocHighlightWrite guibg=#45475a gui=NONE
]]

-- Highlight the symbol and its references on a CursorHold event(cursor is idle)
vim.api.nvim_create_augroup("CocGroup", {})
vim.api.nvim_create_autocmd("CursorHold", {
  group = "CocGroup",
  command = "silent call CocActionAsync('highlight')",
  desc = "Highlight symbol under cursor on CursorHold",
})

-- Symbol renaming
keyset("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true })

-- Formatting selected code
keyset("x", "<leader>f", "<Plug>(coc-format-selected)", { silent = true })
keyset("n", "<leader>f", "<Plug>(coc-format-selected)", { silent = true })

-- Setup formatexpr specified filetype(s)
vim.api.nvim_create_autocmd("FileType", {
  group = "CocGroup",
  pattern = "typescript,json",
  command = "setl formatexpr=CocAction('formatSelected')",
  desc = "Setup formatexpr specified filetype(s).",
})

-- Apply codeAction to the selected region
-- Example: `<leader>aap` for current paragraph
local opts = { silent = true, nowait = true }
keyset("x", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)
keyset("n", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)

-- Remap keys for apply code actions at the cursor position.
keyset("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", opts)
-- Remap keys for apply source code actions for current file.
keyset("n", "<leader>as", "<Plug>(coc-codeaction-source)", opts)
-- Apply the most preferred quickfix action on the current line.
keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", opts)

-- Remap keys for apply refactor code actions.
keyset("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", { silent = true })
keyset("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })
keyset("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })

-- Run the Code Lens actions on the current line
keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)", opts)

-- Map function and class text objects
-- NOTE: Requires 'textDocument.documentSymbol' support from the language server
keyset("x", "if", "<Plug>(coc-funcobj-i)", opts)
keyset("o", "if", "<Plug>(coc-funcobj-i)", opts)
keyset("x", "af", "<Plug>(coc-funcobj-a)", opts)
keyset("o", "af", "<Plug>(coc-funcobj-a)", opts)
keyset("x", "ic", "<Plug>(coc-classobj-i)", opts)
keyset("o", "ic", "<Plug>(coc-classobj-i)", opts)
keyset("x", "ac", "<Plug>(coc-classobj-a)", opts)
keyset("o", "ac", "<Plug>(coc-classobj-a)", opts)

-- Remap <C-f> and <C-b> to scroll float windows/popups
---@diagnostic disable-next-line: redefined-local
local opts = { silent = true, nowait = true, expr = true }
keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
keyset("i", "<C-f>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
keyset("i", "<C-b>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)

-- Use CTRL-S for selections ranges
-- Requires 'textDocument/selectionRange' support of language server
keyset("n", "<C-s>", "<Plug>(coc-range-select)", { silent = true })
keyset("x", "<C-s>", "<Plug>(coc-range-select)", { silent = true })

-- Add `:Format` command to format current buffer
vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

-- " Add `:Fold` command to fold current buffer
vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", { nargs = "?" })

-- Add `:OR` command for organize imports of the current buffer
vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})

-- Add (Neo)Vim's native statusline support
-- NOTE: Please see `:h coc-status` for integrations with external plugins that
-- provide custom statusline: lightline.vim, vim-airline
vim.opt.statusline:prepend "%{coc#status()}%{get(b:,'coc_current_function','')}"

-- Fix Enter key for completion (disabled - using native mapping above)
-- require("user.coc-enter-fix").setup()

-- Mappings for CoCList
-- code actions and coc stuff
---@diagnostic disable-next-line: redefined-local
local opts = { silent = true, nowait = true }
-- Show all diagnostics
keyset("n", "<space>a", ":<C-u>CocList diagnostics<cr>", opts)
-- Manage extensions
keyset("n", "<space>e", ":<C-u>CocList extensions<cr>", opts)
-- Show commands
keyset("n", "<space>c", ":<C-u>CocList commands<cr>", opts)
-- Find symbol of current document
keyset("n", "<space>o", ":<C-u>CocList outline<cr>", opts)
-- Search workspace symbols
keyset("n", "<space>s", ":<C-u>CocList -I symbols<cr>", opts)
-- Do default action for next item
keyset("n", "<space>j", ":<C-u>CocNext<cr>", opts)
-- Do default action for previous item
keyset("n", "<space>k", ":<C-u>CocPrev<cr>", opts)
-- Resume latest coc list
keyset("n", "<space>p", ":<C-u>CocListResume<cr>", opts)
