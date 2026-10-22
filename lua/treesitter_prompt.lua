-- lua/treesitter_prompt.lua
--
-- Offers to install the treesitter parser of the file being opened, when
-- nvim-treesitter has one for it and it is not installed. Highlighting, folds
-- and textobjects need the parser; commenting does not, so nothing breaks
-- without it and nothing is downloaded behind the user's back: installing means
-- fetching a third-party grammar and compiling it.
--
-- One menu per language and per session: Install, Not now (also what dismissing
-- the menu means), or Never for that language, which is written to
-- <state>/treesitter-declined, one language per line; delete the line to be
-- asked again. Nothing is offered when it could not work (see tools_available),
-- without a user interface, for windows that are not files, or for the
-- languages lua/config/treesitter.lua already installs at startup.

local M = {}

-- Languages already asked about, or whose installation failed, in this session.
local seen = {}

-- Languages the configuration installs by itself at startup; set by
-- lua/config/treesitter.lua. Offering one would only duplicate that install.
M.managed = function()
    return {}
end

function M.interactive()
    return #vim.api.nvim_list_uis() > 0
end

-- What nvim-treesitter runs to build a parser: the tree-sitter CLI, a C
-- compiler, curl and tar.
function M.tools_available()
    for _, tool in ipairs({ 'tree-sitter', 'curl', 'tar' }) do
        if vim.fn.executable(tool) ~= 1 then
            return false
        end
    end
    for _, compiler in ipairs({ 'cc', 'gcc', 'clang' }) do
        if vim.fn.executable(compiler) == 1 then
            return true
        end
    end
    return false
end

local function declined_file()
    return vim.fn.stdpath('state') .. '/treesitter-declined'
end

local function read_declined()
    local declined = {}
    local file = declined_file()
    if vim.fn.filereadable(file) == 1 then
        for _, line in ipairs(vim.fn.readfile(file)) do
            local lang = vim.trim(line)
            if lang ~= '' then
                declined[lang] = true
            end
        end
    end
    return declined
end

local function decline(lang)
    local declined = read_declined()
    declined[lang] = true
    local languages = vim.tbl_keys(declined)
    table.sort(languages)
    local file = declined_file()
    vim.fn.mkdir(vim.fs.dirname(file), 'p')
    vim.fn.writefile(languages, file)
    vim.notify(
        ('The %s parser will not be offered again. To be asked again, remove "%s" from %s'):format(lang, lang, file),
        vim.log.levels.INFO
    )
end

-- The parser to offer for a buffer, or nil.
local function language_for(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= '' then
        return nil
    end
    local filetype = vim.bo[bufnr].filetype
    if filetype == '' then
        return nil
    end
    local lang = vim.treesitter.language.get_lang(filetype)
    if not lang or seen[lang] then
        return nil
    end
    local ok, treesitter = pcall(require, 'nvim-treesitter')
    if not ok then
        return nil
    end
    if not vim.list_contains(treesitter.get_available(), lang) or vim.list_contains(treesitter.get_installed(), lang) then
        return nil
    end
    if vim.list_contains(M.managed(), lang) or read_declined()[lang] then
        return nil
    end
    return lang
end

-- nvim-treesitter installs into <data>/site and relies on Neovim searching that
-- directory. On a fresh machine it did not exist at startup: Neovim lists it on
-- the runtimepath but built its cache of searchable directories without it, so
-- a parser installed in this session would not be found until a restart.
-- Assigning the option again makes Neovim look again (checked with the real
-- plugin: runtime files for the new parser go from 0 to 1).
local function make_install_dir_visible()
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

local function start_highlighting(lang)
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

local function install(lang)
    vim.notify(('Installing the %s parser...'):format(lang), vim.log.levels.INFO)
    local started, task = pcall(require('nvim-treesitter').install, { lang })
    local function finished(err, success)
        if started and not err and success then
            vim.notify(('The %s parser is installed.'):format(lang), vim.log.levels.INFO)
            make_install_dir_visible()
            start_highlighting(lang)
        else
            local detail = (not started and task) or err
            vim.notify(
                ('Could not install the %s parser%s'):format(
                    lang,
                    detail and (': ' .. tostring(detail)) or ' (see :messages or :checkhealth nvim-treesitter)'
                ),
                vim.log.levels.ERROR
            )
        end
    end
    if not started then
        finished(nil, false)
        return
    end
    task:await(vim.schedule_wrap(finished))
end

-- Called when a buffer gets its filetype.
function M.maybe_offer(bufnr)
    if not M.interactive() then
        return
    end
    local lang = language_for(bufnr)
    if not lang or not M.tools_available() then
        return
    end
    seen[lang] = true
    -- Let the buffer finish loading before a menu takes the screen.
    vim.schedule(function()
        vim.ui.select({ 'Install', 'Not now', 'Never for ' .. lang }, {
            prompt = ('No treesitter parser for %s. Install it?'):format(lang),
        }, function(_, index)
            if index == 1 then
                install(lang)
            elseif index == 3 then
                decline(lang)
            end
        end)
    end)
end

return M
