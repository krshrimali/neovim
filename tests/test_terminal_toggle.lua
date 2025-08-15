-- Test script to verify terminal toggle fix
print("Testing terminal toggle functionality...")

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

-- Test horizontal terminal toggle
local function test_horizontal_toggle()
  print("=== Testing Horizontal Terminal Toggle ===")
  
  -- Step 1: Create horizontal terminal
  print("1. Creating horizontal terminal...")
  local success, result = pcall(function()
    require("user.terminal").toggle_horizontal_terminal()
  end)
  
  if not success then
    print("✗ Failed to create horizontal terminal:", result)
    return false
  end
  
  vim.wait(100)
  local initial_count = count_terminal_windows()
  print("   Terminal windows after creation:", initial_count)
  
  if initial_count ~= 1 then
    print("✗ Expected 1 terminal window, got:", initial_count)
    return false
  end
  
  -- Step 2: Close terminal (toggle off)
  print("2. Closing horizontal terminal...")
  success, result = pcall(function()
    require("user.terminal").toggle_horizontal_terminal()
  end)
  
  if not success then
    print("✗ Failed to close horizontal terminal:", result)
    return false
  end
  
  vim.wait(100)
  local after_close_count = count_terminal_windows()
  print("   Terminal windows after closing:", after_close_count)
  
  if after_close_count ~= 0 then
    print("✗ Expected 0 terminal windows, got:", after_close_count)
    return false
  end
  
  -- Step 3: Reopen terminal (toggle on)
  print("3. Reopening horizontal terminal...")
  success, result = pcall(function()
    require("user.terminal").toggle_horizontal_terminal()
  end)
  
  if not success then
    print("✗ Failed to reopen horizontal terminal:", result)
    return false
  end
  
  vim.wait(100)
  local after_reopen_count = count_terminal_windows()
  print("   Terminal windows after reopening:", after_reopen_count)
  
  if after_reopen_count ~= 1 then
    print("✗ Expected 1 terminal window, got:", after_reopen_count)
    return false
  end
  
  print("✓ Horizontal terminal toggle test passed!")
  return true
end

-- Test vertical terminal toggle
local function test_vertical_toggle()
  print("\n=== Testing Vertical Terminal Toggle ===")
  
  -- Step 1: Create vertical terminal
  print("1. Creating vertical terminal...")
  local success, result = pcall(function()
    require("user.terminal").toggle_vertical_terminal()
  end)
  
  if not success then
    print("✗ Failed to create vertical terminal:", result)
    return false
  end
  
  vim.wait(100)
  local initial_count = count_terminal_windows()
  print("   Terminal windows after creation:", initial_count)
  
  if initial_count ~= 2 then  -- Should have 2: horizontal + vertical
    print("✗ Expected 2 terminal windows, got:", initial_count)
    return false
  end
  
  -- Step 2: Close terminal (toggle off)
  print("2. Closing vertical terminal...")
  success, result = pcall(function()
    require("user.terminal").toggle_vertical_terminal()
  end)
  
  if not success then
    print("✗ Failed to close vertical terminal:", result)
    return false
  end
  
  vim.wait(100)
  local after_close_count = count_terminal_windows()
  print("   Terminal windows after closing:", after_close_count)
  
  if after_close_count ~= 1 then  -- Should have 1: horizontal only
    print("✗ Expected 1 terminal window, got:", after_close_count)
    return false
  end
  
  -- Step 3: Reopen terminal (toggle on)
  print("3. Reopening vertical terminal...")
  success, result = pcall(function()
    require("user.terminal").toggle_vertical_terminal()
  end)
  
  if not success then
    print("✗ Failed to reopen vertical terminal:", result)
    return false
  end
  
  vim.wait(100)
  local after_reopen_count = count_terminal_windows()
  print("   Terminal windows after reopening:", after_reopen_count)
  
  if after_reopen_count ~= 2 then  -- Should have 2: horizontal + vertical
    print("✗ Expected 2 terminal windows, got:", after_reopen_count)
    return false
  end
  
  print("✓ Vertical terminal toggle test passed!")
  return true
end

-- Run tests
local horizontal_success = test_horizontal_toggle()
local vertical_success = test_vertical_toggle()

print("\n=== Final Test Results ===")
if horizontal_success and vertical_success then
  print("✓ All toggle tests passed! Terminal toggles work correctly.")
else
  print("✗ Some toggle tests failed. Please check the implementation.")
end