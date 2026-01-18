-- Auto-open simple tree when starting Neovim (replaced nvim-tree)
-- vim.api.nvim_create_autocmd({ "VimEnter" }, {
--   callback = function()
--     -- Only open tree if no file was specified on the command line
--     if vim.fn.argc() == 0 then
--       require("user.simple_tree").open_workspace()
--     end
--   end,
-- })

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = {
    -- "Jaq",
    "qf",
    "help",
    "man",
    "lspinfo",
    "spectre_panel",
    "lir",
    "DressingSelect",
    "tsplayground",
    "Markdown",
  },
  callback = function()
    vim.cmd [[
      nnoremap <silent> <buffer> q :close<CR>
      nnoremap <silent> <buffer> <esc> :close<CR>
      set nobuflisted
    ]]
  end,
})

-- Special handling for CoC float windows
vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "CocOpenFloat",
  callback = function()
    -- Set keymaps for CoC float windows when they open
    vim.schedule(function()
      local wins = vim.fn["coc#float#get_float_win_list"]()
      if wins and #wins > 0 then
        for _, win in ipairs(wins) do
          if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            vim.api.nvim_buf_set_keymap(
              buf,
              "n",
              "q",
              "<CMD>call coc#float#close_all()<CR>",
              { silent = true, nowait = true }
            )
            vim.api.nvim_buf_set_keymap(
              buf,
              "n",
              "<Esc>",
              "<CMD>call coc#float#close_all()<CR>",
              { silent = true, nowait = true }
            )
          end
        end
      end
    end)
  end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function() vim.cmd "set formatoptions-=cro" end,
})

vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  callback = function() vim.highlight.on_yank { higroup = "Visual", timeout = 100 } end, -- Reduced timeout
})

-- Custom commands for config editing and reloading
vim.api.nvim_create_user_command(
  "ConfigEdit",
  function() vim.cmd("edit " .. vim.fn.stdpath "config" .. "/init.lua") end,
  { desc = "Edit Neovim config (init.lua)" }
)

vim.api.nvim_create_user_command("ConfigReload", function()
  -- Clear Lua module cache for all user modules
  for name, _ in pairs(package.loaded) do
    if name:match "^user" then package.loaded[name] = nil end
  end

  -- Reload the main config
  dofile(vim.fn.stdpath "config" .. "/init.lua")

  -- Notify user
  vim.notify("Configuration reloaded!", vim.log.levels.INFO)
end, { desc = "Reload Neovim configuration" })

vim.api.nvim_create_user_command("ConfigOpen", function()
  local config_path = vim.fn.stdpath "config"
  vim.cmd("cd " .. config_path)
  vim.cmd("edit " .. config_path)
end, { desc = "Open Neovim config directory and cd to it" })
