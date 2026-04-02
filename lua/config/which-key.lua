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
    { '<Leader>f',  group = 'Find' },
    { '<Leader>d',  group = 'Diagnostics' },
    { '<Leader>g',  group = 'Git' },
    { '<Leader>h',  group = 'Help' },
    { '<Leader>s',  group = 'Spell' },
    { '<Leader>t',  group = 'Toggle' },
    { '<Leader>tn', desc  = 'Cycle line numbers' },
    { '<Leader>n',  desc  = 'Toggle file explorer' },
    { '<Leader>?',  desc  = 'Browse keymaps' },
    { '<Leader>fp', desc  = 'Browse profiles' },
    { '<Leader>hc', desc  = 'Open cheatsheet' },
    { '<Leader>pp', desc  = 'Toggle paste mode' },
    { '<Leader><CR>', desc = 'Clear search highlight' },
    { '<Leader>cd', desc  = 'Change CWD to current file' },
    { '<Leader>ss', desc  = 'Toggle spell checking' },
})
