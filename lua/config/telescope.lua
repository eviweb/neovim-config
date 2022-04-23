-- lua/config/telescope.lua

local telescope = require('telescope')

telescope.setup({
    defaults = {
        mappings = {
            i = {
                ['<C-h>'] = 'which_key',
            },
        },
        color_devicons = true,
    },
    extensions = {
        tele_tabby = {
            use_highlighter = true,
        }
    },
})

telescope.load_extension("node_modules")

