-- lua/ui/shared.lua
-- Plugin specs common to both classic and modern UI variants:
-- colorscheme, statusline, bufferline, and LSP breadcrumb.

local M = {}

function M.get_plugins()
  return {
    require('plugins.nightfox'),
    require('plugins.lualine'),
    require('plugins.bufferline'),
    require('plugins.nvim-navic'),
  }
end

return M
