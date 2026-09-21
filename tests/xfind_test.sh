#!/usr/bin/env bash
set -euo pipefail

# Keep these tests in sync with bin/bash/xfind. Behavior changes should update
# this file in the same change.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
XFIND="$ROOT/bin/bash/xfind"
XGREP="$ROOT/bin/bash/xgrep"
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
  mkdir -p "$FIXTURE/lib" "$FIXTURE/node_modules/pkg"
  mkdir -p "$FIXTURE/spec" "$FIXTURE/src" "$FIXTURE/src/nested"

  printf 'foo bar application\n' >"$FIXTURE/src/app.js"
  printf 'foo bar test\n' >"$FIXTURE/src/app.spec.js"
  printf 'foo only filename\n' >"$FIXTURE/src/bar-name.txt"
  printf 'foo only nested\n' >"$FIXTURE/src/nested/other.js"
  printf 'foo bar unusual filename\n' >"$FIXTURE/src/space name\\file.txt"
  printf 'foo on first line\nbar on second line\n' >"$FIXTURE/src/split-lines.txt"
  printf 'foo bar ruby\n' >"$FIXTURE/lib/tool.rb"
  printf 'foo specification\n' >"$FIXTURE/spec/helper.rb"
  printf 'nothing relevant and literal\n' >"$FIXTURE/README.md"
  printf 'foo dependency\n' >"$FIXTURE/node_modules/pkg/index.js"

  git init -b main "$FIXTURE" >/dev/null
  git -C "$FIXTURE" config user.email test@example.com
  git -C "$FIXTURE" config user.name Test
  git -C "$FIXTURE" add .
  git -C "$FIXTURE" commit -m initial >/dev/null
  printf 'foo hidden git\n' >"$FIXTURE/.git/xfind-test"
}

test_help_and_errors() {
  local output status

  output="$($XFIND --help)"
  assert_contains 'Terms are required by default and are combined with AND' "$output" "help explains Boolean defaults"
  assert_contains 'A nonempty NO_COLOR disables colored output' "$output" "help documents NO_COLOR"
  assert_contains '-t, --include-type TYPE' "$output" "help documents included types"
  assert_contains '-T, --exclude-type TYPE' "$output" "help documents excluded types"
  assert_not_contains '-n,' "$output" "help omits removed include alias"
  assert_not_contains '-N,' "$output" "help omits removed exclude alias"

  set +e
  output="$(cd "$FIXTURE" && "$XFIND" --unknown 2>&1)"
  status="$?"
  set -e
  assert_eq 2 "$status" "unknown option exits 2"
  assert_contains 'unknown option: --unknown' "$output" "unknown option explains failure"

  set +e
  output="$(cd "$FIXTURE" && "$XFIND" -n js 2>&1)"
  status="$?"
  set -e
  assert_eq 2 "$status" "removed -n alias exits 2"
  assert_contains 'unknown option: -n' "$output" "removed -n alias explains failure"

  set +e
  output="$(cd "$FIXTURE" && "$XFIND" or 2>&1)"
  status="$?"
  set -e
  assert_eq 2 "$status" "operator without a term exits 2"
  assert_contains 'at least one search term is required' "$output" "operator without a term explains failure"
}

test_default_file_listing() {
  local expected output sorted

  output="$(cd "$FIXTURE" && "$XFIND")"
  expected="$(
    printf '\n'
    printf '%s\n' ./README.md ./lib/tool.rb ./spec/helper.rb ./src/app.js ./src/app.spec.js ./src/bar-name.txt ./src/nested/other.js './src/space name\file.txt' ./src/split-lines.txt
  )"
  assert_eq "$expected" "$output" "xfind lists files in sorted order"

  sorted="$(printf '%s\n' "$output" | LC_ALL=C sort)"
  assert_eq "$sorted" "$output" "default output remains sorted"
  assert_not_contains '.git/config' "$output" "default listing excludes .git"
  assert_not_contains 'node_modules' "$output" "default listing excludes node_modules"
}

test_type_options() {
  local output

  output="$(cd "$FIXTURE" && "$XFIND" -t js -T spec.js)"
  assert_contains './src/app.js' "$output" "include type keeps JavaScript file"
  assert_contains './src/nested/other.js' "$output" "include type searches nested files"
  assert_not_contains 'app.spec.js' "$output" "exclude type removes JavaScript tests"
  assert_not_contains 'tool.rb' "$output" "include type removes other extensions"

  output="$(cd "$FIXTURE" && "$XFIND" -t js -t rb)"
  assert_contains './src/app.js' "$output" "repeated type includes JavaScript"
  assert_contains './lib/tool.rb' "$output" "repeated type includes Ruby"
}

assert_search_parity() {
  local message="$1"
  local xfind_output xgrep_output
  shift

  xfind_output="$(cd "$FIXTURE" && "$XFIND" "$@" | sed 's|^\./||')"
  xgrep_output="$(cd "$FIXTURE" && "$XGREP" "$@")"
  assert_eq "$xgrep_output" "$xfind_output" "$message"
}

test_xgrep_parity() {
  assert_search_parity "required terms match xgrep" --include-type=js foo bar
  assert_search_parity "pure OR matches xgrep" -t js or application nested
  assert_search_parity "combined Boolean groups match xgrep" \
    -t js foo or application nested not test
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
  assert_not_contains $'\033[' "$output" "redirected output omits ANSI color codes"
  assert_contains './src/app.js:foo bar application' "$output" "multiple terms keep matching JavaScript line"
  assert_contains './lib/tool.rb:foo bar ruby' "$output" "multiple terms keep matching Ruby line"
  assert_contains './src/space name\file.txt:foo bar unusual filename' "$output" "unusual filenames remain intact"
  assert_not_contains 'bar-name.txt' "$output" "a filename cannot satisfy a search term"
  assert_not_contains 'other.js' "$output" "second term narrows prior results"
  assert_not_contains 'split-lines.txt' "$output" "required terms must occur on the same line"
  assert_not_contains '.git/config' "$output" "content search honors default exclusions"
  assert_not_contains 'node_modules' "$output" "content search excludes dependencies"

  set +e
  output="$(cd "$FIXTURE" && "$XFIND" missing-term 2>&1)"
  status="$?"
  set -e
  assert_eq 1 "$status" "no matches exit 1"
  assert_eq '' "$output" "no matches produce no output"
}

test_boolean_groups() {
  local output

  output="$(cd "$FIXTURE" && "$XFIND" foo and bar)"
  assert_contains './src/app.js' "$output" "and switches back to the required group"
  assert_not_contains 'bar-name.txt' "$output" "required terms still apply to content only"
  assert_not_contains 'split-lines.txt' "$output" "required terms remain line based"

  output="$(cd "$FIXTURE" && "$XFIND" or application ruby)"
  assert_contains './src/app.js' "$output" "pure OR includes its first alternative"
  assert_contains './lib/tool.rb' "$output" "pure OR includes its second alternative"
  assert_not_contains './spec/helper.rb' "$output" "pure OR excludes unrelated lines"

  output="$(cd "$FIXTURE" && "$XFIND" foo or application specification not test)"
  assert_contains './src/app.js' "$output" "combined expression includes an OR alternative"
  assert_contains './spec/helper.rb' "$output" "combined expression includes another OR alternative"
  assert_not_contains 'app.spec.js' "$output" "NOT excludes matching lines"
  assert_not_contains './lib/tool.rb' "$output" "OR remains required when AND terms exist"

  output="$(cd "$FIXTURE" && "$XFIND" not relevant)"
  assert_contains './src/app.js' "$output" "NOT-only search keeps nonmatching lines"
  assert_not_contains './README.md' "$output" "NOT-only search removes matching lines"

  output="$(cd "$FIXTURE" && "$XFIND" -- --and)"
  assert_contains './README.md:nothing relevant and literal' "$output" "prefixed operator searches for its literal word"
}

test_debug_and_project_defaults() {
  local output

  output="$(cd "$FIXTURE" && unset NO_COLOR && TERM=xterm "$XFIND" -d foo -t js -T spec.js)"
  assert_starts_with $'\n' "$output" "xfind prints a blank line before its output"
  assert_contains 'find . -type f' "$output" "debug displays find command"
  assert_contains '-name \*.js' "$output" "debug displays included type"
  assert_contains '\! -name \*.spec.js' "$output" "debug displays excluded type"
  assert_contains '| xargs grep --color=auto -H -- foo' "$output" "debug displays grep command"

  output="$(cd "$FIXTURE" && TERM=xterm NO_COLOR=1 "$XFIND" -d foo)"
  assert_contains '| xargs grep --color=never -H -- foo' "$output" "NO_COLOR disables grep colors"

  output="$(cd "$FIXTURE" && TERM=xterm NO_COLOR='' "$XFIND" -d foo)"
  assert_contains '| xargs grep --color=auto -H -- foo' "$output" "empty NO_COLOR leaves grep colors enabled"

  output="$(cd "$FIXTURE" && unset NO_COLOR && TERM=xterm "$XFIND" -d foo bar application)"
  assert_contains 'grep -- foo < "$file" | grep -- bar | grep -- application' \
    "$output" "multiple terms filter file content before adding its name"
  assert_contains 'printf "%s:%s\n" "$file" "$line"' \
    "$output" "debug adds the filename after content filtering"
  assert_contains '| grep --color=auto -e foo -e bar -e application' \
    "$output" "the final grep colors every search term"

  output="$(cd "$FIXTURE" && unset NO_COLOR && TERM=xterm "$XFIND" -d foo or bar application not filename nested)"
  assert_contains 'grep -- foo < "$file" | grep -e bar -e application | grep -v -e filename -e nested' \
    "$output" "debug displays AND, OR, and NOT filtering stages"
  assert_contains '| grep --color=auto -e foo -e bar -e application' \
    "$output" "debug highlights positive Boolean terms"
  assert_not_contains '| grep --color=auto -e foo -e bar -e application -e filename' \
    "$output" "debug does not highlight excluded terms"

  printf '%s\n' '-t js' '-T spec.js' >"$FIXTURE/.xfind"
  output="$(cd "$FIXTURE" && "$XFIND" foo)"
  assert_contains './src/app.js' "$output" ".xfind applies included type"
  assert_not_contains 'app.spec.js' "$output" ".xfind applies excluded type"
  assert_not_contains 'tool.rb' "$output" ".xfind defaults remove other types"
}

make_fixture
run_test "help and errors" test_help_and_errors
run_test "default file listing" test_default_file_listing
run_test "type options" test_type_options
run_test "path options" test_path_options
run_test "content search" test_content_search
run_test "Boolean groups" test_boolean_groups
run_test "xgrep parity" test_xgrep_parity
run_test "debug and project defaults" test_debug_and_project_defaults

printf 'all xfind tests passed\n'
