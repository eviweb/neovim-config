-- lua/config/which-key.lua

local wk = require('which-key')

wk.setup({
    plugins = {
        spelling = {
            enabled = true,
        },
    },
})

-- Group labels shown in the which-key popup when a prefix is pressed.
wk.add({
    { '<Leader>f', group = 'Find' },
    { '<Leader>d', group = 'Diagnostics' },
    { '<Leader>n', desc = 'Toggle file explorer' },
    { '<Leader>?', desc = 'Browse keymaps' },
})
