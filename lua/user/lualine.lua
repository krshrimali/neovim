local M = {}
local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
    return
end

local lualine_scheme = "auto"
-- local lualine_scheme = "onedarker_alt"

local status_theme_ok, theme = pcall(require, "lualine.themes." .. lualine_scheme)
if not status_theme_ok then
    return
end

-- local navic = require("nvim-navic")

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
                path = 3, -- Show absolute path
            },
            {
                function()
                    -- Cache to reduce jitter/flicker
                    local cache_key = vim.api.nvim_get_current_buf() .. ':' .. vim.fn.line('.') .. ':' .. vim.fn.col('.')
                    local cache_timeout = 100 -- milliseconds

                    -- Static cache table with cleanup
                    if not _G.breadcrumb_cache then
                        _G.breadcrumb_cache = {}
                        _G.breadcrumb_cache_last_cleanup = 0
                    end

                    -- Periodic cache cleanup to prevent memory leaks
                    local now = vim.loop.now()
                    if now - _G.breadcrumb_cache_last_cleanup > 10000 then      -- Cleanup every 10 seconds
                        for key, cached_item in pairs(_G.breadcrumb_cache) do
                            if now - cached_item.time > cache_timeout * 10 then -- Remove old entries
                                _G.breadcrumb_cache[key] = nil
                            end
                        end
                        _G.breadcrumb_cache_last_cleanup = now
                    end

                    local cached = _G.breadcrumb_cache[cache_key]
                    if cached and vim.loop.now() - cached.time < cache_timeout then
                        return cached.result
                    end

                    -- Safe treesitter breadcrumb navigation
                    local ok, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
                    if not ok then
                        -- Fallback: try the newer API
                        local ts_ok = pcall(require, 'nvim-treesitter')
                        if not ts_ok then
                            _G.breadcrumb_cache[cache_key] = { result = '', time = vim.loop.now() }
                            return ''
                        end
                    end

                    -- Get current node safely
                    local node
                    if ts_utils and ts_utils.get_node_at_cursor then
                        local ok_node, result_node = pcall(ts_utils.get_node_at_cursor)
                        if ok_node then
                            node = result_node
                        end
                    else
                        -- Use newer API if available
                        -- Check if current window is valid before getting cursor position
                        local current_win = vim.api.nvim_get_current_win()
                        if not vim.api.nvim_win_is_valid(current_win) then
                            _G.breadcrumb_cache[cache_key] = { result = '', time = vim.loop.now() }
                            return ''
                        end

                        local ok_cursor, cursor = pcall(vim.api.nvim_win_get_cursor, current_win)
                        if not ok_cursor then
                            _G.breadcrumb_cache[cache_key] = { result = '', time = vim.loop.now() }
                            return ''
                        end

                        local row, col = cursor[1] - 1, cursor[2]
                        local ok_parser, parser = pcall(vim.treesitter.get_parser, 0)
                        if not ok_parser or not parser then
                            _G.breadcrumb_cache[cache_key] = { result = '', time = vim.loop.now() }
                            return ''
                        end

                        local ok_parse, trees = pcall(parser.parse, parser)
                        if not ok_parse or not trees or not trees[1] then
                            _G.breadcrumb_cache[cache_key] = { result = '', time = vim.loop.now() }
                            return ''
                        end

                        local tree = trees[1]
                        local ok_desc, desc_node = pcall(tree.root, tree)
                        if not ok_desc then
                            _G.breadcrumb_cache[cache_key] = { result = '', time = vim.loop.now() }
                            return ''
                        end

                        local ok_range, range_node = pcall(desc_node.descendant_for_range, desc_node, row, col, row, col)
                        if ok_range then
                            node = range_node
                        end
                    end

                    if not node then
                        _G.breadcrumb_cache[cache_key] = { result = '', time = vim.loop.now() }
                        return ''
                    end

                    -- Define node types for different languages (comprehensive and language-agnostic)
                    local structural_types = {
                        -- Classes and similar structures
                        'class_declaration', 'class_definition', 'impl_item', 'struct_item',
                        'interface_declaration', 'trait_item', 'enum_item', 'type_item',
                        'class_body', 'impl_block', 'namespace_definition', 'module_definition',
                        'object_definition', 'type_declaration', 'type_definition',

                        -- Functions and methods
                        'function_item', 'function_definition', 'function_declaration',
                        'method_definition', 'method_declaration', 'arrow_function',
                        'function_expression', 'method_item', 'lambda', 'closure',
                        'anonymous_function', 'function_call', 'call_expression',

                        -- Variable assignments and declarations
                        'variable_declaration', 'variable_declarator', 'local_variable_declaration',
                        'assignment_statement', 'assignment_expression', 'local_declaration',
                        'let_declaration', 'const_declaration', 'var_declaration',
                        'field_declaration', 'property_declaration', 'attribute_statement',
                        'assignment', 'local_assignment', 'global_assignment',

                        -- Control structures that create scope
                        'if_statement', 'for_statement', 'while_statement', 'try_statement',
                        'with_statement', 'match_expression', 'block_expression',
                        'for_in_statement', 'for_numeric_statement', 'repeat_statement',
                        'switch_statement', 'case_statement', 'conditional_expression',

                        -- Language-specific constructs
                        'table_constructor', 'dictionary', 'list_comprehension',
                        'generator_expression', 'decorator', 'annotation'
                    }

                    -- Helper function to safely get node text
                    local function get_node_name(node_obj)
                        local ok_text, text = pcall(vim.treesitter.get_node_text, node_obj, 0)
                        if ok_text and text and text ~= '' then
                            -- Clean up the text (remove newlines, trim)
                            text = text:gsub('\n', ' '):match('^%s*(.-)%s*$')
                            -- Limit length to prevent winbar overflow
                            if #text > 25 then
                                text = text:sub(1, 22) .. '...'
                            end
                            return text
                        end
                        return nil
                    end

                    -- Helper function to find name node safely
                    local function find_name_node(current)
                        if not current then return nil end

                        -- Try different field names based on language
                        local field_names = {
                            'name', 'identifier', 'type', 'field_identifier', 'function_name',
                            'variable', 'left', 'target', 'id', 'key', 'property', 'field'
                        }

                        for _, field_name in ipairs(field_names) do
                            local ok_field, field_nodes = pcall(current.field, current, field_name)
                            if ok_field and field_nodes and field_nodes[1] then
                                return field_nodes[1]
                            end
                        end

                        -- Fallback: try to find identifier in immediate children
                        local ok_iter, iter = pcall(current.iter_children, current)
                        if ok_iter then
                            for child in iter do
                                local child_type = child:type()
                                if child_type == 'identifier' or child_type == 'name' or
                                    child_type == 'field_identifier' or child_type == 'property_identifier' then
                                    return child
                                end
                            end
                        end

                        return nil
                    end

                    -- Helper function to get a meaningful name from node
                    local function get_meaningful_name(current_node, node_type)
                        -- First try to get the direct name
                        local name_node = find_name_node(current_node)
                        if name_node then
                            local name = get_node_name(name_node)
                            if name and name ~= '' then
                                return name
                            end
                        end

                        -- Handle variable assignments and declarations
                        if node_type:match('assignment') or node_type:match('declaration') or node_type:match('local_') then
                            -- Try to extract variable name from assignment patterns
                            local full_text = get_node_name(current_node)
                            if full_text then
                                -- Match patterns like "local var_name =" or "var_name ="
                                local var_name = full_text:match('local%s+([%w_]+)%s*=') or
                                    full_text:match('^%s*([%w_]+)%s*=') or
                                    full_text:match('([%w_]+)%s*:') or             -- Python/JS object patterns
                                    full_text:match('([%w_]+)%s*%[') or            -- Array/table patterns
                                    full_text:match('([%w_]+)%s*%(')               -- Function call patterns

                                if var_name and var_name ~= '' then
                                    return var_name
                                end
                            end

                            -- Fallback: try to find the first identifier child
                            local ok_iter, iter = pcall(current_node.iter_children, current_node)
                            if ok_iter then
                                for child in iter do
                                    if child:type() == 'identifier' then
                                        local child_name = get_node_name(child)
                                        if child_name and child_name ~= '' then
                                            return child_name
                                        end
                                    end
                                end
                            end
                        end

                        -- Handle table constructors and similar structures
                        if node_type:match('table_') or node_type:match('dictionary') or node_type:match('object_') then
                            -- Look for the parent assignment to get the variable name
                            local parent = current_node:parent()
                            if parent and (parent:type():match('assignment') or parent:type():match('declaration')) then
                                return get_meaningful_name(parent, parent:type())
                            end
                        end

                        -- For control structures, try to get a meaningful snippet
                        if node_type:match('if_') or node_type:match('for_') or node_type:match('while_') then
                            local condition_text = get_node_name(current_node)
                            if condition_text then
                                -- Extract just the condition part, not the whole block
                                local condition = condition_text:match('(%w+[^{]*)')
                                if condition then
                                    return condition:gsub('%s+', ' ')
                                end
                            end
                        end

                        -- For function calls and expressions, try to get the function name
                        if node_type:match('call') or node_type:match('expression') then
                            local ok_iter, iter = pcall(current_node.iter_children, current_node)
                            if ok_iter then
                                for child in iter do
                                    if child:type() == 'identifier' or child:type() == 'field_expression' then
                                        local child_name = get_node_name(child)
                                        if child_name and child_name ~= '' and not child_name:match('^[%s%p]*$') then
                                            return child_name
                                        end
                                    end
                                end
                            end
                        end

                        return nil
                    end

                    -- Walk up the tree to collect ALL hierarchy
                    local current = node
                    local breadcrumbs = {}
                    local depth = 0
                    local max_depth = 30  -- Prevent infinite loops
                    local seen_names = {} -- Prevent duplicate names

                    while current and depth < max_depth do
                        local node_type = current:type()
                        depth = depth + 1

                        -- Check if this node type is structurally significant
                        for _, struct_type in ipairs(structural_types) do
                            if node_type == struct_type then
                                local meaningful_name = get_meaningful_name(current, node_type)
                                if meaningful_name and not seen_names[meaningful_name] then
                                    -- Filter out noise and very short/generic names
                                    if #meaningful_name > 1 and
                                        not meaningful_name:match('^[%s%p]*$') and
                                        not meaningful_name:match('^[%d]+$') and
                                        meaningful_name ~= 'end' and meaningful_name ~= 'do' then
                                        seen_names[meaningful_name] = true
                                        -- Insert at the beginning to maintain hierarchy order
                                        table.insert(breadcrumbs, 1, meaningful_name)
                                    end
                                    break -- Only process this node once
                                end
                            end
                        end

                        current = current:parent()
                    end

                    -- Build breadcrumb string
                    local result = ''
                    if #breadcrumbs > 0 then
                        result = ' → ' .. table.concat(breadcrumbs, ' → ')
                    end

                    -- Cache the result
                    _G.breadcrumb_cache[cache_key] = { result = result, time = vim.loop.now() }

                    return result
                end,
                cond = function()
                    local ft = vim.bo.filetype
                    -- Enable for programming languages only
                    local supported_types = {
                        'lua', 'python', 'javascript', 'typescript', 'rust', 'go',
                        'c', 'cpp', 'java', 'php', 'ruby', 'html', 'css'
                    }

                    for _, supported_ft in ipairs(supported_types) do
                        if ft == supported_ft then
                            return true
                        end
                    end

                    return false
                end
            }
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
    tabline = {},
    extensions = {},
}
