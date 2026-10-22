#!/usr/bin/env bats

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
  unset XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME
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

@test "lsp config requests its servers through lsp_requirements, not through a check written for one server (json-lsp, ts_ls, pyright... are npm packages; Node.js is opt-in via install deps --with-node)" {
  run grep -n "lsp_requirements" lua/config/lsp.lua
  [ "$status" -eq 0 ]
  run grep -n "executable('npm')" lua/config/lsp.lua
  [ "$status" -eq 1 ]
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

@test "treesitter parser list includes ssh_config (sshconfig filetype maps to the ssh_config parser)" {
  run grep -n "'ssh_config'" lua/config/treesitter.lua
  [ "$status" -eq 0 ]
}

@test "treesitter config also installs the parsers declared by active profiles" {
  run grep -n "get_treesitter_parsers" lua/config/treesitter.lua
  [ "$status" -eq 0 ]
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

@test "treesitter swap keymaps use bracket motions, not Leader>a (collides with the AI which-key group prefix)" {
  run grep -n "nvim-treesitter-textobjects\.swap" lua/config/treesitter.lua
  [ "$status" -eq 0 ]
  run grep -n "'<Leader>a'\|'<Leader>A'" lua/config/treesitter.lua
  [ "$status" -eq 1 ]
  run grep -n "'\]a'" lua/config/treesitter.lua
  [ "$status" -eq 0 ]
  run grep -n "'\[a'" lua/config/treesitter.lua
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

@test "conform does not format shell scripts on save (shfmt defaults would rewrite most of an existing script), other filetypes still do" {
  # conform and profiles are stubbed so this runs without any plugin installed.
  run nvim --headless --noplugin -u NONE --cmd "set rtp+=$(pwd)" \
    -c "lua package.preload['conform'] = function() return { setup = function(o) _G.conform_opts = o end, format = function() end } end
         package.preload['profiles'] = function() return { get_conform_formatters = function() return {} end } end
         dofile('lua/config/conform.lua')
         local sh_buf, lua_buf = vim.api.nvim_create_buf(false, true), vim.api.nvim_create_buf(false, true)
         vim.bo[sh_buf].filetype = 'sh'
         vim.bo[lua_buf].filetype = 'lua'
         local on_save = _G.conform_opts.format_on_save
         io.stdout:write('SH=' .. type(on_save(sh_buf)) .. ' LUA=' .. type(on_save(lua_buf)) .. '\n')" \
    -c "qa!"
  [[ "$output" == *"SH=nil LUA=table"* ]]
}

# ---------------------------------------------------------------------------
# Language servers installed with npm are requested only when npm is available
# ---------------------------------------------------------------------------

# Runs the Lua file $1 in a headless Neovim that sees this repository's lua/
# directory, from an empty working directory (no project files, so no profile
# is detected). NPM_PRESENT=1|0 decides what vim.fn.executable('npm') answers;
# every other tool answers 0. Stubs are loaded by the probe itself.
_nvim_probe() {
  local repo="$PWD"
  mkdir -p "$BATS_TEST_TMPDIR/empty-project"
  printf '%s\n' "$1" > "$BATS_TEST_TMPDIR/probe.lua"
  cd "$BATS_TEST_TMPDIR/empty-project"
  REPO="$repo" run nvim --headless --noplugin -u NONE --cmd "set rtp+=$repo" \
    -c "lua vim.fn.executable = function(name) return (name == 'npm' and os.getenv('NPM_PRESENT') == '1') and 1 or 0 end" \
    -c "luafile $BATS_TEST_TMPDIR/probe.lua" -c "qa!"
  cd "$repo"
}

_LSP_STUBS='
local profile_servers = vim.split(os.getenv("PROFILE_SERVERS") or "", ",", { trimempty = true })
captured = nil
package.preload["profiles"] = function()
  return {
    is_active = function(name) return name == "termux" and os.getenv("TERMUX") == "1" end,
    get_lsp_servers = function() return profile_servers end,
    get_dap_mason_packages = function() return {} end,
    get_mason_packages = function() return {} end,
    install_mason_packages = function() end,
  }
end
package.preload["lspkind"] = function() return { init = function() end } end
package.preload["schemastore"] = function()
  return { json = { schemas = function() return {} end }, yaml = { schemas = function() return { sentinel = true } end } }
end
package.preload["mason"] = function() return { setup = function() end } end
package.preload["mason-lspconfig"] = function() return { setup = function(o) captured = o end } end
package.preload["mason-registry"] = function() return { get_package = function() error("unused") end } end
dofile(os.getenv("REPO") .. "/lua/config/lsp.lua")
'

@test "lsp_requirements keeps servers that need no other tool, and drops the npm ones when npm is missing" {
  NPM_PRESENT=0 _nvim_probe "local kept, skipped = require('lsp_requirements').installable({ 'lua_ls', 'jsonls', 'bashls', 'rust_analyzer' })
io.stdout:write('KEPT=' .. table.concat(kept, ',') .. ' SKIPPED=' .. table.concat(skipped, ',') .. '\n')"
  [[ "$output" == *"KEPT=lua_ls,rust_analyzer SKIPPED=jsonls,bashls"* ]]
}

@test "lsp_requirements keeps every server, in order, when npm is available" {
  NPM_PRESENT=1 _nvim_probe "local kept, skipped = require('lsp_requirements').installable({ 'lua_ls', 'jsonls', 'bashls', 'rust_analyzer' })
io.stdout:write('KEPT=' .. table.concat(kept, ',') .. ' SKIPPED=' .. table.concat(skipped, ',') .. '\n')"
  [[ "$output" == *"KEPT=lua_ls,jsonls,bashls,rust_analyzer SKIPPED="$'\n'* ]] || [[ "$output" == *"KEPT=lua_ls,jsonls,bashls,rust_analyzer SKIPPED="* ]]
  [[ "$output" != *"SKIPPED=jsonls"* ]]
}

@test "lsp_requirements keeps a server it knows nothing about (it cannot tell what it needs)" {
  NPM_PRESENT=0 _nvim_probe "local kept = require('lsp_requirements').installable({ 'some_new_server' })
io.stdout:write('KEPT=' .. table.concat(kept, ',') .. '\n')"
  [[ "$output" == *"KEPT=some_new_server"* ]]
}

@test "lsp_requirements lists the npm servers the base config and the profiles use" {
  _nvim_probe "local r = require('lsp_requirements').requires
local missing = {}
for _, s in ipairs({ 'jsonls', 'ts_ls', 'vue_ls', 'svelte', 'intelephense', 'pyright', 'bashls', 'yamlls', 'dockerls' }) do
  if r[s] ~= 'npm' then table.insert(missing, s) end
end
for _, s in ipairs({ 'lua_ls', 'rust_analyzer' }) do
  if r[s] ~= nil then table.insert(missing, s .. ' (needs nothing)') end
end
io.stdout:write('PROBLEMS=' .. table.concat(missing, ',') .. '\n')"
  [[ "$output" == *"PROBLEMS="$'\n'* ]] || [ "$(grep -o 'PROBLEMS=.*' <<< "$output")" = "PROBLEMS=" ]
}

@test "lsp config without npm asks Mason for lua_ls and the servers that are not npm packages, nothing else" {
  PROFILE_SERVERS=rust_analyzer,ts_ls,pyright,bashls,yamlls,dockerls NPM_PRESENT=0 \
    _nvim_probe "${_LSP_STUBS}
io.stdout:write('INSTALL=' .. table.concat(captured.ensure_installed, ',') .. '\n')"
  [[ "$output" == *"INSTALL=lua_ls,rust_analyzer"$'\n'* ]] || [ "$(grep -o 'INSTALL=.*' <<< "$output")" = "INSTALL=lua_ls,rust_analyzer" ]
}

@test "lsp config with npm asks Mason for the base servers first, then every server of the active profiles" {
  PROFILE_SERVERS=rust_analyzer,ts_ls,pyright,bashls,yamlls,dockerls NPM_PRESENT=1 \
    _nvim_probe "${_LSP_STUBS}
io.stdout:write('INSTALL=' .. table.concat(captured.ensure_installed, ',') .. '\n')"
  [ "$(grep -o 'INSTALL=.*' <<< "$output")" = "INSTALL=lua_ls,jsonls,rust_analyzer,ts_ls,pyright,bashls,yamlls,dockerls" ]
}

@test "lsp config on Termux still skips Mason's installs altogether, npm or not" {
  TERMUX=1 NPM_PRESENT=1 _nvim_probe "${_LSP_STUBS}
io.stdout:write('INSTALL=' .. tostring(captured.ensure_installed) .. '\n')"
  [ "$(grep -o 'INSTALL=.*' <<< "$output")" = "INSTALL=nil" ]
}

@test "bash-language-server runs with its shellcheck integration off (nvim-lint already runs shellcheck: otherwise every diagnostic appears twice)" {
  NPM_PRESENT=1 _nvim_probe "${_LSP_STUBS}
local settings = vim.lsp.config.bashls.settings
io.stdout:write('SHELLCHECK_PATH=[' .. tostring(settings.bashIde.shellcheckPath) .. ']\n')"
  [[ "$output" == *"SHELLCHECK_PATH=[]"* ]]
}

@test "yaml-language-server takes its schemas from the schemastore plugin, not from its own built-in catalogue" {
  NPM_PRESENT=1 _nvim_probe "${_LSP_STUBS}
local yaml = vim.lsp.config.yamlls.settings.yaml
io.stdout:write('STORE=' .. tostring(yaml.schemaStore.enable) .. ' SCHEMAS=' .. tostring(yaml.schemas.sentinel) .. '\n')"
  [[ "$output" == *"STORE=false SCHEMAS=true"* ]]
}

@test "switching a profile on enables only the servers that can be installed, and says which ones were left out" {
  PROFILE=devops NPM_PRESENT=0 _nvim_probe "local enabled, notices = {}, {}
vim.lsp.enable = function(servers) for _, s in ipairs(type(servers) == 'table' and servers or { servers }) do table.insert(enabled, s) end end
vim.notify = function(msg) table.insert(notices, msg) end
require('profiles').activate('devops')
io.stdout:write('ENABLED=' .. table.concat(enabled, ',') .. '\n')
io.stdout:write('NOTICE=' .. (table.concat(notices, ' | '):gsub('\n', ' / ')) .. '\n')"
  [ "$(grep -o 'ENABLED=.*' <<< "$output")" = "ENABLED=" ]
  [[ "$output" == *"NOTICE="*"yamlls (needs npm), dockerls (needs npm)"* ]]
}

@test "switching a profile on with npm available enables its language servers" {
  PROFILE=shell NPM_PRESENT=1 _nvim_probe "local enabled = {}
vim.lsp.enable = function(servers) for _, s in ipairs(type(servers) == 'table' and servers or { servers }) do table.insert(enabled, s) end end
vim.notify = function() end
require('profiles').activate('shell')
io.stdout:write('ENABLED=' .. table.concat(enabled, ',') .. '\n')"
  [ "$(grep -o 'ENABLED=.*' <<< "$output")" = "ENABLED=bashls" ]
}

@test "dockerfile-language-server leaves the three rules hadolint also checks (several CMD, ENTRYPOINT or HEALTHCHECK) to hadolint, and names every other rule: the server treats a rule it is not told about as off" {
  NPM_PRESENT=1 _nvim_probe "${_LSP_STUBS}
local d = vim.lsp.config.dockerls.settings.docker.languageserver.diagnostics
local off, on = {}, {}
for _, name in ipairs({ 'instructionCmdMultiple', 'instructionEntrypointMultiple', 'instructionHealthcheckMultiple' }) do
  if d[name] ~= 'ignore' then table.insert(off, name) end
end
for _, name in ipairs({ 'deprecatedMaintainer', 'directiveCasing', 'emptyContinuationLine', 'instructionCasing', 'instructionJSONInSingleQuotes', 'instructionWorkdirRelative' }) do
  if d[name] ~= 'warning' then table.insert(on, name) end
end
io.stdout:write('NOT_IGNORED=' .. table.concat(off, ',') .. ' NOT_WARNING=' .. table.concat(on, ',') .. '\n')"
  [[ "$output" == *"NOT_IGNORED= NOT_WARNING="* ]]
}
