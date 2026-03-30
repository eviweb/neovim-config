-- lua/plugins/emmet.lua

return {
    'mattn/emmet-vim',
    ft = { 'html', 'css', 'javascriptreact', 'typescriptreact' },
    dependencies = { 'mattn/webapi-vim' },
}
