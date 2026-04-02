-- lua/ui/variant.lua
-- Reads .nvim-ui at the config root and returns the active UI variant.
-- Defaults to 'classic' if the file is absent or contains an unrecognised value.

local M = {}

function M.get()
  local ui_file = vim.fn.stdpath('config') .. '/.nvim-ui'
  local f = io.open(ui_file, 'r')
  if f then
    local variant = f:read('*l')
    f:close()
    if variant == 'modern' then
      return 'modern'
    end
  end
  return 'classic'
end

return M
