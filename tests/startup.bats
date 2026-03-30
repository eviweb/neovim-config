#!/usr/bin/env bats

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_is_snap_nvim() {
  [[ "$(command -v nvim 2>/dev/null)" == /snap/* ]]
}

# ---------------------------------------------------------------------------
# Option B — Static structural integrity
#
# Verify that every require() target declared in the entry points actually
# exists on disk.  These tests catch "file was deleted but require() was not
# updated" regressions without needing a running Neovim process.
# ---------------------------------------------------------------------------

@test "every top-level require in init.lua has a matching lua file" {
  missing=""
  while IFS= read -r mod; do
    [ -f "lua/${mod}.lua" ] || missing="${missing} lua/${mod}.lua"
  done < <(grep -oP "require\('\K[^']+" init.lua)
  [ -z "$missing" ]
}

@test "every plugins.X required in plugins.lua has a matching lua file" {
  missing=""
  while IFS= read -r mod; do
    [ -f "lua/plugins/${mod}.lua" ] || missing="${missing} lua/plugins/${mod}.lua"
  done < <(grep -oP "require\('plugins\.\K[^']+" lua/plugins.lua)
  [ -z "$missing" ]
}

@test "every config.X required in bootstrap.lua has a matching lua file" {
  missing=""
  while IFS= read -r mod; do
    [ -f "lua/config/${mod}.lua" ] || missing="${missing} lua/config/${mod}.lua"
  done < <(grep -oP "require\('config\.\K[^']+" lua/bootstrap.lua)
  [ -z "$missing" ]
}

# ---------------------------------------------------------------------------
# Option A — Neovim headless startup smoke test
#
# Skipped when nvim is installed via Snap (sandbox restrictions make headless
# startup unreliable in that environment) or when NVIM_HEADLESS_TESTS_SKIP=1.
# Set NVIM_HEADLESS_TESTS_SKIP=0 to force-enable even under Snap.
# ---------------------------------------------------------------------------

@test "nvim starts headlessly without lua errors" {
  if [[ "${NVIM_HEADLESS_TESTS_SKIP:-}" == "1" ]]; then
    skip "NVIM_HEADLESS_TESTS_SKIP=1"
  fi
  if [[ "${NVIM_HEADLESS_TESTS_SKIP:-}" != "0" ]] && _is_snap_nvim; then
    skip "nvim is installed via Snap; set NVIM_HEADLESS_TESTS_SKIP=0 to override"
  fi

  local output
  output="$(nvim --headless -u init.lua +qa 2>&1 || true)"

  # Fail only on hard Lua errors (syntax errors, uncaught require failures).
  # Missing-plugin warnings from packer/pcall-guarded paths are tolerated.
  run bash -c "echo '${output}' | grep -cE 'E5108:|E5113:|stack traceback' || true"
  [ "$output" -eq 0 ]
}

@test "nvim headless startup produces no uncaught error in options.lua" {
  if [[ "${NVIM_HEADLESS_TESTS_SKIP:-}" == "1" ]]; then
    skip "NVIM_HEADLESS_TESTS_SKIP=1"
  fi
  if [[ "${NVIM_HEADLESS_TESTS_SKIP:-}" != "0" ]] && _is_snap_nvim; then
    skip "nvim is installed via Snap; set NVIM_HEADLESS_TESTS_SKIP=0 to override"
  fi

  run nvim --headless --noplugin -u NORC \
    +"luafile lua/options.lua" \
    +qa
  [ "$status" -eq 0 ]
}

@test "nvim headless startup produces no uncaught error in keymaps.lua" {
  if [[ "${NVIM_HEADLESS_TESTS_SKIP:-}" == "1" ]]; then
    skip "NVIM_HEADLESS_TESTS_SKIP=1"
  fi
  if [[ "${NVIM_HEADLESS_TESTS_SKIP:-}" != "0" ]] && _is_snap_nvim; then
    skip "nvim is installed via Snap; set NVIM_HEADLESS_TESTS_SKIP=0 to override"
  fi

  run nvim --headless --noplugin -u NORC \
    +"luafile lua/options.lua" \
    +"luafile lua/keymaps.lua" \
    +qa
  [ "$status" -eq 0 ]
}
