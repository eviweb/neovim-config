-- lua/plugins/nightfox.lua

return {
    'EdenEast/nightfox.nvim',
    lazy = false,
    priority = 1000,
    config = function()
        require('config.nightfox')
        vim.cmd([[colorscheme nightfox]])
    end,
}
