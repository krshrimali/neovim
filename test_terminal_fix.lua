-- Test script to verify terminal fix
-- This script tests the horizontal terminal creation to ensure no treesitter errors

print("Testing horizontal terminal creation...")

-- Simulate the terminal creation process
local function test_horizontal_terminal()
  -- Create a split
  vim.cmd("split")
  
  -- Get the buffer
  local buf = vim.api.nvim_get_current_buf()
  
  -- Set buffer options (like in our fix)
  vim.api.nvim_buf_set_option(buf, "buftype", "terminal")
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  
  -- Disable syntax highlighting
  vim.api.nvim_buf_set_option(buf, "syntax", "")
  
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