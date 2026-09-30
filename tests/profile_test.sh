#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_BASH_PROFILE="$ROOT/dotfiles/bash/profile.sh"
SOURCE_SHARED_PROFILE="$ROOT/dotfiles/shared/profile.sh"
SOURCE_ZSH_PROFILE="$ROOT/dotfiles/zsh/profile.sh"
README="$ROOT/README.md"
TEST_ROOT="$(mktemp -d /tmp/git-utilities-profile-tests.XXXXXX)"
FIXTURE="$TEST_ROOT/repository with spaces"
BASH_PROFILE="$FIXTURE/dotfiles/bash/profile.sh"
SHARED_PROFILE="$FIXTURE/dotfiles/shared/profile.sh"
ZSH_PROFILE="$FIXTURE/dotfiles/zsh/profile.sh"

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

make_fixture() {
  mkdir -p "$FIXTURE/dotfiles/bash" "$FIXTURE/dotfiles/shared" \
    "$FIXTURE/dotfiles/zsh" "$FIXTURE/bin"
  cp "$SOURCE_BASH_PROFILE" "$BASH_PROFILE"
  cp "$SOURCE_SHARED_PROFILE" "$SHARED_PROFILE"
  cp "$SOURCE_ZSH_PROFILE" "$ZSH_PROFILE"

  printf '#!/bin/sh\nexit 0\n' >"$FIXTURE/bin/feature"
  chmod +x "$FIXTURE/bin/feature"
}

test_shell() {
  local shell_name="$1"
  local profile="$2"
  local expected actual

  actual="$(
    PROFILE="$profile" FIXTURE="$FIXTURE" "$shell_name" -c '
      set -u
      PATH=/usr/bin:/bin
      source "$PROFILE" sam
      source "$PROFILE" sam
      sh -c '\''printf "%s\n%s\n%s\n" "$FEATURE_USER" "$GIT_UTILITIES" "$PATH"'\''
    '
  )"
  expected="$(printf '%s\n' sam "$FIXTURE" "$FIXTURE/bin:/usr/bin:/bin")"
  assert_eq "$expected" "$actual" "$shell_name exports values without duplicating PATH"

  actual="$(
    PROFILE="$profile" FIXTURE="$FIXTURE" "$shell_name" -c '
      FEATURE_USER=original
      GIT_UTILITIES=/original
      PATH=/usr/bin:/bin
      export FEATURE_USER GIT_UTILITIES PATH

      if source "$PROFILE" >/dev/null 2>&1; then
        exit 1
      fi

      printf "%s\n%s\n%s\n" "$FEATURE_USER" "$GIT_UTILITIES" "$PATH"
    '
  )"
  expected="$(printf '%s\n' original /original /usr/bin:/bin)"
  assert_eq "$expected" "$actual" "$shell_name leaves the environment unchanged after a usage error"
}

test_readme_feature_user_validation() {
  local validation_count

  if grep -Fq '*[!A-Za-z0-9_]*' "$README"; then
    printf 'not ok: README FEATURE_USER validation triggers shell history expansion\n' >&2
    exit 1
  fi

  validation_count="$(grep -Fc "LC_ALL=C grep -Eq '[^A-Za-z0-9_]'" "$README" || true)"
  assert_eq 2 "$validation_count" "README uses shell-safe FEATURE_USER validation for Bash and zsh"
}

make_fixture
bash -n "$SOURCE_BASH_PROFILE" "$SOURCE_SHARED_PROFILE"
test_readme_feature_user_validation
test_shell bash "$BASH_PROFILE"

if command -v zsh >/dev/null 2>&1; then
  zsh -n "$SOURCE_SHARED_PROFILE" "$SOURCE_ZSH_PROFILE"
  test_shell zsh "$ZSH_PROFILE"
else
  printf 'skip: zsh is not installed\n'
fi

printf 'all profile tests passed\n'
