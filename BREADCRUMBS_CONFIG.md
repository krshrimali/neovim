# Lualine Breadcrumbs Configuration

This document explains the optimized breadcrumbs functionality in the lualine configuration.

## Features

### Performance Optimizations
- **Caching**: Breadcrumbs are cached for 100ms to avoid unnecessary recomputation
- **Debouncing**: Updates are debounced by 50ms to prevent flickering during rapid cursor movements
- **Smart Updates**: Only recalculates when buffer or cursor line changes

### Configurable Positions
- **Top Breadcrumbs**: Shown in the winbar (top of each window)
- **Bottom Breadcrumbs**: Shown in the main statusline (bottom)
- **Both**: Can be enabled independently or together

## Toggle Commands

### Available Commands
- `:BreadcrumbsToggleTop` - Toggle breadcrumbs in the top winbar
- `:BreadcrumbsToggleBottom` - Toggle breadcrumbs in the bottom statusline  
- `:BreadcrumbsToggleBoth` - Toggle both top and bottom breadcrumbs

### Default State
- Top breadcrumbs: **Enabled** by default
- Bottom breadcrumbs: **Disabled** by default

## What Breadcrumbs Show

The breadcrumbs display hierarchical context using TreeSitter:
- **Class/Struct/Interface** → **Function/Method** → **Current Node Type**

### Supported Languages
Works with any language that has TreeSitter support, including:
- Rust (`impl_item`, `struct_item`, `function_item`)
- JavaScript/TypeScript (`class_declaration`, `function_declaration`, `arrow_function`)
- Python (`class_definition`, `function_definition`)
- And many more...

## Configuration

The breadcrumbs behavior can be customized by modifying the `breadcrumbs_config` table in `lua/user/lualine.lua`:

```lua
local breadcrumbs_config = {
    enabled_top = true,           -- Enable top breadcrumbs by default
    enabled_bottom = false,       -- Disable bottom breadcrumbs by default
    cache_timeout = 100,          -- Cache results for 100ms
    debounce_timeout = 50,        -- Debounce updates by 50ms
}
```

## Excluded File Types

Breadcrumbs are automatically disabled for:
- `help` files
- `alpha` dashboard
- Empty buffers
- `NvimTree`
- `terminal` buffers

## Performance Notes

The optimized implementation should eliminate the slowness and flickering issues from the previous version by:

1. **Avoiding redundant TreeSitter queries** through intelligent caching
2. **Debouncing rapid updates** during cursor movements
3. **Early returns** for unchanged contexts
4. **Proper timer cleanup** to prevent memory leaks

## Usage Examples

```vim
" Toggle top breadcrumbs on/off
:BreadcrumbsToggleTop

" Enable bottom breadcrumbs
:BreadcrumbsToggleBottom

" Toggle both positions
:BreadcrumbsToggleBoth
```

The commands provide feedback showing whether breadcrumbs are enabled or disabled for each position.