-- lua/config/gitsigns.lua

require('gitsigns').setup({
    signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
    },
    on_attach = function(bufnr)
        local gs  = package.loaded.gitsigns
        local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end

        -- hunk navigation
        map('n', ']h', gs.next_hunk, 'Next hunk')
        map('n', '[h', gs.prev_hunk,  'Previous hunk')

        -- hunk actions
        map('n', '<Leader>gs', gs.stage_hunk,                                'Stage hunk')
        map('n', '<Leader>gr', gs.reset_hunk,                                'Reset hunk')
        map('n', '<Leader>gp', gs.preview_hunk,                              'Preview hunk')
        map('n', '<Leader>gb', function() gs.blame_line({ full = true }) end, 'Blame line')
        map('n', '<Leader>gd', gs.diffthis,                                  'Diff this file')
    end,
})
