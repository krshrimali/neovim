-- Test file for Next Edit Suggestions
-- Run this with :luafile test-next-edit.lua

print("Testing Next Edit Suggestions...")

-- Test 1: Check if plugin is loaded
local ok, next_edit = pcall(require, "next-edit-suggestions")
if not ok then
  print("❌ Plugin not loaded:", next_edit)
  return
end

print("✅ Plugin loaded successfully")

-- Test 2: Check plugin status
local status = next_edit.status()
print("Plugin status:", vim.inspect(status))

-- Test 3: Test keymap registration
print("\nTesting keymaps...")
print("Try these commands:")
print("  :NextEditTest - Create test suggestions")
print("  :NextEditTrigger - Manually trigger detection")
print("  <leader>nt - Toggle plugin")
print("  <leader>ns - Show status")

-- Test 4: Create test suggestions directly
print("\nCreating test suggestions...")
local bufnr = vim.api.nvim_get_current_buf()
local cursor = vim.api.nvim_win_get_cursor(0)
local line = cursor[1] - 1

local test_suggestions = {
  {
    line = line + 1,
    col_start = 0,
    col_end = 5,
    text = "newVar",
    type = "rename_suggestion",
    distance = 1,
    priority = "nearby"
  },
  {
    line = line + 2,
    col_start = 8,
    col_end = 13,
    text = "newVar", 
    type = "rename_suggestion",
    distance = 2,
    priority = "nearby"
  }
}

local change_info = {
  new_name = "newVar",
  line = line,
  col = cursor[2],
  type = "variable"
}

-- Display test suggestions
next_edit.display_edit_suggestions(test_suggestions, change_info)

print("✅ Test suggestions created!")
print("\nNow try these keys in normal mode:")
print("  <Tab> - Apply current suggestion and go to next")
print("  <CR> - Accept current suggestion") 
print("  <leader>x - Dismiss suggestions")
print("  <leader>a - Apply all suggestions")
print("  <leader>u - Undo last suggestion")

print("\nIf keymaps don't work, check with:")
print("  :verbose map <Tab>")
print("  :verbose map <CR>")
print("  :verbose map <leader>x")