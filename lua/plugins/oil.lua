-- lua/plugins/oil.lua

return {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd  = 'Oil',
    keys = { '-' },
    config = function()
        require('config.oil')
    end,
}
