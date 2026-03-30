-- lua/config/neo-tree.lua

require('neo-tree').setup({
    close_if_last_window = true,
    filesystem = {
        hijack_netrw_behavior = 'open_default',
    },
})
