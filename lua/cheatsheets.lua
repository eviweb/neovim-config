-- lua/cheatsheets.lua
--
-- Where :Cheat finds its topics. A topic is a `<name>.md` file in one of these
-- directories, listed from lowest to highest precedence (on a name clash the
-- last one wins, so a sheet of your own can replace a built-in one):
--
--   1. built-in:  <config>/docs/cheatsheets
--   2. profiles:  the `cheatsheets` directories of the active profiles
--                 (relative to the config root, or absolute)
--   3. user:      <config>-cheatsheets (e.g. ~/.config/nvim-cheatsheets), then
--                 each directory of $NVIM_CHEATSHEET_DIRS (colon-separated)
--
-- Missing directories, subdirectories and non-markdown files are ignored.
-- Everything is computed on each call, so a profile switched on with
-- :NvimProfile shows its sheets right away.

local M = {}

-- Resolve a directory declared by a profile: absolute as is, otherwise
-- relative to the config root.
local function resolve(dir, root)
    if dir:sub(1, 1) == '/' then
        return dir
    end
    return root .. '/' .. dir
end

local function user_dirs()
    local dirs = { vim.fn.stdpath('config') .. '-cheatsheets' }
    local env = vim.env.NVIM_CHEATSHEET_DIRS
    if env and env ~= '' then
        for _, dir in ipairs(vim.split(env, ':', { plain = true, trimempty = true })) do
            table.insert(dirs, dir)
        end
    end
    return dirs
end

-- opts (all optional, for tests): root, profile_dirs, user_dirs.
function M.sources(opts)
    opts = opts or {}
    local root = opts.root or vim.fn.stdpath('config')
    local profile_dirs = opts.profile_dirs
    if profile_dirs == nil then
        profile_dirs = require('profiles').get_cheatsheet_dirs()
    end

    local sources = { root .. '/docs/cheatsheets' }
    for _, dir in ipairs(profile_dirs) do
        table.insert(sources, resolve(dir, root))
    end
    for _, dir in ipairs(opts.user_dirs or user_dirs()) do
        table.insert(sources, dir)
    end
    return sources
end

-- Map of topic name -> path, later sources replacing earlier ones.
local function index(opts)
    local found = {}
    for _, dir in ipairs(M.sources(opts)) do
        local handle = vim.uv.fs_scandir(dir)
        while handle do
            local name, kind = vim.uv.fs_scandir_next(handle)
            if not name then break end
            if kind == 'file' and name:match('%.md$') then
                found[name:sub(1, -4)] = dir .. '/' .. name
            end
        end
    end
    return found
end

function M.topics(opts)
    local names = vim.tbl_keys(index(opts))
    table.sort(names)
    return names
end

-- Looked up in the index rather than built from the name, so a topic such as
-- `../notes` or an absolute path cannot reach a file outside the sources.
function M.path(topic, opts)
    return index(opts)[topic]
end

return M
