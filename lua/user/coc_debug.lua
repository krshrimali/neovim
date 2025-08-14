-- COC Debug Helper
-- This helps diagnose COC completion issues

local M = {}

function M.check_coc_status()
    print("=== COC Debug Information ===")
    
    -- Check if COC is loaded
    if vim.fn.exists(':CocInfo') == 2 then
        print("✓ COC is loaded")
    else
        print("✗ COC is not loaded")
        return
    end
    
    -- Check COC service status
    local coc_status = vim.fn.CocAction('serviceReady')
    if coc_status then
        print("✓ COC service is ready")
    else
        print("✗ COC service is not ready")
    end
    
    -- Check extensions
    print("\n=== COC Extensions ===")
    require("user.coc_install").check_status()
    
    -- Check completion settings
    print("\n=== Completion Settings ===")
    print("omnifunc: " .. (vim.bo.omnifunc or "not set"))
    print("completefunc: " .. (vim.bo.completefunc or "not set"))
    print("completion_enable_auto_popup: " .. tostring(vim.g.completion_enable_auto_popup))
    
    -- Check LSP clients
    print("\n=== LSP Clients ===")
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
        for _, client in ipairs(clients) do
            print("LSP Client: " .. client.name)
            print("  - Completion: " .. tostring(client.server_capabilities.completionProvider ~= false))
        end
    else
        print("No LSP clients attached to current buffer")
    end
    
    -- Check if COC has completion for current filetype
    local filetype = vim.bo.filetype
    print("\n=== Current Buffer ===")
    print("Filetype: " .. filetype)
    
    -- Test COC completion trigger
    print("\n=== COC Completion Test ===")
    print("Try typing some code and press <C-Space> to trigger completion")
    print("Or run :CocList diagnostics to see if COC is working")
end

function M.fix_completion()
    print("=== Attempting to fix COC completion ===")
    
    -- Reset completion functions
    vim.bo.omnifunc = ''
    vim.bo.completefunc = ''
    
    -- Restart COC
    vim.cmd('CocRestart')
    
    print("COC restarted. Try completion again.")
end

function M.test_completion()
    print("=== Testing COC Completion ===")
    print("1. Make sure you're in a Python/JS/TS file")
    print("2. Type some code (e.g., 'import ' in Python)")
    print("3. Press <Tab> or <C-Space> to trigger completion")
    print("4. If no completion appears, run :CocInstallMissing")
end

return M