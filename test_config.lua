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
    "user.plugins",
    "user.coc"
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

-- Test 4: Check COC function availability
if vim.fn.exists('*CocActionAsync') == 1 then
    print("✓ CocActionAsync is available")
else
    print("! CocActionAsync not available (normal if COC not loaded yet)")
end

if vim.fn.exists('*CocAction') == 1 then
    print("✓ CocAction is available")
else
    print("! CocAction not available (normal if COC not loaded yet)")
end

-- Test 5: Check spider plugin loading
local ok, spider = pcall(require, 'spider')
if ok then
    print("✓ nvim-spider loaded successfully")
else
    print("! nvim-spider not loaded (normal if lazy-loaded)")
end

print("Configuration test completed!")
print("Note: Some tests may not work in headless mode. Run inside Neovim for full testing.")
print("COC functions may not be available until COC.nvim plugin is fully loaded.")