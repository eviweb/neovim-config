-- lua/plugins/treesitter.lua

local use = require('packer').use

use({
    'nvim-treesitter/nvim-treesitter',
	run = ':TSUpdate',
    requires = {
        'nvim-treesitter/nvim-treesitter-textobjects'
    },
    config = function()
        require("config.treesitter")
    end,
})

