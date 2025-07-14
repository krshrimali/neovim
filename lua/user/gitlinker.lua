local status_ok, gitlinker = pcall(require, "gitlinker")
if not status_ok then
    return
end

gitlinker.setup({
    opts = {
        -- callbacks = {
        -- 	["git.comcast.com"] = require("gitlinker.hosts").get_github_type_url,
        -- },
        -- adds current line nr in the url for normal mode
        add_current_line_on_normal_mode = true,
        -- callback for what to do with the url
        action_callback = require("gitlinker.actions").open_in_browser,
        -- print the url after performing the action
        print_url = true,
        -- mapping to call url generation
        mappings = "<leader>gy",
        -- router = {
        --     browse = {
        --         ["^github%.deshaw%.com"] = "https://github.deshaw.com/"
        --             .. "{_A.ORG}"
        --             .. "{_A.REPO}/blob/",
        --         ["github.deshaw.com"] = "https://github.deshaw.com/"
        --
        --             .. "{_A.ORG}"
        --             .. "{_A.REPO}/blob/",
        --     },
        --
        --     blame = {
        --         ["^github%.deshaw%.com"] = require('gitlinker.routers').github_blame,
        --     }
        -- }
    },
})
