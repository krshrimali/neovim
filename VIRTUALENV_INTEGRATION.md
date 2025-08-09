# Virtual Environment Integration for Neovim + CoC

This integration automatically synchronizes virtual environment changes between your terminal and CoC (Conquer of Completion) Python language server in Neovim.

## Features

- 🔄 **Automatic Sync**: Detects when you activate/deactivate virtualenvs in terminal and prompts to update CoC
- 🎯 **Virtual Environment Picker**: Quick picker to select and switch between available virtualenvs
- 📍 **Auto-detection**: Automatically detects Python projects and suggests virtualenv activation
- ⚡ **Real-time Monitoring**: Continuously monitors for virtualenv changes
- 🛠️ **Enhanced Shell Commands**: Provides convenient commands for virtualenv management

## Installation

### 1. Neovim Configuration

The integration is already configured in your Neovim setup. The following files have been added/modified:

- `lua/user/virtualenv_sync.lua` - Main integration module
- `init.lua` - Loads the integration on startup
- `lua/user/keymaps.lua` - Adds keymaps for virtualenv functions

### 2. Shell Integration (Optional but Recommended)

To enable enhanced shell integration, add this line to your shell configuration:

**For Bash (`~/.bashrc`):**
```bash
source /workspace/nvim_virtualenv_integration.sh
```

**For Zsh (`~/.zshrc`):**
```bash
source /workspace/nvim_virtualenv_integration.sh
```

**For Fish (`~/.config/fish/config.fish`):**
```fish
# Note: The shell script is bash-specific. For fish, you'll need to adapt the functions
# or use the Neovim-only features
```

### 3. Optional: Install neovim-remote for Better Integration

For enhanced integration when using Neovim's terminal:

```bash
pip install neovim-remote
```

## Usage

### Neovim Keymaps

| Keymap | Command | Description |
|--------|---------|-------------|
| `<leader>vp` | `VirtualEnvPick` | Open virtualenv picker |
| `<leader>vi` | `VirtualEnvInfo` | Show current virtualenv sync status |
| `<leader>vs` | `VirtualEnvSync` | Manually check and sync virtualenv |
| `<leader>vm` | `VirtualEnvToggleMonitoring` | Toggle automatic monitoring |

### Neovim Commands

- `:VirtualEnvPick` - Open interactive virtualenv picker
- `:VirtualEnvInfo` - Display current virtualenv and CoC Python path
- `:VirtualEnvSync` - Manually trigger virtualenv sync check
- `:VirtualEnvToggleMonitoring` - Enable/disable automatic monitoring

### Shell Commands (if shell integration is enabled)

- `create_venv [name] [python_version]` - Create a new virtual environment
- `activate_venv <path>` - Activate a virtual environment
- `list_venvs` - List all available virtual environments
- `switch_venv [name]` - Switch to a virtual environment
- `toggle_nvim_venv_notify` - Toggle Neovim notifications

### Shell Aliases

- `lsvenv` - List virtual environments
- `mkvenv` - Create virtual environment
- `workon` - Switch to virtual environment

## How It Works

### Automatic Detection

1. **Polling**: The Neovim module polls every 2 seconds to check for `$VIRTUAL_ENV` changes
2. **State Tracking**: Maintains state file to track current virtualenv
3. **User Prompts**: When changes are detected, prompts user to sync CoC Python path
4. **CoC Integration**: Updates CoC configuration and restarts Python language server

### Shell Integration

1. **Hook Functions**: Intercepts virtualenv activation/deactivation
2. **Auto-detection**: Detects Python projects when changing directories
3. **State Synchronization**: Updates state file for Neovim to detect
4. **Remote Commands**: Can send commands to Neovim if `neovim-remote` is available

### Virtual Environment Discovery

The system searches for virtual environments in these locations:

- `~/.virtualenvs/*`
- `~/.pyenv/versions/*`
- `~/venv/*`
- `~/virtualenvs/*`
- `./venv`
- `./.venv`
- `./env`
- `./.env`

## Configuration

### Neovim Configuration

You can customize the integration by modifying the setup call in `init.lua`:

```lua
require("user.virtualenv_sync").setup({
  debug = false,           -- Enable debug messages
  poll_interval = 2000,    -- Polling interval in milliseconds
  auto_monitor = true,     -- Start monitoring automatically
  search_paths = {         -- Custom search paths for virtualenvs
    vim.fn.expand("~/.virtualenvs"),
    vim.fn.expand("~/.pyenv/versions"),
    -- Add custom paths here
  }
})
```

### Shell Configuration

The shell integration can be configured by setting these variables before sourcing:

```bash
# Disable notifications
NVIM_VENV_NOTIFY_ENABLED=0

# Custom state file location
NVIM_VENV_STATE_FILE="$HOME/.cache/nvim/custom_venv_state"

source /workspace/nvim_virtualenv_integration.sh
```

## Troubleshooting

### Common Issues

1. **CoC Python not updating**
   - Check if CoC Python extension is installed: `:CocList extensions`
   - Manually restart CoC: `:CocRestart`
   - Check CoC configuration: `:CocConfig`

2. **Virtualenv not detected**
   - Ensure `$VIRTUAL_ENV` is set when virtualenv is active
   - Check if virtualenv path is in search locations
   - Use `:VirtualEnvInfo` to see current status

3. **Shell integration not working**
   - Verify the script is sourced: `type activate_venv`
   - Check if functions are loaded: `declare -f nvim_notify_venv_change`
   - Ensure script path is correct in shell config

### Debug Mode

Enable debug mode to see detailed logging:

```lua
require("user.virtualenv_sync").setup({
  debug = true
})
```

### Manual Testing

1. Create a test virtualenv:
   ```bash
   python3 -m venv test_venv
   ```

2. Activate it:
   ```bash
   source test_venv/bin/activate
   ```

3. Check Neovim detects the change:
   ```
   :VirtualEnvInfo
   ```

4. Test the picker:
   ```
   <leader>vp
   ```

## Integration with Other Tools

### PyEnv

The integration works with PyEnv virtual environments. Ensure PyEnv virtualenvs are in `~/.pyenv/versions/`.

### Conda

For Conda environments, you may need to add Conda's environment path to the search paths:

```lua
require("user.virtualenv_sync").setup({
  search_paths = {
    vim.fn.expand("~/miniconda3/envs"),
    vim.fn.expand("~/anaconda3/envs"),
    -- ... other paths
  }
})
```

### Poetry

Poetry virtual environments are typically in `~/.cache/pypoetry/virtualenvs/`. Add this to search paths if needed.

## Contributing

The integration consists of these main components:

- `lua/user/virtualenv_sync.lua` - Core Neovim integration
- `nvim_virtualenv_integration.sh` - Shell integration script
- Keymaps and commands for user interaction

Feel free to customize and extend the functionality based on your workflow needs.