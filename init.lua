-- init.lua

-- Stop early, with a clear message, on a Neovim that is too old.
local minimum_version = require('minimum_version')
if not minimum_version.satisfied() then
    vim.notify(minimum_version.message(), vim.log.levels.ERROR)
    return
end

-- Configuration options
require('options')

-- Keymaps
require('keymaps')

-- Commands
require('commands')

-- Plugins
require('plugins')

-- Bootstrap
require('bootstrap')

