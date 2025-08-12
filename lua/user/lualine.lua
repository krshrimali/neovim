local M = {}
local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
    return
end

-- Breadcrumbs configuration
local breadcrumbs_config = {
    enabled_top = true,
    enabled_bottom = false,
    cache_timeout = 100, -- ms
    debounce_timeout = 50, -- ms
}

-- Breadcrumbs cache and debounce state
local breadcrumbs_cache = {
    last_update = 0,
    last_result = '',
    last_bufnr = -1,
    last_cursor_line = -1,
    debounce_timer = nil,
}

-- check if value in table
local function contains(t, value)
    for _, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

vim.o.statusline = vim.o.tabline

local hl_str = function(str)
    return "%#" .. "#" .. str .. "%*"
end

local hide_in_width_60 = function()
    return vim.o.columns > 60
end

local hide_in_width = function()
    return vim.o.columns > 80
end

local hide_in_width_100 = function()
    return vim.o.columns > 100
end

local diagnostics = {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    colored = false,
    update_in_insert = false,
    always_visible = true,
    padding = 1,
}

local diff = {
    "diff",
    colored = true,
    symbols = { added = "+" .. " ", modified = "=" .. " ", removed = "-" .. " " }, -- changes diff symbols
    cond = hide_in_width_60,
    separator = "│ " .. "%*",
}

local filetype = {
    "filetype",
    fmt = function(str)
        local ui_filetypes = {
            "help",
            "packer",
            "neogitstatus",
            "NvimTree",
            "Trouble",
            "lir",
            "Outline",
            "spectre_panel",
            "terminal",
            "DressingSelect",
            "",
            "nil",
        }

        local return_val = function(str_)
            -- return hl_str(" ", "SLSep") .. hl_str(str, "SLFT") .. hl_str("", "SLSep")
            return hl_str " (" .. hl_str(str_) .. hl_str ")"
        end

        if str == "TelescopePrompt" then
            return return_val("T")
        end

        local function get_term_num()
            local t_status_ok, toggle_num = pcall(vim.api.nvim_buf_get_var, 0, "toggle_number")
            if not t_status_ok then
                return ""
            end
            return toggle_num
        end

        if str == "terminal" then
            -- 
            local term = " " .. "%*" .. "TERM" .. "%*"

            return return_val(term)
        end

        if contains(ui_filetypes, str) then
            return ""
        else
            return return_val(str)
        end
    end,
    icons_enabled = false,
    padding = 0,
}

local branch = {
    "branch",
    icons_enabled = false,
    icon = " " .. "%*",
    -- color = "Constant",
    -- colored = false,
    padding = 1,
    -- cond = hide_in_width_100,
    fmt = function(str)
        if str == "" or str == nil then
            return "!=vcs"
        end

        return str
    end,
}

local progress = {
    "progress",
    fmt = function(str)
        -- return "▊"
        return hl_str "(" .. hl_str "%P/%L" .. hl_str ") "
        -- return "  "
    end,
    -- color = "SLProgress",
    padding = 0,
}

-- local current_signature = {
--   function()
--     local buf_ft = vim.bo.filetype

--     if buf_ft == "terminal" or buf_ft == "TelescopePrompt" then
--       return ""
--     end
--     -- if not pcall(require, "lsp_signature") then
--     --   return ""
--     -- end

--     local sig = require("lsp_signature").status_line()
--     -- return sig.label .. " " .. sig.hint

--     if not require("user.functions").isempty(sig.hint) then
--       -- return "%#SLSeparator#│ : " .. hint .. "%*"
--       -- return "%#SLSeparator#│ " .. hint .. "%*"
--       return sig.hint .. "%*"
--     end

--     -- return "functions empty"
--     return ""
--   end,
--   cond = hide_in_width_100,
--   padding = 0,
-- }

local spaces = {
    function()
        local buf_ft = vim.bo.filetype

        local ui_filetypes = {
            "help",
            "packer",
            "neogitstatus",
            "NvimTree",
            "Trouble",
            "lir",
            "Outline",
            "spectre_panel",
            "terminal",
            "DressingSelect",
            "",
        }
        local space = ""

        if contains(ui_filetypes, buf_ft) then
            space = " "
        end

        local shiftwidth = vim.api.nvim_buf_get_option(0, "shiftwidth")

        if shiftwidth == nil then
            return ""
        end

        -- TODO: update codicons and use their indent
        return hl_str " (" .. hl_str("Spaces: " .. shiftwidth .. space) .. hl_str ")"
    end,
    padding = 0,
    -- separator = "%#SLSeparator#" .. " │" .. "%*",
    -- cond = hide_in_width_100,
}

local lanuage_server = {
    function()
        local buf_ft = vim.bo.filetype
        local ui_filetypes = {
            "help",
            "packer",
            "neogitstatus",
            "NvimTree",
            "Trouble",
            "lir",
            "Outline",
            "spectre_panel",
            "terminal",
            "DressingSelect",
            "TelescopePrompt",
            "lspinfo",
            "lsp-installer",
            "",
        }

        if contains(ui_filetypes, buf_ft) then
            if M.language_servers == nil then
                return ""
            else
                return M.language_servers
            end
        end

        local clients = vim.lsp.get_clients { bufnr = 0 }
        local client_names = {}
        local copilot_active = false

        -- add client
        for _, client in pairs(clients) do
            if client.name ~= "copilot" and client.name ~= "null-ls" then
                table.insert(client_names, client.name)
            end
            if client.name == "copilot" then
                copilot_active = true
            end
        end

        -- add formatter and linter from null-ls if available
        local ok_sources, s = pcall(require, "null-ls.sources")
        if ok_sources then
            local available_sources = s.get_available(buf_ft)
            local registered = {}
            for _, source in ipairs(available_sources) do
                for method in pairs(source.methods) do
                    registered[method] = registered[method] or {}
                    table.insert(registered[method], source.name)
                end
            end

            local formatter = registered["NULL_LS_FORMATTING"]
            local linter = registered["NULL_LS_DIAGNOSTICS"]
            if formatter ~= nil then
                vim.list_extend(client_names, formatter)
            end
            if linter ~= nil then
                vim.list_extend(client_names, linter)
            end
        end

        -- join client names with commas
        local client_names_str = table.concat(client_names, ", ")

        -- check client_names_str if empty
        local language_servers = ""
        local client_names_str_len = #client_names_str
        if client_names_str_len ~= 0 then
            language_servers = hl_str "" .. hl_str(client_names_str) .. hl_str ""
        end
        if copilot_active then
            language_servers = language_servers .. " " .. "C" .. "%*"
        end

        if client_names_str_len == 0 and not copilot_active then
            return ""
        else
            M.language_servers = language_servers
            return language_servers:gsub(", anonymous source", "")
        end
    end,
    padding = 0,
    cond = hide_in_width,
    -- separator = "%#SLSeparator#" .. " │" .. "%*",
}

local location = {
    "location",
    fmt = function(str)
        -- return "▊"
        return hl_str " (" .. hl_str(str) .. hl_str ") "
        -- return hl_str(" (") .. hl_str(str) .. hl_str(") ")
        -- return "  "
    end,
    padding = 0,
}

-- Create optimized breadcrumbs function with caching and debouncing
local function get_breadcrumbs()
    local current_time = vim.loop.hrtime() / 1000000 -- Convert to milliseconds
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
    
    -- Check if we can use cached result
    if breadcrumbs_cache.last_bufnr == bufnr and
       breadcrumbs_cache.last_cursor_line == cursor_line and
       (current_time - breadcrumbs_cache.last_update) < breadcrumbs_config.cache_timeout then
        return breadcrumbs_cache.last_result
    end
    
    -- Clear existing debounce timer
    if breadcrumbs_cache.debounce_timer then
        vim.loop.timer_stop(breadcrumbs_cache.debounce_timer)
        vim.loop.timer_close(breadcrumbs_cache.debounce_timer)
        breadcrumbs_cache.debounce_timer = nil
    end
    
    -- Use cached result during debounce period
    if (current_time - breadcrumbs_cache.last_update) < breadcrumbs_config.debounce_timeout then
        return breadcrumbs_cache.last_result
    end
    
    local function update_breadcrumbs()
        local ok, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
        if not ok then 
            breadcrumbs_cache.last_result = ''
            return breadcrumbs_cache.last_result
        end
        
        local node = ts_utils.get_node_at_cursor()
        if not node then 
            breadcrumbs_cache.last_result = ''
            return breadcrumbs_cache.last_result
        end
        
        local current_node_type = node:type()
        
        -- Define node types for different languages
        local class_types = {
            'class_declaration', 'class_definition', 'impl_item', 'struct_item',
            'interface_declaration', 'trait_item', 'enum_item', 'type_item'
        }
        
        local function_types = {
            'function_item', 'function_definition', 'function_declaration',
            'method_definition', 'method_declaration', 'arrow_function'
        }
        
        -- Walk up the tree to collect hierarchy
        local current = node:parent()
        local class_name = nil
        local function_name = nil
        
        while current do
            local type = current:type()
            
            -- Look for class/struct/impl
            if not class_name then
                for _, class_type in ipairs(class_types) do
                    if type == class_type then
                        local name_node = current:field('name')[1] or 
                                         current:field('type')[1] or
                                         current:field('identifier')[1]
                        if name_node then
                            class_name = vim.treesitter.get_node_text(name_node, 0)
                            break
                        end
                    end
                end
            end
            
            -- Look for function/method
            if not function_name then
                for _, func_type in ipairs(function_types) do
                    if type == func_type then
                        local name_node = current:field('name')[1] or 
                                         current:field('identifier')[1]
                        if name_node then
                            function_name = vim.treesitter.get_node_text(name_node, 0)
                            break
                        end
                    end
                end
            end
            
            current = current:parent()
        end
        
        -- Build breadcrumb string
        local parts = {}
        if class_name then
            table.insert(parts, class_name)
        end
        if function_name then
            table.insert(parts, function_name)
        end
        -- Always show current node type (useful for debugging and context)
        table.insert(parts, current_node_type)
        
        local result = ''
        if #parts > 0 then
            result = ' → ' .. table.concat(parts, ' → ')
        end
        
        -- Update cache
        breadcrumbs_cache.last_result = result
        breadcrumbs_cache.last_update = current_time
        breadcrumbs_cache.last_bufnr = bufnr
        breadcrumbs_cache.last_cursor_line = cursor_line
        
        return result
    end
    
    -- Set up debounce timer
    breadcrumbs_cache.debounce_timer = vim.loop.new_timer()
    breadcrumbs_cache.debounce_timer:start(breadcrumbs_config.debounce_timeout, 0, vim.schedule_wrap(function()
        update_breadcrumbs()
        vim.cmd('redrawstatus')
    end))
    
    -- Return cached result or compute immediately if cache is stale
    if breadcrumbs_cache.last_result == '' or 
       breadcrumbs_cache.last_bufnr ~= bufnr then
        return update_breadcrumbs()
    end
    
    return breadcrumbs_cache.last_result
end

-- Breadcrumbs component factory
local function create_breadcrumbs_component()
    return {
        function()
            return get_breadcrumbs()
        end,
        cond = function() 
            return vim.bo.filetype ~= 'help' and 
                   vim.bo.filetype ~= 'alpha' and 
                   vim.bo.filetype ~= '' and
                   vim.bo.filetype ~= 'NvimTree' and
                   vim.bo.filetype ~= 'terminal'
        end
    }
end

-- Toggle functions for breadcrumbs
local function toggle_breadcrumbs_top()
    breadcrumbs_config.enabled_top = not breadcrumbs_config.enabled_top
    -- Clear cache to force refresh
    breadcrumbs_cache.last_update = 0
    breadcrumbs_cache.last_result = ''
    
    -- Update lualine configuration
    local config = require('lualine').get_config()
    if breadcrumbs_config.enabled_top then
        config.winbar.lualine_c = { 
            {
                'filename',
                path = 1,  -- Show relative path
            },
            create_breadcrumbs_component()
        }
    else
        config.winbar.lualine_c = { 
            {
                'filename',
                path = 1,  -- Show relative path
            }
        }
    end
    
    require('lualine').setup(config)
    print("Breadcrumbs top: " .. (breadcrumbs_config.enabled_top and "enabled" or "disabled"))
end

local function toggle_breadcrumbs_bottom()
    breadcrumbs_config.enabled_bottom = not breadcrumbs_config.enabled_bottom
    -- Clear cache to force refresh
    breadcrumbs_cache.last_update = 0
    breadcrumbs_cache.last_result = ''
    
    -- Update lualine configuration
    local config = require('lualine').get_config()
    if breadcrumbs_config.enabled_bottom then
        config.sections.lualine_c = { 
            {
                'filename',
                path = 3,  -- Show absolute path
            },
            create_breadcrumbs_component()
        }
    else
        config.sections.lualine_c = { 
            {
                'filename',
                path = 3,  -- Show absolute path
            }
        }
    end
    
    require('lualine').setup(config)
    print("Breadcrumbs bottom: " .. (breadcrumbs_config.enabled_bottom and "enabled" or "disabled"))
end

-- Create user commands
vim.api.nvim_create_user_command('BreadcrumbsToggleTop', toggle_breadcrumbs_top, {})
vim.api.nvim_create_user_command('BreadcrumbsToggleBottom', toggle_breadcrumbs_bottom, {})
vim.api.nvim_create_user_command('BreadcrumbsToggleBoth', function()
    toggle_breadcrumbs_top()
    toggle_breadcrumbs_bottom()
end, {})

-- Expose functions for external use
M.toggle_breadcrumbs_top = toggle_breadcrumbs_top
M.toggle_breadcrumbs_bottom = toggle_breadcrumbs_bottom
M.breadcrumbs_config = breadcrumbs_config

local lualine_scheme = "auto"
-- local lualine_scheme = "onedarker_alt"

local status_theme_ok, theme = pcall(require, "lualine.themes." .. lualine_scheme)
if not status_theme_ok then
    return
end

-- local navic = require("nvim-navic")

-- Create custom theme for Cursor Dark
local function create_cursor_dark_theme()
    local cursor_colors = require("user.themes.init").get_colors()
    
    return {
        normal = {
            a = { fg = cursor_colors.bg, bg = cursor_colors.blue, gui = 'bold' },
            b = { fg = cursor_colors.fg_light, bg = cursor_colors.bg_light },
            c = { fg = cursor_colors.fg, bg = cursor_colors.bg },
        },
        insert = {
            a = { fg = cursor_colors.bg, bg = cursor_colors.green, gui = 'bold' },
        },
        visual = {
            a = { fg = cursor_colors.bg, bg = cursor_colors.purple, gui = 'bold' },
        },
        replace = {
            a = { fg = cursor_colors.bg, bg = cursor_colors.red, gui = 'bold' },
        },
        command = {
            a = { fg = cursor_colors.bg, bg = cursor_colors.yellow, gui = 'bold' },
        },
        terminal = {
            a = { fg = cursor_colors.bg, bg = cursor_colors.cyan, gui = 'bold' },
        },
        inactive = {
            a = { fg = cursor_colors.fg_dark, bg = cursor_colors.bg_alt },
            b = { fg = cursor_colors.fg_dark, bg = cursor_colors.bg_alt },
            c = { fg = cursor_colors.fg_dark, bg = cursor_colors.bg_alt },
        },
    }
end

local cursor_theme = create_cursor_dark_theme()

lualine.setup {
    options = {
        globalstatus = true,
        icons_enabled = false,
        theme = cursor_theme,
        -- Alternative themes (commented out):
        -- theme = auto,
        -- theme = "shado",
        -- theme = "catppuccin",
        -- theme = "darkplus",
        -- theme = "gruvbox-material",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { "alpha", "dashboard" },
        always_divide_middle = true,
    },
    sections = {
        -- lualine_a = { left_pad, mode, branch, right_pad },
        -- lualine_a = { "mode", "branch", diff },
        -- lualine_a = { 'filename', file_status=true, path=2 },
        -- lualine_b = { diagnostics },
        -- lualine_c = {},
        -- lualine_c = { 'filename', { navic.get_location, cond = navic.is_available } },
        -- lualine_c = { 'filename', { function() return require('lspsaga.symbol.winbar').get_bar() end, cond = function()
        --     return
        --         require('lspsaga.symbol.winbar').get_bar() ~= nil
        -- end } },
        lualine_c = { 
            {
                'filename',
                path = 3,  -- Show absolute path
            },
            -- Bottom breadcrumbs (initially disabled)
            breadcrumbs_config.enabled_bottom and create_breadcrumbs_component() or nil
        },
        -- lualine_x = { diff, spaces, "encoding", filetype },
        -- lualine_x = { diff, lanuage_server, spaces, filetype },
        -- lualine_x = { lanuage_server, spaces, filetype },
        -- lualine_x = { lanuage_server, spaces, filetype },
        lualine_x = { lanuage_server, spaces },
        lualine_y = {
            -- "buffers",
            -- show_filename_only = true,
            -- show_modified_status = true,

            -- mode = 0,
            -- max_length = vim.o.columns * 2 / 3,

            -- buffer_color = {
            --   active = "lualine_x_normal",
            --   inactive = "lualine_x_inactive",
            -- },
        },
        -- {
        --   "filename",
        --   file_status = true,
        --   path = 3,
        -- },
        lualine_z = { location, progress },
    },
    winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 
            {
                'filename',
                path = 1,  -- Show relative path
            },
            -- Top breadcrumbs (initially enabled)
            breadcrumbs_config.enabled_top and create_breadcrumbs_component() or nil
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
    },
    inactive_winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
    },
    tabline = {},
    extensions = {},
}

return M
