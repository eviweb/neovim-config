-- lua/config/nvim-lint.lua

local lint = require('lint')

-- Resolve a binary from node_modules/.bin first, then fall back to global.
local function node_bin(name)
    local bin = vim.fn.getcwd() .. '/node_modules/.bin/' .. name
    return vim.fn.executable(bin) == 1 and bin or name
end

-- Resolve a binary from vendor/bin first, then fall back to global.
local function vendor_bin(name)
    local bin = vim.fn.getcwd() .. '/vendor/bin/' .. name
    return vim.fn.executable(bin) == 1 and bin or name
end

lint.linters_by_ft = require('profiles').get_lint_linters()

-- Override commands with local-binary resolution (evaluated at lint time).
local overrides = {
    eslint  = function() return node_bin('eslint') end,
    phpstan = function() return vendor_bin('phpstan') end,
    phpcs   = function() return vendor_bin('phpcs') end,
    phpmd   = function() return vendor_bin('phpmd') end,
}
for name, cmd_fn in pairs(overrides) do
    if lint.linters[name] then
        lint.linters[name] = vim.tbl_extend('force', lint.linters[name], { cmd = cmd_fn })
    end
end

-- phpmd: explicit ruleset args matching the none-ls configuration.
if lint.linters.phpmd then
    lint.linters.phpmd = vim.tbl_extend('force', lint.linters.phpmd, {
        args = { '$FILENAME', 'text', 'cleancode,codesize,controversial,design,naming,unusedcode' },
    })
end

vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
    group    = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
    callback = function() lint.try_lint() end,
    desc     = 'Run linters on save and insert leave',
})
