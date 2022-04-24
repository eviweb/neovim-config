-- lua/plugins/nvim-cmp.lua

local use = require('packer').use

use({
    'hrsh7th/nvim-cmp',
    requires = {
        'onsails/lspkind-nvim',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'saadparwaiz1/cmp_luasnip',
        'L3MON4D3/LuaSnip',        
        'rafamadriz/friendly-snippets',
    },
    config = function()
        require('config.nvim-cmp')
    end,
})

