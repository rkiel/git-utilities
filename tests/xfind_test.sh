#!/usr/bin/env bash
set -euo pipefail

# Keep these tests in sync with bin/bash/xfind. Behavior changes should update
# this file in the same change.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
XFIND="$ROOT/bin/bash/xfind"
TEST_ROOT="$(mktemp -d /tmp/xfind-tests.XXXXXX)"
FIXTURE="$TEST_ROOT/files"

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

make_fixture() {
  mkdir -p "$FIXTURE/.git" "$FIXTURE/lib" "$FIXTURE/node_modules/pkg"
  mkdir -p "$FIXTURE/spec" "$FIXTURE/src" "$FIXTURE/src/nested"

  printf 'foo bar application\n' >"$FIXTURE/src/app.js"
  printf 'foo bar test\n' >"$FIXTURE/src/app.spec.js"
  printf 'foo only filename\n' >"$FIXTURE/src/bar-name.txt"
  printf 'foo only nested\n' >"$FIXTURE/src/nested/other.js"
  printf 'foo bar ruby\n' >"$FIXTURE/lib/tool.rb"
  printf 'foo specification\n' >"$FIXTURE/spec/helper.rb"
  printf 'nothing relevant\n' >"$FIXTURE/README.md"
  printf 'foo hidden git\n' >"$FIXTURE/.git/config"
  printf 'foo dependency\n' >"$FIXTURE/node_modules/pkg/index.js"
}

test_help_and_errors() {
  local output status

  output="$($XFIND --help)"
  assert_contains '-n, -t, --include-type TYPE' "$output" "help documents include aliases"
  assert_contains '-N, -T, --exclude-type TYPE' "$output" "help documents exclude aliases"

  set +e
  output="$(cd "$FIXTURE" && "$XFIND" --unknown 2>&1)"
  status="$?"
  set -e
  assert_eq 2 "$status" "unknown option exits 2"
  assert_contains 'unknown option: --unknown' "$output" "unknown option explains failure"
}

test_default_file_listing() {
  local expected output sorted

  output="$(cd "$FIXTURE" && "$XFIND")"
  expected="$(
    printf '\n'
    printf '%s\n' ./README.md ./lib/tool.rb ./spec/helper.rb ./src/app.js ./src/app.spec.js ./src/bar-name.txt ./src/nested/other.js
  )"
  assert_eq "$expected" "$output" "xfind lists files in sorted order"

  sorted="$(printf '%s\n' "$output" | LC_ALL=C sort)"
  assert_eq "$sorted" "$output" "default output remains sorted"
  assert_not_contains '.git/config' "$output" "default listing excludes .git"
  assert_not_contains 'node_modules' "$output" "default listing excludes node_modules"
}

test_type_options_and_aliases() {
  local names output types

  names="$(cd "$FIXTURE" && "$XFIND" -n js -N spec.js)"
  types="$(cd "$FIXTURE" && "$XFIND" -t js -T spec.js)"
  assert_eq "$names" "$types" "type aliases match name options"
  assert_contains './src/app.js' "$types" "include type keeps JavaScript file"
  assert_contains './src/nested/other.js' "$types" "include type searches nested files"
  assert_not_contains 'app.spec.js' "$types" "exclude type removes JavaScript tests"
  assert_not_contains 'tool.rb' "$types" "include type removes other extensions"

  output="$(cd "$FIXTURE" && "$XFIND" -t js -t rb)"
  assert_contains './src/app.js' "$output" "repeated type includes JavaScript"
  assert_contains './lib/tool.rb' "$output" "repeated type includes Ruby"
}

test_path_options() {
  local output

  output="$(cd "$FIXTURE" && "$XFIND" -p src -p lib)"
  assert_contains './src/app.js' "$output" "repeated path includes src"
  assert_contains './lib/tool.rb' "$output" "repeated path includes lib"
  assert_not_contains './spec/helper.rb' "$output" "include path removes other directories"

  output="$(cd "$FIXTURE" && "$XFIND" -P spec)"
  assert_contains './src/app.js' "$output" "exclude path keeps other directories"
  assert_not_contains './spec/helper.rb' "$output" "exclude path removes spec"
}

test_content_search() {
  local output status

  output="$(cd "$FIXTURE" && "$XFIND" foo bar)"
  assert_contains './src/app.js:foo bar application' "$output" "multiple terms keep matching JavaScript line"
  assert_contains './lib/tool.rb:foo bar ruby' "$output" "multiple terms keep matching Ruby line"
  assert_not_contains 'bar-name.txt' "$output" "a filename cannot satisfy a search term"
  assert_not_contains 'other.js' "$output" "second term narrows prior results"
  assert_not_contains '.git/config' "$output" "content search honors default exclusions"
  assert_not_contains 'node_modules' "$output" "content search excludes dependencies"

  set +e
  output="$(cd "$FIXTURE" && "$XFIND" missing-term 2>&1)"
  status="$?"
  set -e
  assert_eq 1 "$status" "no matches exit 1"
  assert_eq '' "$output" "no matches produce no output"
}

test_debug_and_project_defaults() {
  local output

  output="$(cd "$FIXTURE" && "$XFIND" -d foo -t js -T spec.js)"
  assert_starts_with $'\n' "$output" "xfind prints a blank line before its output"
  assert_contains 'find . -type f' "$output" "debug displays find command"
  assert_contains '-name \*.js' "$output" "debug displays included type"
  assert_contains '\! -name \*.spec.js' "$output" "debug displays excluded type"
  assert_contains '| xargs grep --color=auto -H -- foo' "$output" "debug displays grep command"

  output="$(cd "$FIXTURE" && "$XFIND" -d foo bar application)"
  assert_contains 'grep -- foo < "$file" | grep -- bar | grep -- application' \
    "$output" "multiple terms filter file content before adding its name"
  assert_contains 'printf "%s:%s\n" "$file" "$line"' \
    "$output" "debug adds the filename after content filtering"
  assert_contains '| grep --color=auto -e foo -e bar -e application' \
    "$output" "the final grep colors every search term"

  printf '%s\n' '-t js' '-T spec.js' >"$FIXTURE/.xfind"
  output="$(cd "$FIXTURE" && "$XFIND" foo)"
  assert_contains './src/app.js' "$output" ".xfind applies included type"
  assert_not_contains 'app.spec.js' "$output" ".xfind applies excluded type"
  assert_not_contains 'tool.rb' "$output" ".xfind defaults remove other types"
}

make_fixture
run_test "help and errors" test_help_and_errors
run_test "default file listing" test_default_file_listing
run_test "type options and aliases" test_type_options_and_aliases
run_test "path options" test_path_options
run_test "content search" test_content_search
run_test "debug and project defaults" test_debug_and_project_defaults

printf 'all xfind tests passed\n'
