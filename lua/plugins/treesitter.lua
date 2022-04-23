-- lua/plugins/treesitter.lua

local use = require('packer').use

use({
    'nvim-treesitter/nvim-treesitter',
	run = ':TSUpdate',
    config = function()
        require("config.treesitter")
    end,
})

