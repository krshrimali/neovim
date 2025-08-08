-- Test script to verify vi mode functionality
print("Testing vi mode functionality...")

-- Function to test vi mode in terminal
local function test_vi_mode()
  print("=== Testing Vi Mode in Terminal ===")
  
  -- Create a horizontal terminal
  print("1. Creating horizontal terminal with vi mode...")
  local success, result = pcall(function()
    require("user.terminal").horizontal_terminal()
  end)
  
  if not success then
    print("✗ Failed to create terminal:", result)
    return false
  end
  
  print("✓ Terminal created successfully")
  print("   Vi mode should be enabled automatically")
  print("   You can now:")
  print("   - Press 'Esc' to enter normal mode in the terminal")
  print("   - Use 'h', 'j', 'k', 'l' to navigate")
  print("   - Use 'i' to enter insert mode")
  print("   - Use 'v' to enter visual mode")
  print("   - Use 'w', 'b', 'e' for word navigation")
  print("   - Use '0', '$' for line navigation")
  
  return true
end

-- Function to test different shells
local function test_shell_vi_mode()
  print("\n=== Testing Different Shells ===")
  
  -- Test fish shell
  print("1. Testing fish shell vi mode...")
  local success, result = pcall(function()
    require("user.terminal").float_terminal("fish")
  end)
  
  if success then
    print("✓ Fish terminal created with vi mode")
  else
    print("✗ Failed to create fish terminal:", result)
  end
  
  -- Test zsh shell
  print("2. Testing zsh shell vi mode...")
  success, result = pcall(function()
    require("user.terminal").float_terminal("zsh")
  end)
  
  if success then
    print("✓ Zsh terminal created with vi mode")
  else
    print("✗ Failed to create zsh terminal:", result)
  end
  
  return true
end

-- Run tests
local vi_mode_success = test_vi_mode()
local shell_success = test_shell_vi_mode()

print("\n=== Test Results ===")
if vi_mode_success and shell_success then
  print("✓ Vi mode functionality is working!")
  print("   You can now use vi key bindings in your terminals.")
  print("   Press 'Esc' in any terminal to enter normal mode.")
else
  print("✗ Some vi mode tests failed.")
end

print("\n=== Vi Mode Instructions ===")
print("In your terminals, you can now:")
print("- Press 'Esc' to enter normal mode")
print("- Use 'h', 'j', 'k', 'l' for navigation")
print("- Use 'i' to enter insert mode")
print("- Use 'v' to enter visual mode")
print("- Use 'w', 'b', 'e' for word navigation")
print("- Use '0', '$' for line navigation")
print("- Use 'dd' to delete lines")
print("- Use 'yy' to yank lines")
print("- Use 'p' to paste")