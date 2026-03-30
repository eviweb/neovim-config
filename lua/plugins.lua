-- lua/plugins.lua

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git', 'clone', '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable',
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    -- Themes
    require('plugins.nightfox'),

    -- Status bar
    require('plugins.lualine'),

    -- File browser
    require('plugins.neo-tree'),

    -- Parsers
    require('plugins.treesitter'),

    -- Utils
    require('plugins.nvim-navic'),
    require('plugins.telescope'),
    require('plugins.nvim-autopairs'),
    require('plugins.which-key'),
    require('plugins.vim-surround'),
    require('plugins.comment'),
    require('plugins.emmet'),

    -- Completion
    require('plugins.luasnip'),
    require('plugins.nvim-cmp'),

    -- LSP Configuration
    require('plugins.lsp'),
    require('plugins.null-ls'),

    -- Diagnostics
    require('plugins.trouble'),

    -- Text Objects
    require('plugins.treesitter-textobjects'),

    -- Views/Tabs
    require('plugins.bufferline'),
})
