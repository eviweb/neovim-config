-- lua/config/null-ls.lua

local null_ls = require('null-ls')
local utils = require('null-ls.utils')
local profiles = require('profiles')

local base_sources = {
    null_ls.builtins.completion.spell,
    null_ls.builtins.completion.tags,
    null_ls.builtins.hover.dictionary,
}

null_ls.setup({
    debug = true,
    root_dir = utils.root_pattern('.git', 'README.md', 'CHANGELOG.md', 'composer.json', 'package.json', 'init.lua'),
    diagnostics_format = '#{m} (#{c}) [#{s}]',
    sources = vim.list_extend(base_sources, profiles.get_null_ls_sources()),
})
