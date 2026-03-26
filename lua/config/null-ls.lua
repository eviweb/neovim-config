-- lua/config/null-ls.lua

local null_ls = require('null-ls')
local utils = require('null-ls.utils')

null_ls.setup({
    debug = true,
    root_dir = utils.root_pattern('.git', 'README.md', 'CHANGELOG.md', 'composer.json', 'package.json', 'init.lua'),
    diagnostics_format = '#{m} (#{c}) [#{s}]',
    sources = {
        null_ls.builtins.completion.spell,
        null_ls.builtins.completion.tags,
        null_ls.builtins.hover.dictionary,
    },
 })
