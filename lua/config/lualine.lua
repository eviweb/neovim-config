-- lua/config/lualine.lua

local lualine = require('lualine')
local is_navic_present, navic = pcall(require, 'nvim-navic')

local navic_component = {}
if is_navic_present then
    navic_component = {
        {
            navic.get_location,
            cond = navic.is_available,
            color = { fg = '#f3ca28' },
        },
    }
end

lualine.setup({
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = vim.list_extend(
            {
                {
                    'filename',
                    file_status = true,
                    path = 1,
                    shortingf_target = 40,
                    symbols = { modified = '[]', readonly = ' ' },
                },
            },
            navic_component
        ),
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
