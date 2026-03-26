-- lua/plugins/bufferline.lua

local use = require('packer').use

use({
    'akinsho/bufferline.nvim',
    tag = "*",
    requires = {
        'nvim-tree/nvim-web-devicons'
    },
    config = function ()
        require('config.bufferline')
    end
})
