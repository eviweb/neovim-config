-- lua/plugins/vim-surround.lua

return {
    'tpope/vim-surround',
    event = 'BufReadPost',
    dependencies = { 'tpope/vim-repeat' },
}
