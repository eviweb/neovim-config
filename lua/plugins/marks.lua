-- lua/plugins/marks.lua

return {
    'chentoast/marks.nvim',
    event = 'BufReadPost',
    config = function()
        require('config.marks')
    end,
}
