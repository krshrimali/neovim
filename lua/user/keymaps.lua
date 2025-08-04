-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Shorten function name
M = {}
local opts = { noremap = true, silent = true }

local keymap = vim.api.nvim_set_keymap

--Remap comma as leader key
vim.g.mkdp_browser = "microsoft-edge"

-- Normal --
keymap("n", "glb", "<cmd>Gitsigns blame_line<cr>", opts)

-- Better window navigation
-- keymap("n", "<m-h>", "<C-w>h", opts)
-- keymap("n", "<m-j>", "<C-w>j", opts)
-- keymap("n", "<m-k>", "<C-w>k", opts)
-- keymap("n", "<m-l>", "<C-w>l", opts)

keymap("n", "+", "<C-a>", opts)
keymap("n", "-", "<C-x>", opts)

-- Delete word backwards
keymap("n", "dw", 'vb"_d', opts)

-- Select all
keymap("n", "<C-a>", "gg<S-v>G", opts)

keymap("n", "<C-w><left>", "<C-w><", opts)
keymap("n", "<C-w><right>", "<C-w>>", opts)
keymap("n", "<C-w><up>", "<C-w>+", opts)
keymap("n", "<C-w><down>", "<C-w>-", opts)

-- -- Resize with arrows
-- Didnd't work well on Mac
-- keymap("n", "<m-S-k>", ":resize -2<CR>", opts)
-- keymap("n", "<m-S-j>", ":resize +2<CR>", opts)
-- keymap("n", "<m-S-l>", ":vertical resize -2<CR>", opts)
-- keymap("n", "<m-S-h>", ":vertical resize +2<CR>", opts)

-- Naviagate buffers
-- TODO: Maybe this is not required in favor of C-l, C-h
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- keymap("n", "<RightMouse>", ":Alpha<CR>", opts)

-- Move text up and down
-- keymap("n", "<S-f>", "<Esc>:m .+1<CR>", opts)
keymap("n", "<S-d>", "<Esc>:m .+1<CR>", opts)
keymap("n", "<S-u>", "<Esc>:m .-2<CR>", opts)

-- Insert --
-- Press jk fast to enter
-- TODO: Experimenting with this for now, and let's see how this goes
-- TODO: Map caps to control and use ctrl-C instead (no need to remap)
keymap("i", "jk", "<ESC>", opts)

-- Stay in indent mode
-- Visual --
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

keymap("v", "p", '"_dP', opts)

keymap("v", "F", ":m '>+1<CR>gv=gv", opts)
keymap("v", "U", ":m '<-2<CR>gv=gv", opts)

keymap("n", "<leader>d", '"_d', opts)
keymap("x", "<leader>d", '"_d', opts)
keymap("x", "<leader>p", '"_dP', opts)
-- keymap("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", opts)
keymap("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>//gI<Left><Left><Left>", opts)

-- NOTE: the fact that tab and ctrl-i are the same is stupid
keymap("n", "<leader>Q", "<cmd>bdelete!<CR>", opts)
keymap("n", "<F11>", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
keymap("n", "<F12>", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
keymap("n", "gR", "<cmd>lua vim.lsp.buf.references()<CR>", opts)

-- keymap("n", "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
-- keymap("n", "gi", "<cmd>lua vim.lsp.buf.incoming_calls()<CR>", opts)
keymap("n", "go", "<cmd>lua vim.lsp.buf.outgoing_calls()<CR>", opts)
keymap("n", "<C-p>", "<cmd>FzfLua files<cr>", opts)
keymap("n", "<C-s>", "<cmd>lua vim.lsp.buf.document_symbol()<cr>", opts)
keymap("n", "<C-z>", "<cmd>ZenMode<cr>", opts)

-- keymap("n", "-", ":lua require'lir.float'.toggle()<cr>", opts)

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

M.show_documentation = function()
    local filetype = vim.bo.filetype
    if vim.tbl_contains({ "vim", "help" }, filetype) then
        vim.cmd("h " .. vim.fn.expand "<cword>")
    elseif vim.tbl_contains({ "man" }, filetype) then
        vim.cmd("Man " .. vim.fn.expand "<cword>")
    elseif vim.fn.expand "%:t" == "Cargo.toml" then
        require("crates").show_popup()
    else
        vim.lsp.buf.hover()
    end
end

vim.api.nvim_set_keymap("n", "K", ":lua require('user.keymaps').show_documentation()<CR>", opts)

-- TODO: Rethink on this, currently not using it... (harpoon)
-- vim.api.nvim_set_keymap(
--   "n",
--   "<C-m>",
--   "<cmd>lua require('telescope').extensions.harpoon.marks(require('telescope.themes').get_dropdown{ layout_strategy = 'horizontal', layout_config = { width = function(_, max_columns, _) return math.min(max_columns, 120) end, height= function(_, _, max_lines) return math.min(max_lines, 30) end, }, initial_mode='normal', prompt_title='Harpoon'})<cr>",
--   opts
-- )

vim.api.nvim_set_keymap("n", "<s-t>", "<cmd>TodoQuickFix<cr>", opts)
vim.api.nvim_set_keymap("n", "<m-t>", "<cmd>TodoQuickFix<cr>", opts)

-- vim.api.nvim_set_keymap("n", "<leader>o", "<cmd>Portal jumplist backward<cr>", opts)
-- vim.api.nvim_set_keymap("n", "<leader>i", "<cmd>Portal jumplist forward<cr>", opts)

-- vim.api.nvim_set_keymap('v', '<leader>gLb', '<cmd>lua require"gitlinker".get_buf_range_url("v", {action_callback = require"gitlinker.actions".open_in_browser})<cr>', {})
vim.cmd [[
  function! QuickFixToggle()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen
    else
      cclose
    endif
  endfunction
]]

-- nvim-spider keymaps are now handled by the plugin's lazy loading configuration in plugins.lua

keymap("n", "<m-q>", ":call QuickFixToggle()<cr>", opts)

-- imap <silent><script><expr> <C-M> copilot#Accept("\<CR>")
-- vim.keymap.set({"i", "C", "M"}, )
-- vim.api.nvim_set_keymap("i", "<C-M>", "<cmd>copilot#Accept('<CR>')<cr>", opts)
-- vim.api.nvim_set_keymap("n", "<C-M>", "<cmd>copilot#Accept('<CR>')<cr>", opts)
-- vim.api.nvim_set_keymap("i", "<C-N>", "<cmd>copilot#Next()<cr>", opts)
-- vim.api.nvim_set_keymap("n", "<C-N>", "<cmd>copilot#Next()<cr>", opts)
-- vim.api.nvim_set_keymap("i", "<C-P>", "<cmd>copilot#Prev()<cr>", opts)
-- vim.api.nvim_set_keymap("n", "<C-P>", "<cmd>copilot#Prev()<cr>", opts)
-- map copilot#Accept
-- vim.api.nvim_set_keymap("i", "<C-M>", "<cmd>copilot#Accept('<CR>')<cr>", opts)
-- vim.api.nvim_set_keymap("n", "<C-M>", "<cmd>copilot#Accept('<CR>')<cr>", opts)
-- let g:copilot_no_tab_map = v:true

-- vim.cmd [[
--   imap <silent><script><expr> <C-y> copilot#Accept("\<CR>")
--   let g:copilot_no_tab_map = v:true
-- ]]

-- vim.api.nvim_set_keymap('n', ':', '<cmd>FineCmdline<CR>', {noremap = true})
-- vim.api.nvim_set_keymap("i", "<C-y>", 'copilot#Accept("<CR>")', { expr = true, silent = true })
-- vim.keymap.set('v', '<leader>lf', vim.lsp.buf.format, bufopts)

-- vim.api.nvim_set_keymap("n", ":", "<cmd>FineCmdline<CR>", { noremap = true })

vim.g.copilot_no_tab_map = true


-- Helper functions to fetch the current scope and set `search_dirs`
_G.find_files = function()
    local current_path = vim.fn.expand "%:p:h"
    local relative_path = vim.fn.fnamemodify(current_path, ":~:.")

    require("fzf-lua").files {
        cwd = relative_path,
        winopts = {
            preview = { hidden = true },
        },
    }
end
_G.live_grep = function()
    local current_path = vim.fn.expand "%:p:h"
    local relative_path = vim.fn.fnamemodify(current_path, ":~:.")

    require("fzf-lua").live_grep {
        cwd = relative_path,
        winopts = {
            preview = { hidden = true },
        },
    }
end

vim.api.nvim_set_keymap("n", "<Leader><leader>f", ":lua find_files()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Leader><leader>g", ":lua live_grep()<CR>", { noremap = true })

-- vim.api.nvim_set_keymap("n", "<Leader><leader>F", "<cmd>Telescope dir find_files<CR>", { noremap = true })
-- vim.api.nvim_set_keymap("n", "<Leader><leader>t", "<cmd>Telescope dir live_grep<CR>", { noremap = true })
--
-- vim.api.nvim_set_keymap("n", "<leader>zm", '[[:lua require("ufo").openAllFolds()<CR>]]', opts)
-- vim.api.nvim_set_keymap("n", "<leader>zr", '[[:lua require("ufo").closeAllFolds()<CR>]]', opts)

vim.api.nvim_set_keymap("n", "<leader><leader>s", ":FzfLua command_history<CR>", opts)
-- vim.keymap.set("n", "zR", require("ufo").openAllFolds)
-- vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
-- vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
-- vim.keymap.set("n", "zm", require("ufo").closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
-- vim.keymap.set("n", "zK", function()
--   local winid = require("ufo").peekFoldedLinesUnderCursor()
--   if not winid then
--     vim.lsp.buf.hover()
--   end
-- end)
-- Keymaps for goto-preview are now replaced with CodeInsight (COC-compatible)
-- Alternative COC-based preview functionality using floating windows
vim.keymap.set("n", "<leader>lgg", function()
  -- Use COC's definition in floating window
  vim.fn.CocActionAsync('jumpDefinition', 'float')
end, { noremap = true, desc = "COC Definition Float" })

vim.keymap.set("n", "<leader>lgr", function()
  -- Use COC's references list
  vim.cmd('CocList references')
end, { noremap = true, desc = "COC References List" })

-- vim.keymap.set("n", "<leader>lgg", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", { noremap = true })
-- vim.keymap.set(
--   "n",
--   "<leader>lgi",
--   "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",
--   { noremap = true }
-- )
-- vim.keymap.set(
--   "n",
--   "<leader>lgd",
--   "<cmd>lua require('goto-preview').goto_preview_declaration()<CR>",
--   { noremap = true }
-- )
-- vim.keymap.set("n", "<leader>lgw", "<cmd>lua require('goto-preview').close_all_win()<CR>", { noremap = true })
-- vim.keymap.set("n", "<leader>gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>", { noremap = true })
vim.keymap.set(
  { "n", "x" },
  "<leader>gy",
  function()
    Snacks.gitbrowse({
      open = function(url) vim.fn.setreg("+", url) end,
      notify = false
    })
  end,
  { desc = "Git Browse (copy)" }
)

-- nnoremap <leader>fb <cmd>FzfLua files cwd=/prod/tools/base/<cr>
-- nnoremap <leader>gb <cmd>FzfLua live_grep cwd=/prod/tools/base/<cr>
vim.keymap.set('n', '<leader>fb', function()
  require('fzf-lua').files {
    cwd = '/prod/tools/base/',
    winopts = {
      height = 0.6,
      width = 0.8,
    },
  }
end, { desc = 'Find files in base' })
vim.keymap.set('n', '<leader>gb', function()
  require('fzf-lua').live_grep {
    cwd = '/prod/tools/base/',
    winopts = {
      height = 0.6,
      width = 0.8,
    },
  }
end, { desc = 'Live grep in base' })

-- Diagnostic Display Plugin Keymaps
keymap("n", "<leader>dl", "<cmd>lua require('user.diagnostics_display').show_current_line_diagnostics()<cr>", opts)
keymap("n", "<leader>df", "<cmd>lua require('user.diagnostics_display').show_current_file_diagnostics()<cr>", opts)
keymap("n", "<leader>dd", "<cmd>lua require('user.diagnostics_display').debug()<cr>", opts)
keymap("n", "<leader>dt", "<cmd>lua require('user.diagnostics_display').test_line_numbers()<cr>", opts)

-- Lazygit keymaps
keymap("n", "<leader>gg", "<cmd>lua require('user.terminal').lazygit_float()<cr>", opts)
keymap("n", "<leader>gt", "<cmd>lua require('user.terminal').lazygit_tab()<cr>", opts)

return M
