#!/usr/bin/env bats

# Release tooling: scripts/extract-changelog.sh, and the rules that keep VERSION,
# the CHANGELOG sections and its compare links in agreement.

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
  unset XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME
  SCRIPT="$PWD/scripts/extract-changelog.sh"
}

_write_changelog() {
  cat > "$1" <<'EOF'
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- pending thing

## [1.2.0] - 2026-02-01

### Added
- new thing

### Fixed
- a bug

## [1.1.0] - 2026-01-01

- old thing

## [1.0.0] - 2025-12-01

- first thing

[Unreleased]: https://github.com/owner/repo/compare/1.2.0...HEAD
[1.2.0]: https://github.com/owner/repo/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/owner/repo/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/owner/repo/releases/tag/1.0.0
EOF
}

# ---------------------------------------------------------------------------
# scripts/extract-changelog.sh
# ---------------------------------------------------------------------------

@test "extract-changelog prints the body of the requested version, without its heading, up to the next version" {
  _write_changelog "$BATS_TEST_TMPDIR/CHANGELOG.md"
  run "$SCRIPT" 1.2.0 "$BATS_TEST_TMPDIR/CHANGELOG.md"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "### Added" ]
  [[ "$output" == *"- new thing"* ]]
  [[ "$output" == *"- a bug"* ]]
  [[ "$output" != *"## [1.2.0]"* ]]
  [[ "$output" != *"pending thing"* ]]
  [[ "$output" != *"old thing"* ]]
}

@test "extract-changelog stops before the link block that follows the oldest section" {
  _write_changelog "$BATS_TEST_TMPDIR/CHANGELOG.md"
  run "$SCRIPT" 1.0.0 "$BATS_TEST_TMPDIR/CHANGELOG.md"
  [ "$status" -eq 0 ]
  [ "$output" = "- first thing" ]
}

@test "extract-changelog trims the blank lines around the section" {
  _write_changelog "$BATS_TEST_TMPDIR/CHANGELOG.md"
  run "$SCRIPT" 1.1.0 "$BATS_TEST_TMPDIR/CHANGELOG.md"
  [ "$output" = "- old thing" ]
}

@test "extract-changelog does not mistake 0.1.0 for 0.10.0" {
  printf '# Changelog\n\n## [0.10.0] - 2026-02-01\n\n- ten\n\n## [0.1.0] - 2026-01-01\n\n- one\n' > "$BATS_TEST_TMPDIR/CHANGELOG.md"
  run "$SCRIPT" 0.1.0 "$BATS_TEST_TMPDIR/CHANGELOG.md"
  [ "$output" = "- one" ]
}

@test "extract-changelog fails clearly when the version has no section" {
  _write_changelog "$BATS_TEST_TMPDIR/CHANGELOG.md"
  run "$SCRIPT" 9.9.9 "$BATS_TEST_TMPDIR/CHANGELOG.md"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Error: no section [9.9.9]"* ]]
}

@test "extract-changelog fails when the section is empty (a release without notes)" {
  printf '# Changelog\n\n## [1.0.0] - 2026-01-01\n\n## [0.9.0] - 2025-12-01\n\n- x\n' > "$BATS_TEST_TMPDIR/CHANGELOG.md"
  run "$SCRIPT" 1.0.0 "$BATS_TEST_TMPDIR/CHANGELOG.md"
  [ "$status" -eq 1 ]
  [[ "$output" == *"[1.0.0]"*"empty"* ]]
}

@test "extract-changelog fails when the changelog file does not exist" {
  run "$SCRIPT" 1.0.0 "$BATS_TEST_TMPDIR/nope.md"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Error: changelog not found: $BATS_TEST_TMPDIR/nope.md"* ]]
}

@test "extract-changelog rejects a missing, v-prefixed or malformed version with exit 2" {
  run "$SCRIPT"
  [ "$status" -eq 2 ]
  run "$SCRIPT" v1.2.0 "$BATS_TEST_TMPDIR/x.md"
  [ "$status" -eq 2 ]
  [[ "$output" == *"X.Y.Z"*"v1.2.0"* ]]
  run "$SCRIPT" 1.2 "$BATS_TEST_TMPDIR/x.md"
  [ "$status" -eq 2 ]
  run "$SCRIPT" Unreleased "$BATS_TEST_TMPDIR/x.md"
  [ "$status" -eq 2 ]
}

@test "extract-changelog --help prints the usage and exits 0" {
  run "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"X.Y.Z"* ]]
}

@test "extract-changelog reads the project's CHANGELOG.md by default, whatever the current directory" {
  cd "$BATS_TEST_TMPDIR"
  run "$SCRIPT" 0.10.0
  [ "$status" -eq 0 ]
  [[ "$output" == *"XDG base directories"* ]]
  [[ "$output" != "## "* ]]
}

@test "extract-changelog is executable" {
  [ -x scripts/extract-changelog.sh ]
}

# ---------------------------------------------------------------------------
# VERSION, the CHANGELOG sections and its compare links agree
# ---------------------------------------------------------------------------

# Prints one line per problem; prints nothing when the three agree.
_changelog_problems() {
  local changelog="$1" version="$2"
  local -a versions=() dates=() expected_links=()
  local line i base

  [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || echo "VERSION is not X.Y.Z: '$version'"

  while IFS= read -r line; do
    if [[ "$line" =~ ^\#\#\ \[([0-9]+\.[0-9]+\.[0-9]+)\]\ -\ ([0-9]{4}-[0-9]{2}-[0-9]{2})$ ]]; then
      versions+=("${BASH_REMATCH[1]}")
      dates+=("${BASH_REMATCH[2]}")
    elif [ "$line" != "## [Unreleased]" ]; then
      echo "malformed heading: $line"
    fi
  done < <(grep -E '^## ' "$changelog")

  [ "$(grep -m1 -E '^## ' "$changelog")" = "## [Unreleased]" ] || echo "the first section is not [Unreleased]"
  [ "$(grep -c '^## \[Unreleased\]$' "$changelog")" -eq 1 ] || echo "[Unreleased] must appear exactly once"
  [ "${#versions[@]}" -gt 0 ] || { echo "no released section"; return 0; }

  [ "${versions[0]}" = "$version" ] || echo "newest released section is [${versions[0]}] but VERSION is $version"
  [ "$(printf '%s ' "${versions[@]}")" = "$(printf '%s\n' "${versions[@]}" | sort -rV | uniq | tr '\n' ' ')" ] \
    || echo "versions are not in strictly descending order: ${versions[*]}"
  [ "$(printf '%s ' "${dates[@]}")" = "$(printf '%s\n' "${dates[@]}" | sort -r | tr '\n' ' ')" ] \
    || echo "dates are not in descending order: ${dates[*]}"
  for line in "${dates[@]}"; do
    [ "$(date -d "$line" +%F 2> /dev/null)" = "$line" ] || echo "not a real date: $line"
  done

  base="$(grep -oP '^\[Unreleased\]: \Khttps://github\.com/[^/]+/[^/]+(?=/compare/)' "$changelog")" \
    || { echo "the [Unreleased] link is missing or is not a GitHub compare link"; return 0; }
  expected_links+=("[Unreleased]: $base/compare/$version...HEAD")
  for i in "${!versions[@]}"; do
    if [ "$i" -lt $(( ${#versions[@]} - 1 )) ]; then
      expected_links+=("[${versions[$i]}]: $base/compare/${versions[$((i + 1))]}...${versions[$i]}")
    else
      expected_links+=("[${versions[$i]}]: $base/releases/tag/${versions[$i]}")
    fi
  done
  comm -23 <(printf '%s\n' "${expected_links[@]}" | sort) <(grep -E '^\[[^]]+\]: ' "$changelog" | sort) | sed 's/^/missing or wrong link: /'
  comm -13 <(printf '%s\n' "${expected_links[@]}" | sort) <(grep -E '^\[[^]]+\]: ' "$changelog" | sort) | sed 's/^/unexpected link: /'
}

# $1 sed expression that breaks the fixture, $2 VERSION to check it against, $3 expected problem
_expect_problem() {
  _write_changelog "$BATS_TEST_TMPDIR/CHANGELOG.md"
  sed -i "$1" "$BATS_TEST_TMPDIR/CHANGELOG.md"
  run _changelog_problems "$BATS_TEST_TMPDIR/CHANGELOG.md" "$2"
  [[ "$output" == *"$3"* ]] || { printf '# expected a problem containing: %s\n# got: %s\n' "$3" "$output" >&3; return 1; }
}

@test "the fixture used below is consistent (so each failure that follows is caused by its own breakage)" {
  _write_changelog "$BATS_TEST_TMPDIR/CHANGELOG.md"
  run _changelog_problems "$BATS_TEST_TMPDIR/CHANGELOG.md" 1.2.0
  [ -z "$output" ] || { printf '# %s\n' "$output" >&3; return 1; }
}

@test "VERSION, the CHANGELOG sections and its compare links of this repository agree" {
  run _changelog_problems CHANGELOG.md "$(tr -d '\n' < VERSION)"
  [ -z "$output" ] || { printf '# %s\n' "$output" >&3; return 1; }
}

@test "changelog check: VERSION ahead of the newest section is reported" {
  _expect_problem 's/x/x/' 1.3.0 "newest released section is [1.2.0] but VERSION is 1.3.0"
}

@test "changelog check: VERSION behind the newest section is reported" {
  _expect_problem 's/x/x/' 1.1.0 "newest released section is [1.2.0] but VERSION is 1.1.0"
}

@test "changelog check: a VERSION that is not X.Y.Z is reported" {
  _expect_problem 's/x/x/' v1.2.0 "VERSION is not X.Y.Z"
}

@test "changelog check: a released section above [Unreleased] is reported" {
  _expect_problem 's/^## \[Unreleased\]$/## [1.3.0] - 2026-03-01\n\n- x\n\n## [Unreleased]/' 1.3.0 "the first section is not [Unreleased]"
}

@test "changelog check: a missing [Unreleased] section is reported" {
  _expect_problem '/^## \[Unreleased\]$/d' 1.2.0 "the first section is not [Unreleased]"
}

@test "changelog check: a malformed heading is reported" {
  _expect_problem 's/^## \[1.1.0\] - 2026-01-01$/## [1.1] - 2026-01-01/' 1.2.0 "malformed heading: ## [1.1] - 2026-01-01"
}

@test "changelog check: a date that does not exist is reported" {
  _expect_problem 's/^## \[1.1.0\] - 2026-01-01$/## [1.1.0] - 2026-13-45/' 1.2.0 "not a real date: 2026-13-45"
}

@test "changelog check: sections out of order are reported" {
  _expect_problem 's/^## \[1.1.0\] - 2026-01-01$/## [1.1.0] - 2026-03-05/' 1.2.0 "dates are not in descending order"
}

@test "changelog check: a version listed twice is reported" {
  _expect_problem 's/^## \[1.0.0\] - 2025-12-01$/## [1.1.0] - 2025-12-01/' 1.2.0 "versions are not in strictly descending order"
}

@test "changelog check: a section without its compare link is reported" {
  _expect_problem '/^\[1.1.0\]: /d' 1.2.0 "missing or wrong link: [1.1.0]: https://github.com/owner/repo/compare/1.0.0...1.1.0"
}

@test "changelog check: the [Unreleased] link left on the previous version (forgotten at release time) is reported" {
  _expect_problem 's|^\[Unreleased\]: .*|[Unreleased]: https://github.com/owner/repo/compare/1.1.0...HEAD|' 1.2.0 "missing or wrong link: [Unreleased]: https://github.com/owner/repo/compare/1.2.0...HEAD"
}

@test "changelog check: a compare link that starts from the wrong version is reported" {
  _expect_problem 's|^\[1.2.0\]: .*|[1.2.0]: https://github.com/owner/repo/compare/1.0.0...1.2.0|' 1.2.0 "unexpected link: [1.2.0]: https://github.com/owner/repo/compare/1.0.0...1.2.0"
}

@test "changelog check: a link for a version that has no section is reported" {
  _expect_problem '$a [0.9.0]: https://github.com/owner/repo/compare/0.8.0...0.9.0' 1.2.0 "unexpected link: [0.9.0]"
}

@test "changelog check: the oldest version links to its release tag, not to a comparison" {
  _expect_problem 's|^\[1.0.0\]: .*|[1.0.0]: https://github.com/owner/repo/compare/0.9.0...1.0.0|' 1.2.0 "missing or wrong link: [1.0.0]: https://github.com/owner/repo/releases/tag/1.0.0"
}
