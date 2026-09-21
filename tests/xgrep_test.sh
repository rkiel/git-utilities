#!/usr/bin/env bash
set -euo pipefail

# Keep these tests in sync with bin/bash/xgrep. Behavior changes should update
# this file in the same change.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
XGREP="$ROOT/bin/bash/xgrep"
TEST_ROOT="$(mktemp -d /tmp/xgrep-tests.XXXXXX)"
REPO="$TEST_ROOT/repo"

cleanup() {
  rm -rf "$TEST_ROOT"
}

trap cleanup EXIT

assert_eq() {
  local expected="$1"
  local actual="$2"
  local message="$3"

  if [ "$expected" != "$actual" ]; then
    printf 'not ok: %s\nexpected: %s\nactual:   %s\n' \
      "$message" "$expected" "$actual" >&2
    exit 1
  fi
}

assert_contains() {
  local needle="$1"
  local haystack="$2"
  local message="$3"

  if [[ "$haystack" != *"$needle"* ]]; then
    printf 'not ok: %s\nmissing: %s\noutput:\n%s\n' \
      "$message" "$needle" "$haystack" >&2
    exit 1
  fi
}

assert_not_contains() {
  local needle="$1"
  local haystack="$2"
  local message="$3"

  if [[ "$haystack" == *"$needle"* ]]; then
    printf 'not ok: %s\nunexpected: %s\noutput:\n%s\n' \
      "$message" "$needle" "$haystack" >&2
    exit 1
  fi
}

assert_starts_with() {
  local prefix="$1"
  local value="$2"
  local message="$3"

  if [[ "$value" != "$prefix"* ]]; then
    printf 'not ok: %s\nexpected prefix: %q\noutput:\n%s\n' \
      "$message" "$prefix" "$value" >&2
    exit 1
  fi
}

run_test() {
  local name="$1"
  shift

  printf 'test: %s ... ' "$name"
  "$@"
  printf 'ok\n'
}

make_repo() {
  mkdir -p "$REPO/docs" "$REPO/scripts" "$REPO/src"
  git init -b main "$REPO" >/dev/null
  git -C "$REPO" config user.email test@example.com
  git -C "$REPO" config user.name Test

  printf 'alpha beta safe\n' >"$REPO/src/alpha.txt"
  printf 'alpha gamma safe\n' >"$REPO/src/gamma.txt"
  printf 'alpha beta blocked\n' >"$REPO/src/blocked.txt"
  printf 'delta only\n' >"$REPO/src/delta.txt"
  printf 'alpha beta docs\n' >"$REPO/docs/guide.md"
  printf 'alpha gamma ruby\n' >"$REPO/scripts/tool.rb"
  printf 'salt and pepper\n' >"$REPO/docs/words.md"

  git -C "$REPO" add .
  git -C "$REPO" commit -m initial >/dev/null
}

test_help_and_errors() {
  local output status

  output="$($XGREP --help)"
  assert_contains 'Terms are required by default' "$output" "help explains default AND behavior"
  assert_contains 'Search terms use extended regular expressions' "$output" "help documents pattern syntax"
  assert_contains 'Project defaults:' "$output" "help documents .xgrep"
  assert_contains 'A nonempty NO_COLOR disables colored output' "$output" "help documents NO_COLOR"

  set +e
  output="$(cd "$REPO" && "$XGREP" 2>&1)"
  status="$?"
  set -e
  assert_eq 2 "$status" "missing terms exit 2"
  assert_contains 'at least one search term is required' "$output" "missing terms explain failure"

  set +e
  output="$(cd "$REPO" && "$XGREP" --unknown alpha 2>&1)"
  status="$?"
  set -e
  assert_eq 2 "$status" "unknown option exits 2"
  assert_contains 'unknown option: --unknown' "$output" "unknown option explains failure"
}

test_boolean_groups() {
  local output

  output="$(cd "$REPO" && "$XGREP" alpha beta)"
  assert_contains 'src/alpha.txt' "$output" "default group requires first matching file"
  assert_contains 'src/blocked.txt' "$output" "default group includes all matching files"
  assert_not_contains 'src/gamma.txt' "$output" "default group combines terms with AND"

  output="$(cd "$REPO" && "$XGREP" or beta gamma)"
  assert_contains 'src/alpha.txt' "$output" "OR group includes beta"
  assert_contains 'src/gamma.txt' "$output" "OR group includes gamma"
  assert_not_contains 'src/delta.txt' "$output" "OR group excludes unrelated lines"

  output="$(cd "$REPO" && "$XGREP" alpha or beta gamma not blocked)"
  assert_contains 'src/alpha.txt' "$output" "combined expression includes beta"
  assert_contains 'src/gamma.txt' "$output" "combined expression includes gamma"
  assert_not_contains 'src/blocked.txt' "$output" "NOT group excludes blocked lines"

  output="$(cd "$REPO" && "$XGREP" -- --and)"
  assert_contains 'docs/words.md' "$output" "prefixed operator searches for literal word"
}

test_path_and_type_filters() {
  local output

  output="$(cd "$REPO" && "$XGREP" -t txt alpha)"
  assert_contains 'src/alpha.txt' "$output" "include type searches matching extension"
  assert_not_contains 'docs/guide.md' "$output" "include type excludes other extensions"

  output="$(cd "$REPO" && "$XGREP" -T txt alpha)"
  assert_contains 'docs/guide.md' "$output" "exclude type keeps other extensions"
  assert_contains 'scripts/tool.rb' "$output" "exclude type searches from repository root"
  assert_not_contains 'src/alpha.txt' "$output" "exclude type removes matching extension"

  output="$(cd "$REPO" && "$XGREP" -p src alpha)"
  assert_contains 'src/alpha.txt' "$output" "include path searches selected path"
  assert_not_contains 'docs/guide.md' "$output" "include path excludes other paths"

  output="$(cd "$REPO" && "$XGREP" -P src alpha)"
  assert_contains 'docs/guide.md' "$output" "exclude path keeps other paths"
  assert_not_contains 'src/alpha.txt' "$output" "exclude path removes selected path"
}

test_git_grep_modes() {
  local output status

  output="$(cd "$REPO" && "$XGREP" -i alpha)"
  assert_contains 'src/delta.txt' "$output" "invert selects non-matching line"
  assert_not_contains 'src/alpha.txt' "$output" "invert removes matching lines"

  output="$(cd "$REPO" && "$XGREP" -f alpha)"
  assert_contains 'src/delta.txt' "$output" "file mode lists files without a match"
  assert_not_contains 'src/alpha.txt' "$output" "file mode omits files with a match"

  set +e
  output="$(cd "$REPO" && "$XGREP" absent-term 2>&1)"
  status="$?"
  set -e
  assert_eq 1 "$status" "no matches preserve git grep exit status"
  assert_eq '' "$output" "no matches produce no output"
}

test_debug_and_project_defaults() {
  local output

  output="$(cd "$REPO" && unset NO_COLOR && TERM=xterm "$XGREP" -d 'alpha beta' not 'blocked value')"
  assert_starts_with $'\n' "$output" "xgrep prints a blank line before git grep output"
  assert_contains 'git grep -E -e alpha\ beta --and --not' "$output" "debug prints shell-safe command"
  assert_contains '-e blocked\ value' "$output" "debug quotes the excluded pattern"

  output="$(cd "$REPO" && TERM=xterm NO_COLOR=1 "$XGREP" -d alpha)"
  assert_contains 'git grep -E --no-color -e alpha' "$output" "NO_COLOR disables Git colors"

  output="$(cd "$REPO" && TERM=xterm NO_COLOR='' "$XGREP" -d alpha)"
  assert_not_contains '--no-color' "$output" "empty NO_COLOR leaves Git colors enabled"

  printf '%s\n' '-t txt' >"$REPO/.xgrep"
  output="$(cd "$REPO" && "$XGREP" alpha)"
  assert_contains 'src/alpha.txt' "$output" ".xgrep applies project type filter"
  assert_not_contains 'docs/guide.md' "$output" ".xgrep filter excludes other types"

  printf '%s\n' '-d' '-t txt' >"$REPO/.xgrep"
  output="$(cd "$REPO" && "$XGREP" --no-debug alpha)"
  assert_contains 'src/alpha.txt' "$output" "command line can disable project debug mode"
  assert_not_contains 'git grep -E' "$output" "disabled debug runs the search"
}

make_repo
run_test "help and errors" test_help_and_errors
run_test "Boolean groups" test_boolean_groups
run_test "path and type filters" test_path_and_type_filters
run_test "git grep modes" test_git_grep_modes
run_test "debug and project defaults" test_debug_and_project_defaults

printf 'all xgrep tests passed\n'
