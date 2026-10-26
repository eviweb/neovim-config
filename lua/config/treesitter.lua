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
    'markdown', 'markdown_inline', 'query', 'regex', 'ssh_config',
    'typescript', 'vim', 'vimdoc', 'yaml',
}

-- The parsers installed at startup: the global list and the ones declared by
-- active profiles (e.g. php).
local function startup_parsers()
    return vim.list_extend(vim.deepcopy(parsers), require('profiles').get_treesitter_parsers())
end

-- Install missing parsers once on startup (async, non-blocking). What it
-- installs is usable in this session: see lua/treesitter_install.lua.
vim.api.nvim_create_autocmd('VimEnter', {
    once     = true,
    callback = function()
        require('treesitter_install').install(startup_parsers())
    end,
    desc = 'Install missing treesitter parsers',
})

-- For any other language, ask before installing: see lua/treesitter_prompt.lua.
-- The ones installed above are managed here and are not offered.
local treesitter_prompt = require('treesitter_prompt')
treesitter_prompt.managed = startup_parsers
vim.api.nvim_create_autocmd('FileType', {
    callback = function(ev)
        treesitter_prompt.maybe_offer(ev.buf)
    end,
    desc = 'Offer to install a missing treesitter parser',
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

-- Swap: ]a (next parameter), [a (previous parameter).
-- Was <Leader>a / <Leader>A (nvim-treesitter-textobjects' own README example)
-- until it collided with <Leader>a as the AI which-key group prefix: with a
-- real keymap on the exact prefix key, pressing <Leader>a either fired the
-- swap immediately or raced the AI submenu against Vim's timeoutlen,
-- depending on typing speed. Bracket motions match the convention already
-- used above for other treesitter textobject moves ([m/]m, [[/]], [h/]h).
vim.keymap.set('n', ']a', function()
    require('nvim-treesitter-textobjects.swap').swap_next('@parameter.outer', 'textobjects')
end, { desc = 'Swap with next parameter' })
vim.keymap.set('n', '[a', function()
    require('nvim-treesitter-textobjects.swap').swap_previous('@parameter.inner', 'textobjects')
end, { desc = 'Swap with previous parameter' })
