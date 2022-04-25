-- lua/config/telescope.lua

local telescope = require('telescope')
local trouble = require('trouble')

telescope.setup({
    defaults = {
        mappings = {
            i = {
                ['<C-h>'] = 'which_key',
                ['<C-t>'] = trouble.open_with_trouble,
            },
            n = {
                ['<C-t>'] = trouble.open_with_trouble,
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

