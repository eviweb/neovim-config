#!/usr/bin/env bats

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
}

@test "null-ls config does not reference invalid luasnip formatter" {
  run grep -n "null_ls\\.builtins\\.formatting\\.luasnip" lua/config/null-ls.lua
  [ "$status" -eq 1 ]
}

@test "nvim-tree config does not use removed open_on_setup option" {
  run grep -rn "open_on_setup" lua/config/
  [ "$status" -eq 1 ]
}

@test "plugins list loads the dedicated luasnip plugin module" {
  run grep -n "require('plugins\\.luasnip')" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "nvim-cmp config does not lazy-load vscode snippets directly" {
  run grep -n "luasnip\\.loaders\\.from_vscode" lua/config/nvim-cmp.lua
  [ "$status" -eq 1 ]
}

@test "lsp plugin does not depend on nvim-lsp-installer" {
  run grep -n "nvim-lsp-installer" lua/plugins/lsp.lua
  [ "$status" -eq 1 ]
}

@test "lsp plugin uses mason and mason-lspconfig" {
  run grep -n "williamboman/mason.nvim" lua/plugins/lsp.lua
  [ "$status" -eq 0 ]

  run grep -n "williamboman/mason-lspconfig.nvim" lua/plugins/lsp.lua
  [ "$status" -eq 0 ]
}

@test "lsp config does not use deprecated capability helper" {
  run grep -n "update_capabilities" lua/config/lsp.lua
  [ "$status" -eq 1 ]
}

@test "lsp config does not use deprecated formatting call" {
  run grep -n "vim\\.lsp\\.buf\\.formatting(" lua/config/lsp.lua
  [ "$status" -eq 1 ]
}

@test "lsp config does not depend on global lsp server list" {
  run grep -n "vim\\.g\\.lsp_servers" lua/config/lsp.lua
  [ "$status" -eq 1 ]
}

@test "lsp config defines explicit default servers" {
  run grep -n "lua_ls" lua/config/lsp.lua
  [ "$status" -eq 0 ]

  run grep -n "jsonls" lua/config/lsp.lua
  [ "$status" -eq 0 ]
}

@test "null-ls plugin uses the maintained none-ls repository" {
  run grep -n "nvimtools/none-ls.nvim" lua/plugins/null-ls.lua
  [ "$status" -eq 0 ]

  run grep -n "jose-elias-alvarez/null-ls.nvim" lua/plugins/null-ls.lua
  [ "$status" -eq 1 ]
}

@test "treesitter config does not install every parser indiscriminately" {
  run grep -n "ensure_installed = 'all'" lua/config/treesitter.lua
  [ "$status" -eq 1 ]
}

@test "treesitter config does not enable rainbow without a declared plugin" {
  run grep -n "rainbow =" lua/config/treesitter.lua
  [ "$status" -eq 1 ]
}

@test "treesitter config does not reference undefined custom captures" {
  run grep -n "@custom-capture" lua/config/treesitter.lua
  [ "$status" -eq 1 ]
}

@test "treesitter config does not use removed nvim-treesitter.configs module" {
  run grep -n "require.*nvim-treesitter\.configs" lua/config/treesitter.lua
  [ "$status" -eq 1 ]
}

@test "treesitter config uses FileType autocmd for highlight" {
  run grep -n "FileType" lua/config/treesitter.lua
  [ "$status" -eq 0 ]
  run grep -n "vim\.treesitter\.start" lua/config/treesitter.lua
  [ "$status" -eq 0 ]
}

@test "treesitter config adds the vendored tree-sitter CLI to PATH if present (nvim-treesitter shells out to a bare 'tree-sitter' command with no configurable path)" {
  run grep -n "vendor/tree-sitter" lua/config/treesitter.lua
  [ "$status" -eq 0 ]
  run grep -n "vim.env.PATH" lua/config/treesitter.lua
  [ "$status" -eq 0 ]
}

@test "treesitter config uses vim.treesitter.foldexpr for folds" {
  run grep -n "vim\.treesitter\.foldexpr" lua/config/treesitter.lua
  [ "$status" -eq 0 ]
}

@test "treesitter textobject keymaps use nvim-treesitter-textobjects v2 API" {
  run grep -n "nvim-treesitter-textobjects\.select\|nvim-treesitter-textobjects\.move" lua/config/treesitter.lua
  [ "$status" -eq 0 ]
}

@test "lsp plugin does not depend on diaglist anymore" {
  run grep -n "diaglist.nvim" lua/plugins/lsp.lua
  [ "$status" -eq 1 ]
}

@test "nvim-cmp config does not use deprecated mapping.close" {
  run grep -n "cmp.mapping.close" lua/config/nvim-cmp.lua
  [ "$status" -eq 1 ]
}

@test "nvim-cmp tab mappings declare insert and select modes" {
  run grep -n "{ 'i', 's' }" lua/config/nvim-cmp.lua
  [ "$status" -eq 0 ]
}

@test "lsp config defines on_attach and passes it to server setup" {
  run grep -n "on_attach" lua/config/lsp.lua
  [ "$status" -eq 0 ]
}

@test "lsp config does not use removed setup_handlers API" {
  run grep -n "setup_handlers" lua/config/lsp.lua
  [ "$status" -eq 1 ]
}

@test "lsp config uses vim.lsp.config for global server defaults" {
  run grep -n "vim.lsp.config('\*'" lua/config/lsp.lua
  [ "$status" -eq 0 ]
}

@test "lsp config does not call deprecated vim.lsp.with" {
  run grep -n "= vim\.lsp\.with(" lua/config/lsp.lua
  [ "$status" -eq 1 ]
}

@test "lsp config calls vim.diagnostic.config" {
  run grep -n "vim.diagnostic.config" lua/config/lsp.lua
  [ "$status" -eq 0 ]
}

@test "lsp config attaches nvim-navic in on_attach" {
  run grep -n "navic.attach" lua/config/lsp.lua
  [ "$status" -eq 0 ]
}

@test "lsp config extends ensure_installed with profile lsp servers" {
  run grep -n "get_lsp_servers" lua/config/lsp.lua
  [ "$status" -eq 0 ]
}

@test "null-ls config integrates profile sources" {
  run grep -n "get_null_ls_sources" lua/config/null-ls.lua
  [ "$status" -eq 0 ]
}

@test "conform plugin file exists" {
  run test -f lua/plugins/conform.lua
  [ "$status" -eq 0 ]
}

@test "conform config file exists" {
  run test -f lua/config/conform.lua
  [ "$status" -eq 0 ]
}

@test "conform config sets up format_on_save" {
  run grep -n "format_on_save" lua/config/conform.lua
  [ "$status" -eq 0 ]
}

@test "conform config maps Space f to format" {
  run grep -n "Space.*f\|<[Ss]pace>f" lua/config/conform.lua
  [ "$status" -eq 0 ]
}

@test "conform config integrates profile formatters" {
  run grep -n "get_conform_formatters" lua/config/conform.lua
  [ "$status" -eq 0 ]
}

@test "nvim-lint plugin file exists" {
  run test -f lua/plugins/nvim-lint.lua
  [ "$status" -eq 0 ]
}

@test "nvim-lint config file exists" {
  run test -f lua/config/nvim-lint.lua
  [ "$status" -eq 0 ]
}

@test "nvim-lint config triggers on BufWritePost and InsertLeave" {
  run grep -n "BufWritePost\|InsertLeave" lua/config/nvim-lint.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"BufWritePost"* ]]
  [[ "$output" == *"InsertLeave"* ]]
}

@test "nvim-lint config integrates profile linters" {
  run grep -n "get_lint_linters" lua/config/nvim-lint.lua
  [ "$status" -eq 0 ]
}

@test "plugins list loads conform" {
  run grep -n "conform" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "plugins list loads nvim-lint" {
  run grep -n "nvim-lint" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "lsp on_attach does not duplicate Space f when conform is present" {
  # '<space>f' as keymap lhs should not appear (moved to config/conform.lua)
  run grep -n "'<space>f'" lua/config/lsp.lua
  [ "$status" -ne 0 ]
}
