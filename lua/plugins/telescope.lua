-- lua/plugins/telescope.lua

local use = require('packer').use

use({
    'nvim-telescope/telescope.nvim',
    requires = {
        'nvim-lua/plenary.nvim',
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            run = 'make',
        },
        'nvim-telescope/telescope-node-modules.nvim',
        'TC72/telescope-tele-tabby.nvim',
        'nvim-telescope/telescope-live-grep-raw.nvim',
        'nvim-telescope/telescope-symbols.nvim',
    },
    config = function()
        require('config.telescope')
    end,
})

