#!/usr/bin/env bats

# :Cheat topics come from several sources (see lua/cheatsheets.lua). These tests
# drive the module headless, with no plugin and no installed config: the repo is
# put on the runtimepath explicitly and every directory is a temp directory.

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
  unset XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME
  export ROOT="$BATS_TEST_TMPDIR/root"
  mkdir -p "$ROOT/docs/cheatsheets" "$ROOT/docs/profile-cheatsheets/demo"
  : > "$ROOT/docs/cheatsheets/builtin.md"
  : > "$ROOT/docs/cheatsheets/shared.md"
  printf 'from-builtin\n' > "$ROOT/docs/cheatsheets/shared.md"
}

# Runs a Lua snippet with require('cheatsheets') as `c`. Extra env passes through.
_lua() {
  nvim --headless --noplugin -u NONE --cmd "set rtp+=$(pwd)" \
    -c "lua local c = require('cheatsheets'); $1" -c "qa!" 2>&1
}

@test "built-in topics are discovered from docs/cheatsheets" {
  run _lua "io.stdout:write('T=' .. table.concat(c.topics({ root = '$ROOT', profile_dirs = {}, user_dirs = {} }), ','))"
  [[ "$output" == *"T=builtin,shared"* ]]
}

@test "topics of an active profile are added" {
  : > "$ROOT/docs/profile-cheatsheets/demo/extra.md"
  run _lua "io.stdout:write('T=' .. table.concat(c.topics({ root = '$ROOT', profile_dirs = { 'docs/profile-cheatsheets/demo' }, user_dirs = {} }), ','))"
  [[ "$output" == *"T=builtin,extra,shared"* ]]
}

@test "without that profile its topics are absent" {
  : > "$ROOT/docs/profile-cheatsheets/demo/extra.md"
  run _lua "io.stdout:write('T=' .. table.concat(c.topics({ root = '$ROOT', profile_dirs = {}, user_dirs = {} }), ','))"
  [[ "$output" != *"extra"* ]]
}

@test "topics from user directories are added" {
  mkdir -p "$BATS_TEST_TMPDIR/mine"; : > "$BATS_TEST_TMPDIR/mine/mynotes.md"
  run _lua "io.stdout:write('T=' .. table.concat(c.topics({ root = '$ROOT', profile_dirs = {}, user_dirs = { '$BATS_TEST_TMPDIR/mine' } }), ','))"
  [[ "$output" == *"mynotes"* ]]
}

@test "precedence on a name clash: user over profile over built-in" {
  mkdir -p "$BATS_TEST_TMPDIR/mine"
  printf 'from-profile\n' > "$ROOT/docs/profile-cheatsheets/demo/shared.md"
  run _lua "io.stdout:write('P=' .. c.path('shared', { root = '$ROOT', profile_dirs = { 'docs/profile-cheatsheets/demo' }, user_dirs = {} }))"
  [[ "$output" == *"P=$ROOT/docs/profile-cheatsheets/demo/shared.md"* ]]
  printf 'from-user\n' > "$BATS_TEST_TMPDIR/mine/shared.md"
  run _lua "io.stdout:write('P=' .. c.path('shared', { root = '$ROOT', profile_dirs = { 'docs/profile-cheatsheets/demo' }, user_dirs = { '$BATS_TEST_TMPDIR/mine' } }))"
  [[ "$output" == *"P=$BATS_TEST_TMPDIR/mine/shared.md"* ]]
}

@test "a name clash lists the topic once" {
  printf 'x\n' > "$ROOT/docs/profile-cheatsheets/demo/shared.md"
  run _lua "io.stdout:write('T=' .. table.concat(c.topics({ root = '$ROOT', profile_dirs = { 'docs/profile-cheatsheets/demo' }, user_dirs = {} }), ','))"
  [[ "$output" == *"T=builtin,shared"* ]]
}

@test "missing directories, subdirectories and non-markdown files are ignored" {
  mkdir -p "$ROOT/docs/cheatsheets/subdir"; : > "$ROOT/docs/cheatsheets/subdir/hidden.md"
  : > "$ROOT/docs/cheatsheets/notes.txt"
  run _lua "io.stdout:write('T=' .. table.concat(c.topics({ root = '$ROOT', profile_dirs = { 'nope/missing' }, user_dirs = { '/nonexistent/dir' } }), ','))"
  [ "$status" -eq 0 ]
  [[ "$output" == *"T=builtin,shared"* ]]
}

@test "a topic name cannot escape the cheatsheet directories" {
  printf 'secret\n' > "$BATS_TEST_TMPDIR/secret.md"
  run _lua "io.stdout:write('P=' .. tostring(c.path('../secret', { root = '$ROOT', profile_dirs = {}, user_dirs = {} })))"
  [[ "$output" == *"P=nil"* ]]
  run _lua "io.stdout:write('P=' .. tostring(c.path('/etc/passwd', { root = '$ROOT', profile_dirs = {}, user_dirs = {} })))"
  [[ "$output" == *"P=nil"* ]]
}

@test "the default user directory is <config>-cheatsheets (next to the nvim config dir, XDG_CONFIG_HOME aware)" {
  mkdir -p "$BATS_TEST_TMPDIR/xdg/nvim-cheatsheets"; : > "$BATS_TEST_TMPDIR/xdg/nvim-cheatsheets/fromdefault.md"
  XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/xdg" run _lua "io.stdout:write('T=' .. table.concat(c.topics({ root = '$ROOT', profile_dirs = {} }), ','))"
  [[ "$output" == *"fromdefault"* ]]
}

@test "NVIM_CHEATSHEET_DIRS adds colon-separated directories" {
  mkdir -p "$BATS_TEST_TMPDIR/d1" "$BATS_TEST_TMPDIR/d2"; : > "$BATS_TEST_TMPDIR/d1/one.md"; : > "$BATS_TEST_TMPDIR/d2/two.md"
  NVIM_CHEATSHEET_DIRS="$BATS_TEST_TMPDIR/d1:$BATS_TEST_TMPDIR/d2" XDG_CONFIG_HOME="$BATS_TEST_TMPDIR/none" \
    run _lua "io.stdout:write('T=' .. table.concat(c.topics({ root = '$ROOT', profile_dirs = {} }), ','))"
  [[ "$output" == *"one"* ]]
  [[ "$output" == *"two"* ]]
}

@test "profiles.get_cheatsheet_dirs returns the directories of active profiles only" {
  local d="$BATS_TEST_TMPDIR/proj"; mkdir -p "$d"; printf 'shell\n' > "$d/.nvim-profile"
  run nvim --headless --noplugin -u NONE --cmd "set rtp+=$(pwd)" --cmd "cd $d" \
    -c "lua io.stdout:write('ACTIVE=' .. table.concat(require('profiles').get_cheatsheet_dirs(), ','))" -c "qa!"
  [[ "$output" == *"ACTIVE=docs/profile-cheatsheets/shell"* ]]
  rm "$d/.nvim-profile"; : > "$d/README.md"
  run nvim --headless --noplugin -u NONE --cmd "set rtp+=$(pwd)" --cmd "cd $d" \
    -c "lua io.stdout:write('ACTIVE=[' .. table.concat(require('profiles').get_cheatsheet_dirs(), ',') .. ']')" -c "qa!"
  [[ "$output" == *"ACTIVE=[]"* ]]
}

@test "every cheatsheets directory declared by a profile exists and holds at least one sheet" {
  local missing="" f dir rel
  for f in lua/profiles/*.lua; do
    while IFS= read -r rel; do
      [ -n "$rel" ] || continue
      dir="$rel"
      if ! ls "$dir"/*.md > /dev/null 2>&1; then missing="$missing $(basename "$f"):$rel"; fi
    done < <(grep -oP "cheatsheets *= *\{ *'\K[^']+" "$f")
  done
  [ -z "$missing" ] || { echo "empty or missing:$missing"; return 1; }
}

@test "the shell and devops profiles each ship a cheatsheet" {
  run grep -n "cheatsheets *= *{ *'docs/profile-cheatsheets/shell'" lua/profiles/shell.lua
  [ "$status" -eq 0 ]
  run grep -n "cheatsheets *= *{ *'docs/profile-cheatsheets/devops'" lua/profiles/devops.lua
  [ "$status" -eq 0 ]
}

@test ":Cheat resolves topics through lua/cheatsheets.lua instead of a hardcoded directory" {
  run grep -n "require('cheatsheets')" lua/commands.lua
  [ "$status" -eq 0 ]
  run grep -n "stdpath('config') .. '/docs/cheatsheets" lua/commands.lua
  [ "$status" -eq 1 ]
}

@test ":Cheat opens a profile's sheet in a floating window and refuses names that escape the directories" {
  local d="$BATS_TEST_TMPDIR/proj"; mkdir -p "$d"; printf 'shell\n' > "$d/.nvim-profile"
  # The built-in sheets are read from stdpath('config'): point it at this repo
  # explicitly rather than rely on ~/.config/nvim being installed (CI has none).
  local xdg="$BATS_TEST_TMPDIR/xdg"; mkdir -p "$xdg"; ln -s "$(pwd)" "$xdg/nvim"
  # No bare `:Cheat` here: without a topic it opens an interactive picker.
  XDG_CONFIG_HOME="$xdg" run timeout 30 nvim --headless --noplugin -u NONE --cmd "set rtp+=$(pwd)" --cmd "cd $d" \
    -c "lua require('commands'); local notes = {}; vim.notify = function(m) notes[#notes+1] = m end; vim.cmd('Cheat shell'); io.stdout:write('FLOAT=' .. tostring(vim.api.nvim_win_get_config(0).relative == 'editor') .. ' FIRST=' .. vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] .. '\n'); vim.cmd('close'); vim.cmd('Cheat ../../etc/passwd'); io.stdout:write('NOTES=' .. table.concat(notes, '|') .. '\n')" -c "qa!"
  [[ "$output" == *"FLOAT=true FIRST=# Shell profile"* ]]
  [[ "$output" == *"NOTES=Cheatsheet not found: ../../etc/passwd"* ]]
}
