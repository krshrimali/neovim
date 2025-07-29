M = {}
local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
    return
end

-- Use a static theme that matches the colorscheme without mode changes
local function get_colorscheme_theme()
    -- Get current colorscheme colors
    local normal_bg = vim.fn.synIDattr(vim.fn.hlID('Normal'), 'bg')
    local normal_fg = vim.fn.synIDattr(vim.fn.hlID('Normal'), 'fg')
    local statusline_bg = vim.fn.synIDattr(vim.fn.hlID('StatusLine'), 'bg')
    local statusline_fg = vim.fn.synIDattr(vim.fn.hlID('StatusLine'), 'fg')
    
    -- Fallback to reasonable defaults if colors are not found
    if normal_bg == '' then normal_bg = '#1e1e1e' end
    if normal_fg == '' then normal_fg = '#ffffff' end
    if statusline_bg == '' then statusline_bg = '#2d2d2d' end
    if statusline_fg == '' then statusline_fg = '#ffffff' end
    
    -- Create a static theme that doesn't change with mode
    local theme = {
        normal = {
            a = { fg = statusline_fg, bg = statusline_bg, gui = 'bold' },
            b = { fg = statusline_fg, bg = statusline_bg },
            c = { fg = statusline_fg, bg = 'NONE' },
        },
        insert = {
            a = { fg = statusline_fg, bg = statusline_bg, gui = 'bold' },
            b = { fg = statusline_fg, bg = statusline_bg },
            c = { fg = statusline_fg, bg = 'NONE' },
        },
        visual = {
            a = { fg = statusline_fg, bg = statusline_bg, gui = 'bold' },
            b = { fg = statusline_fg, bg = statusline_bg },
            c = { fg = statusline_fg, bg = 'NONE' },
        },
        replace = {
            a = { fg = statusline_fg, bg = statusline_bg, gui = 'bold' },
            b = { fg = statusline_fg, bg = statusline_bg },
            c = { fg = statusline_fg, bg = 'NONE' },
        },
        command = {
            a = { fg = statusline_fg, bg = statusline_bg, gui = 'bold' },
            b = { fg = statusline_fg, bg = statusline_bg },
            c = { fg = statusline_fg, bg = 'NONE' },
        },
        inactive = {
            a = { fg = statusline_fg, bg = statusline_bg },
            b = { fg = statusline_fg, bg = statusline_bg },
            c = { fg = statusline_fg, bg = 'NONE' },
        },
    }
    
    return theme
end

-- Cache for breadcrumbs to avoid expensive treesitter operations
local breadcrumb_cache = {}
local last_cursor_pos = {}

-- Optimized breadcrumb function with caching
local function get_cached_breadcrumbs()
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_key = bufnr .. ':' .. cursor[1] .. ':' .. cursor[2]
    
    -- Check if cursor position changed significantly (more than 2 lines)
    local last_pos = last_cursor_pos[bufnr]
    if last_pos and math.abs(cursor[1] - last_pos[1]) < 3 and breadcrumb_cache[bufnr] then
        return breadcrumb_cache[bufnr]
    end
    
    -- Update last cursor position
    last_cursor_pos[bufnr] = cursor
    
    -- Only calculate breadcrumbs for certain filetypes to improve performance
    local ft = vim.bo.filetype
    local supported_filetypes = {
        'lua', 'python', 'javascript', 'typescript', 'rust', 'go', 'c', 'cpp', 'java'
    }
    
    local is_supported = false
    for _, supported_ft in ipairs(supported_filetypes) do
        if ft == supported_ft then
            is_supported = true
            break
        end
    end
    
    if not is_supported then
        breadcrumb_cache[bufnr] = ''
        return ''
    end
    
    local ok, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
    if not ok then 
        breadcrumb_cache[bufnr] = ''
        return '' 
    end
    
    local node = ts_utils.get_node_at_cursor()
    if not node then 
        breadcrumb_cache[bufnr] = ''
        return '' 
    end
    
    -- Simplified breadcrumb generation - only get function/class names
    local breadcrumbs = {}
    local current = node:parent()
    
    while current and #breadcrumbs < 3 do -- Limit to 3 levels for performance
        local type = current:type()
        
        -- Only look for major structural elements
        if type:match('function') or type:match('method') or type:match('class') or type:match('struct') then
            local name_node = current:field('name')[1] or current:field('identifier')[1]
            if name_node then
                local name = vim.treesitter.get_node_text(name_node, 0)
                if name and name ~= '' then
                    table.insert(breadcrumbs, 1, name)
                end
            end
        end
        
        current = current:parent()
    end
    
    local result = ''
    if #breadcrumbs > 0 then
        result = ' → ' .. table.concat(breadcrumbs, ' → ')
    end
    
    breadcrumb_cache[bufnr] = result
    return result
end

-- Clear cache when buffer changes significantly
vim.api.nvim_create_autocmd({'BufWritePost', 'TextChanged'}, {
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        breadcrumb_cache[bufnr] = nil
    end
})

-- Refresh lualine when colorscheme changes to maintain dynamic theming
vim.api.nvim_create_autocmd('ColorScheme', {
    callback = function()
        -- Clear breadcrumb cache on colorscheme change
        breadcrumb_cache = {}
        last_cursor_pos = {}
        
        -- Refresh lualine with new theme
        vim.schedule(function()
            require('lualine').setup {
                options = {
                    globalstatus = true,
                    icons_enabled = false,
                    theme = get_colorscheme_theme(),
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    disabled_filetypes = { "alpha", "dashboard" },
                    always_divide_middle = true,
                    refresh = {
                        statusline = 1000,
                        tabline = 1000,
                        winbar = 1000,
                    },
                },
                sections = {
                    lualine_c = { 
                        {
                            'filename',
                            path = 3,
                        }
                    },
                    lualine_x = { lanuage_server, spaces },
                    lualine_y = {},
                    lualine_z = { location, progress },
                },
                winbar = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { 
                        {
                            'filename',
                            path = 1,
                        },
                        {
                            get_cached_breadcrumbs,
                            cond = function() 
                                return vim.bo.filetype ~= 'help' and vim.bo.filetype ~= 'alpha' and vim.bo.filetype ~= ''
                            end
                        }
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
        end)
    end
})

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
            "toggleterm",
            "DressingSelect",
            "",
            "nil",
        }

        local return_val = function(str_)
            -- return hl_str(" ", "SLSep") .. hl_str(str, "SLFT") .. hl_str("", "SLSep")
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

        if str == "toggleterm" then
            -- 
            local term = " " .. "%*" .. get_term_num() .. "%*"

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
    icon = " " .. "%*",
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
        -- return "  "
    end,
    -- color = "SLProgress",
    padding = 0,
}

-- local current_signature = {
--   function()
--     local buf_ft = vim.bo.filetype

--     if buf_ft == "toggleterm" or buf_ft == "TelescopePrompt" then
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
            "toggleterm",
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

        -- add formatter
        local s = require "null-ls.sources"
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

        -- join client names with commas
        local client_names_str = table.concat(client_names, ", ")

        -- check client_names_str if empty
        local language_servers = ""
        local client_names_str_len = #client_names_str
        if client_names_str_len ~= 0 then
            language_servers = hl_str "" .. hl_str(client_names_str) .. hl_str ""
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
        -- return "  "
    end,
    padding = 0,
}

lualine.setup {
    options = {
        globalstatus = true,
        icons_enabled = false,
        theme = get_colorscheme_theme(),
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { "alpha", "dashboard" },
        always_divide_middle = true,
        refresh = {
            statusline = 1000,  -- Refresh every 1 second instead of constantly
            tabline = 1000,
            winbar = 1000,
        },
    },
    sections = {
        lualine_c = { 
            {
                'filename',
                path = 3,  -- Show absolute path
            }
        },
        lualine_x = { lanuage_server, spaces },
        lualine_y = {},
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
            {
                get_cached_breadcrumbs,
                cond = function() 
                    return vim.bo.filetype ~= 'help' and vim.bo.filetype ~= 'alpha' and vim.bo.filetype ~= ''
                end
            }
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
