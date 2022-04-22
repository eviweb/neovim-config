-- lua/options.lua

--[[
    Aspect
--]]
-- Global
vim.opt.background = 'dark' -- defines the editor color set
vim.opt.encoding = 'utf-8' -- sets default encoding
vim.opt.signcolumn = 'yes' -- always shows the sing column
vim.opt.termguicolors = true -- enables 24-bit RGB color (required for some themes)
vim.opt.title = true -- shows the file title
vim.opt.wildmenu = true -- shows a more advanced menu for auto-completion

-- Lines
vim.opt.cursorline = true -- highlights the current line
vim.opt.number = true -- shows line numbers
vim.opt.relativenumber = true -- shows line numbers starting from the current line

-- Search
vim.opt.hlsearch = true -- highlights search results
vim.opt.ignorecase = true -- ignores case while searching
vim.opt.smartcase = true -- does not ignore case if the search pattern has uppercase

-- Tabs
vim.opt.expandtab = true -- transforms tabs into spaces
vim.opt.shiftwidth = 0 -- sets the number of indentation spaces
vim.opt.softtabstop = 4 -- inserts this number of spaces for a tab
vim.opt.tabstop = 4 -- sets the numbers of spaces for tabs

--[[
    Behaviour
--]]
-- Global
vim.opt.clipboard = 'unnamedplus' -- enables the clipboard between neovim and others
vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'noinsert' } -- customizes the auto-completion
vim.opt.hidden = true -- allows multiple buffers
vim.opt.mouse = 'a' -- allows the use of the mouse in all modes
vim.opt.shortmess:append("c") -- prevents messages to be passed to |ins-completion-menu|
vim.opt.showmatch = true -- highlights matching brackets
vim.opt.swapfile = false -- prevents the use of swap files for buffers
vim.opt.wrap = false -- disables wrapping

-- Timers
vim.opt.updatetime = 750 -- sets the time of the update trigger in milliseconds
vim.opt.ttimeoutlen = 0 -- sets the time in milliseconds to run commands

-- Views
vim.opt.inccommand = 'split' -- shows replacements in a split screen before applying
vim.opt.splitbelow = true -- new horizontal splits are made below the current view
vim.opt.splitright = true -- new vertical splits are made on the right of the current view

--[[
    File Browser
--]]
vim.g.netrw_altv = 1 -- switches the NetRW view to the left
vim.g.netrw_banner = 1 -- shows NetRW top information
vim.g.netrw_browse_split = 4 -- opens files in a previous window
vim.g.netrw_keepdir = 0 -- keeps the directory you accessed previously
vim.g.netrw_liststyle = 0 -- shows directory tree
vim.g.netrw_localcopydircmd = 'cp -r' -- recursively copies directories
vim.g.netrw_winsize = 25 -- limits the view size to 25% of the available screen space
