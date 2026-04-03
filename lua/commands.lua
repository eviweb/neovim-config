-- lua/commands.lua

-- prevents new line to also start with a comment
vim.api.nvim_exec(
    [[
  augroup disable-comments-on-new-lines
    au!
    au FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
  augroup END
]],
    false
)

-- places the cursor at the last position on file re-opening
vim.cmd([[
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END
]])

-- hightlights any yanked line
vim.cmd([[
  augroup highlight-text-on-yank
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]])

-- :NvimProfile [name] — activate a profile or open the profile picker
vim.api.nvim_create_user_command('NvimProfile', function(opts)
    local name = vim.trim(opts.args)
    if name == '' then
        require('profiles.picker').pick()
    else
        require('profiles').activate(name)
    end
end, {
    nargs = '?',
    complete = function()
        local names = {}
        local profiles_dir = vim.fn.stdpath('config') .. '/lua/profiles'
        local handle = vim.loop.fs_scandir(profiles_dir)
        if handle then
            while true do
                local fname, ftype = vim.loop.fs_scandir_next(handle)
                if not fname then break end
                if ftype == 'file' and fname:match('%.lua$') then
                    local stem = fname:sub(1, -5)
                    if stem ~= 'init' and stem ~= 'picker' then
                        table.insert(names, stem)
                    end
                end
            end
        end
        return names
    end,
    desc = 'Activate a project profile or open the profile picker',
})

-- :Cheat [topic] — open a cheatsheet in a centered floating window
local cheat_topics = { 'editing', 'git', 'lsp', 'plugins', 'profiles' }

local function open_cheatsheet(topic)
    if topic == '' or topic == nil then
        vim.notify(
            'Usage: :Cheat <topic>  —  topics: ' .. table.concat(cheat_topics, ', '),
            vim.log.levels.INFO
        )
        return
    end

    local path = vim.fn.stdpath('config') .. '/docs/cheatsheets/' .. topic .. '.md'
    if vim.fn.filereadable(path) == 0 then
        vim.notify('Cheatsheet not found: ' .. topic, vim.log.levels.ERROR)
        return
    end

    local lines = vim.fn.readfile(path)
    local width  = math.min(80, vim.o.columns - 4)
    local height = math.min(#lines, vim.o.lines - 6)
    local row    = math.floor((vim.o.lines - height) / 2)
    local col    = math.floor((vim.o.columns - width) / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype   = 'markdown'

    local win = vim.api.nvim_open_win(buf, true, {
        relative  = 'editor',
        width     = width,
        height    = height,
        row       = row,
        col       = col,
        style     = 'minimal',
        border    = 'rounded',
        title     = ' ' .. topic .. ' ',
        title_pos = 'center',
    })

    local close = function() vim.api.nvim_win_close(win, true) end
    vim.keymap.set('n', 'q',     close, { buffer = buf, silent = true })
    vim.keymap.set('n', '<Esc>', close, { buffer = buf, silent = true })
end

vim.api.nvim_create_user_command('Cheat', function(opts)
    open_cheatsheet(vim.trim(opts.args))
end, {
    nargs    = '?',
    complete = function() return cheat_topics end,
    desc     = 'Open a cheatsheet in a floating window',
})

-- :Theme [name] — apply and persist a colorscheme
vim.api.nvim_create_user_command('Theme', function(opts)
    local theme = require('ui.theme')
    local name  = vim.trim(opts.args)
    if name == '' then
        vim.notify('Current theme: ' .. theme.get(), vim.log.levels.INFO)
        return
    end
    if not theme.VALID[name] then
        vim.notify('Unknown theme: ' .. name .. '\nAvailable: ' .. table.concat(theme.NAMES, ', '), vim.log.levels.ERROR)
        return
    end
    local f = io.open(vim.fn.stdpath('config') .. '/.nvim-theme', 'w')
    if f then f:write(name .. '\n'); f:close() end
    vim.cmd('colorscheme ' .. name)
    vim.notify('Theme → ' .. name, vim.log.levels.INFO)
end, {
    nargs    = '?',
    complete = function() return require('ui.theme').NAMES end,
    desc     = 'Apply and persist a colorscheme',
})

-- auto-saves all modified buffers when Neovim loses focus or a buffer is left
vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave' }, {
    pattern  = '*',
    callback = function() vim.cmd('silent! wa') end,
    desc     = 'Auto-save all buffers on focus loss or buffer leave',
})

-- removes all trailing whitespace on save
vim.api.nvim_exec(
    [[
  augroup trim-white-space-on-save
    au!
    autocmd BufWritePre * :%s/\s\+$//e
  augroup END
  ]],
    false
)

