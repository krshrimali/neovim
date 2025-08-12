# Neovim Clipboard Integration Fix

## Problem
When using `y` (yank) and `p` (paste) in Neovim, the text doesn't get copied to or pasted from the system clipboard, especially when connecting via PuTTY/SSH.

## Root Causes
1. **Missing clipboard provider**: Neovim needs a clipboard utility to interface with the system clipboard
2. **No X11 forwarding**: When using SSH/PuTTY without proper X11 forwarding
3. **Incorrect Neovim configuration**: The `clipboard` option is not properly set
4. **Missing dependencies**: Required clipboard utilities are not installed

## Solutions

### Solution 1: Configure Neovim to Use System Clipboard

Create or edit your Neovim configuration file:

**For init.lua** (`~/.config/nvim/init.lua`):
```lua
-- Enable system clipboard integration
vim.opt.clipboard = "unnamedplus"

-- Alternative: Use both unnamed and unnamedplus
-- vim.opt.clipboard = {"unnamed", "unnamedplus"}
```

**For init.vim** (`~/.config/nvim/init.vim`):
```vim
" Enable system clipboard integration
set clipboard=unnamedplus

" Alternative: Use both unnamed and unnamedplus
" set clipboard=unnamed,unnamedplus
```

### Solution 2: Install Required Clipboard Utilities

#### On Ubuntu/Debian:
```bash
sudo apt update
sudo apt install xclip xsel
```

#### On CentOS/RHEL/Fedora:
```bash
# For CentOS/RHEL
sudo yum install xclip xsel
# For Fedora
sudo dnf install xclip xsel
```

#### On Arch Linux:
```bash
sudo pacman -S xclip xsel
```

### Solution 3: Enable X11 Forwarding in PuTTY

1. **In PuTTY Configuration:**
   - Go to Connection → SSH → X11
   - Check "Enable X11 forwarding"
   - Set X display location to `localhost:0.0`

2. **On Windows, install an X Server:**
   - Install VcXsrv or Xming
   - Start the X server before connecting via PuTTY

3. **Verify X11 forwarding works:**
   ```bash
   echo $DISPLAY  # Should show something like localhost:10.0
   ```

### Solution 4: Alternative Clipboard Methods

If system clipboard integration still doesn't work, use these workarounds:

#### Method 1: Use Neovim's built-in registers
```vim
" Copy to system clipboard
"+y

" Paste from system clipboard
"+p

" Copy to primary selection (X11)
"*y

" Paste from primary selection
"*p
```

#### Method 2: Use terminal selection
- Select text with mouse in terminal
- Right-click to copy (or use Ctrl+Shift+C)
- Right-click to paste (or use Ctrl+Shift+V)

### Solution 5: SSH with Clipboard Forwarding

For remote servers, you can set up clipboard forwarding:

1. **Install clipboard utilities on the remote server**
2. **Use SSH with X11 forwarding:**
   ```bash
   ssh -X username@remote-server
   # or
   ssh -Y username@remote-server  # for trusted X11 forwarding
   ```

### Solution 6: Advanced Configuration

Create a more robust clipboard configuration in your `init.lua`:

```lua
-- Clipboard configuration with fallbacks
local function setup_clipboard()
  if vim.fn.has('wsl') == 1 then
    -- WSL specific clipboard
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
  elseif vim.fn.has('mac') == 1 then
    -- macOS clipboard
    vim.opt.clipboard = 'unnamedplus'
  elseif vim.fn.executable('xclip') == 1 then
    -- Linux with xclip
    vim.opt.clipboard = 'unnamedplus'
  elseif vim.fn.executable('xsel') == 1 then
    -- Linux with xsel
    vim.opt.clipboard = 'unnamedplus'
  else
    -- Fallback: show warning
    vim.notify("No clipboard provider found. Install xclip or xsel.", vim.log.levels.WARN)
  end
end

setup_clipboard()
```

## Testing the Fix

1. **Check clipboard provider status:**
   ```vim
   :checkhealth provider
   ```

2. **Test copying:**
   - Type some text in Neovim
   - Select it in visual mode (`v`)
   - Press `y` to yank
   - Try pasting in another application

3. **Test pasting:**
   - Copy text from another application
   - In Neovim, press `p` to paste

## Troubleshooting

### Issue: `:checkhealth provider` shows clipboard errors
- **Solution**: Install missing clipboard utilities (xclip, xsel)

### Issue: X11 forwarding not working
- **Solution**: Check PuTTY X11 settings and ensure X server is running on Windows

### Issue: WSL clipboard not working
- **Solution**: Use the WSL-specific configuration shown above

### Issue: Still not working after configuration
- **Solution**: Restart Neovim and verify the configuration file is being loaded

## Quick Commands Reference

```vim
" Check clipboard status
:echo has('clipboard')

" Check available providers
:checkhealth provider

" Manual clipboard operations
"+y    " Copy to system clipboard
"+p    " Paste from system clipboard
"*y    " Copy to primary selection
"*p    " Paste from primary selection

" Set clipboard option
:set clipboard=unnamedplus
```

This should resolve your clipboard integration issues with Neovim in PuTTY!