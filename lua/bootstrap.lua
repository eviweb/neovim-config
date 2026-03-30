-- lua/bootstrap.lua

-- enables nightfox theme
vim.cmd([[silent! colorscheme nightfox]])

-- securely enables lualine statusbar
local status_ok, lualine = pcall(require, 'lualine')
if not status_ok then
    return
else
    require('config.lualine')
end

-- setups neo-tree
require('config.neo-tree')
