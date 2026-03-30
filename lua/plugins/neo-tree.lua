-- lua/plugins/neo-tree.lua

local use = require('packer').use

use({
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    requires = {
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons',
        'MunifTanjim/nui.nvim',
    },
    config = function()
        require('config.neo-tree')
    end
})
