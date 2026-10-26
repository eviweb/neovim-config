#!/usr/bin/env bats

# lua/treesitter_prompt.lua: offer to install a treesitter parser that is
# missing for the file being opened. nvim-treesitter, the menu and the
# notifications are stand-ins; the installation itself is checked for real in a
# separate, networked run (see the pull request).

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
  unset XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME
  export XDG_STATE_HOME="$BATS_TEST_TMPDIR/state"
  DECLINED_FILE="$XDG_STATE_HOME/nvim/treesitter-declined"
}

# Runs the Lua given as $1 in a headless Neovim that sees this repository's
# lua/ directory. The prelude stands in for nvim-treesitter (AVAILABLE and
# INSTALLED are comma lists), for the menu (CHOICE is the number picked; unset
# means the menu is dismissed), and records what happened in `calls`.
_probe() {
  local repo="$PWD"
  cat > "$BATS_TEST_TMPDIR/probe.lua" <<'EOF'
local calls = { select = {}, items = {}, install = {}, notices = {}, started = {} }
local available = vim.split(os.getenv('AVAILABLE') or 'go,java,php,bash,lua,ssh_config', ',')
local installed = vim.split(os.getenv('INSTALLED') or 'lua', ',')
local pending
package.preload['nvim-treesitter'] = function()
  return {
    get_available = function() return available end,
    get_installed = function() return installed end,
    install = function(langs)
      table.insert(calls.install, table.concat(langs, ','))
      return { await = function(_, callback) pending = callback end }
    end,
  }
end
package.preload['nvim-treesitter.config'] = function()
  return { get_install_dir = function(name) return (os.getenv('INSTALL_ROOT') or '/nonexistent/site') .. '/' .. name end }
end
local prompt = require('treesitter_prompt')
prompt.interactive = function() return os.getenv('INTERACTIVE') ~= '0' end
prompt.tools_available = function() return os.getenv('TOOLS') ~= '0' end
vim.ui.select = function(items, opts, on_choice)
  table.insert(calls.select, opts.prompt)
  calls.items = items
  local choice = tonumber(os.getenv('CHOICE'))
  on_choice(choice and items[choice] or nil, choice)
end
vim.notify = function(msg) table.insert(calls.notices, msg) end
vim.treesitter.start = function(buf) table.insert(calls.started, buf) end
local function buffer(filetype, buftype)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.bo[buf].buftype = buftype or ''
  vim.bo[buf].filetype = filetype
  return buf
end
local function settle() vim.wait(150, function() return false end, 10) end
local function finish_install(err, ok) pending(err, ok); settle() end
local function say(key, value) io.stdout:write(key .. '=' .. tostring(value) .. '\n') end
EOF
  printf '%s\n' "$1" >> "$BATS_TEST_TMPDIR/probe.lua"
  REPO="$repo" run nvim --headless --noplugin -u NONE --cmd "set rtp+=$repo" \
    -c "luafile $BATS_TEST_TMPDIR/probe.lua" -c "qa!"
}

_value() { grep -o "^$1=.*" <<< "$output" | head -1 | cut -d= -f2-; }

@test "a normal file whose parser is missing gets a question with three choices" {
  CHOICE=2 _probe "prompt.maybe_offer(buffer('go')); settle()
say('QUESTIONS', #calls.select)
say('PROMPT', calls.select[1])
say('ITEMS', table.concat(calls.items, '|'))"
  [ "$(_value QUESTIONS)" = "1" ]
  [[ "$(_value PROMPT)" == *"go"* ]]
  [ "$(_value ITEMS)" = "Install|Not now|Never for go" ]
}

@test "no question when the parser is already installed" {
  INSTALLED=lua,go _probe "prompt.maybe_offer(buffer('go')); settle()
say('QUESTIONS', #calls.select)"
  [ "$(_value QUESTIONS)" = "0" ]
}

@test "no question for a filetype nvim-treesitter has no parser for (text, qf, plugin windows)" {
  _probe "for _, ft in ipairs({ 'text', 'qf', 'TelescopePrompt', 'lazy', 'neo-tree' }) do prompt.maybe_offer(buffer(ft)) end; settle()
say('QUESTIONS', #calls.select)"
  [ "$(_value QUESTIONS)" = "0" ]
}

@test "no question for a window that is not a file, whatever its filetype (nofile, prompt, help, quickfix, acwrite, and a real terminal)" {
  _probe "for _, bt in ipairs({ 'nofile', 'prompt', 'help', 'quickfix', 'acwrite' }) do prompt.maybe_offer(buffer('go', bt)) end
local term = vim.api.nvim_create_buf(true, true)
vim.api.nvim_open_term(term, {})
say('TERMINAL_BUFTYPE', vim.bo[term].buftype)
vim.bo[term].filetype = 'go'
prompt.maybe_offer(term); settle()
say('QUESTIONS', #calls.select)"
  [ "$(_value TERMINAL_BUFTYPE)" = "terminal" ]
  [ "$(_value QUESTIONS)" = "0" ]
}

@test "no question for a buffer without a filetype" {
  _probe "prompt.maybe_offer(buffer('')); settle()
say('QUESTIONS', #calls.select)"
  [ "$(_value QUESTIONS)" = "0" ]
}

@test "no question without a user interface (headless runs, tests)" {
  INTERACTIVE=0 _probe "prompt.maybe_offer(buffer('go')); settle()
say('QUESTIONS', #calls.select)"
  [ "$(_value QUESTIONS)" = "0" ]
}

@test "no question when the installation could not work: the tree-sitter CLI, a C compiler, curl or tar is missing" {
  TOOLS=0 _probe "prompt.maybe_offer(buffer('go')); settle()
say('QUESTIONS', #calls.select)"
  [ "$(_value QUESTIONS)" = "0" ]
}

@test "the tool check needs the tree-sitter CLI, curl, tar and one C compiler (cc, gcc or clang), and nothing else" {
  run nvim --headless --noplugin -u NONE --cmd "set rtp+=$PWD" -c "lua
    local prompt = require('treesitter_prompt')
    local function with(present)
      vim.fn.executable = function(name) return present[name] and 1 or 0 end
      return tostring(prompt.tools_available())
    end
    local base = { ['tree-sitter'] = true, curl = true, tar = true }
    local function plus(extra) local t = vim.deepcopy(base) for k, v in pairs(extra) do t[k] = v end return t end
    local function without(name) local t = plus({ cc = true }) t[name] = nil return t end
    io.stdout:write(table.concat({
      'CC=' .. with(plus({ cc = true })),
      'GCC=' .. with(plus({ gcc = true })),
      'CLANG=' .. with(plus({ clang = true })),
      'NO_COMPILER=' .. with(base),
      'NO_CLI=' .. with(without('tree-sitter')),
      'NO_CURL=' .. with(without('curl')),
      'NO_TAR=' .. with(without('tar')),
    }, ' ') .. '\n')" -c "qa!"
  [[ "$output" == *"CC=true GCC=true CLANG=true NO_COMPILER=false NO_CLI=false NO_CURL=false NO_TAR=false"* ]]
}

@test "a language is asked about once per session, whatever the buffer" {
  CHOICE=2 _probe "prompt.maybe_offer(buffer('go')); settle(); prompt.maybe_offer(buffer('go')); settle()
say('QUESTIONS', #calls.select)"
  [ "$(_value QUESTIONS)" = "1" ]
}

@test "a language the configuration installs itself at startup is not offered" {
  CHOICE=2 _probe "prompt.managed = function() return { 'go', 'php' } end
prompt.maybe_offer(buffer('go')); prompt.maybe_offer(buffer('java')); settle()
say('QUESTIONS', #calls.select)
say('PROMPT', calls.select[1])"
  [ "$(_value QUESTIONS)" = "1" ]
  [[ "$(_value PROMPT)" == *"java"* ]]
}

@test "a filetype is offered under the name of its parser (sshconfig is the ssh_config parser)" {
  CHOICE=2 _probe "vim.treesitter.language.register('ssh_config', 'sshconfig')
prompt.maybe_offer(buffer('sshconfig')); settle()
say('PROMPT', calls.select[1])
say('ITEMS', table.concat(calls.items, '|'))"
  [[ "$(_value PROMPT)" == *"ssh_config"* ]]
  [ "$(_value ITEMS)" = "Install|Not now|Never for ssh_config" ]
}

@test "choosing Install installs that parser alone, then says so and starts highlighting in the buffers already open" {
  CHOICE=1 _probe "local first, second = buffer('go'), buffer('go')
prompt.maybe_offer(first); settle()
say('INSTALL_CALLS', table.concat(calls.install, ';'))
say('STARTED_BEFORE', #calls.started)
finish_install(nil, true)
say('STARTED', #calls.started)
say('NOTICES', table.concat(calls.notices, ' | '))"
  [ "$(_value INSTALL_CALLS)" = "go" ]
  [ "$(_value STARTED_BEFORE)" = "0" ]
  [ "$(_value STARTED)" = "2" ]
  [[ "$(_value NOTICES)" == *"Installing"*"go"*"installed"* ]]
}

@test "after an installation the install directory is made visible to Neovim when it is not on the runtimepath (a fresh machine has no site directory at startup, so the new parser would not be found until a restart)" {
  CHOICE=1 INSTALL_ROOT="$BATS_TEST_TMPDIR/data/site" _probe "prompt.maybe_offer(buffer('go')); settle()
say('RTP_BEFORE', tostring(vim.tbl_contains(vim.opt.runtimepath:get(), os.getenv('INSTALL_ROOT'))))
finish_install(nil, true)
say('RTP_AFTER', tostring(vim.tbl_contains(vim.opt.runtimepath:get(), os.getenv('INSTALL_ROOT'))))
say('STARTED', #calls.started)"
  [ "$(_value RTP_BEFORE)" = "false" ]
  [ "$(_value RTP_AFTER)" = "true" ]
  [ "$(_value STARTED)" = "1" ]
}

@test "a parser installed in the default site directory, which did not exist when Neovim started, is found in the same session (the directory is on the runtimepath from the start, yet Neovim does not search it until the option is assigned again)" {
  local data="$BATS_TEST_TMPDIR/fresh-data"
  [ ! -e "$data" ]
  XDG_DATA_HOME="$data" CHOICE=1 INSTALL_ROOT="$data/nvim/site" _probe "say('RTP_LISTS_IT', tostring(vim.tbl_contains(vim.opt.runtimepath:get(), os.getenv('INSTALL_ROOT'))))
prompt.maybe_offer(buffer('go')); settle()
-- the installation creates the directory and the parser
vim.fn.mkdir(os.getenv('INSTALL_ROOT') .. '/parser', 'p')
vim.fn.writefile({ 'x' }, os.getenv('INSTALL_ROOT') .. '/parser/fakelang.so')
say('VISIBLE_BEFORE', #vim.api.nvim_get_runtime_file('parser/fakelang.*', true))
finish_install(nil, true)
say('VISIBLE_AFTER', #vim.api.nvim_get_runtime_file('parser/fakelang.*', true))"
  [ "$(_value RTP_LISTS_IT)" = "true" ]
  [ "$(_value VISIBLE_BEFORE)" = "0" ]
  [ "$(_value VISIBLE_AFTER)" = "1" ]
}

@test "the install directory is not added to the runtimepath a second time when it is already there" {
  CHOICE=1 INSTALL_ROOT="$BATS_TEST_TMPDIR/data/site" _probe "vim.opt.runtimepath:prepend(os.getenv('INSTALL_ROOT'))
prompt.maybe_offer(buffer('go')); settle()
finish_install(nil, true)
local count = 0
for _, entry in ipairs(vim.opt.runtimepath:get()) do if entry == os.getenv('INSTALL_ROOT') then count = count + 1 end end
say('OCCURRENCES', count)"
  [ "$(_value OCCURRENCES)" = "1" ]
}

@test "a failed installation leaves the runtimepath alone" {
  CHOICE=1 INSTALL_ROOT="$BATS_TEST_TMPDIR/data/site" _probe "prompt.maybe_offer(buffer('go')); settle()
finish_install(nil, false)
say('RTP_AFTER', tostring(vim.tbl_contains(vim.opt.runtimepath:get(), os.getenv('INSTALL_ROOT'))))"
  [ "$(_value RTP_AFTER)" = "false" ]
}

@test "a failed installation is reported once, starts nothing, and the language is not offered again this session" {
  CHOICE=1 _probe "prompt.maybe_offer(buffer('go')); settle()
finish_install(nil, false)
prompt.maybe_offer(buffer('go')); settle()
say('STARTED', #calls.started)
say('QUESTIONS', #calls.select)
say('NOTICES', table.concat(calls.notices, ' | '))"
  [ "$(_value STARTED)" = "0" ]
  [ "$(_value QUESTIONS)" = "1" ]
  [[ "$(_value NOTICES)" == *"Could not install the go parser"* ]]
}

@test "an installation that raises an error is reported with that error" {
  CHOICE=1 _probe "prompt.maybe_offer(buffer('go')); settle()
finish_install('no network', nil)
say('STARTED', #calls.started)
say('NOTICES', table.concat(calls.notices, ' | '))"
  [ "$(_value STARTED)" = "0" ]
  [[ "$(_value NOTICES)" == *"Could not install the go parser"*"no network"* ]]
}

@test "choosing Not now installs nothing and remembers nothing on disk" {
  CHOICE=2 _probe "prompt.maybe_offer(buffer('go')); settle()
say('INSTALL_CALLS', #calls.install)"
  [ "$(_value INSTALL_CALLS)" = "0" ]
  [ ! -e "$DECLINED_FILE" ]
}

@test "dismissing the menu (Escape) counts as Not now" {
  _probe "prompt.maybe_offer(buffer('go')); settle()
say('INSTALL_CALLS', #calls.install)
say('QUESTIONS', #calls.select)"
  [ "$(_value INSTALL_CALLS)" = "0" ]
  [ "$(_value QUESTIONS)" = "1" ]
  [ ! -e "$DECLINED_FILE" ]
}

@test "choosing Never writes the language to a file in the state directory and says where, so it can be undone" {
  CHOICE=3 _probe "prompt.maybe_offer(buffer('go')); settle()
say('INSTALL_CALLS', #calls.install)
say('NOTICES', table.concat(calls.notices, ' | '))"
  [ "$(_value INSTALL_CALLS)" = "0" ]
  [ "$(cat "$DECLINED_FILE")" = "go" ]
  [[ "$(_value NOTICES)" == *"$DECLINED_FILE"* ]]
}

@test "a language declined with Never is not offered in the next session, the others still are" {
  mkdir -p "$(dirname "$DECLINED_FILE")"
  printf 'go\n' > "$DECLINED_FILE"
  CHOICE=2 _probe "prompt.maybe_offer(buffer('go')); prompt.maybe_offer(buffer('java')); settle()
say('QUESTIONS', #calls.select)
say('PROMPT', calls.select[1])"
  [ "$(_value QUESTIONS)" = "1" ]
  [[ "$(_value PROMPT)" == *"java"* ]]
}

@test "declining a second language keeps the first in the file" {
  mkdir -p "$(dirname "$DECLINED_FILE")"
  printf 'go\n' > "$DECLINED_FILE"
  CHOICE=3 _probe "prompt.maybe_offer(buffer('java')); settle()"
  [ "$(sort "$DECLINED_FILE" | tr '\n' ' ')" = "go java " ]
}

@test "the declined file tolerates blank lines, spaces and Windows line endings" {
  mkdir -p "$(dirname "$DECLINED_FILE")"
  printf '\n  go  \r\n\n' > "$DECLINED_FILE"
  CHOICE=2 _probe "prompt.maybe_offer(buffer('go')); settle()
say('QUESTIONS', #calls.select)"
  [ "$(_value QUESTIONS)" = "0" ]
}

@test "the state directory is created when the first language is declined" {
  [ ! -d "$XDG_STATE_HOME" ]
  CHOICE=3 _probe "prompt.maybe_offer(buffer('go')); settle()"
  [ -f "$DECLINED_FILE" ]
}

@test "without nvim-treesitter the module does nothing and raises no error" {
  run nvim --headless --noplugin -u NONE --cmd "set rtp+=$PWD" -c "lua
    local prompt = require('treesitter_prompt')
    prompt.interactive = function() return true end
    prompt.tools_available = function() return true end
    local buf = vim.api.nvim_create_buf(true, false)
    vim.bo[buf].filetype = 'go'
    local ok, err = pcall(prompt.maybe_offer, buf)
    vim.wait(100, function() return false end)
    io.stdout:write('OK=' .. tostring(ok) .. ' ERR=' .. tostring(err) .. '\n')" -c "qa!"
  [[ "$output" == *"OK=true"* ]]
}

@test "requiring the module changes nothing by itself (no autocommand, no install)" {
  run nvim --headless --noplugin -u NONE --cmd "set rtp+=$PWD" -c "lua
    local before = #vim.api.nvim_get_autocmds({})
    require('treesitter_prompt')
    io.stdout:write('NEW_AUTOCMDS=' .. (#vim.api.nvim_get_autocmds({}) - before) .. '\n')" -c "qa!"
  [[ "$output" == *"NEW_AUTOCMDS=0"* ]]
}

@test "the treesitter config offers missing parsers on FileType, and keeps out of it the parsers it installs itself" {
  run grep -n "treesitter_prompt" lua/config/treesitter.lua
  [ "$status" -eq 0 ]
  run grep -n "maybe_offer" lua/config/treesitter.lua
  [ "$status" -eq 0 ]
  run grep -n "managed" lua/config/treesitter.lua
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# The parsers installed at startup are usable in the session that installs them
# (lua/treesitter_install.lua)
# ---------------------------------------------------------------------------

@test "once the startup install is done, the buffers of the languages it installed get highlighting without a restart" {
  _probe "local installer = require('treesitter_install')
buffer('php'); buffer('php'); buffer('java')
installer.install({ 'php', 'lua' })
say('INSTALL_CALLS', table.concat(calls.install, ';'))
say('STARTED_BEFORE', #calls.started)
table.insert(installed, 'php')
finish_install(nil, true)
say('STARTED_AFTER', #calls.started)"
  [ "$(_value INSTALL_CALLS)" = "php,lua" ]
  [ "$(_value STARTED_BEFORE)" = "0" ]
  [ "$(_value STARTED_AFTER)" = "2" ]
}

@test "when the startup install changed nothing (every parser already there) no buffer is touched and the runtimepath keeps its value" {
  INSTALLED=lua,php _probe "local installer = require('treesitter_install')
buffer('php')
local rtp = vim.o.runtimepath
installer.install({ 'php', 'lua' })
finish_install(nil, true)
say('STARTED', #calls.started)
say('RTP_UNCHANGED', tostring(vim.o.runtimepath == rtp))"
  [ "$(_value STARTED)" = "0" ]
  [ "$(_value RTP_UNCHANGED)" = "true" ]
}

@test "when only some startup parsers could be installed, only those get highlighting" {
  _probe "local installer = require('treesitter_install')
buffer('php'); buffer('java')
installer.install({ 'php', 'java' })
table.insert(installed, 'php')   -- java failed
finish_install(nil, false)
say('STARTED', #calls.started)"
  [ "$(_value STARTED)" = "1" ]
}

@test "a startup install that raises an error starts nothing and raises none of its own" {
  _probe "local installer = require('treesitter_install')
buffer('php')
installer.install({ 'php' })
finish_install('boom', nil)
say('STARTED', #calls.started)"
  [ "$(_value STARTED)" = "0" ]
  [[ "$output" != *"Error"* ]]
}

@test "on a fresh machine a parser installed at startup is found in the same session (the default site directory did not exist when Neovim started)" {
  local data="$BATS_TEST_TMPDIR/fresh-data"
  [ ! -e "$data" ]
  XDG_DATA_HOME="$data" INSTALL_ROOT="$data/nvim/site" _probe "local installer = require('treesitter_install')
buffer('php')
installer.install({ 'php' })
vim.fn.mkdir(os.getenv('INSTALL_ROOT') .. '/parser', 'p')
vim.fn.writefile({ 'x' }, os.getenv('INSTALL_ROOT') .. '/parser/fakelang.so')
say('VISIBLE_BEFORE', #vim.api.nvim_get_runtime_file('parser/fakelang.*', true))
table.insert(installed, 'php')
finish_install(nil, true)
say('VISIBLE_AFTER', #vim.api.nvim_get_runtime_file('parser/fakelang.*', true))"
  [ "$(_value VISIBLE_BEFORE)" = "0" ]
  [ "$(_value VISIBLE_AFTER)" = "1" ]
}

@test "requiring treesitter_install changes nothing by itself (no autocommand, no install)" {
  run nvim --headless --noplugin -u NONE --cmd "set rtp+=$PWD" -c "lua
    local before = #vim.api.nvim_get_autocmds({})
    require('treesitter_install')
    io.stdout:write('NEW_AUTOCMDS=' .. (#vim.api.nvim_get_autocmds({}) - before) .. '\n')" -c "qa!"
  [[ "$output" == *"NEW_AUTOCMDS=0"* ]]
}

@test "the treesitter config installs its startup parsers through treesitter_install, once, on VimEnter" {
  run grep -n "treesitter_install" lua/config/treesitter.lua
  [ "$status" -eq 0 ]
  run grep -n "require('nvim-treesitter').install(" lua/config/treesitter.lua
  [ "$status" -eq 1 ]
  run grep -c "VimEnter" lua/config/treesitter.lua
  [ "$output" -ge 1 ]
}

@test "the parser menu uses the same steps once its install is done (one place to fix)" {
  run grep -n "treesitter_install" lua/treesitter_prompt.lua
  [ "$status" -eq 0 ]
}
