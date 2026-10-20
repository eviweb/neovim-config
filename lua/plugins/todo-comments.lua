-- lua/plugins/todo-comments.lua

return {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    event  = { 'BufReadPre', 'BufNewFile' },
    -- ]t / [t jump to the next / previous tagged comment. They replace Neovim's
    -- own :tnext / :tprevious (tag stack), which this config does not use.
    -- Declared as lazy keys so the first press also loads the plugin.
    keys = {
        { ']t', function() require('todo-comments').jump_next() end, desc = 'Next TODO comment' },
        { '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous TODO comment' },
    },
    config = function()
        require('todo-comments').setup()
    end,
}
