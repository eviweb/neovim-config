-- lua/plugins/lsp.lua

return {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'onsails/lspkind-nvim',
        'b0o/schemastore.nvim',
    },
    config = function()
        require('config.lsp')
    end,
}
