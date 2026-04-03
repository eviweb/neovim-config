#!/usr/bin/env bats

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
}

@test "plugin declarations do not use the legacy kyazdani42 namespace" {
  run grep -R -n "kyazdani42/" lua/plugins
  [ "$status" -eq 1 ]
}

@test "keymaps do not expose diaglist commands anymore" {
  run grep -n "diaglist" lua/keymaps.lua
  [ "$status" -eq 1 ]
}

@test "telescope plugin does not include unused tele-tabby extension" {
  run grep -n "tele-tabby" lua/plugins/telescope.lua
  [ "$status" -eq 1 ]
}

@test "telescope plugin does not include unused live-grep-raw extension" {
  run grep -n "live-grep-raw" lua/plugins/telescope.lua
  [ "$status" -eq 1 ]
}

@test "telescope plugin does not include unused symbols extension" {
  run grep -n "telescope-symbols" lua/plugins/telescope.lua
  [ "$status" -eq 1 ]
}

@test "telescope config does not configure or load removed extensions" {
  run grep -n "tele_tabby" lua/config/telescope.lua
  [ "$status" -eq 1 ]
}

@test "plugins list does not load archived nvim-gps" {
  run grep -n "nvim-gps" lua/plugins.lua
  [ "$status" -eq 1 ]
}

@test "lualine config does not reference nvim-gps" {
  run grep -n "nvim-gps\|nvim_gps" lua/config/lualine.lua
  [ "$status" -eq 1 ]
}

@test "lualine config uses nvim-navic for breadcrumb" {
  run grep -n "nvim-navic" lua/config/lualine.lua
  [ "$status" -eq 0 ]
}

@test "lualine config guards nvim-navic with pcall" {
  run grep -n "pcall(require, 'nvim-navic')" lua/config/lualine.lua
  [ "$status" -eq 0 ]
}

@test "trouble plugin does not declare lsp-colors" {
  run grep -n "lsp-colors" lua/plugins/trouble.lua
  [ "$status" -eq 1 ]
}

@test "plugins list loads neo-tree instead of nvim-tree" {
  run grep -n "require('plugins.neo-tree')" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "plugins list does not load nvim-tree" {
  run grep -n "require('plugins.nvim-tree')" lua/plugins.lua
  [ "$status" -eq 1 ]
}

@test "keymaps use Neotree command instead of NvimTreeToggle" {
  run grep -n "NvimTreeToggle" lua/keymaps.lua
  [ "$status" -eq 1 ]
}

@test "keymaps do not use trouble v1 workspace_diagnostics" {
  run grep -n "workspace_diagnostics" lua/keymaps.lua
  [ "$status" -eq 1 ]
}

@test "keymaps do not use trouble v1 document_diagnostics" {
  run grep -n "document_diagnostics" lua/keymaps.lua
  [ "$status" -eq 1 ]
}

@test "keymaps do not use trouble v1 quickfix command" {
  run grep -n "Trouble quickfix" lua/keymaps.lua
  [ "$status" -eq 1 ]
}

@test "telescope config loads fzf extension" {
  run grep -n "load_extension('fzf')" lua/config/telescope.lua
  [ "$status" -eq 0 ]
}

@test "telescope config guards node_modules extension with pcall" {
  run grep -n "pcall(telescope.load_extension, 'node_modules')" lua/config/telescope.lua
  [ "$status" -eq 0 ]
}

@test "telescope config does not use trouble v1 open_with_trouble" {
  run grep -n "open_with_trouble" lua/config/telescope.lua
  [ "$status" -eq 1 ]
}

@test "which-key config uses wk.add for group registration" {
  run grep -n "wk.add" lua/config/which-key.lua
  [ "$status" -eq 0 ]
}

@test "which-key config registers Leader f group as Find" {
  run grep -n "Leader>f" lua/config/which-key.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"Find"* ]]
}

@test "which-key config registers Leader d group as Diagnostics" {
  run grep -n "Leader>d" lua/config/which-key.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"Diagnostics"* ]]
}

@test "keymaps cheatsheet documents leader key and how to change it" {
  run grep -n "mapleader" docs/keymaps.md
  [ "$status" -eq 0 ]
}

@test "keymaps define Leader? for telescope keymaps picker" {
  run grep -n 'Leader>?' lua/keymaps.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"telescope.builtin"* ]]
  [[ "$output" == *"keymaps"* ]]
}

@test "keymaps cheatsheet documents Leader?" {
  run grep -n 'Leader>?' docs/keymaps.md
  [ "$status" -eq 0 ]
}

@test "bufferline config uses neo-tree filetype offset" {
  run grep -n "neo-tree" lua/config/bufferline.lua
  [ "$status" -eq 0 ]
}

@test "which-key config annotates Leader fp for profiles" {
  run grep -n "Leader>fp" lua/config/which-key.lua
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Phase 9 — UI variant system
# ---------------------------------------------------------------------------

@test "ui variant module exists" {
  [ -f "lua/ui/variant.lua" ]
}

@test "ui shared module exists" {
  [ -f "lua/ui/shared.lua" ]
}

@test "ui classic module exists" {
  [ -f "lua/ui/classic.lua" ]
}

@test "ui modern module exists" {
  [ -f "lua/ui/modern.lua" ]
}

@test "ui variant module defaults to classic" {
  run grep -n "return 'classic'" lua/ui/variant.lua
  [ "$status" -eq 0 ]
}

@test "ui shared module loads lualine and bufferline" {
  run grep -n "plugins.lualine" lua/ui/shared.lua
  [ "$status" -eq 0 ]
  run grep -n "plugins.bufferline" lua/ui/shared.lua
  [ "$status" -eq 0 ]
}

@test "ui classic module loads telescope" {
  run grep -n "plugins.telescope" lua/ui/classic.lua
  [ "$status" -eq 0 ]
}

@test "ui modern module loads snacks.nvim" {
  run grep -n "folke/snacks.nvim" lua/ui/modern.lua
  [ "$status" -eq 0 ]
}

@test "plugins.lua uses ui variant system" {
  run grep -n "ui.variant" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "plugins.lua does not load telescope directly" {
  run grep -n "require('plugins.telescope')" lua/plugins.lua
  [ "$status" -eq 1 ]
}

@test ".nvim-ui is listed in .gitignore" {
  run grep -n "\.nvim-ui" .gitignore
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Vimrc audit — ported behaviours
# ---------------------------------------------------------------------------

@test "options sets scrolloff to 7" {
  run grep -n "scrolloff = 7" lua/options.lua
  [ "$status" -eq 0 ]
}

@test "keymaps remap 0 to first non-blank character" {
  run grep -n "'0', '\\^'" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

@test "keymaps define visual star search forward" {
  run grep -n "\\\\V" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

@test "keymaps define Leader pp for paste toggle" {
  run grep -n "Leader>pp\|paste!" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

@test "keymaps define Leader cd to change working directory" {
  run grep -n "Leader>cd\|:cd %:p:h" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

@test "keymaps define Leader ss for spell toggle" {
  run grep -n "Leader>ss\|spell!" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

@test "which-key annotates Leader h group as Help" {
  run grep -n "Leader>h" lua/config/which-key.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"Help"* ]]
}

@test "which-key annotates Leader s group as Spell" {
  run grep -n "Leader>s" lua/config/which-key.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"Spell"* ]]
}

@test "keymaps define Leader CR to clear search highlight" {
  run grep -n "Leader>.*CR\|noh" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

@test "commands define auto-save on focus loss" {
  run grep -n "FocusLost\|auto-save" lua/commands.lua
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Phase 11 — gitsigns
# ---------------------------------------------------------------------------

@test "gitsigns plugin file exists" {
  [ -f "lua/plugins/gitsigns.lua" ]
}

@test "gitsigns plugin uses lewis6991 repository" {
  run grep -n "lewis6991/gitsigns.nvim" lua/plugins/gitsigns.lua
  [ "$status" -eq 0 ]
}

@test "gitsigns config file exists" {
  [ -f "lua/config/gitsigns.lua" ]
}

@test "gitsigns config defines hunk navigation" {
  run grep -n "next_hunk\|prev_hunk" lua/config/gitsigns.lua
  [ "$status" -eq 0 ]
}

@test "gitsigns config defines blame line keymap" {
  run grep -n "blame_line" lua/config/gitsigns.lua
  [ "$status" -eq 0 ]
}

@test "plugins list loads gitsigns" {
  run grep -n "plugins.gitsigns" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "which-key annotates Leader g group as Git" {
  run grep -n "Leader>g" lua/config/which-key.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"Git"* ]]
}

# ---------------------------------------------------------------------------
# Phase 11 — line number toggle
# ---------------------------------------------------------------------------

@test "keymaps define Leader tn to cycle line numbers" {
  run grep -n "Leader.*tn\|relativenumber" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

@test "which-key annotates Leader t group as Toggle" {
  run grep -n "Leader>t" lua/config/which-key.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"Toggle"* ]]
}

@test "which-key annotates Leader tn for line number cycle" {
  run grep -n "Leader>tn" lua/config/which-key.lua
  [ "$status" -eq 0 ]
}

@test "keymaps cheatsheet documents Leader tn" {
  run grep -n "Leader.*tn\|line number" docs/keymaps.md
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Phase 12 — persistent theme system
# ---------------------------------------------------------------------------

@test "theme module exists" {
  [ -f "lua/ui/theme.lua" ]
}

@test "theme module exposes VALID table" {
  run grep -n "M.VALID" lua/ui/theme.lua
  [ "$status" -eq 0 ]
}

@test "theme module exposes NAMES array" {
  run grep -n "M.NAMES" lua/ui/theme.lua
  [ "$status" -eq 0 ]
}

@test "theme module defaults to nightfox" {
  run grep -n "nightfox" lua/ui/theme.lua
  [ "$status" -eq 0 ]
}

@test "theme module lists all 14 dark themes" {
  local count
  count=$(grep -c "true" lua/ui/theme.lua)
  [ "$count" -ge 14 ]
}

@test "catppuccin plugin file exists" {
  [ -f "lua/plugins/catppuccin.lua" ]
}

@test "catppuccin plugin uses priority 1000" {
  run grep -n "priority.*1000" lua/plugins/catppuccin.lua
  [ "$status" -eq 0 ]
}

@test "tokyonight plugin file exists" {
  [ -f "lua/plugins/tokyonight.lua" ]
}

@test "tokyonight plugin uses priority 1000" {
  run grep -n "priority.*1000" lua/plugins/tokyonight.lua
  [ "$status" -eq 0 ]
}

@test "kanagawa plugin file exists" {
  [ -f "lua/plugins/kanagawa.lua" ]
}

@test "kanagawa plugin uses priority 1000" {
  run grep -n "priority.*1000" lua/plugins/kanagawa.lua
  [ "$status" -eq 0 ]
}

@test "gruvbox-material plugin file exists" {
  [ -f "lua/plugins/gruvbox-material.lua" ]
}

@test "gruvbox-material plugin uses priority 1000" {
  run grep -n "priority.*1000" lua/plugins/gruvbox-material.lua
  [ "$status" -eq 0 ]
}

@test "nightfox plugin does not apply colorscheme directly" {
  run grep -n "vim.cmd.*colorscheme" lua/plugins/nightfox.lua
  [ "$status" -eq 1 ]
}

@test "plugins.lua loads catppuccin" {
  run grep -n "plugins.catppuccin" lua/ui/shared.lua
  [ "$status" -eq 0 ]
}

@test "plugins.lua loads tokyonight" {
  run grep -n "plugins.tokyonight" lua/ui/shared.lua
  [ "$status" -eq 0 ]
}

@test "plugins.lua loads kanagawa" {
  run grep -n "plugins.kanagawa" lua/ui/shared.lua
  [ "$status" -eq 0 ]
}

@test "plugins.lua loads gruvbox-material" {
  run grep -n "plugins.gruvbox-material" lua/ui/shared.lua
  [ "$status" -eq 0 ]
}

@test "plugins.lua declares theme-init spec" {
  run grep -n "theme-init" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "theme-init spec uses priority 0" {
  run grep -n "priority = 0" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "theme-init applies colorscheme via theme.get()" {
  run grep -n "ui.theme" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "commands.lua declares Theme user command" {
  run grep -n "Theme" lua/commands.lua
  [ "$status" -eq 0 ]
}

@test "Theme command uses theme module for completion" {
  run grep -n "ui.theme.*NAMES\|theme.*NAMES" lua/commands.lua
  [ "$status" -eq 0 ]
}

@test ".nvim-theme is listed in .gitignore" {
  run grep -n "\.nvim-theme" .gitignore
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Phase 12 — render-markdown
# ---------------------------------------------------------------------------

@test "render-markdown plugin file exists" {
  [ -f "lua/plugins/render-markdown.lua" ]
}

@test "render-markdown plugin is lazy-loaded on markdown filetype" {
  run grep -n "ft.*markdown\|markdown.*ft" lua/plugins/render-markdown.lua
  [ "$status" -eq 0 ]
}

@test "render-markdown config file exists" {
  [ -f "lua/config/render-markdown.lua" ]
}

@test "plugins.lua loads render-markdown" {
  run grep -n "plugins.render-markdown" lua/plugins.lua
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Phase 12 — bash shebang filetype detection
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Phase 13 — nvim-spectre, zen-mode
# ---------------------------------------------------------------------------

@test "nvim-spectre plugin file exists" {
  [ -f "lua/plugins/nvim-spectre.lua" ]
}

@test "nvim-spectre plugin uses nvim-pack repository" {
  run grep -n "nvim-pack/nvim-spectre" lua/plugins/nvim-spectre.lua
  [ "$status" -eq 0 ]
}

@test "plugins.lua loads nvim-spectre" {
  run grep -n "plugins.nvim-spectre" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "keymaps define Leader sr for Spectre" {
  run grep -n "Spectre" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

@test "keymaps define Leader sw to search word under cursor" {
  run grep -n "select_word" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

@test "zen-mode plugin file exists" {
  [ -f "lua/plugins/zen-mode.lua" ]
}

@test "zen-mode plugin uses folke repository" {
  run grep -n "folke/zen-mode.nvim" lua/plugins/zen-mode.lua
  [ "$status" -eq 0 ]
}

@test "plugins.lua loads zen-mode" {
  run grep -n "plugins.zen-mode" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "keymaps define Leader tz for ZenMode" {
  run grep -n "ZenMode" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Phase 13 — codeium, mini.ai
# ---------------------------------------------------------------------------

@test "codeium plugin file exists" {
  [ -f "lua/plugins/codeium.lua" ]
}

@test "codeium plugin uses Exafunction repository" {
  run grep -n "Exafunction/codeium.nvim" lua/plugins/codeium.lua
  [ "$status" -eq 0 ]
}

@test "plugins.lua loads codeium" {
  run grep -n "plugins.codeium" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "nvim-cmp sources include codeium" {
  run grep -n "codeium" lua/config/nvim-cmp.lua
  [ "$status" -eq 0 ]
}

@test "mini-ai plugin file exists" {
  [ -f "lua/plugins/mini-ai.lua" ]
}

@test "mini-ai plugin uses echasnovski repository" {
  run grep -n "echasnovski/mini.ai" lua/plugins/mini-ai.lua
  [ "$status" -eq 0 ]
}

@test "plugins.lua loads mini-ai" {
  run grep -n "plugins.mini-ai" lua/plugins.lua
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Phase 13 — toggleterm
# ---------------------------------------------------------------------------

@test "toggleterm plugin file exists" {
  [ -f "lua/plugins/toggleterm.lua" ]
}

@test "toggleterm plugin uses akinsho repository" {
  run grep -n "akinsho/toggleterm.nvim" lua/plugins/toggleterm.lua
  [ "$status" -eq 0 ]
}

@test "toggleterm config file exists" {
  [ -f "lua/config/toggleterm.lua" ]
}

@test "plugins.lua loads toggleterm" {
  run grep -n "plugins.toggleterm" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "toggleterm config defines C-backslash open mapping" {
  run grep -n "open_mapping" lua/config/toggleterm.lua
  [ "$status" -eq 0 ]
}

@test "toggleterm config defines dedicated Claude terminal" {
  run grep -n "claude" lua/config/toggleterm.lua
  [ "$status" -eq 0 ]
}

@test "toggleterm config defines dedicated Codex terminal" {
  run grep -n "codex" lua/config/toggleterm.lua
  [ "$status" -eq 0 ]
}

@test "toggleterm config defines Leader tt keymap" {
  run grep -n "Leader.*tt\|ToggleTerm" lua/config/toggleterm.lua
  [ "$status" -eq 0 ]
}

@test "which-key annotates Leader tC and Leader tX" {
  run grep -n "Leader>tC\|Leader>tX" lua/config/which-key.lua
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Phase 13 — harpoon
# ---------------------------------------------------------------------------

@test "harpoon plugin file exists" {
  [ -f "lua/plugins/harpoon.lua" ]
}

@test "harpoon plugin uses harpoon2 branch" {
  run grep -n "harpoon2" lua/plugins/harpoon.lua
  [ "$status" -eq 0 ]
}

@test "harpoon config file exists" {
  [ -f "lua/config/harpoon.lua" ]
}

@test "plugins.lua loads harpoon" {
  run grep -n "plugins.harpoon" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "harpoon config defines Leader ha to add file" {
  run grep -n "Leader.*ha\|:add()" lua/config/harpoon.lua
  [ "$status" -eq 0 ]
}

@test "harpoon config defines Leader hh to toggle menu" {
  run grep -n "toggle_quick_menu" lua/config/harpoon.lua
  [ "$status" -eq 0 ]
}

@test "harpoon config defines C-1 to C-4 jump keymaps" {
  run grep -n "<C-1>" lua/config/harpoon.lua
  [ "$status" -eq 0 ]
  run grep -n "<C-4>" lua/config/harpoon.lua
  [ "$status" -eq 0 ]
}

@test "which-key annotates Leader ha and Leader hh" {
  run grep -n "Leader>ha\|Leader>hh" lua/config/which-key.lua
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Phase 13 — todo-comments, diffview
# ---------------------------------------------------------------------------

@test "todo-comments plugin file exists" {
  [ -f "lua/plugins/todo-comments.lua" ]
}

@test "todo-comments plugin uses folke repository" {
  run grep -n "folke/todo-comments.nvim" lua/plugins/todo-comments.lua
  [ "$status" -eq 0 ]
}

@test "plugins.lua loads todo-comments" {
  run grep -n "plugins.todo-comments" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "keymaps define Leader ft for TodoTelescope" {
  run grep -n "TodoTelescope" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

@test "diffview plugin file exists" {
  [ -f "lua/plugins/diffview.lua" ]
}

@test "diffview plugin uses sindrets repository" {
  run grep -n "sindrets/diffview.nvim" lua/plugins/diffview.lua
  [ "$status" -eq 0 ]
}

@test "plugins.lua loads diffview" {
  run grep -n "plugins.diffview" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "keymaps define Leader gv for DiffviewOpen" {
  run grep -n "DiffviewOpen" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

@test "keymaps define Leader gH for DiffviewFileHistory" {
  run grep -n "DiffviewFileHistory" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

@test "which-key annotates Leader gv and Leader gH" {
  run grep -n "Leader>gv\|Leader>gH" lua/config/which-key.lua
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Phase 13 — vim-illuminate, indent-blankline, friendly-snippets
# ---------------------------------------------------------------------------

@test "vim-illuminate plugin file exists" {
  [ -f "lua/plugins/vim-illuminate.lua" ]
}

@test "vim-illuminate plugin uses RRethy repository" {
  run grep -n "RRethy/vim-illuminate" lua/plugins/vim-illuminate.lua
  [ "$status" -eq 0 ]
}

@test "plugins.lua loads vim-illuminate" {
  run grep -n "plugins.vim-illuminate" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "indent-blankline plugin file exists" {
  [ -f "lua/plugins/indent-blankline.lua" ]
}

@test "indent-blankline plugin uses ibl main module" {
  run grep -n "main.*ibl\|'ibl'" lua/plugins/indent-blankline.lua
  [ "$status" -eq 0 ]
}

@test "plugins.lua loads indent-blankline" {
  run grep -n "plugins.indent-blankline" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "friendly-snippets is declared as LuaSnip dependency" {
  run grep -n "friendly-snippets" lua/plugins/luasnip.lua
  [ "$status" -eq 0 ]
}

@test "luasnip config loads friendly-snippets via lazy_load" {
  run grep -n "lazy_load" lua/plugins/luasnip.lua
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Phase 12 — session restore (persistence.nvim)
# ---------------------------------------------------------------------------

@test "persistence plugin file exists" {
  [ -f "lua/plugins/persistence.lua" ]
}

@test "persistence config file exists" {
  [ -f "lua/config/persistence.lua" ]
}

@test "persistence plugin uses folke repository" {
  run grep -n "folke/persistence.nvim" lua/plugins/persistence.lua
  [ "$status" -eq 0 ]
}

@test "persistence config auto-restores session on VimEnter with no arguments" {
  run grep -n "VimEnter" lua/config/persistence.lua
  [ "$status" -eq 0 ]
  run grep -n "argc" lua/config/persistence.lua
  [ "$status" -eq 0 ]
}

@test "plugins.lua loads persistence" {
  run grep -n "plugins.persistence" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "keymaps define Leader qs to restore session" {
  run grep -n "Leader.*qs\|persistence.*load" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

@test "keymaps define Leader qd to stop persistence" {
  run grep -n "Leader.*qd\|persistence.*stop" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

@test "which-key annotates Leader q group as Session" {
  run grep -n "Leader>q" lua/config/which-key.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"Session"* ]]
}

@test "Cheat command uses vim.ui.select when no topic is given" {
  run grep -n "vim.ui.select" lua/commands.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"cheat_topics"* ]]
}

@test "commands define w!! sudo save abbreviation" {
  run grep -n "w!!" lua/commands.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"sudo tee"* ]]
}

@test "options.lua uses vim.filetype.add for shebang detection" {
  run grep -n "vim.filetype.add" lua/options.lua
  [ "$status" -eq 0 ]
}

@test "options.lua matches /bin/bash shebang" {
  run grep -n "bin/bash" lua/options.lua
  [ "$status" -eq 0 ]
}

@test "options.lua matches env bash shebang" {
  run grep -n "env.*bash\|env%s+bash" lua/options.lua
  [ "$status" -eq 0 ]
}

@test "shebang detection uses lowest priority" {
  run grep -n "priority.*math.huge\|-math.huge" lua/options.lua
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Phase 12 — keymaps cleanup
# ---------------------------------------------------------------------------

@test "keymaps define C-s save in normal mode" {
  run grep -n "'<C-s>'.*:w" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

@test "keymaps define C-s save in insert mode" {
  run grep -n "\"i\".*C-s\|'i'.*C-s" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

@test "keymaps do not map C-z to undo" {
  run grep -n "'<C-z>'.*'u'\|\"<C-z>\".*\"u\"" lua/keymaps.lua
  [ "$status" -eq 1 ]
}

@test "keymaps do not remap C-r in insert mode" {
  run grep -n "'i'.*'<C-r>'\|\"i\".*\"<C-r>\"" lua/keymaps.lua
  [ "$status" -eq 1 ]
}

# ---------------------------------------------------------------------------
# Phase 13 — lazygit integration
# ---------------------------------------------------------------------------

@test "toggleterm config defines a lazygit terminal" {
  run grep -n "lazygit" lua/config/toggleterm.lua
  [ "$status" -eq 0 ]
}

@test "toggleterm config maps Leader gg to lazygit toggle" {
  run grep -n "Leader.*gg\|gg.*lazygit" lua/config/toggleterm.lua
  [ "$status" -eq 0 ]
}

@test "which-key annotates Leader gg as Open lazygit" {
  run grep -n "Leader>gg" lua/config/which-key.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"lazygit"* ]]
}
