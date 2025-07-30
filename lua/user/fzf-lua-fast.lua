-- Ultra-minimal fzf-lua configuration for debugging slow file opening
local status_ok, fzf_lua = pcall(require, "fzf-lua")
if not status_ok then
    return
end

-- Minimal setup focused on pure speed
fzf_lua.setup({
    -- Use max-perf profile
    "max-perf",
    
    -- Minimal window options
    winopts = {
        height = 0.8,
        width = 0.8,
        preview = {
            hidden = true, -- Always hidden
        },
    },
    
    -- Minimal fzf options
    fzf_opts = {
        ["--info"] = "hidden",
        ["--no-scrollbar"] = true,
        ["--no-separator"] = true,
        ["--layout"] = "reverse",
    },
    
    -- Minimal file picker
    files = {
        prompt = "Files> ",
        cmd = "fd --type f --strip-cwd-prefix",
        multiprocess = false, -- Try single process
        git_icons = false,
        file_icons = false,
        color_icons = false,
        previewer = false,
        cwd_prompt = false,
        path_shorten = false,
    },
    
    -- Minimal oldfiles
    oldfiles = {
        prompt = "Recent> ",
        stat_file = false,
        file_icons = false,
        git_icons = false,
        color_icons = false,
        previewer = false,
    },
    
    -- Minimal buffers
    buffers = {
        prompt = "Buffers> ",
        file_icons = false,
        color_icons = false,
        previewer = false,
    },
    
    -- Simple actions
    actions = {
        files = {
            ["enter"] = function(selected)
                if selected and #selected > 0 then
                    -- Direct file opening
                    vim.cmd.edit(selected[1])
                end
            end,
        },
    },
})

return fzf_lua