-- lua/config/persistence.lua

require('persistence').setup()

-- restore the session for the current directory automatically on startup
-- only when Neovim is opened without file arguments
vim.api.nvim_create_autocmd('VimEnter', {
    nested  = true,
    once    = true,
    callback = function()
        if vim.fn.argc() == 0 then
            require('persistence').load()
        end
    end,
    desc = 'Auto-restore session when Neovim is opened with no arguments',
})
