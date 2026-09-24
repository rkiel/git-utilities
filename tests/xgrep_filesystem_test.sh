#!/usr/bin/env bash
set -euo pipefail

# Keep these tests in sync with the xgrep filesystem engine. Behavior changes
# should update this file in the same change.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
XGREP="$ROOT/bin/bash/xgrep"
TEST_ROOT="$(mktemp -d /tmp/xgrep-filesystem-tests.XXXXXX)"
FIXTURE="$TEST_ROOT/files"
FAKE_BIN="$TEST_ROOT/bin"

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

assert_file_missing() {
  local path="$1"
  local message="$2"

  if [ -e "$path" ]; then
    printf 'not ok: %s\nunexpected file: %s\n' "$message" "$path" >&2
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
  mkdir -p "$FAKE_BIN"
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    'printf "%s\n" "$@" >"$FZF_ARGS_FILE"' \
    'command cat >"$FZF_INPUT_FILE"' >"$FAKE_BIN/fzf"
  printf '%s\n' '#!/usr/bin/env bash' 'exit 0' >"$FAKE_BIN/bat"
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    'printf "%s\n" "$@" >"$LESS_ARGS_FILE"' \
    'printf "%s\n" "${LESS-}" >"$LESS_ENV_FILE"' \
    'command cat >"$LESS_INPUT_FILE"' >"$FAKE_BIN/less"
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    'cd "$PAGER_FIXTURE"' \
    'if [ "${PAGER_NO_PAGER:-}" = true ]; then' \
    '  set -- --no-pager' \
    'else' \
    '  set --' \
    'fi' \
    'PATH="$PAGER_FAKE_BIN:$PATH" NO_COLOR= TERM=xterm \' \
    '  PAGER="${PAGER_SETTING:-}" LESS= "$PAGER_XGREP" "$@" foo bar' \
    >"$FAKE_BIN/run-pager-test"
  chmod +x "$FAKE_BIN/fzf"
  chmod +x "$FAKE_BIN/bat"
  chmod +x "$FAKE_BIN/less"
  chmod +x "$FAKE_BIN/run-pager-test"

  mkdir -p "$FIXTURE/lib" "$FIXTURE/node_modules/pkg"
  mkdir -p "$FIXTURE/spec" "$FIXTURE/src" "$FIXTURE/src/nested"

  printf 'foo bar application\n' >"$FIXTURE/src/app.js"
  printf 'foo bar test\n' >"$FIXTURE/src/app.spec.js"
  printf 'foo only filename\n' >"$FIXTURE/src/bar-name.txt"
  printf 'foo only nested\n' >"$FIXTURE/src/nested/other.js"
  printf 'foo bar unusual filename\n' >"$FIXTURE/src/space name\\file.txt"
  printf 'foo on first line\nbar on second line\n' >"$FIXTURE/src/split-lines.txt"
  printf 'foo bar first\nfoo bar second\n' >"$FIXTURE/src/repeated.js"
  printf 'FOO BAR uppercase\n' >"$FIXTURE/src/uppercase.js"
  printf 'foo bar ruby\n' >"$FIXTURE/lib/tool.rb"
  printf 'foo specification\n' >"$FIXTURE/spec/helper.rb"
  printf 'nothing relevant and literal\n' >"$FIXTURE/README.md"
  printf 'foo dependency\n' >"$FIXTURE/node_modules/pkg/index.js"
  printf '\0foo bar binary\n' >"$FIXTURE/src/binary.dat"

  mkdir -p "$FIXTURE/.git"
  printf 'foo hidden git\n' >"$FIXTURE/.git/xgrep-test"
}

test_help_and_errors() {
  local output status

  output="$($XGREP --help)"
  assert_contains 'Terms are required by default and are combined with AND' "$output" "help explains Boolean defaults"
  assert_contains 'Search terms use extended regular expressions' "$output" "help documents pattern syntax"
  assert_contains 'Binary files are ignored' "$output" "help documents binary handling"
  assert_contains 'A nonempty NO_COLOR disables colored output' "$output" "help documents NO_COLOR"
  assert_contains '-i, --ignore-case' "$output" "help documents case-insensitive searching"
  assert_contains '-l, --files-with-matches' "$output" "help documents filename output"
  assert_contains '--no-pager' "$output" "help documents paging override"
  assert_contains '--fzf' "$output" "help documents interactive file selection"
  assert_contains 'bat or batcat' "$output" "help documents optional syntax highlighting"
  assert_contains 'PAGER=cat disables filesystem paging' "$output" "help documents pager environment"
  assert_not_contains '-f, --file' "$output" "help omits removed file option"
  assert_not_contains '--invert' "$output" "help omits an invert option"
  assert_contains '-t, --include-type TYPE' "$output" "help documents included types"
  assert_contains '-T, --exclude-type TYPE' "$output" "help documents excluded types"
  assert_not_contains '-n,' "$output" "help omits removed include alias"
  assert_not_contains '-N,' "$output" "help omits removed exclude alias"

  set +e
  output="$(cd "$FIXTURE" && "$XGREP" 2>&1)"
  status="$?"
  set -e
  assert_eq 2 "$status" "missing terms exit 2"
  assert_contains 'at least one search term is required' "$output" "missing terms explain failure"

  set +e
  output="$(cd "$FIXTURE" && "$XGREP" -t js 2>&1)"
  status="$?"
  set -e
  assert_eq 2 "$status" "filters without terms exit 2"
  assert_contains 'at least one search term is required' "$output" "filters without terms explain failure"

  set +e
  output="$(cd "$FIXTURE" && "$XGREP" --unknown 2>&1)"
  status="$?"
  set -e
  assert_eq 2 "$status" "unknown option exits 2"
  assert_contains 'unknown option: --unknown' "$output" "unknown option explains failure"

  set +e
  output="$(cd "$FIXTURE" && "$XGREP" -n js 2>&1)"
  status="$?"
  set -e
  assert_eq 2 "$status" "removed -n alias exits 2"
  assert_contains 'unknown option: -n' "$output" "removed -n alias explains failure"

  set +e
  output="$(cd "$FIXTURE" && "$XGREP" -f foo 2>&1)"
  status="$?"
  set -e
  assert_eq 2 "$status" "removed file option exits 2"
  assert_contains 'unknown option: -f' "$output" "removed file option explains failure"

  set +e
  output="$(cd "$FIXTURE" && "$XGREP" or 2>&1)"
  status="$?"
  set -e
  assert_eq 2 "$status" "operator without a term exits 2"
  assert_contains 'at least one search term is required' "$output" "operator without a term explains failure"
}

test_type_options() {
  local output

  output="$(cd "$FIXTURE" && "$XGREP" -t js -T spec.js foo)"
  assert_contains 'src/app.js' "$output" "include type keeps JavaScript file"
  assert_contains 'src/nested/other.js' "$output" "include type searches nested files"
  assert_not_contains 'app.spec.js' "$output" "exclude type removes JavaScript tests"
  assert_not_contains 'tool.rb' "$output" "include type removes other extensions"

  output="$(cd "$FIXTURE" && "$XGREP" -t js -t rb foo)"
  assert_contains 'src/app.js' "$output" "repeated type includes JavaScript"
  assert_contains 'lib/tool.rb' "$output" "repeated type includes Ruby"
}

test_path_options() {
  local output

  output="$(cd "$FIXTURE" && "$XGREP" -p src -p lib foo)"
  assert_contains 'src/app.js' "$output" "repeated path includes src"
  assert_contains 'lib/tool.rb' "$output" "repeated path includes lib"
  assert_not_contains 'spec/helper.rb' "$output" "include path removes other directories"

  output="$(cd "$FIXTURE" && "$XGREP" -P spec foo)"
  assert_contains 'src/app.js' "$output" "exclude path keeps other directories"
  assert_not_contains 'spec/helper.rb' "$output" "exclude path removes spec"
}

test_content_search() {
  local count output status

  output="$(cd "$FIXTURE" && "$XGREP" foo bar 2>&1)"
  assert_not_contains $'\033[' "$output" "redirected output omits ANSI color codes"
  assert_not_contains './src/' "$output" "output omits the leading dot directory"
  assert_contains 'src/app.js:foo bar application' "$output" "multiple terms keep matching JavaScript line"
  assert_contains 'lib/tool.rb:foo bar ruby' "$output" "multiple terms keep matching Ruby line"
  assert_contains 'src/space name\file.txt:foo bar unusual filename' "$output" "unusual filenames remain intact"
  assert_not_contains 'bar-name.txt' "$output" "a filename cannot satisfy a search term"
  assert_not_contains 'other.js' "$output" "second term narrows prior results"
  assert_not_contains 'split-lines.txt' "$output" "required terms must occur on the same line"
  assert_not_contains 'uppercase.js' "$output" "searches are case-sensitive by default"
  assert_not_contains '.git/config' "$output" "content search honors default exclusions"
  assert_not_contains 'node_modules' "$output" "content search excludes dependencies"
  assert_not_contains 'src/binary.dat' "$output" "filesystem engine ignores binary files"
  assert_not_contains 'Binary file' "$output" "filesystem engine suppresses binary warnings"

  output="$(cd "$FIXTURE" && "$XGREP" -i foo bar)"
  assert_contains 'src/uppercase.js:FOO BAR uppercase' "$output" "ignore-case applies to every required term"

  output="$(cd "$FIXTURE" && "$XGREP" -l foo bar)"
  assert_contains 'src/app.js' "$output" "filename mode lists files with matching lines"
  assert_not_contains 'src/app.js:' "$output" "filename mode omits matching content"
  count="$(printf '%s\n' "$output" | command grep -Fxc 'src/repeated.js')"
  assert_eq 1 "$count" "filename mode prints each matching file once"

  output="$(cd "$FIXTURE" && "$XGREP" -l foo or application specification not test)"
  assert_contains 'src/app.js' "$output" "filename mode supports combined Boolean groups"
  assert_contains 'spec/helper.rb' "$output" "filename mode includes OR alternatives"
  assert_not_contains 'src/app.spec.js' "$output" "filename mode applies NOT exclusions"

  set +e
  output="$(cd "$FIXTURE" && "$XGREP" missing-term 2>&1)"
  status="$?"
  set -e
  assert_eq 1 "$status" "no matches exit 1"
  assert_eq '' "$output" "no matches produce no output"
}

test_boolean_groups() {
  local output

  output="$(cd "$FIXTURE" && "$XGREP" foo and bar)"
  assert_contains 'src/app.js' "$output" "and switches back to the required group"
  assert_not_contains 'bar-name.txt' "$output" "required terms still apply to content only"
  assert_not_contains 'split-lines.txt' "$output" "required terms remain line based"

  output="$(cd "$FIXTURE" && "$XGREP" or application ruby)"
  assert_contains 'src/app.js' "$output" "pure OR includes its first alternative"
  assert_contains 'lib/tool.rb' "$output" "pure OR includes its second alternative"
  assert_not_contains 'spec/helper.rb' "$output" "pure OR excludes unrelated lines"

  output="$(cd "$FIXTURE" && "$XGREP" foo or application specification not test)"
  assert_contains 'src/app.js' "$output" "combined expression includes an OR alternative"
  assert_contains 'spec/helper.rb' "$output" "combined expression includes another OR alternative"
  assert_not_contains 'app.spec.js' "$output" "NOT excludes matching lines"
  assert_not_contains 'lib/tool.rb' "$output" "OR remains required when AND terms exist"

  output="$(cd "$FIXTURE" && "$XGREP" not relevant)"
  assert_contains 'src/app.js' "$output" "NOT-only search keeps nonmatching lines"
  assert_not_contains 'README.md' "$output" "NOT-only search removes matching lines"

  output="$(cd "$FIXTURE" && "$XGREP" -- --and)"
  assert_contains 'README.md:nothing relevant and literal' "$output" "prefixed operator searches for its literal word"
}

run_pager_in_terminal() {
  if command script -q -c true /dev/null >/dev/null 2>&1; then
    command script -q -c "$FAKE_BIN/run-pager-test" /dev/null >/dev/null
  else
    command script -q /dev/null "$FAKE_BIN/run-pager-test" >/dev/null
  fi
}

test_paging() {
  local args_file="$TEST_ROOT/less-args"
  local env_file="$TEST_ROOT/less-env"
  local input_file="$TEST_ROOT/less-input"
  local output pager_input

  if ! command -v script >/dev/null 2>&1; then
    printf 'skip: script is unavailable; '
    return 0
  fi

  export LESS_ARGS_FILE="$args_file"
  export LESS_ENV_FILE="$env_file"
  export LESS_INPUT_FILE="$input_file"
  export PAGER_FAKE_BIN="$FAKE_BIN"
  export PAGER_FIXTURE="$FIXTURE"
  export PAGER_NO_PAGER=false
  export PAGER_SETTING=
  export PAGER_XGREP="$XGREP"

  run_pager_in_terminal

  assert_eq '-R' "$(<"$args_file")" "filesystem paging enables ANSI colors in less"
  assert_eq 'FRX' "$(<"$env_file")" "filesystem paging uses Git-like less defaults"
  pager_input="$(<"$input_file")"
  assert_contains 'src/app.js' "$pager_input" "pager receives matching output"
  assert_contains $'\033[' "$pager_input" "pager receives colored output"

  rm -f "$args_file" "$env_file" "$input_file"
  export PAGER_SETTING=cat
  run_pager_in_terminal
  assert_file_missing "$args_file" "PAGER=cat bypasses filesystem paging"

  export PAGER_NO_PAGER=true
  export PAGER_SETTING=
  run_pager_in_terminal
  assert_file_missing "$args_file" "--no-pager bypasses filesystem paging"

  output="$(cd "$FIXTURE" && "$XGREP" --no-pager foo bar)"
  assert_contains 'src/app.js' "$output" "--no-pager prints matching output directly"
  assert_not_contains $'\033[' "$output" "redirected --no-pager output remains color-free"
}

test_fzf_mode() {
  local args_file="$TEST_ROOT/xgrep-fzf-args"
  local input_file="$TEST_ROOT/xgrep-fzf-input"
  local fzf_arguments fzf_input output

  output="$(
    cd "$FIXTURE" &&
      PATH="$FAKE_BIN:$PATH" \
      NO_COLOR= \
      TERM=xterm \
      FZF_ARGS_FILE="$args_file" \
      FZF_INPUT_FILE="$input_file" \
      "$XGREP" --fzf foo bar
  )"
  assert_eq '' "$output" "fzf owns interactive output"

  fzf_input="$(<"$input_file")"
  assert_contains 'src/app.js' "$fzf_input" "fzf receives matching filenames"
  assert_contains 'lib/tool.rb' "$fzf_input" "fzf receives every matching filename"
  assert_not_contains 'src/nested/other.js' "$fzf_input" \
    "fzf receives only complete expression matches"
  assert_not_contains 'src/app.js:' "$fzf_input" "fzf receives filenames without content"
  assert_not_contains $'\033[' "$fzf_input" "fzf receives filenames without color codes"

  fzf_arguments="$(<"$args_file")"
  assert_contains '--exit-0' "$fzf_arguments" "fzf exits when there are no candidates"
  assert_contains 'bat --color=always --style=numbers --line-range=:200 -- {}' \
    "$fzf_arguments" "fzf uses bat for syntax-highlighted previews"
  assert_contains 'enter:become(${VISUAL:-${EDITOR:-vi}} {})' "$fzf_arguments" \
    "fzf opens the selected file with the configured editor"

  output="$(cd "$FIXTURE" && PATH="$FAKE_BIN:$PATH" NO_COLOR= TERM=xterm "$XGREP" -d --fzf foo)"
  assert_contains '| xargs grep -E -I -l -- foo' "$output" \
    "debug shows implied filename mode"
  assert_contains '| fzf --exit-0 --preview' "$output" "debug shows the fzf pipeline"
  assert_contains 'bat\ --color=always' "$output" "debug shows the syntax-highlighted preview"
  assert_contains 'enter:become' "$output" "debug shows the editor binding"

  output="$(cd "$FIXTURE" && PATH="$FAKE_BIN:$PATH" NO_COLOR=1 "$XGREP" -d --fzf foo)"
  assert_contains 'head\ -n\ 200\ \{\}' "$output" "NO_COLOR selects the plain preview"
  assert_not_contains 'bat\ --color=always' "$output" "NO_COLOR disables preview highlighting"
}

test_debug_and_project_defaults() {
  local output

  output="$(cd "$FIXTURE" && unset NO_COLOR && TERM=xterm "$XGREP" -d foo -t js -T spec.js)"
  assert_starts_with 'find ' "$output" "filesystem debug output starts with find"
  assert_contains 'find . -type f' "$output" "debug displays find command"
  assert_contains '-name \*.js' "$output" "debug displays included type"
  assert_contains '\! -name \*.spec.js' "$output" "debug displays excluded type"
  assert_contains '| xargs grep -E -I --color=auto -H -- foo' "$output" "debug displays grep command"

  output="$(cd "$FIXTURE" && TERM=xterm NO_COLOR=1 "$XGREP" -d foo)"
  assert_contains '| xargs grep -E -I --color=never -H -- foo' "$output" "NO_COLOR disables grep colors"

  output="$(cd "$FIXTURE" && TERM=xterm NO_COLOR='' "$XGREP" -d foo)"
  assert_contains '| xargs grep -E -I --color=auto -H -- foo' "$output" "empty NO_COLOR leaves grep colors enabled"

  output="$(cd "$FIXTURE" && unset NO_COLOR && TERM=xterm "$XGREP" -d foo bar application)"
  assert_contains 'grep -E -I -- foo < "$file" | grep -E -I -- bar | grep -E -I -- application' \
    "$output" "multiple terms filter file content before adding its name"
  assert_contains 'printf "%s:%s\n" "$file" "$line"' \
    "$output" "debug adds the filename after content filtering"
  assert_contains '| grep -E -I --color=auto -e foo -e bar -e application' \
    "$output" "the final grep colors every search term"

  output="$(cd "$FIXTURE" && unset NO_COLOR && TERM=xterm "$XGREP" -d -i foo bar)"
  assert_contains 'grep -E -I -i -- foo < "$file" | grep -E -I -i -- bar' \
    "$output" "debug applies ignore-case to every filtering stage"
  assert_contains '| grep -E -I -i --color=auto -e foo -e bar' \
    "$output" "debug applies ignore-case to final highlighting"

  output="$(cd "$FIXTURE" && "$XGREP" -d -l foo)"
  assert_contains '| xargs grep -E -I -l -- foo' "$output" "debug displays simple filename mode"

  output="$(cd "$FIXTURE" && "$XGREP" -d -l foo or application specification not test)"
  assert_contains 'file="${file#./}"; if grep -E -I -- foo < "$file"' \
    "$output" "debug evaluates Boolean filename matches per file"
  assert_contains '> /dev/null; then printf' \
    "$output" "debug suppresses matching content in filename mode"
  assert_contains '"$file"; fi; done' \
    "$output" "debug prints each matching filename once"

  output="$(cd "$FIXTURE" && unset NO_COLOR && TERM=xterm "$XGREP" -d foo or bar application not filename nested)"
  assert_contains 'grep -E -I -- foo < "$file" | grep -E -I -e bar -e application | grep -E -I -v -e filename -e nested' \
    "$output" "debug displays AND, OR, and NOT filtering stages"
  assert_contains '| grep -E -I --color=auto -e foo -e bar -e application' \
    "$output" "debug highlights positive Boolean terms"
  assert_not_contains '| grep -E -I --color=auto -e foo -e bar -e application -e filename' \
    "$output" "debug does not highlight excluded terms"

  printf '%s\n' '-t js' '-T spec.js' >"$FIXTURE/.xgrep"
  output="$(cd "$FIXTURE" && "$XGREP" foo)"
  assert_contains 'src/app.js' "$output" ".xgrep applies included type"
  assert_not_contains 'app.spec.js' "$output" ".xgrep applies excluded type"
  assert_not_contains 'tool.rb' "$output" ".xgrep defaults remove other types"
}

make_fixture
run_test "help and errors" test_help_and_errors
run_test "type options" test_type_options
run_test "path options" test_path_options
run_test "content search" test_content_search
run_test "Boolean groups" test_boolean_groups
run_test "paging" test_paging
run_test "fzf mode" test_fzf_mode
run_test "debug and project defaults" test_debug_and_project_defaults

printf 'all xgrep filesystem tests passed\n'
