-- lua/plugins/which-key.lua

local use = require('packer').use

use({
    'folke/which-key.nvim',
    config = function ()
        require('config.which-key')
    end
})

