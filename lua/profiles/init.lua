-- lua/profiles/init.lua
--
-- Profile manager.  A profile is an additive set of LSP servers, plugins, and
-- null-ls sources that are enabled for a given project type.
--
-- Activation order (first match wins):
--   1. .nvim-profile file at the project root (comma-separated names)
--   2. Auto-detection from well-known project files

local M = {}

local _active_profiles = nil

-- Return the directory where Neovim was launched.
local function root_dir()
    return vim.fn.getcwd()
end

-- Read .nvim-profile and return a list of names, or nil if absent.
local function read_profile_file(dir)
    local path = dir .. '/.nvim-profile'
    if vim.fn.filereadable(path) == 0 then
        return nil
    end
    local lines = vim.fn.readfile(path)
    if not lines or #lines == 0 then
        return nil
    end
    local names = {}
    for _, name in ipairs(vim.split(lines[1], ',')) do
        name = vim.trim(name)
        if name ~= '' then
            table.insert(names, name)
        end
    end
    return #names > 0 and names or nil
end

-- Auto-detect profiles from project files in dir.
local detectors = {
    web = function(dir)
        return vim.fn.filereadable(dir .. '/package.json') == 1
    end,
    laravel = function(dir)
        if vim.fn.filereadable(dir .. '/composer.json') == 0 then
            return false
        end
        local content = table.concat(vim.fn.readfile(dir .. '/composer.json'), '\n')
        return content:find('laravel/framework') ~= nil
    end,
    php = function(dir)
        if vim.fn.filereadable(dir .. '/composer.json') == 0 then
            return false
        end
        local content = table.concat(vim.fn.readfile(dir .. '/composer.json'), '\n')
        return content:find('laravel/framework') == nil
    end,
    rust = function(dir)
        return vim.fn.filereadable(dir .. '/Cargo.toml') == 1
    end,
}

-- Return names of auto-detected profiles for dir.
function M.detect(dir)
    dir = dir or root_dir()
    local detected = {}
    for name, fn in pairs(detectors) do
        if fn(dir) then
            table.insert(detected, name)
        end
    end
    return detected
end

-- Resolve profile names, expanding `extends` dependencies (depth-first).
local function resolve(names)
    local resolved = {}
    local seen = {}

    local function add(name)
        if seen[name] then
            return
        end
        seen[name] = true
        local ok, profile = pcall(require, 'profiles.' .. name)
        if ok and profile.extends then
            for _, parent in ipairs(profile.extends) do
                add(parent)
            end
        end
        table.insert(resolved, name)
    end

    for _, name in ipairs(names) do
        add(name)
    end
    return resolved
end

-- Detect and store the active profile list.  Called lazily on first access.
function M.load(dir)
    dir = dir or root_dir()
    local names = read_profile_file(dir) or M.detect(dir)
    _active_profiles = resolve(names)
    return _active_profiles
end

-- Return true if the named profile is active.
function M.is_active(name)
    if _active_profiles == nil then
        M.load()
    end
    for _, n in ipairs(_active_profiles) do
        if n == name then
            return true
        end
    end
    return false
end

-- Return the list of active profile names.
function M.active_profiles()
    if _active_profiles == nil then
        M.load()
    end
    return _active_profiles
end

-- Return all lazy.nvim plugin specs contributed by active profiles.
function M.get_plugins()
    local plugins = {}
    for _, name in ipairs(M.active_profiles()) do
        local ok, profile = pcall(require, 'profiles.' .. name)
        if ok and profile.plugins then
            for _, spec in ipairs(profile.plugins) do
                table.insert(plugins, spec)
            end
        end
    end
    return plugins
end

-- Return all LSP server names contributed by active profiles.
function M.get_lsp_servers()
    local servers = {}
    for _, name in ipairs(M.active_profiles()) do
        local ok, profile = pcall(require, 'profiles.' .. name)
        if ok and profile.lsp_servers then
            for _, server in ipairs(profile.lsp_servers) do
                table.insert(servers, server)
            end
        end
    end
    return servers
end

-- Return all null-ls sources contributed by active profiles.
function M.get_null_ls_sources()
    local sources = {}
    local ok_null_ls, null_ls = pcall(require, 'null-ls')
    if not ok_null_ls then
        return sources
    end
    for _, name in ipairs(M.active_profiles()) do
        local ok, profile = pcall(require, 'profiles.' .. name)
        if ok and profile.null_ls_sources then
            local profile_sources = profile.null_ls_sources(null_ls)
            for _, source in ipairs(profile_sources) do
                table.insert(sources, source)
            end
        end
    end
    return sources
end

return M
