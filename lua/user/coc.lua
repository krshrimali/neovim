-- CoC.nvim configuration for fast LSP functionality
-- Replaces native LSP for hover, completion, and other features

-- CoC extensions to install
vim.g.coc_global_extensions = {
  'coc-pyright',      -- Python
  'coc-json',         -- JSON
  'coc-yaml',         -- YAML
  'coc-toml',         -- TOML
  'coc-lua',          -- Lua
  'coc-tsserver',     -- TypeScript/JavaScript
  'coc-rust-analyzer', -- Rust
  'coc-go',           -- Go
  'coc-clangd',       -- C/C++
  'coc-sh',           -- Shell/Bash
  'coc-vimlsp',       -- Vim script
  'coc-html',         -- HTML
  'coc-css',          -- CSS
  'coc-prettier',     -- Prettier formatter
  'coc-pairs',        -- Auto pairs
  'coc-highlight',    -- Color highlighting
}

-- CoC settings
vim.g.coc_config_home = vim.fn.stdpath('config')

-- Basic CoC configuration
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.updatetime = 300
vim.opt.signcolumn = "yes"

-- Highlight the symbol and its references when holding the cursor
vim.api.nvim_create_augroup("CocGroup", {})
vim.api.nvim_create_autocmd("CursorHold", {
  group = "CocGroup",
  pattern = "*",
  callback = function()
    vim.fn.CocActionAsync('highlight')
  end,
  desc = "Highlight symbol under cursor on CursorHold"
})

-- Setup keymaps for CoC
local keyset = vim.keymap.set
local opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}

-- Use Tab for trigger completion with characters ahead and navigate
function _G.check_back_space()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Use Tab and S-Tab to navigate completion list
keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

-- Make <CR> to accept selected completion item
keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

-- Use <c-space> to trigger completion
keyset("i", "<c-space>", "coc#refresh()", opts)

-- Use `[g` and `]g` to navigate diagnostics
keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", {silent = true})
keyset("n", "]g", "<Plug>(coc-diagnostic-next)", {silent = true})

-- GoTo code navigation
keyset("n", "gd", "<Plug>(coc-definition)", {silent = true})
keyset("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
keyset("n", "gi", "<Plug>(coc-implementation)", {silent = true})
keyset("n", "gr", "<Plug>(coc-references)", {silent = true})

-- Use K to show documentation in preview window (FAST!)
-- Press K twice to focus the documentation window
local hover_timer = nil
local hover_count = 0

function _G.show_docs()
  -- Cancel any existing timer
  if hover_timer then
    vim.fn.timer_stop(hover_timer)
  end
  
  hover_count = hover_count + 1
  
  if hover_count == 1 then
    -- First press: show documentation
    local cw = vim.fn.expand('<cword>')
    if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
      vim.api.nvim_command('h ' .. cw)
    elseif vim.api.nvim_eval('coc#rpc#ready()') then
      vim.fn.CocActionAsync('doHover')
    else
      vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
    end
    
    -- Set timer to reset count after 500ms
    hover_timer = vim.fn.timer_start(500, function()
      hover_count = 0
    end)
  elseif hover_count >= 2 then
    -- Second press: focus the float window
    if vim.fn['coc#float#has_float']() == 1 then
      vim.fn['coc#float#jump']()
      -- Map 'q' to close the window when focused
      vim.api.nvim_buf_set_keymap(0, 'n', 'q', '<CMD>call coc#float#close_all()<CR>', {silent = true, nowait = true})
      -- Also map Escape to close
      vim.api.nvim_buf_set_keymap(0, 'n', '<Esc>', '<CMD>call coc#float#close_all()<CR>', {silent = true, nowait = true})
    end
    hover_count = 0
  end
end

keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', {silent = true})

-- Rename symbol
keyset("n", "<leader>rn", "<Plug>(coc-rename)", {silent = true})

-- Format selected code
keyset("x", "<leader>f", "<Plug>(coc-format-selected)", {silent = true})
keyset("n", "<leader>f", "<Plug>(coc-format-selected)", {silent = true})

-- Apply code action to the selected region
keyset("x", "<leader>a", "<Plug>(coc-codeaction-selected)", {silent = true})
keyset("n", "<leader>a", "<Plug>(coc-codeaction-selected)", {silent = true})

-- Remap keys for apply code actions
keyset("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", {silent = true})
keyset("n", "<leader>as", "<Plug>(coc-codeaction-source)", {silent = true})
keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", {silent = true})

-- Remap keys for apply refactor code actions
keyset("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", { silent = true })
keyset("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })
keyset("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })

-- Run the Code Lens action
keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)", {silent = true})

-- Map function and class text objects
keyset("x", "if", "<Plug>(coc-funcobj-i)", {silent = true})
keyset("o", "if", "<Plug>(coc-funcobj-i)", {silent = true})
keyset("x", "af", "<Plug>(coc-funcobj-a)", {silent = true})
keyset("o", "af", "<Plug>(coc-funcobj-a)", {silent = true})
keyset("x", "ic", "<Plug>(coc-classobj-i)", {silent = true})
keyset("o", "ic", "<Plug>(coc-classobj-i)", {silent = true})
keyset("x", "ac", "<Plug>(coc-classobj-a)", {silent = true})
keyset("o", "ac", "<Plug>(coc-classobj-a)", {silent = true})

-- Scroll float windows/popups
keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', {silent = true, nowait = true, expr = true})
keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', {silent = true, nowait = true, expr = true})
keyset("i", "<C-f>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', {silent = true, nowait = true, expr = true})
keyset("i", "<C-b>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', {silent = true, nowait = true, expr = true})
keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', {silent = true, nowait = true, expr = true})
keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', {silent = true, nowait = true, expr = true})

-- Use CTRL-S for selections ranges
keyset("n", "<C-s>", "<Plug>(coc-range-select)", {silent = true})
keyset("x", "<C-s>", "<Plug>(coc-range-select)", {silent = true})

-- Add `:Format` command to format current buffer
vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

-- Add `:Fold` command to fold current buffer
vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", {nargs = '?'})

-- Add `:OR` command for organize imports
vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})

-- Show all diagnostics
keyset("n", "<leader>Da", ":<C-u>CocList diagnostics<cr>", {silent = true, nowait = true})
-- Manage extensions
keyset("n", "<leader>De", ":<C-u>CocList extensions<cr>", {silent = true, nowait = true})
-- Show commands
keyset("n", "<leader>Dc", ":<C-u>CocList commands<cr>", {silent = true, nowait = true})
-- Find symbol of current document
keyset("n", "<leader>Do", ":<C-u>CocList outline<cr>", {silent = true, nowait = true})
-- Search workspace symbols
keyset("n", "<leader>Ds", ":<C-u>CocList -I symbols<cr>", {silent = true, nowait = true})
-- Do default action for next item
keyset("n", "<leader>Dj", ":<C-u>CocNext<cr>", {silent = true, nowait = true})
-- Do default action for previous item
keyset("n", "<leader>Dk", ":<C-u>CocPrev<cr>", {silent = true, nowait = true})
-- Resume latest coc list
keyset("n", "<leader>Dp", ":<C-u>CocListResume<cr>", {silent = true, nowait = true})

-- Status line support (disabled as we're using lualine)
-- vim.opt.statusline = vim.opt.statusline + "%{coc#status()}%{get(b:,'coc_current_function','')}"

-- Diagnostic hover with double-press focus (like K for documentation)
local diag_timer = nil
local diag_count = 0

function _G.show_diagnostics()
  -- Cancel any existing timer
  if diag_timer then
    vim.fn.timer_stop(diag_timer)
  end
  
  diag_count = diag_count + 1
  
  if diag_count == 1 then
    -- First press: show diagnostics
    vim.fn.CocActionAsync('diagnosticInfo')
    
    -- Set timer to reset count after 500ms
    diag_timer = vim.fn.timer_start(500, function()
      diag_count = 0
    end)
  elseif diag_count >= 2 then
    -- Second press: focus the diagnostic float window
    if vim.fn['coc#float#has_float']() == 1 then
      vim.fn['coc#float#jump']()
      -- Map 'q' to close the window when focused
      vim.api.nvim_buf_set_keymap(0, 'n', 'q', '<CMD>call coc#float#close_all()<CR>', {silent = true, nowait = true})
      -- Also map Escape to close
      vim.api.nvim_buf_set_keymap(0, 'n', '<Esc>', '<CMD>call coc#float#close_all()<CR>', {silent = true, nowait = true})
    end
    diag_count = 0
  end
end

-- Map <leader>d to show diagnostics (press twice to focus)
keyset("n", "<leader>d", '<CMD>lua _G.show_diagnostics()<CR>', {silent = true, desc = "Show diagnostics (press twice to focus)"})

-- Alternative: use gl for diagnostics (similar to VSCode)
keyset("n", "gl", '<CMD>lua _G.show_diagnostics()<CR>', {silent = true, desc = "Show line diagnostics"})

-- Show all diagnostics in current buffer
keyset("n", "<leader>dd", '<CMD>CocList diagnostics<CR>', {silent = true, desc = "Show all diagnostics"})

-- Additional convenience keymaps
-- Close all float windows with <leader>q or Shift+Escape
keyset("n", "<leader>Q", "<CMD>call coc#float#close_all()<CR>", {silent = true, desc = "Close all float windows"})
keyset("n", "<S-Esc>", "<CMD>call coc#float#close_all()<CR>", {silent = true, desc = "Close all float windows"})

-- Auto-close float windows on cursor move (optional - uncomment if desired)
-- vim.api.nvim_create_autocmd("CursorMoved", {
--   group = "CocGroup",
--   pattern = "*",
--   callback = function()
--     if vim.fn['coc#float#has_float']() == 1 and not vim.fn['coc#float#get_float_win_list']()[1] then
--       vim.fn['coc#float#close_all']()
--     end
--   end,
-- })