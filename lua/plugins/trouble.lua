-- lua/plugins/trouble.lua

local use = require('packer').use

use({
    'folke/trouble.nvim',
    requires = 'nvim-tree/nvim-web-devicons',
    config = function ()
        require('trouble').setup({})
    end
})

use({
    'folke/lsp-colors.nvim'
})
