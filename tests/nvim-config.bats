#!/usr/bin/env bats

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
}

@test "help prints usage" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"install"* ]]
}

@test "version reads VERSION file" {
  run ./bin/nvim-config --version
  [ "$status" -eq 0 ]
  [ "$output" = "0.1.0" ]
}

@test "install dry-run prints planned commands" {
  run ./bin/nvim-config --dry-run install
  [ "$status" -eq 0 ]
  [[ "$output" == *"sudo apt update"* ]]
  [[ "$output" == *"sudo apt install curl ripgrep fd-find xsel xclip lolcat"* ]]
}

@test "show-completion bash prints completion script" {
  run ./bin/nvim-config --show-completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"_nvim_config_completions"* ]]
  [[ "$output" == *"install"* ]]
}

@test "install-completion bash writes completion file for current shell" {
  export SHELL="/usr/bin/bash"
  run ./bin/nvim-config --install-completion bash
  [ "$status" -eq 0 ]
  [ -f "$HOME/.local/share/bash-completion/completions/nvim-config" ]
}

@test "null-ls config does not reference invalid luasnip formatter" {
  run grep -n "null_ls\\.builtins\\.formatting\\.luasnip" lua/config/null-ls.lua
  [ "$status" -eq 1 ]
}

@test "nvim-tree config does not use removed open_on_setup option" {
  run grep -n "open_on_setup" lua/config/nvim-tree.lua
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
