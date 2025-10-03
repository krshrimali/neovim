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
      local wins = vim.fn['coc#float#get_float_win_list']()
      if wins and #wins > 0 then
        for _, win in ipairs(wins) do
          if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<CMD>call coc#float#close_all()<CR>', {silent = true, nowait = true})
            vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<CMD>call coc#float#close_all()<CR>', {silent = true, nowait = true})
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
vim.api.nvim_create_user_command("ConfigEdit", function()
  vim.cmd("edit " .. vim.fn.stdpath("config") .. "/init.lua")
end, { desc = "Edit Neovim config (init.lua)" })

vim.api.nvim_create_user_command("ConfigReload", function()
  -- Clear Lua module cache for all user modules
  for name, _ in pairs(package.loaded) do
    if name:match("^user") then
      package.loaded[name] = nil
    end
  end
  
  -- Reload the main config
  dofile(vim.fn.stdpath("config") .. "/init.lua")
  
  -- Notify user
  vim.notify("Configuration reloaded!", vim.log.levels.INFO)
end, { desc = "Reload Neovim configuration" })

-- Defer float window visibility setup
vim.defer_fn(function()
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
      -- Make float borders more visible with a distinct color
      vim.api.nvim_set_hl(0, "FloatBorder", { 
        fg = "#7aa2f7",  -- Bright blue border
        bg = "NONE" 
      })
      
      -- Make the float window background slightly different from editor
      vim.api.nvim_set_hl(0, "NormalFloat", { 
        bg = "#1a1b26",  -- Slightly darker/different background
        fg = "#c0caf5"    -- Normal foreground
      })
      
      -- Title for float windows
      vim.api.nvim_set_hl(0, "FloatTitle", { 
        fg = "#7aa2f7",   -- Blue title
        bg = "#1a1b26",
        bold = true 
      })
      
      -- Footer for float windows  
      vim.api.nvim_set_hl(0, "FloatFooter", { 
        fg = "#565f89",   -- Dimmed footer
        bg = "#1a1b26" 
      })
    end,
  })
end, 200)

-- Defer highlight setup for better startup
vim.defer_fn(function()
  vim.api.nvim_set_hl(0, "FloatBorder", { 
    fg = "#7aa2f7",  -- Bright blue border
    bg = "NONE" 
  })

  vim.api.nvim_set_hl(0, "NormalFloat", { 
    bg = "#1a1b26",  -- Slightly darker/different background
    fg = "#c0caf5"    -- Normal foreground
  })

  vim.api.nvim_set_hl(0, "FloatTitle", { 
    fg = "#7aa2f7",   -- Blue title
    bg = "#1a1b26",
    bold = true 
  })

  vim.api.nvim_set_hl(0, "FloatFooter", { 
    fg = "#565f89",   -- Dimmed footer
    bg = "#1a1b26" 
  })

  -- CoC specific float window highlights
  vim.api.nvim_set_hl(0, "CocFloating", { 
    bg = "#1f2335",  -- Dark background for CoC floats
    fg = "#c0caf5"    -- Normal foreground
  })

  vim.api.nvim_set_hl(0, "CocFloatingBorder", { 
    fg = "#bb9af7",   -- Purple border for CoC
    bg = "#1f2335" 
  })

  vim.api.nvim_set_hl(0, "CocErrorFloat", { fg = "#f7768e" })
  vim.api.nvim_set_hl(0, "CocWarningFloat", { fg = "#e0af68" })
  vim.api.nvim_set_hl(0, "CocInfoFloat", { fg = "#0db9d7" })
  vim.api.nvim_set_hl(0, "CocHintFloat", { fg = "#1abc9c" })
end, 200) -- Delay for better startup
