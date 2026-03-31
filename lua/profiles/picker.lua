-- lua/profiles/picker.lua
--
-- Telescope picker for Neovim profiles.
-- Shows all available profiles with their active (●) or inactive (○) status.
-- Selecting an inactive profile activates it via profiles.activate().

local M = {}

function M.pick()
    local ok_telescope, _ = pcall(require, 'telescope')
    if not ok_telescope then
        vim.notify('telescope.nvim is required for the profile picker', vim.log.levels.ERROR)
        return
    end

    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local profiles = require('profiles')

    -- Collect profile names from lua/profiles/*.lua (skip init and picker)
    local names = {}
    local profiles_dir = vim.fn.stdpath('config') .. '/lua/profiles'
    local handle = vim.loop.fs_scandir(profiles_dir)
    if handle then
        while true do
            local fname, ftype = vim.loop.fs_scandir_next(handle)
            if not fname then break end
            if ftype == 'file' and fname:match('%.lua$') then
                local stem = fname:sub(1, -5)
                if stem ~= 'init' and stem ~= 'picker' then
                    table.insert(names, stem)
                end
            end
        end
        table.sort(names)
    end

    local entries = {}
    for _, name in ipairs(names) do
        local active = profiles.is_active(name)
        table.insert(entries, {
            name = name,
            display = (active and '● ' or '○ ') .. name,
            active = active,
        })
    end

    pickers.new({}, {
        prompt_title = 'Neovim Profiles',
        finder = finders.new_table({
            results = entries,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.display,
                    ordinal = entry.name,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    profiles.activate(selection.value.name)
                end
            end)
            return true
        end,
    }):find()
end

return M
