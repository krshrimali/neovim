-- Minimal FzfLua config (used for vim.ui.select and occasional FzfLua commands)
-- Primary picker is Snacks.picker for performance

local status_ok, fzf_lua = pcall(require, "fzf-lua")
if not status_ok then return end

fzf_lua.setup {
  keymap = {
    fzf = {
      ["ctrl-z"] = "abort",
      ["ctrl-f"] = "half-page-down",
      ["ctrl-b"] = "half-page-up",
      ["ctrl-a"] = "beginning-of-line",
      ["ctrl-e"] = "end-of-line",
      ["alt-a"] = "toggle-all",
      ["f3"] = "toggle-preview-wrap",
      ["f4"] = "toggle-preview",
      ["ctrl-d"] = "preview-page-down",
      ["ctrl-u"] = "preview-page-up",
      ["ctrl-q"] = "select-all+accept",
    },
  },
  actions = {
    files = {
      [1] = true, -- inherit all default bindings (enter, ctrl-s, ctrl-v, etc.)
      ["alt-q"] = { fn = fzf_lua.actions.file_sel_to_qf, prefix = "select-all" },
    },
  },
}

-- Register for vim.ui.select (used by LSP code actions, etc.)
fzf_lua.register_ui_select()

return fzf_lua
