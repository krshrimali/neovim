# Neovim Startup Performance Optimization Guide

## 🚀 Applied Optimizations

### 1. **Plugin Lazy Loading** ✅
- **CoC.nvim**: Now loads only when opening files (`BufReadPre`, `BufNewFile`)
- **Treesitter**: Lazy loaded on file open with reduced parser set
- **Telescope**: Loads only when commands/keymaps are triggered
- **File Explorer**: `nvim-tree` loads only on command/keymap
- **Git Tools**: `gitsigns`, `git-blame`, `neogit` are now lazy loaded
- **UI Plugins**: Most UI plugins now load on `VeryLazy` or specific events

### 2. **CoC.nvim Optimizations** ✅
- Extension installation deferred by 3 seconds to avoid startup blocking
- Heavy autocmds (CursorHold, FileType) are deferred by 500ms
- Simplified completion and documentation functions
- Configuration settings applied with delays to reduce startup impact

### 3. **Treesitter Optimizations** ✅
- Reduced parser set to essential languages only
- Disabled heavy features: rainbow, playground, matchup, autotag
- Reduced max file size from 100KB to 50KB
- Simplified textobjects to essential ones only
- Disabled incremental selection and movement features

### 4. **Configuration Loading Optimizations** ✅
- `init.lua` now loads only essential configs immediately
- Heavy configs moved to plugin lazy loading
- Terminal config deferred by 100ms
- Only UI-critical configs load immediately

## 📊 Expected Performance Improvements

**Before Optimization:**
- ~50+ plugins loading eagerly
- CoC extensions installing on startup
- All treesitter features enabled
- Heavy telescope configuration loaded immediately

**After Optimization:**
- Only ~10 essential plugins load immediately
- CoC and extensions load when editing files
- Treesitter optimized for essential features only
- Most plugins load on-demand

**Estimated startup time improvement: 60-80% faster**

## 🔧 Additional Recommendations

### 1. **System-Level Optimizations**
```bash
# Use faster storage (SSD recommended)
# Increase system memory if possible
# Use a faster terminal emulator

# For Linux users - consider these kernel parameters:
echo 'vm.swappiness=1' | sudo tee -a /etc/sysctl.conf
```

### 2. **Further Plugin Optimizations**

#### Replace Heavy Plugins:
- Consider `mini.nvim` modules instead of multiple separate plugins
- Replace `bufferline.nvim` with simpler alternatives if not essential
- Consider `fzf-lua` instead of telescope for even faster file finding

#### Remove Unused Plugins:
```lua
-- Remove these if not actively used:
-- "rcarriga/nvim-notify" (use vim.notify instead)
-- "stevearc/dressing.nvim" (use default vim UI)
-- Multiple theme plugins (keep only 1-2 favorites)
```

### 3. **Neovim Configuration Optimizations**

#### Optimize Options:
```lua
-- Add to options.lua for better performance
vim.opt.lazyredraw = true        -- Don't redraw during macros
vim.opt.synmaxcol = 200          -- Limit syntax highlighting column
vim.opt.regexpengine = 1         -- Use old regex engine (sometimes faster)
```

#### Reduce Autocommands:
```lua
-- Minimize autocommands in autocommands.lua
-- Group related autocommands together
-- Use specific patterns instead of wildcards
```

### 4. **CoC.nvim Alternatives for Even Better Performance**

Consider switching to native LSP:
```lua
-- Replace CoC with native LSP + nvim-cmp for better startup time
-- This requires more configuration but offers better performance
```

### 5. **Monitoring Startup Performance**

#### Profile Startup Time:
```bash
# Run this to see detailed startup profiling:
nvim --startuptime startup.log +qall && cat startup.log

# Or use this for repeated measurements:
hyperfine "nvim --headless +qall"
```

#### Key Metrics to Watch:
- Total startup time should be < 100ms for optimal experience
- Plugin loading should be < 50ms
- File opening should be instant

### 6. **Environment-Specific Optimizations**

#### For Remote/SSH Usage:
```lua
-- Disable heavy UI features when using SSH
if vim.env.SSH_TTY then
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    -- Disable animations and heavy UI
end
```

#### For Large Codebases:
```lua
-- Add to treesitter config for better performance on large files
disable = function(lang, buf)
    local max_filesize = 25 * 1024 -- Even smaller for large projects
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
    if ok and stats and stats.size > max_filesize then
        return true
    end
end,
```

## 🎯 Quick Wins for Immediate Improvement

1. **Restart Neovim** to apply all lazy loading changes
2. **Run `:Lazy clean`** to remove unused plugins
3. **Run `:Lazy sync`** to update plugins with new lazy loading
4. **Profile startup** with `nvim --startuptime startup.log +qall`
5. **Measure improvement** with `hyperfine "nvim --headless +qall"`

## 🚨 Troubleshooting

### If Something Breaks:
1. Check `:Lazy` for plugin loading issues
2. Use `:checkhealth` to verify plugin configurations
3. Temporarily disable lazy loading for problematic plugins
4. Check `:messages` for error messages

### Plugin Not Loading:
1. Verify the event/cmd/keys triggers are correct
2. Manually trigger with `:Lazy load <plugin-name>`
3. Check plugin documentation for proper lazy loading setup

## 📈 Measuring Success

**Good startup times:**
- < 50ms: Excellent
- 50-100ms: Very good  
- 100-200ms: Acceptable
- > 200ms: Needs more optimization

**Test with:**
```bash
# Average of 10 runs
hyperfine -w 3 -r 10 "nvim --headless +qall"
```

## 🔄 Maintenance

- **Monthly**: Review and update plugin configurations
- **Quarterly**: Profile startup time and optimize further
- **When adding plugins**: Always configure for lazy loading
- **When experiencing slowness**: Re-run startup profiling

---

*This optimization should significantly improve your Neovim startup experience. The key is lazy loading non-essential plugins and deferring heavy operations until they're actually needed.*