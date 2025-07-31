# COC.nvim Virtual Lines Setup

This document explains the different approaches available for displaying toggleable virtual lines/text for diagnostics from coc.nvim.

## Available Solutions

### 1. Native COC.nvim Virtual Text (Recommended)

COC.nvim has built-in support for virtual text diagnostics. This is the most reliable approach since it's directly integrated with coc.nvim.

#### Configuration

The `coc-settings.json` file has been created with the following virtual text settings:

```json
{
  "diagnostic.virtualText": false,
  "diagnostic.virtualTextCurrentLineOnly": false,
  "diagnostic.virtualTextAlign": "after",
  "diagnostic.virtualTextPrefix": " ▎ ",
  "diagnostic.virtualTextLines": 1,
  "diagnostic.virtualTextLineSeparator": "\n"
}
```

#### Key Mappings

- `<leader>lev` - Toggle COC virtual text on/off
- `<leader>leV` - Toggle current line only mode
- `<leader>lel` - Toggle between inline (`after`) and lines (`below`) mode

#### Usage

1. **Enable Virtual Text**: Press `<leader>lev` to toggle virtual text diagnostics
2. **Current Line Only**: Press `<leader>leV` to show diagnostics only on the current line
3. **Switch Modes**: Press `<leader>lel` to switch between:
   - `after` mode: Shows diagnostics inline at the end of the line
   - `below` mode: Shows diagnostics on separate lines below the code

### 2. Custom Virtual Lines Implementation

A custom implementation using Neovim's extmark API has been created in `lua/user/coc_virtual_lines.lua`.

#### Key Mappings

- `<leader>levv` - Toggle custom virtual lines implementation

#### Features

- Uses Neovim's native `virt_lines` feature
- Custom formatting and styling
- Automatic refresh on diagnostic changes
- Current line only mode
- Configurable appearance

#### Configuration

You can customize the appearance by modifying the config in `lua/user/coc_virtual_lines.lua`:

```lua
local config = {
  enabled = false,
  current_line_only = false,
  align = "below",
  prefix = "  ▎ ",
  format = function(diagnostic)
    -- Custom formatting function
  end
}
```

## Comparison

| Feature | Native COC | Custom Implementation |
|---------|------------|----------------------|
| Reliability | ✅ High | ⚠️ Medium |
| Performance | ✅ Optimized | ⚠️ May have overhead |
| Customization | ⚠️ Limited | ✅ Full control |
| Maintenance | ✅ Maintained by COC | ❌ Manual |
| Integration | ✅ Perfect | ⚠️ Manual refresh needed |

## Recommended Approach

**Use the native COC.nvim virtual text approach** (`<leader>lev`, `<leader>leV`, `<leader>lel`) for the best experience:

1. It's officially supported and maintained
2. Better performance and reliability
3. Seamless integration with coc.nvim's diagnostic system
4. Automatic updates when diagnostics change

## Setup Instructions

### Quick Start

1. The configuration is already set up in your Neovim config
2. Open a file with diagnostics (e.g., a file with syntax errors)
3. Press `<leader>lev` to enable virtual text
4. Press `<leader>lel` to switch to "lines" mode if you prefer diagnostics on separate lines
5. Press `<leader>leV` to toggle current line only mode

### Advanced Configuration

To modify COC's virtual text settings permanently, edit the `coc-settings.json` file:

```json
{
  "diagnostic.virtualText": true,
  "diagnostic.virtualTextCurrentLineOnly": false,
  "diagnostic.virtualTextAlign": "below",
  "diagnostic.virtualTextPrefix": "→ ",
  "diagnostic.virtualTextLines": 3
}
```

## Troubleshooting

### Virtual Text Not Showing

1. Ensure COC.nvim is properly installed and running: `:CocInfo`
2. Check if diagnostics are available: `:CocList diagnostics`
3. Verify the setting is enabled: `:CocConfig` and check `diagnostic.virtualText`

### Performance Issues

1. Try reducing `diagnostic.virtualTextLines` in `coc-settings.json`
2. Enable `diagnostic.virtualTextCurrentLineOnly` to reduce visual clutter
3. Use the native COC approach instead of the custom implementation

### Conflicts with Other Plugins

The native COC approach should not conflict with other diagnostic plugins since it uses COC's own rendering system.

## Additional COC.nvim Diagnostic Features

- `:CocList diagnostics` - Show all diagnostics in a list
- `[g` and `]g` - Navigate between diagnostics
- `<leader>ld` - Show diagnostic info for current line
- `:CocDiagnostics` - Open diagnostics in location list

## References

- [COC.nvim Documentation](https://github.com/neoclide/coc.nvim)
- [COC.nvim Configuration](https://github.com/neoclide/coc.nvim/wiki/Using-the-configuration-file)
- [Neovim Virtual Text API](https://neovim.io/doc/user/api.html#nvim_buf_set_extmark())