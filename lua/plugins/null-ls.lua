-- lua/plugins/null-ls.lua

return {
    'nvimtools/none-ls.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('config.null-ls')
    end,
}
