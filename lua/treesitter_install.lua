-- lua/treesitter_install.lua
--
-- What has to happen once nvim-treesitter has installed a parser, so that it
-- can be used in the session that installed it and not only after a restart.
-- Shared by the startup install (lua/config/treesitter.lua) and by the menu
-- that offers a missing parser (lua/treesitter_prompt.lua).

local M = {}

-- nvim-treesitter installs into <data>/site and relies on Neovim searching that
-- directory. On a fresh machine it did not exist at startup: Neovim lists it on
-- the runtimepath but built its cache of searchable directories without it, so
-- a parser installed in this session would not be found until a restart.
-- Assigning the option again makes Neovim look again (checked with the real
-- plugin: runtime files for the new parser go from 0 to 1).
function M.make_install_dir_visible()
    local ok, config = pcall(require, 'nvim-treesitter.config')
    if ok then
        local site = vim.fs.normalize(vim.fs.dirname(config.get_install_dir('parser')))
        local listed = false
        for _, entry in ipairs(vim.opt.runtimepath:get()) do
            if vim.fs.normalize(entry) == site then
                listed = true
            end
        end
        if not listed then
            vim.opt.runtimepath:prepend(site)
        end
    end
    vim.o.runtimepath = vim.o.runtimepath
end

-- Start treesitter highlighting in the loaded file buffers of a language.
function M.start_highlighting(lang)
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if
            vim.api.nvim_buf_is_loaded(bufnr)
            and vim.bo[bufnr].buftype == ''
            and vim.treesitter.language.get_lang(vim.bo[bufnr].filetype) == lang
        then
            pcall(vim.treesitter.start, bufnr)
        end
    end
end

-- Make freshly installed parsers usable now.
function M.activate(languages)
    M.make_install_dir_visible()
    for _, lang in ipairs(languages) do
        M.start_highlighting(lang)
    end
end

-- Install parsers (async, non-blocking). When it is over, whatever it installed
-- is activated; nothing is done if it installed nothing, whatever the outcome.
function M.install(languages)
    local treesitter = require('nvim-treesitter')
    local before = vim.list_slice(treesitter.get_installed())
    treesitter.install(languages):await(vim.schedule_wrap(function()
        local installed = treesitter.get_installed()
        local fresh = vim.tbl_filter(function(lang)
            return vim.list_contains(installed, lang) and not vim.list_contains(before, lang)
        end, languages)
        if #fresh > 0 then
            M.activate(fresh)
        end
    end))
end

return M
