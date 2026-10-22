#!/usr/bin/env bash
# Prints the CHANGELOG.md section of one released version, without its heading:
# the starting point of the release notes (rules/release.md).
#   scripts/extract-changelog.sh <X.Y.Z> [changelog-file]
#   gh release create 0.10.0 --notes-file <(scripts/extract-changelog.sh 0.10.0)
# The version has no `v` prefix, like the tags. The section ends at the next
# `## [` heading or at the block of link references that closes the file; the
# blank lines around it are dropped. Exit status: 0 success, 1 section or file
# not usable, 2 wrong arguments.
set -euo pipefail

usage() {
  echo "Usage: scripts/extract-changelog.sh <X.Y.Z> [changelog-file]"
}

case "${1:-}" in
  -h | --help)
    usage
    exit 0
    ;;
esac

version="${1:-}"
changelog="${2:-}"

if [[ ! "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: version must be X.Y.Z without a 'v' prefix, got '${version}'" >&2
  usage >&2
  exit 2
fi

if [ -z "${changelog}" ]; then
  changelog="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)/CHANGELOG.md"
fi
if [ ! -f "${changelog}" ]; then
  echo "Error: changelog not found: ${changelog}" >&2
  exit 1
fi

status=0
section="$(awk -v heading="## [${version}] - " '
  index($0, heading) == 1 { found = 1; next }
  found && (/^## \[/ || /^\[[^]]+\]: /) { exit }
  found { lines[++count] = $0 }
  END {
    if (!found) exit 3
    first = 1
    while (first <= count && lines[first] ~ /^[[:space:]]*$/) first++
    last = count
    while (last >= first && lines[last] ~ /^[[:space:]]*$/) last--
    for (i = first; i <= last; i++) print lines[i]
  }
' "${changelog}")" || status=$?

if [ "${status}" -eq 3 ]; then
  echo "Error: no section [${version}] in ${changelog} (expected a heading '## [${version}] - YYYY-MM-DD')" >&2
  exit 1
fi
if [ "${status}" -ne 0 ]; then
  echo "Error: could not read ${changelog}" >&2
  exit 1
fi
if [ -z "${section}" ]; then
  echo "Error: the section [${version}] of ${changelog} is empty" >&2
  exit 1
fi

printf '%s\n' "${section}"
