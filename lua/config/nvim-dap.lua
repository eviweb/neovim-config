-- lua/config/nvim-dap.lua

local dap     = require('dap')
local dapui   = require('dapui')

-- ---------------------------------------------------------------------------
-- nvim-dap-ui
-- ---------------------------------------------------------------------------

dapui.setup()

-- Auto-open/close UI when a debug session starts or ends.
dap.listeners.after.event_initialized['dapui_config']  = function() dapui.open() end
dap.listeners.before.event_terminated['dapui_config']  = function() dapui.close() end
dap.listeners.before.event_exited['dapui_config']      = function() dapui.close() end

-- ---------------------------------------------------------------------------
-- Virtual text (variable values inline)
-- ---------------------------------------------------------------------------

require('nvim-dap-virtual-text').setup()

-- ---------------------------------------------------------------------------
-- Lua adapter (one-small-step-for-vimkind — no external executable needed)
-- ---------------------------------------------------------------------------

dap.adapters.nlua = function(callback, config)
    callback({ type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 })
end

dap.configurations.lua = {
    {
        type    = 'nlua',
        request = 'attach',
        name    = 'Attach to running Neovim instance',
    },
}

-- ---------------------------------------------------------------------------
-- Profile-driven adapters and configurations
-- ---------------------------------------------------------------------------

require('profiles').setup_dap(dap)

-- ---------------------------------------------------------------------------
-- Keymaps
-- ---------------------------------------------------------------------------

local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<Leader>Db', dap.toggle_breakpoint,
    vim.tbl_extend('force', opts, { desc = 'Toggle breakpoint' }))

vim.keymap.set('n', '<Leader>DB', function()
    dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, vim.tbl_extend('force', opts, { desc = 'Conditional breakpoint' }))

vim.keymap.set('n', '<Leader>Dc', dap.continue,
    vim.tbl_extend('force', opts, { desc = 'Continue / start' }))

vim.keymap.set('n', '<Leader>Di', dap.step_into,
    vim.tbl_extend('force', opts, { desc = 'Step into' }))

vim.keymap.set('n', '<Leader>Do', dap.step_over,
    vim.tbl_extend('force', opts, { desc = 'Step over' }))

vim.keymap.set('n', '<Leader>DO', dap.step_out,
    vim.tbl_extend('force', opts, { desc = 'Step out' }))

vim.keymap.set('n', '<Leader>Dr', dap.repl.open,
    vim.tbl_extend('force', opts, { desc = 'Open REPL' }))

vim.keymap.set('n', '<Leader>Dl', dap.run_last,
    vim.tbl_extend('force', opts, { desc = 'Run last' }))

vim.keymap.set('n', '<Leader>Du', dapui.toggle,
    vim.tbl_extend('force', opts, { desc = 'Toggle DAP UI' }))

vim.keymap.set('n', '<Leader>Dt', dap.terminate,
    vim.tbl_extend('force', opts, { desc = 'Terminate session' }))
