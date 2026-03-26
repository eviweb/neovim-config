-- lua/config/treesitter.lua

local treesitter = require('nvim-treesitter.configs')

treesitter.setup({
    ensure_installed = {
        'bash',
        'css',
        'html',
        'javascript',
        'json',
        'lua',
        'markdown',
        'markdown_inline',
        'query',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
    },
    sync_installed = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'php' },
    },
    indent = {
        enable = false,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
        },
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ['<leader>a'] = '@parameter.outer',
            },
            swap_previous = {
                ['<leader>A'] = '@parameter.inner',
            },
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                [']m'] = '@function.outer',
                [']]'] = '@class.outer',
            },
            goto_next_end = {
                [']M'] = '@function.outer',
                [']['] = '@class.outer',
            },
            goto_previous_start = {
                ['[m'] = '@function.outer',
                ['[['] = '@class.outer',
            },
            goto_previous_end = {
                ['[M'] = '@function.outer',
                ['[]'] = '@class.outer',
            },
        },
        lsp_interop = {
            enable = true,
            border = 'none',
            peek_definition_code = {
                ['<leader>df'] = '@function.outer',
                ['<leader>dF'] = '@class.outer',
            },
        },
    },
})

-- enables folds (zc and zo) on functions and classes but not by default
vim.cmd([[
    set nofoldenable
    set foldmethod=expr
    set foldexpr=nvim_treesitter#foldexpr()
]])
