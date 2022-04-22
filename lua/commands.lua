-- lua/commands.lua

-- starts NetRw on current dir if NeoVim is opened without parameters
vim.cmd([[
augroup netrw-auto-open-if-no-params
  autocmd!
  autocmd VimEnter * if argc() == 0 | :Lexplore | endif
augroup END
]])

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

