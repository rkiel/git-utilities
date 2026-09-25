## Introduction

This is a collection of simple command-line scripts and wrappers, along with a
few aliases, that make Git easier to use.

The command-line scripts include:

- `feature` - Create, rebase, merge, and discard personal feature branches
  consistently across your team, whether you are new to Git or an experienced
  user. [See documentation](docs/FEATURE.md)
- `xgrep` - Search using simple keywords or complex Boolean logic. It uses
  `git grep` inside Git repositories and `find`/`grep` everywhere else.
  [See documentation](docs/XGREP.md)

**New for 2026:** The command-line scripts were rewritten in Bash 3.2, providing
a simpler installation experience on Linux and macOS.

## Installation for Linux users

### Linux Step 1: Clone the repository

Copy/paste the following to be prompted for the location to clone into.

```bash
{
  read -r -p "Clone this repo into which directory? [$HOME/GitHub/rkiel] " GITHUB_REPOS_DIR
  GITHUB_REPOS_DIR=${GITHUB_REPOS_DIR:-"$HOME/GitHub/rkiel"}
  GIT_UTILITIES_ROOT="$GITHUB_REPOS_DIR/git-utilities"

  mkdir -p "$GITHUB_REPOS_DIR"

  git clone https://github.com/rkiel/git-utilities.git "$GIT_UTILITIES_ROOT"
}
```

### Linux Step 2: Define your `FEATURE_USER`

When you create a feature branch, it includes an identifier that distinguishes
your branches from branches created by other members of your team. The default
is your current username. The identifier may contain only letters, numbers, and
underscores.

Copy/paste the following to accept the default or enter a different
`FEATURE_USER`:

```bash
{
  FEATURE_USER_DEFAULT=${USER:-$(id -un)}
  read -r -p "Enter a unique name [$FEATURE_USER_DEFAULT]: " FEATURE_USER
  FEATURE_USER=${FEATURE_USER:-"$FEATURE_USER_DEFAULT"}
  unset FEATURE_USER_DEFAULT

  case "$FEATURE_USER" in
    ''|*[!A-Za-z0-9_]*)
      printf 'FEATURE_USER must contain only letters, numbers, and underscores\n' >&2
      unset FEATURE_USER
      false
      ;;
  esac
}
```

### Linux Step 3: Update your `.bashrc`

Copy/paste the following to update your `.bashrc` to execute the git-utilities
`profile.sh` script for every interactive shell. The script will:

* export environment variable `FEATURE_USER` with that unique identifier
* add `$GIT_UTILITIES_ROOT/bin` to your `$PATH`

```bash
{
  printf '\nsource "%s/dotfiles/bash/profile.sh" "%s"\n' \
    "$GIT_UTILITIES_ROOT" "$FEATURE_USER" >> "$HOME/.bashrc"

  cat "$HOME/.bashrc"
}
```

### Linux Step 4: Update your `.bashrc`

Copy/paste the following to update your `.bashrc` to execute the git-utilities
`rc.sh` script that will:

* define some aliases
* add support for shell tab completion

```bash
{
  printf '\nsource "%s/dotfiles/bash/rc.sh"\n' \
    "$GIT_UTILITIES_ROOT" >> "$HOME/.bashrc"

  cat "$HOME/.bashrc"
}
```

### Linux Step 5: Verify the installation

Copy/paste the following to load the `profile.sh` and `rc.sh` into your current
shell and verify correctness.

```bash
{
  source "$GIT_UTILITIES_ROOT/dotfiles/bash/profile.sh" "$FEATURE_USER"
  source "$GIT_UTILITIES_ROOT/dotfiles/bash/rc.sh"
  command -v feature
  command -v xgrep
}
```

## Installation for macOS users

### macOS Step 1: Clone the repository

Copy/paste the following to be prompted for the location to clone into.

```zsh
  read -r "GITHUB_REPOS_DIR?Clone this repo into which directory? [$HOME/GitHub/rkiel] "
  GITHUB_REPOS_DIR=${GITHUB_REPOS_DIR:-"$HOME/GitHub/rkiel"}
  GIT_UTILITIES_ROOT="$GITHUB_REPOS_DIR/git-utilities"

  mkdir -p "$GITHUB_REPOS_DIR"

  git clone https://github.com/rkiel/git-utilities.git "$GIT_UTILITIES_ROOT"
```

### macOS Step 2: Define your `FEATURE_USER`

When you create a feature branch, it includes an identifier that distinguishes
your branches from branches created by other members of your team. The default
is your current username. The identifier may contain only letters, numbers, and
underscores.

Copy/paste the following to accept the default or enter a different
`FEATURE_USER`:

```zsh
{
  FEATURE_USER_DEFAULT=${USER:-$(id -un)}
  read -r "FEATURE_USER?Enter a unique name [$FEATURE_USER_DEFAULT]: "
  FEATURE_USER=${FEATURE_USER:-"$FEATURE_USER_DEFAULT"}
  unset FEATURE_USER_DEFAULT

  case "$FEATURE_USER" in
    ''|*[!A-Za-z0-9_]*)
      printf 'FEATURE_USER must contain only letters, numbers, and underscores\n' >&2
      unset FEATURE_USER
      false
      ;;
  esac
}
```

### macOS Step 3: Update your `.zprofile`

Copy/paste the following to update your `.zprofile` to execute the git-utilities
`profile.sh` script that will:

* export environment variable `FEATURE_USER` with that unique identifier
* add `$GIT_UTILITIES_ROOT/bin` to your `$PATH`

```zsh
{
  printf '\nsource "%s/dotfiles/zsh/profile.sh" "%s"\n' \
    "$GIT_UTILITIES_ROOT" "$FEATURE_USER" >> "$HOME/.zprofile"

  cat "$HOME/.zprofile"
}
```

### macOS Step 4: Update your `.zshrc`

Copy/paste the following to update your `.zshrc` to execute the git-utilities
`rc.sh` script that will:

* define some aliases
* add support for shell tab completion

```zsh
{
  printf '\nsource "%s/dotfiles/zsh/rc.sh"\n' \
    "$GIT_UTILITIES_ROOT" >> "$HOME/.zshrc"

  cat "$HOME/.zshrc"
}
```

### macOS Step 5: Verify the installation

Copy/paste the following to load the `profile.sh` and `rc.sh` into your current
shell and verify correctness.

```zsh
{
  source "$GIT_UTILITIES_ROOT/dotfiles/zsh/profile.sh" "$FEATURE_USER"
  source "$GIT_UTILITIES_ROOT/dotfiles/zsh/rc.sh"
  command -v feature
  command -v xgrep
}
```
