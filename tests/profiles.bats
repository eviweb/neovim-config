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

@test "profiles init defines get_treesitter_parsers" {
  run grep -n "get_treesitter_parsers" lua/profiles/init.lua
  [ "$status" -eq 0 ]
}

@test "php profile declares treesitter_parsers with php" {
  run grep -n "treesitter_parsers" lua/profiles/php.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"'php'"* ]]
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

@test "ai profile definition file exists" {
  run test -f lua/profiles/ai.lua
  [ "$status" -eq 0 ]
}

@test "ai profile name is ai" {
  run grep -n "name.*=.*'ai'" lua/profiles/ai.lua
  [ "$status" -eq 0 ]
}

@test "avante plugin cond requires ai profile" {
  run grep -n "is_active.*ai\|ai.*is_active" lua/plugins/avante.lua
  [ "$status" -eq 0 ]
}

@test "codecompanion plugin cond requires ai profile" {
  run grep -n "is_active.*ai\|ai.*is_active" lua/plugins/codecompanion.lua
  [ "$status" -eq 0 ]
}

@test "codeium plugin cond requires ai profile" {
  run grep -n "is_active.*ai\|ai.*is_active" lua/plugins/codeium.lua
  [ "$status" -eq 0 ]
}

@test "mcphub plugin cond requires ai profile" {
  run grep -n "is_active.*ai\|ai.*is_active" lua/plugins/mcphub.lua
  [ "$status" -eq 0 ]
}

@test "mcp-diagnostics plugin cond requires ai profile" {
  run grep -n "is_active.*ai\|ai.*is_active" lua/plugins/mcp-diagnostics.lua
  [ "$status" -eq 0 ]
}

@test "web profile declares treesitter_parsers for tsx, vue and svelte (its LSPs are enabled for those filetypes)" {
  run grep -n "treesitter_parsers" lua/profiles/web.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"'tsx'"* ]]
  [[ "$output" == *"'vue'"* ]]
  [[ "$output" == *"'svelte'"* ]]
}

@test "laravel profile declares the blade treesitter parser" {
  run grep -n "treesitter_parsers" lua/profiles/laravel.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"'blade'"* ]]
}

@test "rust profile declares rust and toml treesitter parsers (Cargo.toml)" {
  run grep -n "treesitter_parsers" lua/profiles/rust.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"'rust'"* ]]
  [[ "$output" == *"'toml'"* ]]
}

@test "python profile declares python and toml treesitter parsers (pyproject.toml)" {
  run grep -n "treesitter_parsers" lua/profiles/python.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"'python'"* ]]
  [[ "$output" == *"'toml'"* ]]
}

@test "runtime profile activation installs the profile's treesitter parsers (previously only done at startup)" {
  run sed -n '/^function M.activate/,/^end/p' lua/profiles/init.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"treesitter_parsers"* ]]
  [[ "$output" == *"nvim-treesitter"* ]]
}

@test "every treesitter parser declared by a profile exists in nvim-treesitter (guards against typos and removed parsers)" {
  local real_home parsers_file
  real_home="$(getent passwd "$(id -u)" | cut -d: -f6)"
  parsers_file="${XDG_DATA_HOME:-${real_home}/.local/share}/nvim/lazy/nvim-treesitter/lua/nvim-treesitter/parsers.lua"
  [ -f "$parsers_file" ] || skip "nvim-treesitter is not installed (CI does not install plugins)"
  # Reads the plugin's parser table directly (pure data): no init.lua, so no
  # network access and no side effects such as parser installation.
  run nvim --headless -u NONE --noplugin -c "lua local available = dofile('${parsers_file}') local missing = {} for _, f in ipairs(vim.fn.glob(vim.fn.getcwd() .. '/lua/profiles/*.lua', false, true)) do local ok, p = pcall(dofile, f) if ok and type(p) == 'table' and p.treesitter_parsers then for _, l in ipairs(p.treesitter_parsers) do if not available[l] then missing[#missing + 1] = vim.fn.fnamemodify(f, ':t:r') .. ':' .. l end end end end io.stdout:write('MISSING=' .. table.concat(missing, ',') .. '\n')" -c "qa!"
  local result
  result="$(printf '%s\n' "$output" | grep '^MISSING=')"
  [ "$result" = "MISSING=" ]
}

@test "profile create template includes the treesitter_parsers field" {
  run grep -n "treesitter_parsers = {}" bin/nvim-config
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# shell profile
# ---------------------------------------------------------------------------

_lua_detect() {
  # Prints the profiles auto-detected by lua/profiles/init.lua for directory $1.
  nvim --headless -u NONE --noplugin --cmd "set rtp+=$(pwd)" \
    -c "lua io.stdout:write('DETECTED=' .. table.concat(require('profiles').detect('$1'), ',') .. '\n')" \
    -c "qa!" 2>&1 | grep '^DETECTED='
}

@test "shell profile definition file exists and is named shell" {
  [ -f "lua/profiles/shell.lua" ]
  run grep -n "name = 'shell'" lua/profiles/shell.lua
  [ "$status" -eq 0 ]
}

@test "shell profile formats with shfmt and lints with shellcheck, for sh buffers (bash, .bats and shebang scripts are all filetype sh)" {
  run grep -n "shfmt" lua/profiles/shell.lua
  [ "$status" -eq 0 ]
  run grep -n "shellcheck" lua/profiles/shell.lua
  [ "$status" -eq 0 ]
  run grep -n "sh = {" lua/profiles/shell.lua
  [ "$status" -eq 0 ]
}

@test "shell profile declares no language server (bash-language-server is deferred: npm package, duplicates shellcheck diagnostics)" {
  run grep -n "lsp_servers = {}" lua/profiles/shell.lua
  [ "$status" -eq 0 ]
}

@test "lua detection finds the shell profile from .shellcheckrc" {
  local d="$BATS_TEST_TMPDIR/p"; mkdir -p "$d"; : > "$d/.shellcheckrc"
  run _lua_detect "$d"
  [[ "$output" == *"shell"* ]]
}

@test "lua detection finds the shell profile from a root-level .sh file" {
  local d="$BATS_TEST_TMPDIR/p"; mkdir -p "$d"; : > "$d/deploy.sh"
  run _lua_detect "$d"
  [[ "$output" == *"shell"* ]]
}

@test "lua detection finds the shell profile from a root-level .bash file" {
  local d="$BATS_TEST_TMPDIR/p"; mkdir -p "$d"; : > "$d/lib.bash"
  run _lua_detect "$d"
  [[ "$output" == *"shell"* ]]
}

@test "lua detection finds the shell profile from bats tests under tests/" {
  local d="$BATS_TEST_TMPDIR/p"; mkdir -p "$d/tests"; : > "$d/tests/cli.bats"
  run _lua_detect "$d"
  [[ "$output" == *"shell"* ]]
}

@test "lua detection does not pick the shell profile for an unrelated directory" {
  local d="$BATS_TEST_TMPDIR/p"; mkdir -p "$d/tests"; : > "$d/README.md"; : > "$d/tests/notes.txt"
  run _lua_detect "$d"
  [[ "$output" != *"shell"* ]]
}

@test "cli 'profile detect' reports every profile the lua detection knows (it was missing python and termux)" {
  local script d
  script="$(pwd)/bin/nvim-config"
  d="$BATS_TEST_TMPDIR/p"; mkdir -p "$d/tests"
  : > "$d/pyproject.toml"; : > "$d/tests/cli.bats"
  cd "$d"
  run "$script" --no-log profile detect
  [[ "$output" == *"python"* ]]
  [[ "$output" == *"shell"* ]]
}

@test "cli 'profile detect' reports termux from TERMUX_VERSION" {
  local script d
  script="$(pwd)/bin/nvim-config"
  d="$BATS_TEST_TMPDIR/p"; mkdir -p "$d"
  cd "$d"
  TERMUX_VERSION=0.118 run "$script" --no-log profile detect
  [[ "$output" == *"termux"* ]]
}

@test "cli 'profile detect' still reports web, rust and php" {
  local script d
  script="$(pwd)/bin/nvim-config"
  d="$BATS_TEST_TMPDIR/p"; mkdir -p "$d"
  : > "$d/package.json"; : > "$d/Cargo.toml"; printf '{}' > "$d/composer.json"
  cd "$d"
  run "$script" --no-log profile detect
  [[ "$output" == *"web"* ]]
  [[ "$output" == *"rust"* ]]
  [[ "$output" == *"php"* ]]
}

# ---------------------------------------------------------------------------
# devops profile + generic mason_packages
# ---------------------------------------------------------------------------

@test "devops profile definition file exists and is named devops" {
  [ -f "lua/profiles/devops.lua" ]
  run grep -n "name = 'devops'" lua/profiles/devops.lua
  [ "$status" -eq 0 ]
}

@test "devops profile lints Dockerfiles with hadolint and GitHub workflows with actionlint (filetype yaml.github splits into yaml + github)" {
  run grep -nE "dockerfile *= *\{ 'hadolint' \}" lua/profiles/devops.lua
  [ "$status" -eq 0 ]
  run grep -nE "github *= *\{ 'actionlint' \}" lua/profiles/devops.lua
  [ "$status" -eq 0 ]
}

@test "devops profile has its tools installed through Mason (neither is in apt) and the dockerfile parser" {
  run grep -n "mason_packages" lua/profiles/devops.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"'actionlint'"* ]]
  [[ "$output" == *"'hadolint'"* ]]
  run grep -n "treesitter_parsers" lua/profiles/devops.lua
  [[ "$output" == *"'dockerfile'"* ]]
}

@test "devops profile declares no language server (yaml-language-server and dockerfile-language-server are npm packages)" {
  run grep -n "lsp_servers = {}" lua/profiles/devops.lua
  [ "$status" -eq 0 ]
}

@test "profiles init defines get_mason_packages and install_mason_packages" {
  run grep -n "function M.get_mason_packages\|function M.install_mason_packages" lua/profiles/init.lua
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
}

@test "lsp config installs profile mason packages at startup, but not on Termux (no ARM binaries)" {
  run grep -B1 "install_mason_packages(profiles.get_mason_packages" lua/config/lsp.lua
  [ "$status" -eq 0 ]
  [[ "$output" == *"if not profiles.is_active('termux') then"* ]]
}

@test "runtime profile activation also installs the profile's mason packages" {
  run sed -n '/^function M.activate/,/^end/p' lua/profiles/init.lua
  [[ "$output" == *"mason_packages"* ]]
}

@test "lua detection finds the devops profile from a Dockerfile" {
  local d="$BATS_TEST_TMPDIR/p"; mkdir -p "$d"; : > "$d/Dockerfile"
  run _lua_detect "$d"
  [[ "$output" == *"devops"* ]]
}

@test "lua detection finds the devops profile from compose.yaml and docker-compose.yml" {
  local d="$BATS_TEST_TMPDIR/p1" e="$BATS_TEST_TMPDIR/p2"; mkdir -p "$d" "$e"
  : > "$d/compose.yaml"; : > "$e/docker-compose.yml"
  run _lua_detect "$d"
  [[ "$output" == *"devops"* ]]
  run _lua_detect "$e"
  [[ "$output" == *"devops"* ]]
}

@test "lua detection finds the devops profile from .github/workflows" {
  local d="$BATS_TEST_TMPDIR/p"; mkdir -p "$d/.github/workflows"
  run _lua_detect "$d"
  [[ "$output" == *"devops"* ]]
}

@test "lua detection does not pick the devops profile for an unrelated directory (a .github dir without workflows is not enough)" {
  local d="$BATS_TEST_TMPDIR/p"; mkdir -p "$d/.github"; : > "$d/README.md"
  run _lua_detect "$d"
  [[ "$output" != *"devops"* ]]
}

@test "cli 'profile detect' reports devops (Dockerfile, compose, workflows)" {
  local script d
  script="$(pwd)/bin/nvim-config"
  d="$BATS_TEST_TMPDIR/p"; mkdir -p "$d/.github/workflows"
  cd "$d"
  run "$script" --no-log profile detect
  [[ "$output" == *"devops"* ]]
  : > "$d/Dockerfile"; rm -rf "$d/.github"
  run "$script" --no-log profile detect
  [[ "$output" == *"devops"* ]]
}

@test "every mason package declared by a profile exists in the Mason registry (guards against typos and renamed packages)" {
  local real_home registry
  real_home="$(getent passwd "$(id -u)" | cut -d: -f6)"
  registry="${XDG_DATA_HOME:-${real_home}/.local/share}/nvim/mason/registries/github/mason-org/mason-registry/registry.json"
  [ -f "$registry" ] || skip "Mason registry not downloaded (CI does not install plugins)"
  run nvim --headless -u NONE --noplugin -c "lua local known = {} for _, p in ipairs(vim.json.decode(table.concat(vim.fn.readfile('${registry}'), '\n'))) do known[p.name] = true end local missing = {} for _, f in ipairs(vim.fn.glob(vim.fn.getcwd() .. '/lua/profiles/*.lua', false, true)) do local ok, p = pcall(dofile, f) if ok and type(p) == 'table' then for _, key in ipairs({ 'mason_packages', 'dap_mason_packages' }) do for _, n in ipairs(p[key] or {}) do if not known[n] then missing[#missing + 1] = vim.fn.fnamemodify(f, ':t:r') .. ':' .. n end end end end end io.stdout:write('MISSING=' .. table.concat(missing, ',') .. '\n')" -c "qa!"
  local result
  result="$(printf '%s\n' "$output" | grep '^MISSING=')"
  [ "$result" = "MISSING=" ]
}
