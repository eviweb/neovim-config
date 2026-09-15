#!/usr/bin/env bats

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
}

@test "readme has a getting started section" {
  run grep -n "Getting Started" README.md
  [ "$status" -eq 0 ]
}

@test "readme documents snap as recommended neovim install method" {
  run grep -n "snap install nvim" README.md
  [ "$status" -eq 0 ]
}

@test "readme has an updating section covering plugins" {
  run grep -n "Lazy" README.md
  [ "$status" -eq 0 ]
  run grep -n "Updating\|update" README.md
  [ "$status" -eq 0 ]
}

@test "readme documents neovim dependencies and plugin managers" {
  run grep -n "lazy.nvim" README.md
  [ "$status" -eq 0 ]

  run grep -n "mason.nvim" README.md
  [ "$status" -eq 0 ]
}

@test "keymaps cheatsheet exists and documents leader key" {
  [ -f "docs/keymaps.md" ]
  run grep -n "Leader" docs/keymaps.md
  [ "$status" -eq 0 ]
}

@test "keymaps cheatsheet covers lsp and completion sections" {
  run grep -n "LSP" docs/keymaps.md
  [ "$status" -eq 0 ]
  run grep -n "nvim-cmp" docs/keymaps.md
  [ "$status" -eq 0 ]
}

@test "readme links to keymaps cheatsheet" {
  run grep -n "docs/keymaps.md" README.md
  [ "$status" -eq 0 ]
}

@test "readme documents sandbox and snap limitations" {
  run grep -n "Snap" README.md
  [ "$status" -eq 0 ]

  run grep -n "sandbox" README.md
  [ "$status" -eq 0 ]
}

@test "readme documents tmux config role for neovim in byobu" {
  run grep -in "byobu\|tmux" README.md
  [ "$status" -eq 0 ]
}

@test "readme documents install tmux command" {
  run grep -n "install tmux" README.md
  [ "$status" -eq 0 ]
}

@test "readme documents the uninstall command and its deps policy" {
  run grep -n "uninstall config\|uninstall nvim\|uninstall mise\|uninstall deps\|uninstall all" README.md
  [ "$status" -eq 0 ]
  run grep -n "never removes apt packages\|never runs" README.md
  [ "$status" -eq 0 ]
}

@test "readme documents node as managed via nvm" {
  run grep -n "nvm" README.md
  [ "$status" -eq 0 ]
}

@test "readme documents --with-node flag for node bootstrap" {
  run grep -n "\-\-with-node" README.md
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Cheatsheets
# ---------------------------------------------------------------------------

@test "cheatsheets directory exists" {
  [ -d "docs/cheatsheets" ]
}

@test "basics cheatsheet exists" {
  [ -f "docs/cheatsheets/basics.md" ]
}

@test "basics cheatsheet covers modes, leader key, and command-line mode" {
  run grep -n "Normal\|Insert\|Visual" docs/cheatsheets/basics.md
  [ "$status" -eq 0 ]
  run grep -n "Leader" docs/cheatsheets/basics.md
  [ "$status" -eq 0 ]
  run grep -n ':w\|:q' docs/cheatsheets/basics.md
  [ "$status" -eq 0 ]
}

@test "basics cheatsheet states this config's actual leader key (Space)" {
  run grep -n "Space" docs/cheatsheets/basics.md
  [ "$status" -eq 0 ]
}

@test "readme links to the basics cheatsheet" {
  run grep -n "docs/cheatsheets/basics.md" README.md
  [ "$status" -eq 0 ]
}

@test "editing cheatsheet exists" {
  [ -f "docs/cheatsheets/editing.md" ]
}

@test "editing cheatsheet does not document the removed C-z undo binding" {
  run grep -n "C-z" docs/cheatsheets/editing.md
  [ "$status" -eq 1 ]
}

@test "editing cheatsheet documents treesitter textobjects (select, move, swap)" {
  run grep -n "af.*if\|Outer / inner function" docs/cheatsheets/editing.md
  [ "$status" -eq 0 ]
  run grep -n "\]m.*\[m\|Next / previous function start" docs/cheatsheets/editing.md
  [ "$status" -eq 0 ]
  run grep -n "\]a\|\[a" docs/cheatsheets/editing.md
  [ "$status" -eq 0 ]
}

@test "lsp cheatsheet exists" {
  [ -f "docs/cheatsheets/lsp.md" ]
}

@test "plugins cheatsheet exists" {
  [ -f "docs/cheatsheets/plugins.md" ]
}

@test "profiles cheatsheet exists" {
  [ -f "docs/cheatsheets/profiles.md" ]
}

@test "commands defines Cheat user command" {
  run grep -n "Cheat" lua/commands.lua
  [ "$status" -eq 0 ]
}

@test "Cheat command reads from docs/cheatsheets directory" {
  run grep -n "cheatsheets" lua/commands.lua
  [ "$status" -eq 0 ]
}

@test "keymaps define Leader hc for cheatsheet" {
  run grep -n "Leader>hc\|hc.*Cheat\|Cheat" lua/keymaps.lua
  [ "$status" -eq 0 ]
}

@test "which-key annotates Leader hc for cheatsheet" {
  run grep -n "Leader>hc" lua/config/which-key.lua
  [ "$status" -eq 0 ]
}

@test "git cheatsheet exists" {
  [ -f "docs/cheatsheets/git.md" ]
}

@test "Cheat command discovers topics dynamically from cheatsheets directory" {
  run grep -n "cheatsheets" lua/commands.lua
  [ "$status" -eq 0 ]
}
