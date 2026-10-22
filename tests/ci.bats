#!/usr/bin/env bats

# Static guards for .github/workflows/ci.yml. They read the file as text, so
# they need no YAML parser and run anywhere.

# Prints the branch filter entries of trigger $1 (push or pull_request).
_trigger_branches() {
  awk -v t="$1" '
    /^  [a-z_]+:/ { in_trigger = ($1 == t ":"); next }
    in_trigger && /^      - / { sub(/^      - /, ""); gsub(/\047/, ""); print }
  ' .github/workflows/ci.yml
}

@test "ci runs on push only for main (a branch push and its pull request would otherwise both run CI on the same commit)" {
  run _trigger_branches push
  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}

@test "ci runs on pull requests targeting main" {
  run _trigger_branches pull_request
  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}

@test "ci can still be started by hand" {
  run grep -n "^  workflow_dispatch:" .github/workflows/ci.yml
  [ "$status" -eq 0 ]
}

@test "ci jobs keep the names Lint and Test, which the main branch ruleset requires as status checks" {
  run grep -n "^    name: Lint$" .github/workflows/ci.yml
  [ "$status" -eq 0 ]
  run grep -n "^    name: Test$" .github/workflows/ci.yml
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# Verified downloads in CI
# ---------------------------------------------------------------------------

# A fake `curl` that "downloads" a tarball containing bin/nvim, and the sha256
# of that tarball. Prints "<fake_bin_dir> <sha256>".
_fake_nvim_release() {
  local dir="$BATS_TEST_TMPDIR/fake_release" src="$BATS_TEST_TMPDIR/nvim-linux-x86_64"
  mkdir -p "$dir" "$src/bin"
  printf '#!/usr/bin/env bash\necho "NVIM fake"\n' > "$src/bin/nvim"
  chmod +x "$src/bin/nvim"
  tar -czf "$dir/nvim-linux-x86_64.tar.gz" -C "$BATS_TEST_TMPDIR" nvim-linux-x86_64
  cat > "$dir/curl" <<'CURLEOF'
#!/usr/bin/env bash
# usage seen by the script: curl ... -o <file> <url>  -> copy the fake tarball
out=""
while [ "$#" -gt 0 ]; do
  case "$1" in -o) out="$2"; shift 2 ;; *) shift ;; esac
done
cp "$(dirname "$0")/nvim-linux-x86_64.tar.gz" "$out"
CURLEOF
  chmod +x "$dir/curl"
  printf '%s %s\n' "$dir" "$(sha256sum "$dir/nvim-linux-x86_64.tar.gz" | cut -d' ' -f1)"
}

@test "install-neovim installs the release when the sha256 matches" {
  local fake sha prefix="$BATS_TEST_TMPDIR/prefix"
  read -r fake sha < <(_fake_nvim_release)
  PATH="$fake:$PATH" run scripts/ci-install-neovim v9.9.9 "$sha" "$prefix"
  [ "$status" -eq 0 ]
  [ -x "$prefix/bin/nvim" ]
}

@test "install-neovim refuses a tarball whose sha256 differs, and extracts nothing" {
  local fake sha prefix="$BATS_TEST_TMPDIR/prefix"
  read -r fake sha < <(_fake_nvim_release)
  PATH="$fake:$PATH" run scripts/ci-install-neovim v9.9.9 "0000000000000000000000000000000000000000000000000000000000000000" "$prefix"
  [ "$status" -ne 0 ]
  [[ "$output" == *"checksum"* ]]
  [ ! -e "$prefix/bin/nvim" ]
}

@test "install-neovim rejects a moving ref such as stable, and a malformed sha256" {
  run scripts/ci-install-neovim stable "$(printf 'a%.0s' {1..64})" "$BATS_TEST_TMPDIR/p"
  [ "$status" -eq 2 ]
  run scripts/ci-install-neovim v0.12.5 "abc" "$BATS_TEST_TMPDIR/p"
  [ "$status" -eq 2 ]
}

@test "ci does not install neovim from the moving 'stable' release" {
  run grep -n "releases/download/stable\|neovim.*stable" .github/workflows/ci.yml
  [ "$status" -eq 1 ]
}

@test "ci installs neovim only through the checksum-verifying script, with a pinned version and a 64-hex sha256" {
  run grep -c "scripts/ci-install-neovim" .github/workflows/ci.yml
  [ "$output" -ge 2 ]
  run grep -E "ci-install-neovim +v[0-9]+\.[0-9]+\.[0-9]+ +[0-9a-f]{64}( |$)" .github/workflows/ci.yml
  [ "$status" -eq 0 ]
  run grep -n "tar -xzf /tmp/nvim.tar.gz" .github/workflows/ci.yml
  [ "$status" -eq 1 ]
}

@test "ci pins bats-core to a full commit SHA, not to a tag (a tag can be moved)" {
  run grep -n "git clone --branch" .github/workflows/ci.yml
  [ "$status" -eq 1 ]
  run grep -E "bats-core.*[0-9a-f]{40}|[0-9a-f]{40}.*bats-core" .github/workflows/ci.yml
  [ "$status" -eq 0 ]
}

@test "every neovim version and sha256 pinned in the startup matrix is well formed" {
  run awk '/matrix:/{m=1} m && /version: /{v++} m && /sha256: /{h++} END{print v, h}' .github/workflows/ci.yml
  [ "$output" = "2 2" ]
  run grep -cE "^ +- version: v[0-9]+\.[0-9]+\.[0-9]+$" .github/workflows/ci.yml
  [ "$output" -eq 2 ]
  run grep -cE "^ +sha256: [0-9a-f]{64}$" .github/workflows/ci.yml
  [ "$output" -eq 2 ]
}

@test "the oldest neovim in the startup matrix is the minimum the init guard enforces" {
  local oldest guard
  oldest="$(grep -oP '^ +- version: v0\.\K[0-9]+' .github/workflows/ci.yml | sort -n | head -1)"
  guard="$(grep -oP 'minor *= *\K[0-9]+' lua/minimum_version.lua | head -1)"
  [ -n "$oldest" ]
  [ "$oldest" = "$guard" ]
}

@test "every action the workflow uses is pinned to a full commit SHA with its version in a trailing comment (rules/ci.md: a tag can be moved)" {
  local total pinned
  total="$(grep -cE '^ +(- )?uses: ' .github/workflows/ci.yml)"
  pinned="$(grep -cE '^ +(- )?uses: [A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+@[0-9a-f]{40} # v[0-9]+\.[0-9]+\.[0-9]+$' .github/workflows/ci.yml)"
  [ "$total" -ge 1 ]
  [ "$total" -eq "$pinned" ]
}

@test "actions/checkout is pinned to a release that runs on Node 24, v5 or newer (GitHub deprecates Node 20, which the v4 line uses and which makes every run print a warning)" {
  local majors major
  majors="$(grep -oP 'uses: actions/checkout@[0-9a-f]{40} # v\K[0-9]+' .github/workflows/ci.yml)"
  [ -n "$majors" ]
  while read -r major; do
    [ "$major" -ge 5 ] || { echo "actions/checkout v$major is still on Node 20"; return 1; }
  done <<< "$majors"
}

@test "the Test job installs the same Neovim, with the same checksum, as the newest entry of the Startup matrix, and its step name says so (CONTRIBUTING: they move together)" {
  local test_pin step_version matrix_version matrix_sha
  test_pin="$(grep -oP 'scripts/ci-install-neovim \Kv[0-9.]+ [0-9a-f]{64}' .github/workflows/ci.yml | head -1)"
  step_version="$(grep -oP 'name: Install Neovim \Kv[0-9.]+$' .github/workflows/ci.yml | head -1)"
  matrix_version="$(grep -oP '^ +- version: \Kv[0-9.]+$' .github/workflows/ci.yml | sort -V | tail -1)"
  matrix_sha="$(awk -v v="$matrix_version" '$0 ~ ("- version: " v "$") {getline; print $2}' .github/workflows/ci.yml)"
  [ -n "$test_pin" ] && [ -n "$step_version" ] && [ -n "$matrix_version" ] && [ -n "$matrix_sha" ]
  [ "$test_pin" = "$matrix_version $matrix_sha" ]
  [ "$step_version" = "$matrix_version" ]
}

@test "the startup job is not one of the checks the main ruleset requires (a network incident must not block a merge)" {
  run grep -n "^    name: Startup" .github/workflows/ci.yml
  [ "$status" -eq 0 ]
  run grep -nE "^    name: (Lint|Test)$" .github/workflows/ci.yml
  [ "${#lines[@]}" -eq 2 ]
}

@test "the full-startup script unsets VIMINIT (when set, Neovim skips init.lua and the check would silently test nothing) and is excluded from tests/run" {
  run grep -n "unset VIMINIT" tests/full-startup
  [ "$status" -eq 0 ]
  [ -x tests/full-startup ]
  run bash -c 'ls tests/*.bats | grep -c full-startup'
  [ "$output" = "0" ]
}

@test "full-startup runs on a copy of the repository, never on the repository itself (lazy.nvim rewrites lazy-lock.json in the config directory)" {
  run grep -n 'ln -s "\${repo}"' tests/full-startup
  [ "$status" -eq 1 ]
  run grep -n -- "--exclude=./.git" tests/full-startup
  [ "$status" -eq 0 ]
}

@test "every bats file that points HOME at a temp directory also clears XDG_* in setup (otherwise a test that writes under XDG_CONFIG_HOME writes into the developer's real config)" {
  local f missing=""
  for f in tests/*.bats; do
    grep -q 'export HOME="\$BATS_TEST_TMPDIR/home"' "$f" || continue
    awk '/^setup\(\) \{/,/^}/' "$f" | grep -q 'unset XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME' || missing="$missing $f"
  done
  [ -z "$missing" ] || { echo "setup() does not unset XDG_* in:$missing"; return 1; }
}

@test "cli.bats clears NVM_DIR in setup (the CLI honours an exported NVM_DIR on purpose, and GitHub's runners and many developer shells export one)" {
  run bash -c "awk '/^setup\\(\\) \\{/,/^}/' tests/cli.bats | grep -q 'unset NVM_DIR'"
  [ "$status" -eq 0 ]
}
