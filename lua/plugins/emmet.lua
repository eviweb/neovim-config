-- lua/plugins/emmet.lua

local use = require('packer').use

use({
    'mattn/emmet-vim',
    requires = {
        'mattn/webapi-vim',
    },
})

