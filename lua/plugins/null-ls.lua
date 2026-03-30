-- lua/plugins/null-ls.lua

return {
    'nvimtools/none-ls.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('config.null-ls')
    end,
}
