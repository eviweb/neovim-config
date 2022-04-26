-- lua/plugins/treesitter-textobjects.lua

local use = require('packer').use

use({
    'nvim-treesitter/nvim-treesitter-textobjects',
    requires = {
        'nvim-treesitter/nvim-treesitter',
    },
})

