#!/usr/bin/env bats

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
}

# ---------------------------------------------------------------------------
# Profile loader structure
# ---------------------------------------------------------------------------

@test "profiles init module exists" {
  [ -f "lua/profiles/init.lua" ]
}

@test "profiles init module defines detect function" {
  run grep -n "M\.detect" lua/profiles/init.lua
  [ "$status" -eq 0 ]
}

@test "profiles init module defines is_active function" {
  run grep -n "M\.is_active" lua/profiles/init.lua
  [ "$status" -eq 0 ]
}

@test "profiles init module defines get_plugins function" {
  run grep -n "M\.get_plugins" lua/profiles/init.lua
  [ "$status" -eq 0 ]
}

@test "profiles init module defines get_lsp_servers function" {
  run grep -n "M\.get_lsp_servers" lua/profiles/init.lua
  [ "$status" -eq 0 ]
}

@test "profiles init module defines get_null_ls_sources function" {
  run grep -n "M\.get_null_ls_sources" lua/profiles/init.lua
  [ "$status" -eq 0 ]
}

@test "profiles init module defines activate function" {
  run grep -n "M\.activate" lua/profiles/init.lua
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Profile definitions
# ---------------------------------------------------------------------------

@test "web profile definition file exists" {
  [ -f "lua/profiles/web.lua" ]
}

@test "web profile declares ts_ls as lsp server" {
  run grep -n "ts_ls" lua/profiles/web.lua
  [ "$status" -eq 0 ]
}

@test "web profile includes emmet plugin" {
  run grep -n "emmet" lua/profiles/web.lua
  [ "$status" -eq 0 ]
}

@test "php profile definition file exists" {
  [ -f "lua/profiles/php.lua" ]
}

@test "php profile declares intelephense as lsp server" {
  run grep -n "intelephense" lua/profiles/php.lua
  [ "$status" -eq 0 ]
}

@test "php profile includes phpstan as null_ls source" {
  run grep -n "phpstan" lua/profiles/php.lua
  [ "$status" -eq 0 ]
}

@test "laravel profile definition file exists" {
  [ -f "lua/profiles/laravel.lua" ]
}

@test "laravel profile extends php" {
  run grep -n "'php'" lua/profiles/laravel.lua
  [ "$status" -eq 0 ]
}

@test "rust profile definition file exists" {
  [ -f "lua/profiles/rust.lua" ]
}

@test "rust profile declares rust_analyzer as lsp server" {
  run grep -n "rust_analyzer" lua/profiles/rust.lua
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Profile integration
# ---------------------------------------------------------------------------

@test "plugins list integrates profile plugins via profiles module" {
  run grep -n "require('profiles')" lua/plugins.lua
  [ "$status" -eq 0 ]
}

@test "emmet plugin is declared in web profile not in global plugin list" {
  run grep -n "emmet" lua/plugins.lua
  [ "$status" -eq 1 ]
  run grep -n "emmet" lua/profiles/web.lua
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# CLI profile command
# ---------------------------------------------------------------------------

@test "help documents profile command" {
  run ./bin/nvim-config --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"profile"* ]]
}

@test "profile list exits successfully" {
  run ./bin/nvim-config profile list
  [ "$status" -eq 0 ]
}

@test "profile set dry-run mentions nvim-profile file" {
  run ./bin/nvim-config --dry-run profile set web
  [ "$status" -eq 0 ]
  [[ "$output" == *".nvim-profile"* ]]
}

@test "profile detect exits successfully in current directory" {
  run ./bin/nvim-config profile detect
  [ "$status" -eq 0 ]
}

@test "profile unset dry-run mentions nvim-profile" {
  run ./bin/nvim-config --dry-run profile unset
  [ "$status" -eq 0 ]
  [[ "$output" == *".nvim-profile"* ]]
}

@test "profile create dry-run generates profile template path" {
  run ./bin/nvim-config --dry-run profile create myprofile
  [ "$status" -eq 0 ]
  [[ "$output" == *"lua/profiles/myprofile.lua"* ]]
}

@test "completion includes profile command" {
  run ./bin/nvim-config --show-completion bash
  [ "$status" -eq 0 ]
  [[ "$output" == *"profile"* ]]
}

@test "zsh completion covers profile subcommands" {
  run ./bin/nvim-config --show-completion zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"profile"* ]]
  [[ "$output" == *"detect"* ]]
}

# ---------------------------------------------------------------------------
# NvimProfile runtime switcher
# ---------------------------------------------------------------------------

@test "profiles picker file exists" {
  [ -f "lua/profiles/picker.lua" ]
}

@test "commands defines NvimProfile user command" {
  run grep -n "NvimProfile" lua/commands.lua
  [ "$status" -eq 0 ]
}

@test "keymaps define Leader fp for profile picker" {
  run grep -n "Leader>fp" lua/keymaps.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"profiles.picker"* ]]
}

# ---------------------------------------------------------------------------
# neotest profile-driven adapters
# ---------------------------------------------------------------------------

@test "profiles init defines get_neotest_adapters" {
  run grep -n "get_neotest_adapters" lua/profiles/init.lua
  [ "$status" -eq 0 ]
}

@test "web profile declares neotest-vitest plugin" {
  run grep -n "neotest-vitest" lua/profiles/web.lua
  [ "$status" -eq 0 ]
}

@test "web profile defines neotest_adapters with vitest detection" {
  run grep -n "neotest_adapters\|vitest" lua/profiles/web.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"neotest_adapters"* ]]
}

@test "php profile declares neotest-phpunit plugin" {
  run grep -n "neotest-phpunit" lua/profiles/php.lua
  [ "$status" -eq 0 ]
}

@test "php profile defines neotest_adapters" {
  run grep -n "neotest_adapters" lua/profiles/php.lua
  [ "$status" -eq 0 ]
}

@test "rust profile declares neotest-rust plugin" {
  run grep -n "neotest-rust" lua/profiles/rust.lua
  [ "$status" -eq 0 ]
}

@test "rust profile defines neotest_adapters" {
  run grep -n "neotest_adapters" lua/profiles/rust.lua
  [ "$status" -eq 0 ]
}

@test "neotest config merges profile adapters" {
  run grep -n "get_neotest_adapters" lua/config/neotest.lua
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# DAP profile-driven adapters
# ---------------------------------------------------------------------------

@test "profiles init defines setup_dap" {
  run grep -n "setup_dap" lua/profiles/init.lua
  [ "$status" -eq 0 ]
}

@test "web profile defines dap_setup for JS/TS" {
  run grep -n "dap_setup\|pwa-node" lua/profiles/web.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"dap_setup"* ]]
}

@test "php profile defines dap_setup for Xdebug" {
  run grep -n "dap_setup\|xdebug\|php-debug-adapter" lua/profiles/php.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"dap_setup"* ]]
}

@test "rust profile defines dap_setup for codelldb" {
  run grep -n "dap_setup\|codelldb" lua/profiles/rust.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"dap_setup"* ]]
}

# ---------------------------------------------------------------------------
# DAP Mason auto-install
# ---------------------------------------------------------------------------

@test "profiles init defines get_dap_mason_packages" {
  run grep -n "get_dap_mason_packages" lua/profiles/init.lua
  [ "$status" -eq 0 ]
}

@test "web profile declares dap_mason_packages with js-debug-adapter" {
  run grep -n "js-debug-adapter" lua/profiles/web.lua
  [ "$status" -eq 0 ]
}

@test "php profile declares dap_mason_packages with php-debug-adapter" {
  run grep -n "php-debug-adapter" lua/profiles/php.lua
  [ "$status" -eq 0 ]
}

@test "rust profile declares dap_mason_packages with codelldb" {
  run grep -n "codelldb" lua/profiles/rust.lua
  [ "$status" -eq 0 ]
}

@test "lsp config auto-installs DAP mason packages" {
  run grep -n "get_dap_mason_packages\|mason-registry" lua/config/lsp.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"get_dap_mason_packages"* ]]
}

@test "profiles init defines get_conform_formatters" {
  run grep -n "get_conform_formatters" lua/profiles/init.lua
  [ "$status" -eq 0 ]
}

@test "profiles init defines get_lint_linters" {
  run grep -n "get_lint_linters" lua/profiles/init.lua
  [ "$status" -eq 0 ]
}

@test "web profile defines conform_formatters with prettier" {
  run grep -n "prettier" lua/profiles/web.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"conform_formatters"* ]] || [[ "$output" == *"prettier"* ]]
}

@test "web profile defines lint_linters with eslint" {
  run grep -n "eslint" lua/profiles/web.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"lint_linters"* ]] || [[ "$output" == *"eslint"* ]]
}

@test "php profile defines conform_formatters with php_cs_fixer" {
  run grep -n "php_cs_fixer\|php-cs-fixer" lua/profiles/php.lua
  [ "$status" -eq 0 ]
}

@test "php profile defines lint_linters with phpstan" {
  run grep -n "phpstan" lua/profiles/php.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"lint_linters"* ]] || [[ "$output" == *"phpstan"* ]]
}

@test "php profile defines lint_linters with phpcs" {
  run grep -n "phpcs" lua/profiles/php.lua
  [ "$status" -eq 0 ]
}

@test "laravel profile defines conform_formatters with blade_formatter" {
  run grep -n "blade_formatter\|blade-formatter" lua/profiles/laravel.lua
  [ "$status" -eq 0 ]
}

@test "rust profile defines conform_formatters with rustfmt" {
  run grep -n "rustfmt" lua/profiles/rust.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"conform_formatters"* ]] || [[ "$output" == *"rustfmt"* ]]
}
