-- lua/minimum_version.lua
--
-- The oldest Neovim this configuration starts on. The LSP setup uses
-- vim.lsp.config / vim.lsp.enable (0.11); on 0.10 the config would otherwise
-- stop with "attempt to call field 'config' (a nil value)". Keep in sync with
-- the README ("Supported Platforms"); a test checks that they agree.

local M = {}

M.minimum = { major = 0, minor = 11 }

function M.satisfied()
    local v = vim.version()
    return v.major > M.minimum.major
        or (v.major == M.minimum.major and v.minor >= M.minimum.minor)
end

function M.message()
    local v = vim.version()
    return string.format(
        'This configuration requires Neovim %d.%d or newer (found %d.%d.%d). '
            .. 'See the README, "Supported Platforms".',
        M.minimum.major, M.minimum.minor, v.major, v.minor, v.patch
    )
end

return M
