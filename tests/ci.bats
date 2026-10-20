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
