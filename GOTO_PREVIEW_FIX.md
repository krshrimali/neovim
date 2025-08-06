# Goto-Preview Plugin Fix

## Problem Identified

The `goto-preview` plugin was not working because:

1. **Incompatibility with COC.nvim**: The `goto-preview` plugin requires **native Neovim LSP** (`vim.lsp`) to function, but this configuration uses **COC.nvim** instead.

2. **Configuration conflicts**: There were multiple setup calls and race conditions:
   - Manual `require("goto-preview").setup {}` in `init.lua`
   - Plugin configuration with `config = true` in `plugins.lua`  
   - Missing proper lazy loading triggers

3. **Missing LSP foundation**: COC.nvim replaces native LSP entirely, so `goto-preview` had no LSP data to work with.

## Solutions Implemented

### Solution 1: CodeInsight Plugin (Recommended)

Replaced `goto-preview` with **CodeInsight** - a COC.nvim compatible alternative:

```lua
{
    "Jersonrn/CodeInsight",
    dependencies = { "neoclide/coc.nvim" },
    keys = {
        { "<leader>lgg", ":ShowFloatDefinition<CR>", desc = "Show Float Definition" },
        { "<leader>lgr", ":ShowFloatReferences<CR>", desc = "Show Float References" },
        { "<leader>lgt", ":ShowFloatTypeDefinition<CR>", desc = "Show Float Type Definition" },
        { "<leader>lgw", ":q<CR>", desc = "Close Float Window" },
    },
    config = function()
        vim.g.code_insight_config = {
            pos = 'top-right',
            opts = {
                width = math.floor(vim.o.columns * 0.5),
                height = math.floor(vim.o.lines * 0.5),
                focusable = true,
                external = false,
                border = {'❖', '═', '╗', '║', '⇲', '═', '╚', '║'},
                title = {{"CodeInsight", 'FloatTitle'}},
                title_pos = 'left',
            }
        }
    end,
}
```

**Features:**
- ✅ Fully compatible with COC.nvim
- ✅ Floating window previews for definitions, references, type definitions
- ✅ Manipulable floating windows
- ✅ Similar functionality to goto-preview

### Solution 2: COC Native Commands (Alternative)

Added COC-based keymaps as fallback:

```lua
-- COC-based preview functionality using floating windows
vim.keymap.set("n", "<leader>lgg", function()
  vim.fn.CocActionAsync('jumpDefinition', 'float')
end, { noremap = true, desc = "COC Definition Float" })

vim.keymap.set("n", "<leader>lgr", function()
  vim.cmd('CocList references')
end, { noremap = true, desc = "COC References List" })
```

## Changes Made

1. **Replaced plugin in `lua/user/plugins.lua`**:
   - Removed: `"rmagatti/goto-preview"`
   - Added: `"Jersonrn/CodeInsight"`

2. **Updated keymaps**:
   - `<leader>lgg` - Show float definition
   - `<leader>lgr` - Show float references  
   - `<leader>lgt` - Show float type definition
   - `<leader>lgw` - Close float window

3. **Cleaned up configuration**:
   - Removed conflicting setup call from `init.lua`
   - Added proper CodeInsight configuration

## Usage

After restarting Neovim and running `:Lazy sync`:

- Press `<leader>lgg` to preview definition in floating window
- Press `<leader>lgr` to show references in floating window
- Press `<leader>lgt` to show type definition in floating window
- Press `<leader>lgw` or `q` to close the floating window

## Why This Solution Works

1. **COC Compatibility**: CodeInsight is specifically designed to work with COC.nvim
2. **Similar Functionality**: Provides the same floating window preview experience
3. **Proper Integration**: Uses COC's LSP data instead of native Neovim LSP
4. **Maintained Project**: Active plugin with recent updates

## Alternative Options Considered

1. **Keep goto-preview + Add native LSP**: Would cause conflicts with COC.nvim
2. **Switch entirely to native LSP**: Major configuration change, not requested
3. **Use glance.nvim**: Also requires native LSP
4. **Use COC floating windows**: Limited functionality compared to dedicated plugin

The CodeInsight solution provides the best balance of functionality and compatibility with your existing COC.nvim setup.