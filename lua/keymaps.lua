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

-- moves line up and down with J/K
map('n', 'J', ':m+<CR>', opts)
map('n', 'K', ':m-2<CR>', opts)

-- modifies j and k when a line is wrapped. Jump to next VISUAL line
map('n', 'k', 'v:count == 0 ? "gk" : "k"', expr)
map('n', 'j', 'v:count == 0 ? "gj" : "j"', expr)

-- resizes windows with Ctrl+<arrow>
map("n", "<C-Up>", ":resize +2<CR>", opts)
map("n", "<C-Down>", ":resize -2<CR>", opts)
map("n", "<C-Left>", ":vertical resize -2<CR>", opts)
map("n", "<C-Right>", ":vertical resize +2<CR>", opts)

--[[
    Insert mode
--]]
-- saves the current file
map('i', '<C-s>', '<Esc>:w<CR>A', opts)

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
