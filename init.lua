-- Neovim Configuration with Clipboard Integration
-- Place this file at ~/.config/nvim/init.lua

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Clipboard configuration with automatic detection
local function setup_clipboard()
  -- Check if we're in WSL
  if vim.fn.has('wsl') == 1 then
    vim.g.clipboard = {
      name = 'WslClipboard',
      copy = {
        ['+'] = 'clip.exe',
        ['*'] = 'clip.exe',
      },
      paste = {
        ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      },
      cache_enabled = 0,
    }
    print("WSL clipboard configured")
  -- Check for macOS
  elseif vim.fn.has('mac') == 1 then
    vim.opt.clipboard = 'unnamedplus'
    print("macOS clipboard configured")
  -- Check for Linux clipboard utilities
  elseif vim.fn.executable('xclip') == 1 then
    vim.opt.clipboard = 'unnamedplus'
    print("Linux clipboard configured with xclip")
  elseif vim.fn.executable('xsel') == 1 then
    vim.opt.clipboard = 'unnamedplus'
    print("Linux clipboard configured with xsel")
  elseif vim.fn.executable('wl-copy') == 1 then
    vim.opt.clipboard = 'unnamedplus'
    print("Wayland clipboard configured")
  else
    print("Warning: No clipboard provider found!")
    print("Install xclip, xsel, or wl-clipboard-tools")
    print("You can still use '+y and '+p for manual clipboard operations")
  end
end

-- Set up clipboard
setup_clipboard()

-- Key mappings for manual clipboard operations (fallback)
vim.keymap.set('v', '<leader>y', '"+y', { desc = 'Copy to system clipboard' })
vim.keymap.set('n', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
vim.keymap.set('n', '<leader>P', '"+P', { desc = 'Paste before cursor from system clipboard' })

-- Function to check clipboard status
local function check_clipboard()
  print("Clipboard status:")
  print("has('clipboard'): " .. vim.fn.has('clipboard'))
  print("Current clipboard setting: " .. vim.inspect(vim.opt.clipboard:get()))
  
  -- Check available providers
  local providers = {
    'xclip', 'xsel', 'wl-copy', 'pbcopy', 'clip.exe'
  }
  
  print("Available clipboard utilities:")
  for _, provider in ipairs(providers) do
    if vim.fn.executable(provider) == 1 then
      print("  ✓ " .. provider)
    else
      print("  ✗ " .. provider)
    end
  end
end

-- Command to check clipboard status
vim.api.nvim_create_user_command('CheckClipboard', check_clipboard, {})

-- Auto-command to show clipboard status on startup
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    -- Small delay to let everything load
    vim.defer_fn(function()
      if vim.opt.clipboard:get()[1] then
        print("✓ System clipboard integration enabled")
      else
        print("⚠ System clipboard not configured - use :CheckClipboard for details")
      end
    end, 100)
  end,
})

print("Neovim configuration loaded!")
