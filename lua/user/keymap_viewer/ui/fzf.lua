local M = {}
local fzf_lua = require "fzf-lua"
local formatter = require "user.keymap_viewer.formatter"
local search = require "user.keymap_viewer.search"

-- Cache for keymaps
local cached_keymaps = nil
local cache_time = 0
local CACHE_TTL = 60 -- seconds

-- Get all keymaps (with caching)
function M.get_keymaps()
  local now = os.time()
  if cached_keymaps and (now - cache_time) < CACHE_TTL then return cached_keymaps end

  local collector = require "user.keymap_viewer.collector"
  local descriptions = require "user.keymap_viewer.descriptions"

  local keymaps = collector.collect_all()
  keymaps = descriptions.enrich_descriptions(keymaps)

  cached_keymaps = keymaps
  cache_time = now

  return keymaps
end

-- Open keymap viewer
function M.open(options)
  options = options or {}

  local keymaps = M.get_keymaps()

  -- Apply initial filters
  if options.mode then keymaps = search.filter(keymaps, nil, { mode = options.mode }) end

  -- Sort
  keymaps = search.sort(keymaps, options.sort_by or "key")

  -- Prepare items as strings for FzfLua
  local items = {}
  local keymap_map = {} -- Map display text to keymap object

  for _, km in ipairs(keymaps) do
    local display_text = formatter.format_for_fzf(km)
    table.insert(items, display_text)
    keymap_map[display_text] = km
  end

  -- Store keymap_map globally for preview access
  _G._keymap_viewer_map = keymap_map

  -- Custom actions
  local actions = {
    ["default"] = function(selected, _)
      -- Just show preview, don't execute
      return
    end,
    ["ctrl-e"] = function(selected, _)
      if selected and selected[1] then
        local km = keymap_map[selected[1]]
        if km and km.source_file then
          vim.cmd("edit " .. vim.fn.fnameescape(km.source_file))
          if km.source_line then vim.fn.cursor(km.source_line, 1) end
        end
      end
    end,
    ["ctrl-y"] = function(selected, _)
      if selected and selected[1] then
        local km = keymap_map[selected[1]]
        if km then
          vim.fn.setreg("+", km.key)
          vim.notify("Copied keymap: " .. km.key, vim.log.levels.INFO)
        end
      end
    end,
  }

  -- Use FzfLua's fzf_exec with proper API
  -- Create a custom picker configuration
  local picker_config = {
    prompt = "Keymaps❯ ",
    fzf_opts = {
      ["--header"] = "Press Ctrl-E to edit source, Ctrl-Y to copy key",
      ["--preview-window"] = "right:50%:wrap",
    },
    winopts = {
      height = 0.85,
      width = 0.90,
      row = 0.35,
      col = 0.50,
      border = "rounded",
      preview = {
        border = "rounded",
        wrap = true,
        vertical = "right:50%",
        horizontal = "down:50%",
        layout = "flex",
        flip_columns = 120,
      },
    },
    actions = actions,
  }

  -- Create preview function that writes to a buffer
  local preview_buf = nil
  local function update_preview(selected_text)
    local km = keymap_map[selected_text]
    if km then
      local preview_content = formatter.format_for_preview(km)
      if preview_buf and vim.api.nvim_buf_is_valid(preview_buf) then
        vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, vim.split(preview_content, "\n"))
      end
    end
  end

  -- Use fzf_exec with items and custom preview
  -- Note: fzf_exec may need items as a function or table
  -- Try both approaches
  local success, err = pcall(function() fzf_lua.fzf_exec(items, picker_config) end)

  if not success then
    -- Fallback: use FzfLua's built-in keymaps with custom items
    -- Create a temporary approach using the items directly
    vim.notify("Using fallback keymap viewer", vim.log.levels.INFO)
    -- For now, just show items in a simple picker
    fzf_lua.fzf_exec(
      items,
      vim.tbl_extend("force", picker_config, {
        fn_transform = function(x)
          if x then update_preview(x) end
          return x
        end,
      })
    )
  end
end

-- Refresh cache
function M.refresh()
  cached_keymaps = nil
  cache_time = 0
end

return M
