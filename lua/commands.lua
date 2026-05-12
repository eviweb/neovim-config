-- lua/commands.lua

-- prevents new line to also start with a comment
vim.api.nvim_create_autocmd('FileType', {
    group   = vim.api.nvim_create_augroup('disable-comments-on-new-lines', { clear = true }),
    pattern = '*',
    callback = function()
        vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' })
    end,
})

-- places the cursor at the last position on file re-opening
vim.api.nvim_create_autocmd('BufReadPost', {
    group   = vim.api.nvim_create_augroup('vimrc-remember-cursor-position', { clear = true }),
    pattern = '*',
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        if mark[1] > 1 and mark[1] <= vim.api.nvim_buf_line_count(0) then
            vim.cmd('normal! g`"')
        end
    end,
})

-- tracks the last accessed tab so <Leader>tl can jump back to it
vim.g.last_tab = 1
vim.api.nvim_create_autocmd('TabLeave', {
    group    = vim.api.nvim_create_augroup('track-last-tab', { clear = true }),
    callback = function() vim.g.last_tab = vim.fn.tabpagenr() end,
})

-- highlights any yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
    group    = vim.api.nvim_create_augroup('highlight-text-on-yank', { clear = true }),
    pattern  = '*',
    callback = function() vim.highlight.on_yank() end,
})

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
local function get_cheat_topics()
    local dir = vim.fn.stdpath('config') .. '/docs/cheatsheets'
    local topics = {}
    local handle = vim.loop.fs_scandir(dir)
    if handle then
        while true do
            local fname, ftype = vim.loop.fs_scandir_next(handle)
            if not fname then break end
            if ftype == 'file' and fname:match('%.md$') then
                table.insert(topics, fname:sub(1, -4))
            end
        end
    end
    table.sort(topics)
    return topics
end

local function open_cheatsheet(topic)
    if topic == '' or topic == nil then
        vim.notify(
            'Usage: :Cheat <topic>  —  topics: ' .. table.concat(get_cheat_topics(), ', '),
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
    local topic = vim.trim(opts.args)
    if topic ~= '' then
        open_cheatsheet(topic)
        return
    end

    local ok_pickers, pickers      = pcall(require, 'telescope.pickers')
    local ok_finders, finders      = pcall(require, 'telescope.finders')
    local ok_conf,    tconf        = pcall(require, 'telescope.config')
    local ok_actions, actions      = pcall(require, 'telescope.actions')
    local ok_state,   action_state = pcall(require, 'telescope.actions.state')

    local topics = get_cheat_topics()
    if ok_pickers and ok_finders and ok_conf and ok_actions and ok_state then
        pickers.new({}, {
            prompt_title = 'Cheatsheet',
            finder  = finders.new_table({ results = topics }),
            sorter  = tconf.values.generic_sorter({}),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local sel = action_state.get_selected_entry()
                    if sel then open_cheatsheet(sel[1]) end
                end)
                return true
            end,
        }):find()
    else
        -- Fallback when Telescope is not available (e.g. modern UI variant)
        vim.ui.select(topics, { prompt = 'Cheatsheet:' }, function(choice)
            if choice then open_cheatsheet(choice) end
        end)
    end
end, {
    nargs    = '?',
    complete = function(arglead)
        return vim.tbl_filter(function(t)
            return t:find(arglead, 1, true) == 1
        end, get_cheat_topics())
    end,
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

-- :w!! — write the current file with sudo (for system files opened without root)
vim.cmd('cabbrev w!! w !sudo tee % > /dev/null')

-- auto-saves all modified regular buffers when Neovim loses focus or a buffer is left.
-- Guard on buftype to avoid interfering with scratch/prompt/input floats (e.g. dressing).
vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave' }, {
    pattern  = '*',
    callback = function()
        local bt = vim.bo.buftype
        if bt == '' or bt == 'acwrite' then
            vim.cmd('silent! wa')
        end
    end,
    desc = 'Auto-save regular buffers on focus loss or buffer leave',
})

-- removes all trailing whitespace on save
vim.api.nvim_create_autocmd('BufWritePre', {
    group    = vim.api.nvim_create_augroup('trim-white-space-on-save', { clear = true }),
    pattern  = '*',
    callback = function()
        if not vim.bo.modifiable or vim.bo.readonly then return end
        local view = vim.fn.winsaveview()
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.winrestview(view)
    end,
})

