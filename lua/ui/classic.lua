-- lua/ui/classic.lua
-- Plugin specs for the classic UI variant:
-- telescope (with fzf and node_modules extensions), which-key, trouble.

local M = {}

function M.get_plugins()
  return {
    require('plugins.telescope'),
    require('plugins.which-key'),
    require('plugins.trouble'),
  }
end

return M
