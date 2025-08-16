-- Enhanced Buffer Navigation for Alt+H/J/K/L
-- Works with all buffers including special ones like SimpleTree, terminals, etc.
local M = {}

-- Get all windows in the current tabpage
local function get_all_windows() return vim.api.nvim_tabpage_list_wins(0) end

-- Get window position for navigation logic
local function get_window_position(win)
  local config = vim.api.nvim_win_get_config(win)
  if config.relative ~= "" then
    -- Floating window - use row/col from config
    return {
      row = config.row or 0,
      col = config.col or 0,
      width = config.width or 1,
      height = config.height or 1,
      is_float = true,
    }
  else
    -- Normal window - use actual position
    local pos = vim.api.nvim_win_get_position(win)
    return {
      row = pos[1],
      col = pos[2],
      width = vim.api.nvim_win_get_width(win),
      height = vim.api.nvim_win_get_height(win),
      is_float = false,
    }
  end
end

-- Check if a window is valid and focusable
local function is_window_focusable(win)
  if not vim.api.nvim_win_is_valid(win) then return false end

  -- Get buffer in the window
  local buf = vim.api.nvim_win_get_buf(win)
  if not vim.api.nvim_buf_is_valid(buf) then return false end

  -- Allow all buffer types including special ones
  local buftype = vim.bo[buf].buftype
  local filetype = vim.bo[buf].filetype

  -- Skip only very specific non-interactive buffers
  if buftype == "quickfix" and filetype ~= "qf" then return false end

  -- Skip nofile buffers that are likely to be temporary/non-interactive
  -- but allow important ones like SimpleTree
  if buftype == "nofile" then
    -- Allow known interactive nofile buffers
    local allowed_filetypes = {
      "SimpleTree",
      "NvimTree",
      "neo-tree",
      "oil",
      "help",
      "man",
    }

    local is_allowed = false
    for _, allowed_ft in ipairs(allowed_filetypes) do
      if filetype == allowed_ft then
        is_allowed = true
        break
      end
    end

    -- If not explicitly allowed, check if it has a meaningful name
    if not is_allowed then
      local name = vim.api.nvim_buf_get_name(buf)
      -- Allow if it has a real file name or is empty (could be SimpleTree)
      if name == "" or name:match "^/" then is_allowed = true end
    end

    if not is_allowed then return false end
  end

  return true
end

-- Find the best window in a given direction
local function find_window_in_direction(direction)
  local current_win = vim.api.nvim_get_current_win()
  local current_pos = get_window_position(current_win)
  local all_windows = get_all_windows()

  local candidates = {}

  for _, win in ipairs(all_windows) do
    if win ~= current_win and is_window_focusable(win) then
      local pos = get_window_position(win)
      local candidate = {
        win = win,
        pos = pos,
        distance = 0,
        alignment = 0,
      }

      -- Calculate if this window is in the right direction
      local is_valid_direction = false
      local distance = 0
      local alignment = 0

      if direction == "h" then -- Left
        if pos.col + pos.width <= current_pos.col then
          is_valid_direction = true
          distance = current_pos.col - (pos.col + pos.width)
          alignment = math.abs(pos.row - current_pos.row)
        end
      elseif direction == "l" then -- Right
        if pos.col >= current_pos.col + current_pos.width then
          is_valid_direction = true
          distance = pos.col - (current_pos.col + current_pos.width)
          alignment = math.abs(pos.row - current_pos.row)
        end
      elseif direction == "k" then -- Up
        if pos.row + pos.height <= current_pos.row then
          is_valid_direction = true
          distance = current_pos.row - (pos.row + pos.height)
          alignment = math.abs(pos.col - current_pos.col)
        end
      elseif direction == "j" then -- Down
        if pos.row >= current_pos.row + current_pos.height then
          is_valid_direction = true
          distance = pos.row - (current_pos.row + current_pos.height)
          alignment = math.abs(pos.col - current_pos.col)
        end
      end

      if is_valid_direction then
        candidate.distance = distance
        candidate.alignment = alignment
        table.insert(candidates, candidate)
      end
    end
  end

  if #candidates == 0 then return nil end

  -- Sort by distance first, then by alignment
  table.sort(candidates, function(a, b)
    if a.distance == b.distance then return a.alignment < b.alignment end
    return a.distance < b.distance
  end)

  return candidates[1].win
end

-- Navigate to window in direction, with fallback to vim's default behavior
local function navigate_to_window(direction)
  local target_win = find_window_in_direction(direction)

  if target_win then
    vim.api.nvim_set_current_win(target_win)
  else
    -- Fallback to vim's default window navigation
    local cmd_map = {
      h = "<C-w>h",
      j = "<C-w>j",
      k = "<C-w>k",
      l = "<C-w>l",
    }

    local cmd = cmd_map[direction]
    if cmd then vim.cmd("normal! " .. cmd) end
  end
end

-- Main navigation functions
function M.navigate_left() navigate_to_window "h" end

function M.navigate_down() navigate_to_window "j" end

function M.navigate_up() navigate_to_window "k" end

function M.navigate_right() navigate_to_window "l" end

-- Debug function to show window layout
function M.debug_windows()
  local current_win = vim.api.nvim_get_current_win()
  local all_windows = get_all_windows()

  print "=== Window Layout Debug ==="
  print("Current window:", current_win)

  for _, win in ipairs(all_windows) do
    local pos = get_window_position(win)
    local buf = vim.api.nvim_win_get_buf(win)
    local buftype = vim.bo[buf].buftype
    local filetype = vim.bo[buf].filetype
    local name = vim.api.nvim_buf_get_name(buf)
    local focusable = is_window_focusable(win)

    print(
      string.format(
        "Win %d: pos(%d,%d) size(%dx%d) buf=%s ft=%s focusable=%s %s",
        win,
        pos.col,
        pos.row,
        pos.width,
        pos.height,
        buftype == "" and "normal" or buftype,
        filetype == "" and "none" or filetype,
        focusable and "yes" or "no",
        current_win == win and "[CURRENT]" or ""
      )
    )

    if name ~= "" then print("  Name:", vim.fn.fnamemodify(name, ":t")) end
  end
  print "========================"
end

return M
