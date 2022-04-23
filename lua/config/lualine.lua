-- lua/config/lualine.lua

local lualine = require('lualine')
local gps = require('nvim-gps')

lualine.setup({
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = {
        { "filename" },
        {
          gps.get_location,
          cond = gps.is_available,
          color = { fg = "#f3ca28" },
        },
      },
      lualine_x = { "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
})

