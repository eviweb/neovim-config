-- lua/ui/theme.lua
-- Reads ~/.config/nvim/.nvim-theme to determine the active colorscheme.
-- Mirrors the pattern of lua/ui/variant.lua.

local M = {}

-- All supported dark themes. Keys are the exact vim colorscheme names.
M.VALID = {
    -- nightfox.nvim variants
    nightfox   = true,
    nordfox    = true,
    duskfox    = true,
    terafox    = true,
    carbonfox  = true,
    -- catppuccin
    ['catppuccin-mocha']     = true,
    ['catppuccin-macchiato'] = true,
    ['catppuccin-frappe']    = true,
    -- tokyonight
    ['tokyonight-night'] = true,
    ['tokyonight-storm'] = true,
    ['tokyonight-moon']  = true,
    -- kanagawa
    ['kanagawa-wave']   = true,
    ['kanagawa-dragon'] = true,
    -- gruvbox-material
    ['gruvbox-material'] = true,
}

-- Sorted list for tab completion.
M.NAMES = (function()
    local names = {}
    for k in pairs(M.VALID) do table.insert(names, k) end
    table.sort(names)
    return names
end)()

function M.get()
    local f = io.open(vim.fn.stdpath('config') .. '/.nvim-theme', 'r')
    if f then
        local name = f:read('*l')
        f:close()
        if name and M.VALID[name] then return name end
    end
    return 'nightfox'
end

return M
