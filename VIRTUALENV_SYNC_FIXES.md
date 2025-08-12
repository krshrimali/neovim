# Virtual Environment Sync Fixes

## Issues Identified and Fixed

### 1. **Shell Compatibility (Zsh vs Bash)**

**Problem**: The original script was written for Bash but you're using Zsh, causing command errors like `basename` not found.

**Fix**:
- Made the script compatible with both Bash and Zsh
- Replaced `$(basename "$path")` with `"${path##*/}"` (POSIX-compatible)
- Fixed `realpath` command fallback for systems without it
- Improved shell detection and hook setup

### 2. **Environment Variable Isolation**

**Problem**: Neovim runs in a separate process, so `$VIRTUAL_ENV` from your terminal doesn't automatically propagate to Neovim.

**Fix**:
- Enhanced `get_current_virtualenv()` function with multiple detection methods:
  1. Check Neovim's own `$VIRTUAL_ENV`
  2. Read from state file (updated by shell integration)
  3. Try to detect from parent shell process
- Added file-based state synchronization with timestamps

### 3. **State Synchronization**

**Problem**: Changes in terminal virtualenv weren't being detected by Neovim.

**Fix**:
- Added timestamp-based change detection
- Improved state file monitoring
- Added manual sync command (`sync_nvim_venv`)
- Enhanced notification system with debug output

### 4. **Deactivate Hook Issues**

**Problem**: The deactivate function hook wasn't working properly, especially in Zsh.

**Fix**:
- Created `setup_deactivate_hook()` function that works after virtualenv activation
- Added Zsh-specific function handling using `functions[]` array
- Improved hook detection to avoid double-hooking

## Key Changes Made

### Shell Script (`nvim_virtualenv_integration.sh`)

1. **Shell Compatibility**:
   ```bash
   # Before: basename "$venv" 
   # After: "${venv##*/}"  # Works in both Bash and Zsh
   ```

2. **Enhanced State Tracking**:
   ```bash
   # Added timestamp for change detection
   echo "$(date +%s)" > "${NVIM_VENV_STATE_FILE}.timestamp"
   ```

3. **Improved Deactivate Handling**:
   ```bash
   setup_deactivate_hook() {
       if [[ -n "$ZSH_VERSION" ]]; then
           eval "functions[original_deactivate]=\${functions[deactivate]}"
       else
           eval "original_$(declare -f deactivate)"
       fi
   }
   ```

### Neovim Module (`lua/user/virtualenv_sync.lua`)

1. **Multi-Method Detection**:
   ```lua
   -- Try multiple ways to detect current virtualenv
   local virtual_env = vim.fn.getenv("VIRTUAL_ENV")  -- Direct
   local state = load_state()                        -- State file
   -- Parent shell process detection                  -- Process tree
   ```

2. **Timestamp-Based Change Detection**:
   ```lua
   local function has_state_file_changed()
       local timestamp_file = config.state_file .. ".timestamp"
       -- Check if timestamp is newer than last check
   end
   ```

3. **Async UI Updates**:
   ```lua
   vim.schedule(function()
       local choice = vim.fn.confirm(...)
   end)
   ```

## Testing Results

✅ **Shell Integration**: Functions load correctly in Zsh
✅ **State File Creation**: Files created at `~/.cache/nvim/nvim_virtualenv_state*`
✅ **Command Compatibility**: `list_venvs` works without basename errors
✅ **Debug Output**: Proper debug messages showing state changes

## Usage Instructions (Updated)

### For Immediate Testing:

1. **Source the updated script**:
   ```bash
   source /workspace/nvim_virtualenv_integration.sh
   ```

2. **Test the functions**:
   ```bash
   list_venvs                    # Should work without errors
   sync_nvim_venv               # Manually sync current state
   ```

3. **In Neovim, test the integration**:
   ```
   :VirtualEnvInfo              # Check current status
   <leader>vp                   # Open virtualenv picker
   ```

### For Permanent Setup:

Add to your `~/.zshrc`:
```bash
source /workspace/nvim_virtualenv_integration.sh
```

## Expected Behavior Now

1. **When you activate a virtualenv in terminal**:
   - State file is updated immediately
   - Debug message shows: `[DEBUG] Updated Neovim state: /path/to/venv`
   - Neovim detects change within 2 seconds and prompts you

2. **When you check status in Neovim**:
   - `:VirtualEnvInfo` should show correct terminal virtualenv
   - Sync status should show ✓ if matched

3. **Manual commands work**:
   - `sync_nvim_venv` in terminal updates Neovim immediately
   - `<leader>vs` in Neovim triggers manual sync check

## Troubleshooting

If sync still doesn't work:

1. **Check state files**:
   ```bash
   ls -la ~/.cache/nvim/nvim_virtualenv_state*
   cat ~/.cache/nvim/nvim_virtualenv_state
   ```

2. **Enable debug mode**:
   ```lua
   require("user.virtualenv_sync").setup({ debug = true })
   ```

3. **Manual trigger**:
   ```bash
   # In terminal after activating venv
   sync_nvim_venv
   ```
   
   ```vim
   " In Neovim
   :VirtualEnvSync
   ```

The integration should now work properly with Zsh and provide reliable synchronization between your terminal and Neovim CoC Python environment!