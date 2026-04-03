-- lua/ui/shared.lua
-- Plugin specs common to both classic and modern UI variants:
-- colorschemes, statusline, bufferline, and LSP breadcrumb.

local M = {}

function M.get_plugins()
  return {
    -- Colorschemes (all loaded early; theme-init applies the active one)
    require('plugins.nightfox'),
    require('plugins.catppuccin'),
    require('plugins.tokyonight'),
    require('plugins.kanagawa'),
    require('plugins.gruvbox-material'),
    -- UI
    require('plugins.lualine'),
    require('plugins.bufferline'),
    require('plugins.nvim-navic'),
  }
end

return M
