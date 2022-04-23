-- lua/config/treesitter.lua

local treesitter = require('nvim-treesitter.configs')

treesitter.setup({
    ensure_installed = "all",
    sync_installed = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "php" },
    },
    indent = {
        enable = false,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
        },
    },
    rainbow = {
        enable = true,
        disable = {},
        extended_mode = true,
        max_file_lines = nil,
    },
})

-- enables folds (zc and zo) on functions and classes but not by default
vim.cmd([[
    set nofoldenable
    set foldmethod=expr
    set foldexpr=nvim_treesitter#foldexpr()
]])

