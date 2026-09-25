#!/usr/bin/env bash
set -euo pipefail

# Keep these tests in sync with bin/xgrep. Behavior changes should update
# this file in the same change.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
XGREP="$ROOT/bin/xgrep"
TEST_ROOT="$(mktemp -d /tmp/xgrep-tests.XXXXXX)"
REPO="$TEST_ROOT/repo"
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

run_test() {
  local name="$1"
  shift

  printf 'test: %s ... ' "$name"
  "$@"
  printf 'ok\n'
}

make_repo() {
  mkdir -p "$FAKE_BIN" "$REPO/docs" "$REPO/scripts" "$REPO/src" "$REPO/src,docs"
  mkdir -p "$REPO/tmp" "$REPO/src/cache/tmp" "$REPO/src/tmp" "$REPO/src/tmpish"
  printf '%s\n' \
    '#!/usr/bin/env bash' \
    'printf "%s\n" "$@" >"$FZF_ARGS_FILE"' \
    'command cat >"$FZF_INPUT_FILE"' >"$FAKE_BIN/fzf"
  printf '%s\n' '#!/usr/bin/env bash' 'exit 0' >"$FAKE_BIN/bat"
  chmod +x "$FAKE_BIN/fzf"
  chmod +x "$FAKE_BIN/bat"

  git init -b main "$REPO" >/dev/null
  git -C "$REPO" config user.email test@example.com
  git -C "$REPO" config user.name Test

  printf 'alpha beta safe\n' >"$REPO/src/alpha.txt"
  printf 'alpha gamma safe\n' >"$REPO/src/gamma.txt"
  printf 'alpha beta blocked\n' >"$REPO/src/blocked.txt"
  printf 'delta only\n' >"$REPO/src/delta.txt"
  printf 'ALPHA uppercase\n' >"$REPO/src/uppercase.txt"
  printf 'alpha beta docs\n' >"$REPO/docs/guide.md"
  printf 'alpha gamma ruby\n' >"$REPO/scripts/tool.rb"
  printf 'salt and pepper\n' >"$REPO/docs/words.md"
  printf 'alpha comma path\n' >"$REPO/src,docs/comma.txt"
  printf 'alpha root temporary\n' >"$REPO/tmp/root.txt"
  printf 'alpha nested temporary\n' >"$REPO/src/tmp/nested.txt"
  printf 'alpha nested cache temporary\n' >"$REPO/src/cache/tmp/cache.txt"
  printf 'alpha similarly named directory\n' >"$REPO/src/tmpish/keep.txt"
  printf '\0alpha beta binary\n' >"$REPO/src/binary.dat"

  git -C "$REPO" add .
  git -C "$REPO" commit -m initial >/dev/null
}

test_help_and_errors() {
  local output status

  output="$($XGREP --help)"
  assert_contains 'Terms are required by default' "$output" "help explains default AND behavior"
  assert_contains 'Inside a Git work tree' "$output" "help explains automatic engine selection"
  assert_contains 'Otherwise, search files' "$output" "help explains filesystem searching"
  assert_contains 'Search terms use extended regular expressions' "$output" "help documents pattern syntax"
  assert_contains 'Binary files are ignored' "$output" "help documents binary handling"
  assert_contains '-i, --ignore-case' "$output" "help documents case-insensitive searching"
  assert_contains '-l, --files-with-matches' "$output" "help documents filename output"
  assert_contains '--fzf' "$output" "help documents interactive file selection"
  assert_contains 'bat or batcat' "$output" "help documents optional syntax highlighting"
  assert_not_contains '-f, --file' "$output" "help omits removed file option"
  assert_contains '-p, --include-path PATH' "$output" "help documents one path per option"
  assert_contains '-t, --include-type TYPE' "$output" "help documents one type per option"
  assert_not_contains '--invert' "$output" "help omits removed invert option"
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

  set +e
  output="$(cd "$REPO" && "$XGREP" --invert alpha 2>&1)"
  status="$?"
  set -e
  assert_eq 2 "$status" "removed invert option exits 2"
  assert_contains 'unknown option: --invert' "$output" "removed invert option explains failure"

  set +e
  output="$(cd "$REPO" && "$XGREP" -f alpha 2>&1)"
  status="$?"
  set -e
  assert_eq 2 "$status" "removed file option exits 2"
  assert_contains 'unknown option: -f' "$output" "removed file option explains failure"
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

  output="$(cd "$REPO" && "$XGREP" -p src -p docs alpha)"
  assert_contains 'src/alpha.txt' "$output" "repeated paths include the first path"
  assert_contains 'docs/guide.md' "$output" "repeated paths include the second path"

  output="$(cd "$REPO" && "$XGREP" -p src,docs alpha)"
  assert_contains 'src,docs/comma.txt' "$output" "a comma remains part of one path"
  assert_not_contains 'src/alpha.txt' "$output" "comma paths are not split into multiple values"
  assert_not_contains 'docs/guide.md' "$output" "comma paths do not include a second value"

  output="$(cd "$REPO" && "$XGREP" -P src alpha)"
  assert_contains 'docs/guide.md' "$output" "exclude path keeps other paths"
  assert_not_contains 'src/alpha.txt' "$output" "exclude path removes selected path"

  output="$(cd "$REPO" && "$XGREP" -p tmp alpha)"
  assert_contains 'tmp/root.txt' "$output" "include path finds a root directory"
  assert_contains 'src/tmp/nested.txt' "$output" "include path finds a nested directory"
  assert_contains 'src/cache/tmp/cache.txt' "$output" "include path finds a deeply nested directory"
  assert_not_contains 'src/tmpish/keep.txt' "$output" "include path does not match partial directory names"

  output="$(cd "$REPO" && "$XGREP" -P tmp alpha)"
  assert_contains 'docs/guide.md' "$output" "nested exclusion keeps unrelated paths"
  assert_contains 'src/tmpish/keep.txt' "$output" "nested exclusion keeps similarly named directories"
  assert_not_contains 'tmp/root.txt' "$output" "exclude path removes a root directory"
  assert_not_contains 'src/tmp/nested.txt' "$output" "exclude path removes a nested directory"
  assert_not_contains 'src/cache/tmp/cache.txt' "$output" "exclude path removes a deeply nested directory"

  output="$(cd "$REPO" && "$XGREP" -p cache/tmp alpha)"
  assert_contains 'src/cache/tmp/cache.txt' "$output" "multi-part include path matches at any depth"
  assert_not_contains 'src/tmp/nested.txt' "$output" "multi-part include path requires the complete path"
}

test_search_modes() {
  local output status

  output="$(cd "$REPO" && "$XGREP" alpha 2>&1)"
  assert_not_contains 'src/uppercase.txt' "$output" "searches are case-sensitive by default"
  assert_not_contains 'src/binary.dat' "$output" "Git engine ignores binary files"
  assert_not_contains 'Binary file' "$output" "Git engine suppresses binary warnings"

  output="$(cd "$REPO" && "$XGREP" -i alpha)"
  assert_contains 'src/uppercase.txt:ALPHA uppercase' "$output" "ignore-case matches uppercase text"

  output="$(cd "$REPO" && "$XGREP" -l alpha beta)"
  assert_contains 'src/alpha.txt' "$output" "filename mode lists files with matching lines"
  assert_contains 'src/blocked.txt' "$output" "filename mode includes every matching file"
  assert_not_contains 'src/gamma.txt' "$output" "filename mode applies the complete expression"
  assert_not_contains 'src/alpha.txt:' "$output" "filename mode omits matching content"

  set +e
  output="$(cd "$REPO" && "$XGREP" absent-term 2>&1)"
  status="$?"
  set -e
  assert_eq 1 "$status" "no matches preserve git grep exit status"
  assert_eq '' "$output" "no matches produce no output"
}

test_fzf_mode() {
  local args_file="$TEST_ROOT/xgrep-fzf-args"
  local input_file="$TEST_ROOT/xgrep-fzf-input"
  local fzf_arguments fzf_input output

  output="$(
    cd "$REPO" &&
      PATH="$FAKE_BIN:$PATH" \
      NO_COLOR= \
      TERM=xterm \
      FZF_ARGS_FILE="$args_file" \
      FZF_INPUT_FILE="$input_file" \
      "$XGREP" --fzf alpha beta
  )"
  assert_eq '' "$output" "fzf owns interactive output"

  fzf_input="$(<"$input_file")"
  assert_contains 'src/alpha.txt' "$fzf_input" "fzf receives matching filenames"
  assert_contains 'src/blocked.txt' "$fzf_input" "fzf receives every matching filename"
  assert_not_contains 'src/gamma.txt' "$fzf_input" "fzf receives only complete expression matches"
  assert_not_contains 'src/alpha.txt:' "$fzf_input" "fzf receives filenames without content"
  assert_not_contains $'\033[' "$fzf_input" "fzf receives filenames without color codes"

  fzf_arguments="$(<"$args_file")"
  assert_contains '--exit-0' "$fzf_arguments" "fzf exits when there are no candidates"
  assert_contains 'bat --color=always --style=numbers --line-range=:200 -- {}' \
    "$fzf_arguments" "fzf uses bat for syntax-highlighted previews"
  assert_contains 'enter:become(${VISUAL:-${EDITOR:-vi}} {})' "$fzf_arguments" \
    "fzf opens the selected file with the configured editor"

  output="$(cd "$REPO" && PATH="$FAKE_BIN:$PATH" NO_COLOR= TERM=xterm "$XGREP" -d --fzf alpha)"
  assert_contains 'git grep -E -I --no-color -l -e alpha' "$output" \
    "debug shows color-free filename mode"
  assert_contains '| fzf --exit-0 --preview' "$output" "debug shows the fzf pipeline"
  assert_contains 'bat\ --color=always' "$output" "debug shows the syntax-highlighted preview"
  assert_contains 'enter:become' "$output" "debug shows the editor binding"

  output="$(cd "$REPO" && PATH="$FAKE_BIN:$PATH" NO_COLOR=1 "$XGREP" -d --fzf alpha)"
  assert_contains 'head\ -n\ 200\ \{\}' "$output" "NO_COLOR selects the plain preview"
  assert_not_contains 'bat\ --color=always' "$output" "NO_COLOR disables preview highlighting"
}

test_debug_and_project_defaults() {
  local output

  output="$(cd "$REPO" && unset NO_COLOR && TERM=xterm "$XGREP" -d 'alpha beta' not 'blocked value')"
  assert_starts_with 'git grep ' "$output" "xgrep output starts with the debug command"
  assert_contains 'git grep -E -I -e alpha\ beta --and --not' "$output" "debug prints shell-safe command"
  assert_contains '-e blocked\ value' "$output" "debug quotes the excluded pattern"

  output="$(cd "$REPO" && TERM=xterm NO_COLOR=1 "$XGREP" -d alpha)"
  assert_contains 'git grep -E -I --no-color -e alpha' "$output" "NO_COLOR disables Git colors"

  output="$(cd "$REPO" && TERM=xterm NO_COLOR='' "$XGREP" -d alpha)"
  assert_not_contains '--no-color' "$output" "empty NO_COLOR leaves Git colors enabled"

  output="$(cd "$REPO" && unset NO_COLOR && TERM=xterm "$XGREP" -d -i alpha)"
  assert_contains 'git grep -E -I -i -e alpha' "$output" "debug displays ignore-case option"

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
run_test "search modes" test_search_modes
run_test "fzf mode" test_fzf_mode
run_test "debug and project defaults" test_debug_and_project_defaults

printf 'all xgrep tests passed\n'
