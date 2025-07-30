-- Test script for Neovim configuration
-- Run this with: nvim -l test_config.lua

print("Testing Neovim configuration fixes...")

-- Test 1: Check if lazy.nvim can be loaded
local ok, lazy = pcall(require, "lazy")
if ok then
    print("✓ Lazy.nvim loaded successfully")
else
    print("✗ Failed to load lazy.nvim")
end

-- Test 2: Check if essential modules can be loaded
local essential_modules = {
    "user.options",
    "user.plugins"
}

for _, module in ipairs(essential_modules) do
    local ok, _ = pcall(require, module)
    if ok then
        print("✓ " .. module .. " loaded successfully")
    else
        print("✗ Failed to load " .. module)
    end
end

-- Test 3: Check LSP function availability
if vim.lsp then
    if vim.lsp.get_clients then
        print("✓ vim.lsp.get_clients() is available")
    else
        print("✗ vim.lsp.get_clients() is not available")
    end
    
    if vim.lsp.buf_get_clients then
        print("! vim.lsp.buf_get_clients() is still available (should be wrapped)")
    end
else
    print("! LSP not available in this context")
end

print("Configuration test completed!")
print("Note: Some tests may not work in headless mode. Run inside Neovim for full testing.")