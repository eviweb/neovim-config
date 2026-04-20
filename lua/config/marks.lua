-- lua/config/marks.lua
-- Visual marks in the sign column with m[a-z] indicators.

require('marks').setup({
    default_mappings = true,
    builtin_marks    = { '.', '<', '>', '^' },
    cyclic           = true,
    force_write_shada = false,
    refresh_interval = 250,
    sign_priority    = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
})
