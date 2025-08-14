-- Test script to verify terminal safety functions
require("user.terminal")
print("Testing terminal safety functions...")

-- Test the configure_terminal_buffer function
local function test_buffer_configuration()
  -- Create a test buffer
  local buf = vim.api.nvim_create_buf(false, true)
  
  if not vim.api.nvim_buf_is_valid(buf) then
    print("✗ Failed to create test buffer")
    return false
  end
  
  print("✓ Test buffer created successfully")
  
  -- Test buffer configuration
  local success = configure_terminal_buffer(buf)
  
  if success then
    print("✓ Buffer configuration successful")
  else
    print("✗ Buffer configuration failed")
  end
  
  -- Clean up
  vim.api.nvim_buf_delete(buf, { force = true })
  
  return success
end

-- Test the disable_treesitter_for_terminal function
local function test_treesitter_disable()
  -- Create a test buffer
  local buf = vim.api.nvim_create_buf(false, true)
  
  if not vim.api.nvim_buf_is_valid(buf) then
    print("✗ Failed to create test buffer")
    return false
  end
  
  print("✓ Test buffer created for treesitter test")
  
  -- Test treesitter disable
  local success = pcall(function()
    disable_treesitter_for_terminal(buf)
  end)
  
  if success then
    print("✓ Treesitter disable successful")
  else
    print("✗ Treesitter disable failed")
  end
  
  -- Clean up
  vim.api.nvim_buf_delete(buf, { force = true })
  
  return success
end

-- Run tests
print("\n=== Running Tests ===")
local config_success = test_buffer_configuration()
local treesitter_success = test_treesitter_disable()

print("\n=== Test Results ===")
if config_success and treesitter_success then
  print("✓ All tests passed! Terminal safety functions are working correctly.")
else
  print("✗ Some tests failed. Please check the implementation.")
end