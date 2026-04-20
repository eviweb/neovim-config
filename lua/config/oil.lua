-- lua/config/oil.lua

require('oil').setup({
    default_file_explorer = false,
    columns = { 'icon' },
    keymaps = {
        ['q'] = 'actions.close',
        ['?'] = 'actions.show_help',
    },
    view_options = {
        show_hidden = true,
    },
})

vim.keymap.set('n', '-', '<cmd>Oil<cr>', { desc = 'Open parent directory (oil)' })
