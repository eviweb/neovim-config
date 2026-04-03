-- lua/config/which-key.lua

local wk = require('which-key')

wk.setup({
    plugins = {
        spelling = {
            enabled = true,
        },
    },
    icons = {
        -- Disable automatic keymap icons (requires Nerd Font; causes boxes without one).
        mappings = false,
    },
})

-- Group labels shown in the which-key popup when a prefix is pressed.
wk.add({
    { '<Leader>f',  group = 'Find' },
    { '<Leader>d',  group = 'Diagnostics' },
    { '<Leader>g',  group = 'Git' },
    { '<Leader>gg', desc  = 'Open lazygit' },
    { '<Leader>gv', desc  = 'Diff view' },
    { '<Leader>gH', desc  = 'File history' },
    { '<Leader>ft', desc  = 'Browse TODOs' },
    { '<Leader>h',  group = 'Help/Harpoon' },
    { '<Leader>ha', desc  = 'Harpoon: add file' },
    { '<Leader>hh', desc  = 'Harpoon: toggle menu' },
    { '<Leader>s',  group = 'Spell' },
    { '<Leader>q',  group = 'Session' },
    { '<Leader>qs', desc  = 'Restore session' },
    { '<Leader>qd', desc  = 'Stop session persistence' },
    { '<Leader>sr', desc  = 'Search/replace (Spectre)' },
    { '<Leader>sw', desc  = 'Search word under cursor' },
    { '<Leader>T',  group = 'Testing' },
    { '<Leader>Tr', desc  = 'Run nearest test' },
    { '<Leader>Tf', desc  = 'Run test file' },
    { '<Leader>Ts', desc  = 'Toggle test summary' },
    { '<Leader>To', desc  = 'Toggle output panel' },
    { '<Leader>t',  group = 'Toggle/Terminal' },
    { '<Leader>tz', desc  = 'Toggle Zen mode' },
    { '<Leader>tn', desc  = 'Cycle line numbers' },
    { '<Leader>tt', desc  = 'Toggle terminal' },
    { '<Leader>tC', desc  = 'Toggle Claude Code' },
    { '<Leader>tX', desc  = 'Toggle Codex CLI' },
    { '<Leader>n',  desc  = 'Toggle file explorer' },
    { '<Leader>?',  desc  = 'Browse keymaps' },
    { '<Leader>fp', desc  = 'Browse profiles' },
    { '<Leader>hc', desc  = 'Open cheatsheet' },
    { '<Leader>pp', desc  = 'Toggle paste mode' },
    { '<Leader><CR>', desc = 'Clear search highlight' },
    { '<Leader>cd', desc  = 'Change CWD to current file' },
    { '<Leader>ss', desc  = 'Toggle spell checking' },
})
