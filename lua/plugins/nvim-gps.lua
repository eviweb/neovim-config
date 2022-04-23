-- lua/plugins/nvim-gps.lua

local use = require('packer').use

use({
    "SmiteshP/nvim-gps",
	requires = "nvim-treesitter/nvim-treesitter",
    config = function()
        require("nvim-gps").setup()
    end
})

