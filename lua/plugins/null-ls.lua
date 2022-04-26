-- lua/plugins/null-ls.lua

local use = require('packer').use

use({
    'jose-elias-alvarez/null-ls.nvim',
    requires = {
        'nvim-lua/plenary.nvim',
    },
    config = function ()
        require('config.null-ls')
    end
})

