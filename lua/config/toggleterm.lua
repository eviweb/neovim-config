-- lua/config/toggleterm.lua

local toggleterm = require('toggleterm')

toggleterm.setup({
    size      = 20,
    open_mapping = [[<C-\>]],
    direction = 'float',
    float_opts = {
        border = 'rounded',
    },
    shade_terminals = true,
})

local Terminal = require('toggleterm.terminal').Terminal

-- dedicated Claude Code terminal
local claude = Terminal:new({
    cmd       = 'claude',
    direction = 'float',
    hidden    = true,
    float_opts = { border = 'rounded' },
})

-- dedicated Codex terminal
local codex = Terminal:new({
    cmd       = 'codex',
    direction = 'float',
    hidden    = true,
    float_opts = { border = 'rounded' },
})

-- dedicated Gemini CLI terminal
local gemini = Terminal:new({
    cmd       = 'gemini',
    direction = 'float',
    hidden    = true,
    float_opts = { border = 'rounded' },
})

-- dedicated lazygit terminal
local lazygit = Terminal:new({
    cmd       = 'lazygit',
    direction = 'float',
    hidden    = true,
    float_opts = { border = 'rounded' },
})

local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<Leader>tt', '<Cmd>ToggleTerm<CR>',
    vim.tbl_extend('force', opts, { desc = 'Toggle terminal' }))

vim.keymap.set('n', '<Leader>tC', function() claude:toggle() end,
    vim.tbl_extend('force', opts, { desc = 'Toggle Claude Code' }))

vim.keymap.set('n', '<Leader>tX', function() codex:toggle() end,
    vim.tbl_extend('force', opts, { desc = 'Toggle Codex CLI' }))

vim.keymap.set('n', '<Leader>tG', function() gemini:toggle() end,
    vim.tbl_extend('force', opts, { desc = 'Toggle Gemini CLI' }))

vim.keymap.set('n', '<Leader>gg', function() lazygit:toggle() end,
    vim.tbl_extend('force', opts, { desc = 'Open lazygit' }))
