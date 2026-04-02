-- lua/ui/modern.lua
-- Plugin specs for the modern UI variant:
-- snacks.nvim providing picker (replaces telescope), notifier, and dashboard.

local M = {}

function M.get_plugins()
  return {
    {
      'folke/snacks.nvim',
      priority = 1000,
      lazy = false,
      opts = {
        picker    = { enabled = true },
        notifier  = { enabled = true },
        dashboard = { enabled = true },
      },
    },
  }
end

return M
