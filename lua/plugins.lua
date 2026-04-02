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

local profiles = require('profiles')
local ui_variant = require('ui.variant').get()
local ui_plugins = vim.list_extend(
    require('ui.shared').get_plugins(),
    require('ui.' .. ui_variant).get_plugins()
)

local base_plugins = {
    -- File browser
    require('plugins.neo-tree'),

    -- Parsers
    require('plugins.treesitter'),

    -- Utils
    require('plugins.nvim-autopairs'),
    require('plugins.vim-surround'),
    require('plugins.comment'),

    -- Completion
    require('plugins.luasnip'),
    require('plugins.nvim-cmp'),

    -- LSP Configuration
    require('plugins.lsp'),
    require('plugins.null-ls'),

    -- Text Objects
    require('plugins.treesitter-textobjects'),

    -- Git
    require('plugins.gitsigns'),
}

vim.list_extend(base_plugins, ui_plugins)
require('lazy').setup(vim.list_extend(base_plugins, profiles.get_plugins()))
