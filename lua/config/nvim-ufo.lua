-- lua/config/nvim-ufo.lua
-- LSP/treesitter-aware folding with fold preview.
-- K peeks the fold under the cursor first; falls back to LSP hover if not foldable.

require('ufo').setup({
    provider_selector = function()
        return { 'lsp', 'treesitter', 'indent' }
    end,
})

local ufo = require('ufo')

vim.keymap.set('n', 'zR', ufo.openAllFolds,  { desc = 'Open all folds' })
vim.keymap.set('n', 'zM', ufo.closeAllFolds, { desc = 'Close all folds' })

-- K: peek fold if foldable, otherwise fall back to LSP hover
vim.keymap.set('n', 'K', function()
    local winid = ufo.peekFoldedLinesUnderCursor()
    if not winid then
        vim.lsp.buf.hover()
    end
end, { desc = 'Peek fold / LSP hover' })
