-- lua/plugins/nightfox.lua

return {
    'EdenEast/nightfox.nvim',
    lazy = false,
    priority = 1000,
    config = function()
        require('config.nightfox')
        -- colorscheme applied centrally by the theme-init plugin (see plugins.lua)
    end,
}
