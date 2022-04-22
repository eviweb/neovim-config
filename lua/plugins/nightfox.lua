-- lua/plugins/nightfox.lua

local use = require('packer').use

use({
    'EdenEast/nightfox.nvim',
    config = function()
        require('config.nightfox')
    end

})

