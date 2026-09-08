-- lua/config/treesitter.lua
-- Migrated to nvim-treesitter v1.0+ (main branch).
-- nvim-treesitter.configs has been removed; each concern is now independent.

-- ---------------------------------------------------------------------------
-- tree-sitter CLI
-- nvim-treesitter shells out to a bare `tree-sitter build` command with no
-- option to configure its path — it relies entirely on PATH. `nvim-config
-- update tree-sitter` downloads the CLI into vendor/tree-sitter/; prepend it
-- to PATH here so that download is actually used instead of silently doing
-- nothing (previously: ENOENT, "Error during tree-sitter build").
-- ---------------------------------------------------------------------------
local vendor_tree_sitter = vim.fn.stdpath('config') .. '/vendor/tree-sitter'
if vim.fn.executable(vendor_tree_sitter .. '/tree-sitter') == 1 then
    vim.env.PATH = vendor_tree_sitter .. ':' .. vim.env.PATH
end

-- ---------------------------------------------------------------------------
-- Parser installation
-- ---------------------------------------------------------------------------
local parsers = {
    'bash', 'css', 'html', 'javascript', 'json', 'lua',
    'markdown', 'markdown_inline', 'query', 'regex', 'typescript',
    'vim', 'vimdoc', 'yaml',
}

-- Install missing parsers once on startup (async, non-blocking).
vim.api.nvim_create_autocmd('VimEnter', {
    once     = true,
    callback = function()
        require('nvim-treesitter').install(parsers)
    end,
    desc = 'Install missing treesitter parsers',
})

-- ---------------------------------------------------------------------------
-- Highlight
-- ---------------------------------------------------------------------------
-- Enable treesitter-based highlighting per buffer; falls back silently when
-- no parser is available for the current filetype.
vim.api.nvim_create_autocmd('FileType', {
    callback = function(ev)
        pcall(vim.treesitter.start, ev.buf)
    end,
    desc = 'Enable treesitter highlight when a parser is available',
})

-- ---------------------------------------------------------------------------
-- Folds (disabled by default — use zc / zo to fold manually)
-- ---------------------------------------------------------------------------
vim.opt.foldenable = false
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr   = 'v:lua.vim.treesitter.foldexpr()'

-- ---------------------------------------------------------------------------
-- Textobjects (nvim-treesitter-textobjects v2)
-- Lazy requires inside each callback to avoid load-order issues.
-- ---------------------------------------------------------------------------

-- Select: af/if (function), ac/ic (class)
vim.keymap.set({ 'x', 'o' }, 'af', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
end, { desc = 'outer function' })
vim.keymap.set({ 'x', 'o' }, 'if', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
end, { desc = 'inner function' })
vim.keymap.set({ 'x', 'o' }, 'ac', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects')
end, { desc = 'outer class' })
vim.keymap.set({ 'x', 'o' }, 'ic', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects')
end, { desc = 'inner class' })

-- Move: ]m/[m (function start), ]M/[M (function end), ]]/[[ (class start), ][/[] (class end)
vim.keymap.set('n', ']m', function()
    require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
end, { desc = 'Next function start' })
vim.keymap.set('n', ']]', function()
    require('nvim-treesitter-textobjects.move').goto_next_start('@class.outer', 'textobjects')
end, { desc = 'Next class start' })
vim.keymap.set('n', ']M', function()
    require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects')
end, { desc = 'Next function end' })
vim.keymap.set('n', '][', function()
    require('nvim-treesitter-textobjects.move').goto_next_end('@class.outer', 'textobjects')
end, { desc = 'Next class end' })
vim.keymap.set('n', '[m', function()
    require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
end, { desc = 'Previous function start' })
vim.keymap.set('n', '[[', function()
    require('nvim-treesitter-textobjects.move').goto_previous_start('@class.outer', 'textobjects')
end, { desc = 'Previous class start' })
vim.keymap.set('n', '[M', function()
    require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects')
end, { desc = 'Previous function end' })
vim.keymap.set('n', '[]', function()
    require('nvim-treesitter-textobjects.move').goto_previous_end('@class.outer', 'textobjects')
end, { desc = 'Previous class end' })

-- Swap: <Leader>a (next parameter), <Leader>A (previous parameter)
vim.keymap.set('n', '<Leader>a', function()
    require('nvim-treesitter-textobjects.swap').swap_next('@parameter.outer', 'textobjects')
end, { desc = 'Swap with next parameter' })
vim.keymap.set('n', '<Leader>A', function()
    require('nvim-treesitter-textobjects.swap').swap_previous('@parameter.inner', 'textobjects')
end, { desc = 'Swap with previous parameter' })
