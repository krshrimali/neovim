# Quick Start Guide

Get up and running with Next Edit Suggestions in 5 minutes!

## 🚀 1-Minute Setup

### Step 1: Install the Plugin

Add to your `lazy.nvim` config:

```lua
{
  "your-username/next-edit-suggestions",
  dependencies = {
    "github/copilot.vim",
    "nvim-lua/plenary.nvim", 
    "nvim-treesitter/nvim-treesitter",
  },
  config = true, -- Use default config
  event = "InsertEnter",
}
```

### Step 2: Authenticate with GitHub

```bash
gh auth login
```

### Step 3: Start Coding!

Open any supported file (`.js`, `.py`, `.lua`, etc.) and start typing in insert mode. Suggestions will appear automatically!

## ⚡ Essential Keybindings

- `<Tab>` - Accept suggestion
- `<Esc>` - Dismiss suggestions  
- `<M-]>` / `<M-[>` - Navigate between suggestions
- `<leader>nt` - Toggle plugin on/off

## 🎯 First Experience

1. **Create a test file**: `nvim test.js`
2. **Enter insert mode**: Press `i`
3. **Start typing**: `function calculateSum(`
4. **See the magic**: AI suggestions appear as you type!
5. **Accept suggestion**: Press `<Tab>`

## 🔧 Quick Configuration

For a faster, more responsive experience:

```lua
require("next-edit-suggestions").setup({
  debounce_ms = 50,        -- Faster response
  ui = {
    accept_key = "<C-j>",  -- Alternative accept key
  },
  copilot = {
    model = "gpt-3.5-turbo", -- Faster model
  },
})
```

## 📋 Quick Commands

- `:NextEditStatus` - Check if everything is working
- `:NextEditToggle` - Turn on/off
- `:NextEditRefreshAuth` - Fix authentication issues

## 🆘 Quick Troubleshooting

**Not seeing suggestions?**
- Run `:NextEditStatus` to check plugin status
- Ensure you're in insert mode
- Check file type is supported

**Authentication issues?**
- Run `:NextEditRefreshAuth`
- Verify: `gh auth status`

**Too slow?**
- Use `gpt-3.5-turbo` instead of `gpt-4`
- Reduce `debounce_ms` to 50

## 🎨 UI Preview

```
function calculateSum(a, b) {
    return a + b;  ← AI suggestion appears here
}                ← Accept with <Tab>
```

## 📚 Next Steps

- Read the full [README.md](README.md) for advanced configuration
- Explore all available commands with `:NextEdit<Tab>`
- Customize keybindings to your preference
- Set up Telescope integration for browsing suggestions

Happy coding! 🎉