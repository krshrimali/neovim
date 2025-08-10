-- Simple Snacks picker configuration
-- Using defaults as suggested by folke/snacks.nvim for optimal speed and simplicity

local status_ok, snacks = pcall(require, "snacks")
if not status_ok then
    return
end

-- Snacks picker uses sensible defaults, so minimal configuration is needed
-- The picker is already enabled in plugins.lua

-- Optional: Set up some global functions for compatibility with existing keymaps
-- These functions provide a bridge between old FzfLua calls and new Snacks picker calls

_G.snacks_files = function(opts)
    opts = opts or {}
    Snacks.picker.files(opts)
end

_G.snacks_oldfiles = function(opts)
    opts = opts or {}
    Snacks.picker.recent(opts)
end

_G.snacks_live_grep = function(opts)
    opts = opts or {}
    Snacks.picker.grep(opts)
end

_G.snacks_buffers = function(opts)
    opts = opts or {}
    Snacks.picker.buffers(opts)
end

_G.snacks_helptags = function(opts)
    opts = opts or {}
    Snacks.picker.help(opts)
end

_G.snacks_git_files = function(opts)
    opts = opts or {}
    Snacks.picker.git_files(opts)
end

_G.snacks_git_status = function(opts)
    opts = opts or {}
    Snacks.picker.git_status(opts)
end

_G.snacks_colorschemes = function(opts)
    opts = opts or {}
    Snacks.picker.colorschemes(opts)
end

_G.snacks_keymaps = function(opts)
    opts = opts or {}
    Snacks.picker.keymaps(opts)
end

_G.snacks_commands = function(opts)
    opts = opts or {}
    Snacks.picker.commands(opts)
end

_G.snacks_command_history = function(opts)
    opts = opts or {}
    Snacks.picker.command_history(opts)
end

_G.snacks_search_history = function(opts)
    opts = opts or {}
    Snacks.picker.search_history(opts)
end

_G.snacks_quickfix = function(opts)
    opts = opts or {}
    Snacks.picker.qflist(opts)
end

_G.snacks_registers = function(opts)
    opts = opts or {}
    Snacks.picker.registers(opts)
end

_G.snacks_marks = function(opts)
    opts = opts or {}
    Snacks.picker.marks(opts)
end

_G.snacks_jumps = function(opts)
    opts = opts or {}
    Snacks.picker.jumps(opts)
end

_G.snacks_highlights = function(opts)
    opts = opts or {}
    Snacks.picker.highlights(opts)
end

_G.snacks_manpages = function(opts)
    opts = opts or {}
    Snacks.picker.man(opts)
end

_G.snacks_builtin = function(opts)
    opts = opts or {}
    Snacks.picker.pick(opts)
end

_G.snacks_resume = function(opts)
    opts = opts or {}
    Snacks.picker.resume(opts)
end

-- LSP functions
_G.snacks_lsp_document_symbols = function(opts)
    opts = opts or {}
    Snacks.picker.lsp_symbols(opts)
end

_G.snacks_lsp_workspace_symbols = function(opts)
    opts = opts or {}
    Snacks.picker.lsp_workspace_symbols(opts)
end

_G.snacks_lsp_references = function(opts)
    opts = opts or {}
    Snacks.picker.lsp_references(opts)
end

_G.snacks_lsp_definitions = function(opts)
    opts = opts or {}
    Snacks.picker.lsp_definitions(opts)
end

_G.snacks_lsp_implementations = function(opts)
    opts = opts or {}
    Snacks.picker.lsp_implementations(opts)
end

_G.snacks_lsp_incoming_calls = function(opts)
    opts = opts or {}
    Snacks.picker.lsp_incoming_calls(opts)
end

_G.snacks_lsp_outgoing_calls = function(opts)
    opts = opts or {}
    Snacks.picker.lsp_outgoing_calls(opts)
end

-- Grep variants
_G.snacks_grep_cword = function(opts)
    opts = opts or {}
    local word = vim.fn.expand("<cword>")
    if word and word ~= "" then
        opts.search = word
        Snacks.picker.grep(opts)
    end
end

_G.snacks_grep_curbuf = function(opts)
    opts = opts or {}
    opts.cwd = vim.fn.expand("%:p:h")
    Snacks.picker.grep(opts)
end

-- Git functions
_G.snacks_git_branches = function(opts)
    opts = opts or {}
    Snacks.picker.git_branches(opts)
end

_G.snacks_git_stash = function(opts)
    opts = opts or {}
    Snacks.picker.git_stash(opts)
end

-- Buffer search
_G.snacks_blines = function(opts)
    opts = opts or {}
    Snacks.picker.lines(opts)
end

return snacks