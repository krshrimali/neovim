-- Test script to verify horizontal terminal fix
print("Testing horizontal terminal creation...")

-- Function to count terminal buffers
local function count_terminal_buffers()
  local count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
      if buftype == "terminal" then
        count = count + 1
      end
    end
  end
  return count
end

-- Function to count terminal windows
local function count_terminal_windows()
  local count = 0
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_buf_is_valid(buf) then
        local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
        if buftype == "terminal" then
          count = count + 1
        end
      end
    end
  end
  return count
end

-- Test horizontal terminal creation
local function test_horizontal_terminal()
  print("Initial terminal buffers:", count_terminal_buffers())
  print("Initial terminal windows:", count_terminal_windows())
  
  -- Create horizontal terminal
  print("\nCreating horizontal terminal...")
  local success, result = pcall(function()
    require("user.terminal").horizontal_terminal()
  end)
  
  if success then
    print("✓ Horizontal terminal created successfully")
  else
    print("✗ Failed to create horizontal terminal:", result)
    return false
  end
  
  -- Wait a moment for the terminal to initialize
  vim.wait(100)
  
  print("Terminal buffers after creation:", count_terminal_buffers())
  print("Terminal windows after creation:", count_terminal_windows())
  
  -- Check if we have exactly one terminal window
  local terminal_windows = count_terminal_windows()
  if terminal_windows == 1 then
    print("✓ Correct number of terminal windows (1)")
    return true
  else
    print("✗ Incorrect number of terminal windows:", terminal_windows)
    return false
  end
end

-- Run the test
local test_success = test_horizontal_terminal()

print("\n=== Test Result ===")
if test_success then
  print("✓ Test passed: Horizontal terminal creates exactly one terminal window")
else
  print("✗ Test failed: Multiple terminal windows detected")
end