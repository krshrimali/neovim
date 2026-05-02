-- remote-mode: detect SSH/remote sessions and apply a low-bandwidth UI profile.
-- Toggleable, restorable. Auto-applies on VimEnter when $SSH_TTY is set.

local M = {}

local saved = nil
local active = false

local defaults = {
  auto = true,
  detect = function() return vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil end,
  options = {
    cursorline = false,
    cursorcolumn = false,
    termguicolors = false,
    lazyredraw = true,
    updatetime = 500,
    signcolumn = "yes:1",
    showcmd = false,
    ruler = false,
  },
  diagnostic = {
    update_in_insert = false,
    virtual_text = false,
    signs = true,
    underline = true,
  },
  lualine_refresh = { statusline = 1000, tabline = 2000, winbar = 2000 },
  treesitter_disable_above = 2000, -- disable TS highlight on buffers larger than N lines
}

local config = vim.deepcopy(defaults)

local function snapshot()
  local s = { options = {}, diagnostic = nil, lualine = nil }
  for k, _ in pairs(config.options) do
    s.options[k] = vim.opt[k]:get()
  end
  s.diagnostic = {
    update_in_insert = vim.diagnostic.config().update_in_insert,
    virtual_text = vim.diagnostic.config().virtual_text,
    signs = vim.diagnostic.config().signs,
    underline = vim.diagnostic.config().underline,
  }
  local ok, lualine = pcall(require, "lualine")
  if ok and lualine.get_config then s.lualine = lualine.get_config() end
  return s
end

local function apply_options(opts)
  for k, v in pairs(opts) do
    vim.opt[k] = v
  end
end

local function apply_lualine(refresh)
  local ok, lualine = pcall(require, "lualine")
  if not ok then return end
  local cfg = lualine.get_config and lualine.get_config() or {}
  cfg.options = cfg.options or {}
  cfg.options.refresh = vim.tbl_extend("force", cfg.options.refresh or {}, refresh)
  lualine.setup(cfg)
end

local function apply_treesitter_limit(limit)
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("RemoteModeTSLimit", { clear = true }),
    callback = function(args)
      local line_count = vim.api.nvim_buf_line_count(args.buf)
      if line_count > limit then pcall(vim.treesitter.stop, args.buf) end
    end,
  })
end

local function clear_treesitter_limit() pcall(vim.api.nvim_del_augroup_by_name, "RemoteModeTSLimit") end

function M.enable()
  if active then return end
  saved = snapshot()
  apply_options(config.options)
  vim.diagnostic.config(config.diagnostic)
  apply_lualine(config.lualine_refresh)
  if config.treesitter_disable_above then apply_treesitter_limit(config.treesitter_disable_above) end
  active = true
  vim.notify("remote-mode: enabled", vim.log.levels.INFO)
end

function M.disable()
  if not active or not saved then return end
  apply_options(saved.options)
  if saved.diagnostic then vim.diagnostic.config(saved.diagnostic) end
  if saved.lualine then
    local ok, lualine = pcall(require, "lualine")
    if ok then lualine.setup(saved.lualine) end
  end
  clear_treesitter_limit()
  active = false
  saved = nil
  vim.notify("remote-mode: disabled", vim.log.levels.INFO)
end

function M.toggle()
  if active then
    M.disable()
  else
    M.enable()
  end
end

function M.status() vim.notify("remote-mode: " .. (active and "ON" or "OFF"), vim.log.levels.INFO) end

function M.setup(user)
  config = vim.tbl_deep_extend("force", defaults, user or {})

  vim.api.nvim_create_user_command("RemoteModeEnable", M.enable, {})
  vim.api.nvim_create_user_command("RemoteModeDisable", M.disable, {})
  vim.api.nvim_create_user_command("RemoteModeToggle", M.toggle, {})
  vim.api.nvim_create_user_command("RemoteModeStatus", M.status, {})

  if config.auto and config.detect() then
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function() M.enable() end,
    })
  end
end

return M
