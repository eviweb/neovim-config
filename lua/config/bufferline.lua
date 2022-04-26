-- lua/config/bufferline.lua

local bufferline = require('bufferline')

bufferline.setup({
    options = {
        offsets = {
            {
                filetype = "NvimTree",
                text = "File Explorer",
                highlight = "Directory",
                text_align = "left"
            }
        },
    }
})

