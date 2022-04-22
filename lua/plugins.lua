-- lua/plugins.lua

--[[
    Paths
--]]
package.path = package.path .. ';../?.lua'
local install_path = vim.fn.resolve(vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim')
local compile_path = vim.fn.resolve(vim.fn.stdpath('config') .. '/.packer/packer_compiled.lua')

--[[
    Packer install
--]]
-- installs from Github if needed
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = vim.fn.system({
        'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path
    })
end

-- automatically runs :PackerCompile whenever this file is updated
vim.cmd([[
    augroup packer_user_config
        autocmd!
        autocmd BufWritePost plugins.lua source <afile> | :PackerSync
    augroup end
]])

-- securely requires packer
local status_ok, packer = pcall(require, 'packer')
if not status_ok then
    return
end

-- diplays packer messages in a popup
packer.init({
    compile_path = compile_path,
    display = {
        open_fn = function()
            return require('packer.util').float({ border = 'rounded' })
        end,
    },
})

--
packer.reset()

--[[
    Plugins install
--]]
require('plugins.packer')

--[[
    Configuration setup
--]]
if PACKER_BOOTSTRAP then
    require('packer').sync()
end
