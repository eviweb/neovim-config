-- lua/plugins/lspconfig.lua

local use = require('packer').use

use({
    'neovim/nvim-lspconfig',
    requires = {
        'williamboman/nvim-lsp-installer',
        'onsails/lspkind-nvim',
        'b0o/schemastore.nvim',
    },
    config = function()
        require('config.lsp')
    end
})

