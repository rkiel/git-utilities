#!/usr/bin/env bash
set -euo pipefail

# Keep these tests in sync with bin/bash/feature. Any behavior change should update
# this file in the same change; new subcommands need happy-path and guard tests.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FEATURE="$ROOT/bin/bash/feature"
TEST_ROOT="$(mktemp -d /tmp/feature-tests.XXXXXX)"

cleanup() {
  rm -rf "$TEST_ROOT"
}

trap cleanup EXIT

assert_eq() {
  local expected="$1"
  local actual="$2"
  local message="$3"

  if [ "$expected" != "$actual" ]; then
    printf 'not ok: %s\nexpected: %s\nactual:   %s\n' "$message" "$expected" "$actual" >&2
    exit 1
  fi
}

assert_ne() {
  local unexpected="$1"
  local actual="$2"
  local message="$3"

  if [ "$unexpected" = "$actual" ]; then
    printf 'not ok: %s\nunexpected: %s\n' "$message" "$unexpected" >&2
    exit 1
  fi
}

assert_contains() {
  local needle="$1"
  local haystack="$2"
  local message="$3"

  if [[ "$haystack" != *"$needle"* ]]; then
    printf 'not ok: %s\nmissing: %s\noutput:\n%s\n' "$message" "$needle" "$haystack" >&2
    exit 1
  fi
}

assert_branch_missing() {
  local repo="$1"
  local branch="$2"

  if git -C "$repo" show-ref --verify --quiet "refs/heads/$branch"; then
    printf 'not ok: local branch still exists: %s\n' "$branch" >&2
    exit 1
  fi
}

assert_remote_branch_missing() {
  local repo="$1"
  local branch="$2"

  if [ -n "$(git -C "$repo" ls-remote --heads origin "$branch")" ]; then
    printf 'not ok: remote branch still exists: %s\n' "$branch" >&2
    exit 1
  fi
}

make_repo() {
  local name="$1"
  local dir="$TEST_ROOT/$name"
  local repo="$dir/repo"
  local remote="$dir/origin.git"

  mkdir -p "$dir"
  git init --bare "$remote" >/dev/null
  git init -b main "$repo" >/dev/null
  git -C "$repo" config user.email test@example.com
  git -C "$repo" config user.name Test
  printf 'initial\n' >"$repo/README.md"
  git -C "$repo" add README.md
  git -C "$repo" commit -m initial >/dev/null
  git -C "$repo" remote add origin "$remote"
  git -C "$repo" push -u origin main >/dev/null 2>&1

  printf '%s\n' "$repo"
}

run_test() {
  local name="$1"
  shift

  printf 'test: %s ... ' "$name"
  "$@"
  printf 'ok\n'
}

test_help_and_usage() {
  local output status

  output="$("$FEATURE" help)"
  assert_contains "FEATURE_USER overrides the user field" "$output" "help documents FEATURE_USER"

  set +e
  output="$("$FEATURE" nope 2>&1)"
  status="$?"
  set -e

  assert_eq 2 "$status" "invalid command exits 2"
  assert_contains "feature start <ticket-number> <words...>" "$output" "invalid command prints help"
}

test_start_and_status() {
  local repo output branch remote_ref

  repo="$(make_repo start-status)"
  (cd "$repo" && FEATURE_USER=sam "$FEATURE" start 123 add login >/dev/null 2>&1)

  branch="$(git -C "$repo" branch --show-current)"
  remote_ref="$(git -C "$repo" ls-remote --heads origin f-main-123-sam-add-login)"

  assert_eq "f-main-123-sam-add-login" "$branch" "start switches to feature branch"
  if [ -z "$remote_ref" ]; then
    printf 'not ok: start did not create remote feature branch\n' >&2
    exit 1
  fi

  output="$(cd "$repo" && "$FEATURE" status)"
  assert_contains "Feature branch: yes" "$output" "status identifies feature branch"
  assert_contains "Initial branch: main" "$output" "status shows initial branch"
  assert_contains "Ticket: #123" "$output" "status shows ticket"
}

test_start_rejects_bad_feature_user() {
  local repo status output branches

  repo="$(make_repo bad-user)"

  set +e
  output="$(cd "$repo" && FEATURE_USER='sam-smith' "$FEATURE" start 456 bad user 2>&1)"
  status="$?"
  set -e

  branches="$(git -C "$repo" branch --format='%(refname:short)')"

  assert_eq 1 "$status" "bad FEATURE_USER exits 1"
  assert_contains "user name must contain only letters" "$output" "bad FEATURE_USER explains failure"
  assert_eq "main" "$branches" "bad FEATURE_USER does not create branch"
}

test_commit_pushes_feature_branch() {
  local repo branch subject local_head remote_head

  repo="$(make_repo commit-push)"
  (cd "$repo" && FEATURE_USER=sam "$FEATURE" start 901 commit pushes >/dev/null 2>&1)
  printf 'initial\ncommit change\n' >"$repo/README.md"
  (cd "$repo" && printf 'y\n' | "$FEATURE" commit push after commit >/dev/null 2>&1)

  branch="$(git -C "$repo" branch --show-current)"
  subject="$(git -C "$repo" log -1 --format=%s)"
  local_head="$(git -C "$repo" rev-parse HEAD)"
  remote_head="$(git -C "$repo" rev-parse origin/f-main-901-sam-commit-pushes)"

  assert_eq "f-main-901-sam-commit-pushes" "$branch" "commit remains on feature branch"
  assert_eq "#901 push after commit" "$subject" "commit prefixes ticket"
  assert_eq "$local_head" "$remote_head" "commit force-pushes feature branch"
}

test_rebase_blocks_tracked_changes_but_allows_untracked() {
  local repo status output local_head remote_head branch junk

  repo="$(make_repo rebase-dirty)"
  (cd "$repo" && FEATURE_USER=sam "$FEATURE" start 111 dirty rebase >/dev/null 2>&1)
  printf 'initial\ndirty\n' >"$repo/README.md"

  set +e
  output="$(cd "$repo" && "$FEATURE" rebase 2>&1)"
  status="$?"
  set -e

  assert_eq 1 "$status" "rebase blocks unstaged tracked changes"
  assert_contains "no unstaged tracked changes" "$output" "rebase explains dirty tracked failure"
  assert_eq "f-main-111-sam-dirty-rebase" "$(git -C "$repo" branch --show-current)" "failed rebase keeps feature branch"

  git -C "$repo" checkout -- README.md
  printf 'feature\n' >"$repo/feature.txt"
  git -C "$repo" add feature.txt
  git -C "$repo" commit -m '#111 feature work' >/dev/null
  printf 'local junk\n' >"$repo/junk.tmp"
  (cd "$repo" && GIT_SEQUENCE_EDITOR=: "$FEATURE" rebase >/dev/null 2>&1)

  branch="$(git -C "$repo" branch --show-current)"
  local_head="$(git -C "$repo" rev-parse HEAD)"
  remote_head="$(git -C "$repo" rev-parse origin/f-main-111-sam-dirty-rebase)"
  junk="$(sed -n '1p' "$repo/junk.tmp")"

  assert_eq "f-main-111-sam-dirty-rebase" "$branch" "rebase stays on feature branch"
  assert_eq "$local_head" "$remote_head" "rebase force-pushes feature branch"
  assert_eq "local junk" "$junk" "rebase allows untracked files"
}

test_merge_pushes_initial_branch() {
  local repo branch main_head feature_head origin_main

  repo="$(make_repo merge)"
  (cd "$repo" && FEATURE_USER=sam "$FEATURE" start 222 merge flow >/dev/null 2>&1)
  printf 'feature\n' >"$repo/feature.txt"
  git -C "$repo" add feature.txt
  git -C "$repo" commit -m '#222 feature work' >/dev/null
  (cd "$repo" && GIT_SEQUENCE_EDITOR=: "$FEATURE" merge >/dev/null 2>&1)

  branch="$(git -C "$repo" branch --show-current)"
  main_head="$(git -C "$repo" rev-parse main)"
  feature_head="$(git -C "$repo" rev-parse f-main-222-sam-merge-flow)"
  origin_main="$(git -C "$repo" rev-parse origin/main)"

  assert_eq "f-main-222-sam-merge-flow" "$branch" "merge returns to feature branch"
  assert_eq "$feature_head" "$main_head" "merge fast-forwards initial branch"
  assert_eq "$main_head" "$origin_main" "merge pushes initial branch"
}

test_end_and_trash_cleanup() {
  local repo branch

  repo="$(make_repo end-cleanup)"
  (cd "$repo" && FEATURE_USER=sam "$FEATURE" start 333 end cleanup >/dev/null 2>&1)
  (cd "$repo" && "$FEATURE" end >/dev/null 2>&1)

  assert_eq "main" "$(git -C "$repo" branch --show-current)" "end switches to initial branch"
  assert_branch_missing "$repo" f-main-333-sam-end-cleanup
  assert_remote_branch_missing "$repo" f-main-333-sam-end-cleanup

  repo="$(make_repo trash-cleanup)"
  (cd "$repo" && FEATURE_USER=sam "$FEATURE" start 444 trash cleanup >/dev/null 2>&1)
  printf 'unmerged\n' >"$repo/unmerged.txt"
  git -C "$repo" add unmerged.txt
  git -C "$repo" commit -m '#444 unmerged work' >/dev/null
  branch="$(git -C "$repo" branch --show-current)"
  (cd "$repo" && "$FEATURE" trash "$branch" >/dev/null 2>&1)

  assert_eq "main" "$(git -C "$repo" branch --show-current)" "trash switches to initial branch"
  assert_branch_missing "$repo" f-main-444-sam-trash-cleanup
  assert_remote_branch_missing "$repo" f-main-444-sam-trash-cleanup
}

run_test "help and usage" test_help_and_usage
run_test "start and status" test_start_and_status
run_test "FEATURE_USER validation" test_start_rejects_bad_feature_user
run_test "commit pushes feature branch" test_commit_pushes_feature_branch
run_test "rebase dirty policy" test_rebase_blocks_tracked_changes_but_allows_untracked
run_test "merge pushes initial branch" test_merge_pushes_initial_branch
run_test "end and trash cleanup" test_end_and_trash_cleanup

printf 'all tests passed\n'
