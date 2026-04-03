-- lua/plugins/catppuccin.lua

return {
    'catppuccin/nvim',
    name     = 'catppuccin',
    lazy     = false,
    priority = 1000,
    config   = function()
        require('catppuccin').setup({
            transparent_background = true,
            styles = {
                comments  = { 'italic' },
                keywords  = { 'bold' },
                functions = { 'italic', 'bold' },
            },
        })
    end,
}
