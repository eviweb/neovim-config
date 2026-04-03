-- lua/config/neotest.lua

local neotest = require('neotest')

neotest.setup({
    adapters = {
        require('neotest-bash'),
    },
})

local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<Leader>Tr', function() neotest.run.run() end,
    vim.tbl_extend('force', opts, { desc = 'Run nearest test' }))

vim.keymap.set('n', '<Leader>Tf', function() neotest.run.run(vim.fn.expand('%')) end,
    vim.tbl_extend('force', opts, { desc = 'Run test file' }))

vim.keymap.set('n', '<Leader>Ts', function() neotest.summary.toggle() end,
    vim.tbl_extend('force', opts, { desc = 'Toggle test summary' }))

vim.keymap.set('n', '<Leader>To', function() neotest.output_panel.toggle() end,
    vim.tbl_extend('force', opts, { desc = 'Toggle output panel' }))
