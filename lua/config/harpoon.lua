-- lua/config/harpoon.lua

local harpoon = require('harpoon')
harpoon:setup()

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- add current file to the harpoon list
map('n', '<Leader>ha', function() harpoon:list():add() end,
    vim.tbl_extend('force', opts, { desc = 'Harpoon: add file' }))

-- open the harpoon list (editable)
map('n', '<Leader>hh', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
    vim.tbl_extend('force', opts, { desc = 'Harpoon: toggle menu' }))

-- jump to file 1-4
map('n', '<C-1>', function() harpoon:list():select(1) end, opts)
map('n', '<C-2>', function() harpoon:list():select(2) end, opts)
map('n', '<C-3>', function() harpoon:list():select(3) end, opts)
map('n', '<C-4>', function() harpoon:list():select(4) end, opts)
