-- lua/plugins/config/nightfox.lua

local nightfox = require('nightfox')

nightfox.setup({
    options = {
        transparent = true,
        styles = {
            comments = 'italic',
            keywords = 'bold',
            functions = 'italic,bold',
        },
    },
})

