-- lua/plugins/vim-illuminate.lua

return {
    'RRethy/vim-illuminate',
    event  = { 'BufReadPre', 'BufNewFile' },
    config = function()
        require('illuminate').configure({
            delay      = 200,
            filetypes_denylist = { 'neo-tree', 'TelescopePrompt', 'mason' },
        })
    end,
}
