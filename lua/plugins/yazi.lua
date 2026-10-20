-- lua/plugins/yazi.lua
--
-- yazi (https://yazi-rs.github.io) in a floating window, with image / video /
-- PDF previews that neo-tree and oil do not have. It complements them rather
-- than replacing either: neo-tree stays the sidebar (<Leader>n) and oil the
-- directory-as-a-buffer editor ('-').
--
-- Loaded only when the `yazi` binary is on PATH. The test runs once, at startup:
-- install yazi and restart Neovim to enable it. Nothing here installs yazi.
-- `:checkhealth yazi` reports a version that is too old.

return {
    'mikavilpas/yazi.nvim',
    version = '*',
    cond = function()
        return vim.fn.executable('yazi') == 1
    end,
    event = 'VeryLazy',
    dependencies = { { 'nvim-lua/plenary.nvim', lazy = true } },
    -- Not the plugin's suggested <Leader>cw (<Leader>c is the CodeCompanion
    -- group here) nor <C-Up> (resizes windows). `:Yazi cwd` opens it in the
    -- working directory.
    keys = {
        { '<Leader>-', '<cmd>Yazi<cr>', mode = { 'n', 'v' }, desc = 'Open yazi at the current file' },
    },
    opts = {
        -- Keep oil.nvim / neo-tree as the handlers for directories.
        open_for_directories = false,
    },
}
