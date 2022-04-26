-- lua/keymaps.lua

--[[
    Modes

normal_mode:        'n'
insert_mode: 		'i'
visual_mode:		'v'
visual_block_mode:  'x'
term_mode:		    't'
command_mode:	    'c'

--]]

--[[
    Shortcuts
--]]
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local expr = { noremap = true, silent = true, expr = true }

--[[
    All modes
--]]
-- copies/cuts/pastes through the system clipboard with respectively YY, XX and PP
vim.cmd([[
noremap YY "+y<CR>
noremap XX "+x<CR>
noremap PP "+p<CR>
]])

--[[
    Normal mode
--]]
-- maps leader key to space
map('n', '<Space>', '<Nop>', opts)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- toggles NvimTree (NvimTreeToggle)
map('n', '<Leader>n', ':NvimTreeToggle<CR>', opts)

-- keeps search matches in the middle of the window
map('n', 'n', 'nzzzv', opts)
map('n', 'N', 'Nzzzv', opts)

-- modifies j and k when a line is wrapped. Jump to next VISUAL line
map('n', 'k', 'v:count == 0 ? "gk" : "k"', expr)
map('n', 'j', 'v:count == 0 ? "gj" : "j"', expr)

-- resizes windows with Ctrl+<arrow>
map('n', '<C-Up>', ':resize -2<CR>', opts)
map('n', '<C-Down>', ':resize +2<CR>', opts)
map('n', '<C-Left>', ':vertical resize +2<CR>', opts)
map('n', '<C-Right>', ':vertical resize -2<CR>', opts)

-- navigates between windows
map('n', '<C-h>', '<C-w>h', opts)
map('n', '<C-j>', '<C-w>j', opts)
map('n', '<C-k>', '<C-w>k', opts)
map('n', '<C-l>', '<C-w>l', opts)

-- moves current line/block up and down with Alt-j/k a la vscode
map('n', '<A-j>', ':m .+1<CR>==', opts)
map('n', '<A-k>', ':m .-2<CR>==', opts)

-- maps undo to Ctrl-z
map('n', '<C-z>', 'u', opts)

--[[
    Insert mode
--]]
-- remaps the <Esc> key to jj
map('i', 'jj', '<Esc>', opts)

-- moves current line/block up and down with Alt-j/k a la vscode
map('i', '<A-j>', '<Esc>:m .+1<CR>==gi', opts)
map('i', '<A-k>', '<Esc>:m .-2<CR>==gi', opts)

-- saves the current file
map('i', '<C-s>', '<Esc>:w<CR>A', opts)

-- maps undo/redo to Ctrl-z/Ctrl-r
map('i', '<C-z>', '<Esc>ui', opts)
map('i', '<C-r>', '<Esc><C-r>i', opts)

--[[
    Terminal mode
--]]
-- double ESC or <C-s> to go to normal mode in terminal
map('t', '<C-s>', '<C-\\><C-n>', opts)
map('t', '<Esc><Esc>', '<C-\\><C-n>', opts)

--[[
    Plugin Mappings
--]]
-- Telescope
map('n', '<Leader>ff', ':lua require("telescope.builtin").find_files()<CR>', opts)
map('n', '<Leader>fg', ':lua require("telescope.builtin").live_grep()<CR>', opts)
map('n', '<Leader>fb', ':lua require("telescope.builtin").buffers()<CR>', opts)
map('n', '<Leader>fh', ':lua require("telescope.builtin").help_tags()<CR>', opts)

-- Trouble
map('n', '<Leader>dx', ':Trouble<CR>', opts)
map('n', '<Leader>dw', ':Trouble workspace_diagnostics<CR>', opts)
map('n', '<Leader>dd', ':Trouble document_diagnostics<CR>', opts)
map('n', '<Leader>dl', ':Trouble loclist<CR>', opts)
map('n', '<Leader>dq', ':Trouble quickfix<CR>', opts)
map('n', 'gR', ':Trouble lsp_references<CR>', opts)

-- Diaglist
map('n', '<Leader>lda', ':lua require("diaglist").open_all_diagnostics()<CR>', opts)
map('n', '<Leader>ldb', ':lua require("diaglist").open_buffer_diagnostics()<CR>', opts)
