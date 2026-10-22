-- lua/lsp_requirements.lua
--
-- Language servers whose Mason package is installed with another tool. Mason
-- installs an npm package with `npm install`, which fails with a Mason error at
-- every startup when Node.js is absent. Node.js is opt-in in this config
-- (`nvim-config install deps --with-node`), so such servers are only requested
-- when the tool is there, rather than retrying a known failure. A server that
-- is not listed is requested as before.
--
-- When the Mason registry has been downloaded, tests/profiles.bats checks this
-- list against it: add a server here as soon as its package is installed by npm.

local M = {}

M.requires = {
    jsonls       = 'npm',
    ts_ls        = 'npm',
    vue_ls       = 'npm',
    svelte       = 'npm',
    intelephense = 'npm',
    pyright      = 'npm',
    bashls       = 'npm',
    yamlls       = 'npm',
    dockerls     = 'npm',
}

-- Split `servers` into the ones that can be installed here and the ones that
-- cannot, keeping the order. Returns `installable, skipped`.
function M.installable(servers)
    local installable, skipped = {}, {}
    for _, server in ipairs(servers) do
        local tool = M.requires[server]
        if tool == nil or vim.fn.executable(tool) == 1 then
            table.insert(installable, server)
        else
            table.insert(skipped, server)
        end
    end
    return installable, skipped
end

return M
