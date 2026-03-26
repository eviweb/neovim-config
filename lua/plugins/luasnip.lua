-- lua/plugins/luasnip.lua

local use = require('packer').use

use({
    'L3MON4D3/LuaSnip',
    requires = {
        'rafamadriz/friendly-snippets',
    },
    config = function ()
        require('luasnip/loaders/from_vscode').lazy_load()
    end
})

