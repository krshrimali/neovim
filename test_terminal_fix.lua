-- Test script to verify terminal fix
-- This script tests the horizontal terminal creation to ensure no treesitter errors

require("user.terminal")

print("Testing horizontal terminal creation...")

-- Simulate the terminal creation process
local function test_horizontal_terminal()
  -- Create a split
  vim.cmd("split")
  
  -- Create a scratch buffer and set it in the split (matches implementation)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)
  
  -- Configure buffer safely using helper
  local ok = configure_terminal_buffer(buf)
  if not ok then
    error("configure_terminal_buffer failed")
  end
  
  -- Disable treesitter/syntax safely using helper
  disable_treesitter_for_terminal(buf)
  
  print("Buffer configured as terminal type")
  print("Treesitter highlighting disabled")
  
  -- Open terminal
  local job_id = vim.fn.termopen("echo 'Test terminal'")
  
  print("Terminal opened successfully")
  print("Job ID:", job_id)
  
  return buf, job_id
end

-- Run the test
local success, result = pcall(test_horizontal_terminal)
if success then
  print("✓ Test passed: Horizontal terminal created without errors")
else
  print("✗ Test failed:", result)
end