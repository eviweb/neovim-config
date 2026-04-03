-- lua/plugins/kanagawa.lua

return {
    'rebelot/kanagawa.nvim',
    lazy     = false,
    priority = 1000,
    config   = function()
        require('kanagawa').setup({
            transparent = true,
            styles = {
                comment  = { italic = true },
                keyword  = { bold = true },
                function_call = { italic = true, bold = true },
            },
        })
    end,
}
