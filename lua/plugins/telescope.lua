-- lua/plugins/telescope.lua

return {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
        'nvim-lua/plenary.nvim',
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
        },
        'nvim-telescope/telescope-node-modules.nvim',
    },
    config = function()
        require('config.telescope')
    end,
}
