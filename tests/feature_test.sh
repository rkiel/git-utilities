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

assert_not_contains() {
  local needle="$1"
  local haystack="$2"
  local message="$3"

  if [[ "$haystack" == *"$needle"* ]]; then
    printf 'not ok: %s\nunexpected: %s\noutput:\n%s\n' "$message" "$needle" "$haystack" >&2
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

create_initial_branch() {
  local repo="$1"
  local branch="$2"

  git -C "$repo" switch -c "$branch" >/dev/null
  git -C "$repo" push -u origin "$branch" >/dev/null 2>&1
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

test_tab_lists_and_filters_commands() {
  local expected actual help_commands output sorted status

  expected="$(printf '%s\n' add commit end help info log merge rebase start status tab trash unstage)"
  actual="$(cd "$TEST_ROOT" && "$FEATURE" tab)"
  assert_eq "$expected" "$actual" "tab lists every subcommand outside a Git repository"

  sorted="$(printf '%s\n' "$actual" | LC_ALL=C sort)"
  assert_eq "$sorted" "$actual" "tab lists subcommands alphabetically"

  help_commands="$(
    "$FEATURE" help | awk '
      /^Usage:$/ { in_usage = 1; next }
      in_usage && /^$/ { exit }
      in_usage { print $2 }
    '
  )"
  assert_eq "$actual" "$help_commands" "help lists the same alphabetized subcommands as tab"

  actual="$(cd "$TEST_ROOT" && "$FEATURE" tab st)"
  assert_eq "$(printf '%s\n' start status)" "$actual" "tab filters by literal prefix"

  actual="$(cd "$TEST_ROOT" && "$FEATURE" tab does-not-match)"
  assert_eq "" "$actual" "tab returns no output when no command matches"

  set +e
  output="$(cd "$TEST_ROOT" && "$FEATURE" tab s t 2>&1)"
  status="$?"
  set -e

  assert_eq 2 "$status" "tab rejects more than one prefix"
  assert_contains "feature tab [<prefix>]" "$output" "tab argument failure prints help"
}

test_bashrc_completion_uses_tab_command() {
  local actual completion_home registration

  completion_home="$TEST_ROOT/completion-home"
  mkdir -p "$completion_home"

  actual="$(
    HOME="$completion_home" PATH="$(dirname "$FEATURE"):$PATH" \
      bash --noprofile --norc -c '
        source "$1"
        COMP_WORDS=(feature st)
        COMP_CWORD=1
        get_feature_commands
        printf "%s\n" "${COMPREPLY[@]}"
      ' _ "$ROOT/dotfiles/bashrc"
  )"

  assert_eq "$(printf '%s\n' start status)" "$actual" "bashrc completes feature subcommands through feature tab"

  registration="$(
    HOME="$completion_home" bash --noprofile --norc -c '
      source "$1"
      complete -p feature
    ' _ "$ROOT/dotfiles/bashrc"
  )"
  assert_contains "-o bashdefault" "$registration" "bashrc enables Bash fallback completion"
  assert_contains "-o default" "$registration" "bashrc enables filesystem fallback completion"
}

test_zshrc_completion_uses_tab_command() {
  local config completion_home

  config="$(cat "$ROOT/dotfiles/zshrc")"
  assert_contains 'feature tab "$PREFIX"' "$config" "zshrc completes subcommands through feature tab"
  assert_contains '_files' "$config" "zshrc enables filesystem fallback completion"
  assert_contains 'compdef get_feature_commands feature' "$config" "zshrc registers feature completion"

  if command -v zsh >/dev/null 2>&1; then
    completion_home="$TEST_ROOT/zsh-completion-home"
    mkdir -p "$completion_home"
    HOME="$completion_home" zsh -n "$ROOT/dotfiles/zshrc"
  fi
}

test_start_and_info() {
  local repo output branch remote_ref

  repo="$(make_repo start-status)"
  (cd "$repo" && FEATURE_USER=sam "$FEATURE" start 123 add login >/dev/null 2>&1)

  branch="$(git -C "$repo" branch --show-current)"
  remote_ref="$(git -C "$repo" ls-remote --heads origin main--sam--123--add-login)"

  assert_eq "main--sam--123--add-login" "$branch" "start switches to feature branch"
  if [ -z "$remote_ref" ]; then
    printf 'not ok: start did not create remote feature branch\n' >&2
    exit 1
  fi

  output="$(cd "$repo" && "$FEATURE" info)"
  assert_contains "Feature branch: yes" "$output" "info identifies feature branch"
  assert_contains "Initial branch: main" "$output" "info shows initial branch"
  assert_contains "Ticket: #123" "$output" "info shows ticket"
}

test_selected_git_commands_are_displayed() {
  local repo output

  repo="$(make_repo displayed-git-commands)"
  output="$(cd "$repo" && FEATURE_USER=sam "$FEATURE" start 124 show commands 2>&1)"

  assert_contains "+ git fetch --all --prune --tags" "$output" "fetch command is displayed"
  assert_contains "+ git rebase --autostash origin/main" "$output" "rebase command is displayed"
  assert_contains "+ git switch -c main--sam--124--show-commands" "$output" "switch command is displayed"
  assert_contains "+ git push -u origin main--sam--124--show-commands" "$output" "push command is displayed"
  assert_not_contains $'\033[' "$output" "redirected command output does not contain terminal colors"
  assert_not_contains "+ git branch" "$output" "branch commands remain quiet"
  assert_not_contains "+ git rev-parse" "$output" "internal rev-parse command remains quiet"
  assert_not_contains "+ git check-ref-format" "$output" "internal ref validation remains quiet"
  assert_not_contains "+ git show-ref" "$output" "internal ref inspection remains quiet"

  printf 'staged content\n' >"$repo/staged.txt"
  output="$(cd "$repo" && "$FEATURE" add 'staged.txt' 2>&1)"
  assert_contains "+ git add staged.txt" "$output" "add command is displayed"
}

test_status_includes_stash_list() {
  local repo expected actual

  repo="$(make_repo status-stashes)"
  printf 'initial\nstatus change\n' >"$repo/README.md"

  expected="$(git -C "$repo" status --porcelain)"
  actual="$(cd "$repo" && "$FEATURE" status --porcelain)"
  assert_eq "$expected" "$actual" "status omits an empty stash section"
  if [[ "$actual" == *"STASH:"* ]]; then
    printf 'not ok: status showed STASH heading with no stashes\n' >&2
    exit 1
  fi

  git -C "$repo" stash push -m 'saved work' >/dev/null
  printf 'untracked\n' >"$repo/untracked.txt"

  expected="$(
    cd "$repo"
    git status --short --branch
    echo
    echo 'STASH:'
    git stash list
    echo
  )"
  actual="$(cd "$repo" && "$FEATURE" status --short --branch)"
  assert_eq "$expected" "$actual" "status shows Git status and populated stash list"
  assert_contains "stash@{0}: On main: saved work" "$actual" "status lists saved stashes"
}

test_log_supports_optional_pretty_format() {
  local repo expected actual output status pretty_format

  repo="$(make_repo log-history)"
  printf 'history\n' >"$repo/history.txt"
  git -C "$repo" add history.txt
  git -C "$repo" commit -m 'add history' >/dev/null

  expected="$(git -C "$repo" log --graph --date=short --pretty=format:'%C(yellow)%h %C(white)%ad %C(black)[%C(green)%an%C(black)] %C(blue)%s%C(yellow)%d')"
  actual="$(cd "$repo" && "$FEATURE" log)"
  assert_eq "$expected" "$actual" "log uses the documented fixed Git format"

  pretty_format='%h %ad %an %s'
  expected="$(git -C "$repo" log --graph --date=short --pretty="format:$pretty_format")"
  actual="$(cd "$repo" && "$FEATURE" log "$pretty_format")"
  assert_eq "$expected" "$actual" "log accepts a custom pretty format"

  set +e
  output="$(cd "$repo" && "$FEATURE" log '%h' '%s' 2>&1)"
  status="$?"
  set -e

  assert_eq 2 "$status" "log rejects more than one format argument"
  assert_contains "feature log [<pretty-format>]" "$output" "log argument failure prints help"
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

test_add_and_unstage() {
  local repo staged output

  repo="$(make_repo add-unstage)"
  (cd "$repo" && FEATURE_USER=sam "$FEATURE" start 800 stage files >/dev/null 2>&1)
  printf 'initial\ntracked change\n' >"$repo/README.md"
  printf 'new file\n' >"$repo/new-file.txt"

  (cd "$repo" && "$FEATURE" add --all)
  staged="$(git -C "$repo" diff --cached --name-only)"
  assert_contains "README.md" "$staged" "add passes options through to git add"
  assert_contains "new-file.txt" "$staged" "add stages untracked files"

  (cd "$repo" && "$FEATURE" unstage new-file.txt)
  staged="$(git -C "$repo" diff --cached --name-only)"
  assert_contains "README.md" "$staged" "unstage leaves other staged paths alone"
  if [[ "$staged" == *"new-file.txt"* ]]; then
    printf 'not ok: unstage left new-file.txt staged\n' >&2
    exit 1
  fi
  if [ ! -f "$repo/new-file.txt" ]; then
    printf 'not ok: unstage removed new-file.txt from the working tree\n' >&2
    exit 1
  fi

  output="$(cd "$repo" && "$FEATURE" info)"
  assert_contains "Staged changes: yes" "$output" "info reports remaining staged changes"
  assert_contains "Untracked files: yes" "$output" "unstaged new file remains untracked"

  (cd "$repo" && "$FEATURE" add new-file.txt)
  staged="$(git -C "$repo" diff --cached --name-only)"
  assert_contains "new-file.txt" "$staged" "add accepts a pathspec"
}

test_add_and_unstage_require_feature_branch() {
  local repo status output

  repo="$(make_repo add-unstage-guard)"

  set +e
  output="$(cd "$repo" && "$FEATURE" add README.md 2>&1)"
  status="$?"
  set -e

  assert_eq 1 "$status" "add rejects an initial branch"
  assert_contains "does not look like a feature branch" "$output" "add feature-branch guard is clear"

  set +e
  output="$(cd "$repo" && "$FEATURE" unstage README.md 2>&1)"
  status="$?"
  set -e

  assert_eq 1 "$status" "unstage rejects an initial branch"
  assert_contains "does not look like a feature branch" "$output" "unstage feature-branch guard is clear"
  assert_eq "" "$(git -C "$repo" diff --cached --name-only)" "guard failures do not change the index"
}

test_commit_pushes_feature_branch() {
  local repo branch subject local_head remote_head output

  repo="$(make_repo commit-push)"
  (cd "$repo" && FEATURE_USER=sam "$FEATURE" start 901 commit pushes >/dev/null 2>&1)
  printf 'initial\ncommit change\n' >"$repo/README.md"
  output="$(cd "$repo" && printf 'y\n' | "$FEATURE" commit push after commit 2>&1)"

  branch="$(git -C "$repo" branch --show-current)"
  subject="$(git -C "$repo" log -1 --format=%s)"
  local_head="$(git -C "$repo" rev-parse HEAD)"
  remote_head="$(git -C "$repo" rev-parse origin/main--sam--901--commit-pushes)"

  assert_eq "main--sam--901--commit-pushes" "$branch" "commit remains on feature branch"
  assert_eq "#901 push after commit" "$subject" "commit prefixes ticket"
  assert_eq "$local_head" "$remote_head" "commit force-pushes feature branch"
  assert_contains "+ git add --patch" "$output" "commit displays patch add command"
  assert_contains "+ git commit -m" "$output" "commit displays commit command"
  assert_contains "+ git push --force origin" "$output" "commit displays force push command"
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
  assert_eq "main--sam--111--dirty-rebase" "$(git -C "$repo" branch --show-current)" "failed rebase keeps feature branch"

  git -C "$repo" checkout -- README.md
  printf 'feature\n' >"$repo/feature.txt"
  git -C "$repo" add feature.txt
  git -C "$repo" commit -m '#111 feature work' >/dev/null
  printf 'local junk\n' >"$repo/junk.tmp"
  (cd "$repo" && GIT_SEQUENCE_EDITOR=: "$FEATURE" rebase >/dev/null 2>&1)

  branch="$(git -C "$repo" branch --show-current)"
  local_head="$(git -C "$repo" rev-parse HEAD)"
  remote_head="$(git -C "$repo" rev-parse origin/main--sam--111--dirty-rebase)"
  junk="$(sed -n '1p' "$repo/junk.tmp")"

  assert_eq "main--sam--111--dirty-rebase" "$branch" "rebase stays on feature branch"
  assert_eq "$local_head" "$remote_head" "rebase force-pushes feature branch"
  assert_eq "local junk" "$junk" "rebase allows untracked files"
}

test_merge_pushes_initial_branch() {
  local repo branch main_head feature_head origin_main output

  repo="$(make_repo merge)"
  (cd "$repo" && FEATURE_USER=sam "$FEATURE" start 222 merge flow >/dev/null 2>&1)
  printf 'feature\n' >"$repo/feature.txt"
  git -C "$repo" add feature.txt
  git -C "$repo" commit -m '#222 feature work' >/dev/null
  output="$(cd "$repo" && GIT_SEQUENCE_EDITOR=: "$FEATURE" merge 2>&1)"

  branch="$(git -C "$repo" branch --show-current)"
  main_head="$(git -C "$repo" rev-parse main)"
  feature_head="$(git -C "$repo" rev-parse main--sam--222--merge-flow)"
  origin_main="$(git -C "$repo" rev-parse origin/main)"

  assert_eq "main--sam--222--merge-flow" "$branch" "merge returns to feature branch"
  assert_eq "$feature_head" "$main_head" "merge fast-forwards initial branch"
  assert_eq "$main_head" "$origin_main" "merge pushes initial branch"
  assert_contains "+ git merge --ff-only main--sam--222--merge-flow" "$output" "merge command is displayed"
}

test_end_and_trash_cleanup() {
  local repo branch

  repo="$(make_repo end-cleanup)"
  (cd "$repo" && FEATURE_USER=sam "$FEATURE" start 333 end cleanup >/dev/null 2>&1)
  (cd "$repo" && "$FEATURE" end >/dev/null 2>&1)

  assert_eq "main" "$(git -C "$repo" branch --show-current)" "end switches to initial branch"
  assert_branch_missing "$repo" main--sam--333--end-cleanup
  assert_remote_branch_missing "$repo" main--sam--333--end-cleanup

  repo="$(make_repo trash-cleanup)"
  (cd "$repo" && FEATURE_USER=sam "$FEATURE" start 444 trash cleanup >/dev/null 2>&1)
  printf 'unmerged\n' >"$repo/unmerged.txt"
  git -C "$repo" add unmerged.txt
  git -C "$repo" commit -m '#444 unmerged work' >/dev/null
  branch="$(git -C "$repo" branch --show-current)"
  (cd "$repo" && "$FEATURE" trash "$branch" >/dev/null 2>&1)

  assert_eq "main" "$(git -C "$repo" branch --show-current)" "trash switches to initial branch"
  assert_branch_missing "$repo" main--sam--444--trash-cleanup
  assert_remote_branch_missing "$repo" main--sam--444--trash-cleanup
}

test_release_branch_full_workflow() {
  local repo branch output local_head remote_head base_head origin_base

  repo="$(make_repo release-workflow)"
  create_initial_branch "$repo" release/1.2.3
  (cd "$repo" && FEATURE_USER=bob "$FEATURE" start 555 release candidate >/dev/null 2>&1)

  branch="$(git -C "$repo" branch --show-current)"
  assert_eq "release/1.2.3--bob--555--release-candidate" "$branch" "start preserves slash and period in initial branch"

  output="$(cd "$repo" && "$FEATURE" info)"
  assert_contains "Feature branch: yes" "$output" "info recognizes release feature branch"
  assert_contains "Initial branch: release/1.2.3" "$output" "info restores release initial branch"
  assert_contains "Ticket: #555" "$output" "info restores release ticket"

  printf 'release feature\n' >"$repo/release.txt"
  git -C "$repo" add release.txt
  git -C "$repo" commit -m '#555 release work' >/dev/null
  (cd "$repo" && GIT_SEQUENCE_EDITOR=: "$FEATURE" rebase >/dev/null 2>&1)

  local_head="$(git -C "$repo" rev-parse HEAD)"
  remote_head="$(git -C "$repo" rev-parse origin/release/1.2.3--bob--555--release-candidate)"
  assert_eq "$local_head" "$remote_head" "rebase pushes release feature branch"

  (cd "$repo" && GIT_SEQUENCE_EDITOR=: "$FEATURE" merge >/dev/null 2>&1)
  assert_eq "$branch" "$(git -C "$repo" branch --show-current)" "merge returns to release feature branch"

  base_head="$(git -C "$repo" rev-parse release/1.2.3)"
  origin_base="$(git -C "$repo" rev-parse origin/release/1.2.3)"
  assert_eq "$local_head" "$base_head" "merge fast-forwards release initial branch"
  assert_eq "$base_head" "$origin_base" "merge pushes release initial branch"

  (cd "$repo" && "$FEATURE" end >/dev/null 2>&1)
  assert_eq "release/1.2.3" "$(git -C "$repo" branch --show-current)" "end returns to release initial branch"
  assert_branch_missing "$repo" "$branch"
  assert_remote_branch_missing "$repo" "$branch"
}

test_accepts_other_git_valid_initial_names() {
  local repo branch output

  repo="$(make_repo flexible-initial)"
  create_initial_branch "$repo" release_candidate/2.0+qa
  (cd "$repo" && FEATURE_USER=sam "$FEATURE" start 666 flexible base >/dev/null 2>&1)

  branch="$(git -C "$repo" branch --show-current)"
  assert_eq "release_candidate/2.0+qa--sam--666--flexible-base" "$branch" "start accepts Git-valid initial branch characters"

  output="$(cd "$repo" && "$FEATURE" info)"
  assert_contains "Initial branch: release_candidate/2.0+qa" "$output" "info restores flexible initial branch"

  (cd "$repo" && "$FEATURE" trash "$branch" >/dev/null 2>&1)
  assert_branch_missing "$repo" "$branch"
  assert_remote_branch_missing "$repo" "$branch"
}

test_start_rejects_reserved_and_feature_branches() {
  local repo status output branch

  repo="$(make_repo reserved-initial)"
  git -C "$repo" switch -c release--candidate >/dev/null

  set +e
  output="$(cd "$repo" && FEATURE_USER=sam "$FEATURE" start 700 reserved delimiter 2>&1)"
  status="$?"
  set -e

  assert_eq 1 "$status" "start rejects reserved delimiter in initial branch"
  assert_contains "reserved -- delimiter" "$output" "reserved delimiter failure is clear"
  assert_eq "release--candidate" "$(git -C "$repo" branch --show-current)" "reserved delimiter failure keeps initial branch"

  repo="$(make_repo nested-feature)"
  (cd "$repo" && FEATURE_USER=sam "$FEATURE" start 701 first feature >/dev/null 2>&1)
  branch="$(git -C "$repo" branch --show-current)"

  set +e
  output="$(cd "$repo" && FEATURE_USER=sam "$FEATURE" start 702 nested feature 2>&1)"
  status="$?"
  set -e

  assert_eq 1 "$status" "start rejects new-format feature branch"
  assert_contains "cannot start a feature branch from another feature branch" "$output" "nested feature failure is clear"
  assert_eq "$branch" "$(git -C "$repo" branch --show-current)" "nested feature failure keeps current branch"
}

test_feature_commands_reject_unsupported_formats() {
  local repo status output

  repo="$(make_repo malformed-feature)"
  git -C "$repo" switch -c main--sam--ticket--description >/dev/null

  set +e
  output="$(cd "$repo" && "$FEATURE" end 2>&1)"
  status="$?"
  set -e

  assert_eq 1 "$status" "feature command rejects malformed new-format branch"
  assert_contains "does not look like a feature branch" "$output" "malformed branch failure is clear"
}

run_test "help and usage" test_help_and_usage
run_test "tab lists and filters commands" test_tab_lists_and_filters_commands
run_test "bashrc completion uses tab command" test_bashrc_completion_uses_tab_command
run_test "zshrc completion uses tab command" test_zshrc_completion_uses_tab_command
run_test "start and info" test_start_and_info
run_test "selected Git commands are displayed" test_selected_git_commands_are_displayed
run_test "status includes stash list" test_status_includes_stash_list
run_test "log supports optional pretty format" test_log_supports_optional_pretty_format
run_test "FEATURE_USER validation" test_start_rejects_bad_feature_user
run_test "add and unstage" test_add_and_unstage
run_test "add and unstage require feature branch" test_add_and_unstage_require_feature_branch
run_test "commit pushes feature branch" test_commit_pushes_feature_branch
run_test "rebase dirty policy" test_rebase_blocks_tracked_changes_but_allows_untracked
run_test "merge pushes initial branch" test_merge_pushes_initial_branch
run_test "end and trash cleanup" test_end_and_trash_cleanup
run_test "release branch workflow" test_release_branch_full_workflow
run_test "other Git-valid initial names" test_accepts_other_git_valid_initial_names
run_test "start rejects reserved and feature branches" test_start_rejects_reserved_and_feature_branches
run_test "feature commands reject unsupported formats" test_feature_commands_reject_unsupported_formats

printf 'all tests passed\n'
