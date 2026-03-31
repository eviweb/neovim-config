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

