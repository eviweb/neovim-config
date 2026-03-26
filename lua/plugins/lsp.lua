-- lua/plugins/lspconfig.lua

local use = require('packer').use

use({
    'neovim/nvim-lspconfig',
    requires = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'onsails/lspkind-nvim',
        'b0o/schemastore.nvim',
        'onsails/diaglist.nvim',
    },
    config = function()
        require('config.lsp')
    end
})
