-- lua/config/telescope.lua

local telescope = require('telescope')
local is_trouble_telescope_present, trouble_telescope = pcall(require, 'trouble.sources.telescope')

local trouble_open = nil
if is_trouble_telescope_present then
    trouble_open = trouble_telescope.open
end

telescope.setup({
    defaults = {
        mappings = {
            i = {
                ['<C-h>'] = 'which_key',
                ['<C-t>'] = trouble_open,
            },
            n = {
                ['<C-t>'] = trouble_open,
            },
        },
        color_devicons = true,
    },
})

telescope.load_extension('fzf')

pcall(telescope.load_extension, 'node_modules')
