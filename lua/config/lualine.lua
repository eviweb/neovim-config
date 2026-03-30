-- lua/config/lualine.lua

local lualine = require('lualine')
local navic = require('nvim-navic')

lualine.setup({
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = {
            {
                'filename',
                file_status = true,
                path = 1,
                shortingf_target = 40,
                symbols = { modified = '[]', readonly = ' ' },
            },
            {
                navic.get_location,
                cond = navic.is_available,
                color = { fg = '#f3ca28' },
            },
        },
        lualine_x = {
            { 'diagnostics', sources = { 'nvim_diagnostic' } },
            'encoding',
            'fileformat',
            'filetype'
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
    },
})

