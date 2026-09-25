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

### Linux Step 3: Environment Variables

Copy/paste the following to update your `.bashrc` to execute the git-utilities
`profile.sh` script for every interactive shell. The script will:

* export environment variable `FEATURE_USER` with that unique identifier
* add `$GIT_UTILITIES_ROOT/bin` to your `$PATH`

```bash
{
  printf '\nsource "%s/dotfiles/bash/profile.sh" "%s"\n' \
    "$GIT_UTILITIES_ROOT" "$FEATURE_USER" >> "$HOME/.bashrc"

  source "$GIT_UTILITIES_ROOT/dotfiles/bash/profile.sh" "$FEATURE_USER"
}
```

### Linux Step 4 Add tab completion (OPTIONAL)

Tab completion suggests `feature` subcommands and filesystem paths as you type.
This convenience is not required to use `feature` or `xgrep`.

Copy/paste the following to add tab completion to your `.bashrc` and load it into
your current shell:

```bash
{
  printf '\nsource "%s/dotfiles/bash/tab_completion.sh"\n' \
    "$GIT_UTILITIES_ROOT" >> "$HOME/.bashrc"

  source "$GIT_UTILITIES_ROOT/dotfiles/bash/tab_completion.sh"
}
```

### Linux Step 5 Install aliases (OPTIONAL)

The optional aliases define short command names that may replace aliases you
already use. [Review the available aliases](dotfiles/shared/aliases.sh) before
enabling them.

Copy/paste the following to add the aliases to your `.bashrc` and load them into
your current shell:

```bash
{
  printf '\nsource "%s/dotfiles/shared/aliases.sh"\n' \
    "$GIT_UTILITIES_ROOT" >> "$HOME/.bashrc"

  source "$GIT_UTILITIES_ROOT/dotfiles/shared/aliases.sh"
}
```

### Linux Step 6: Verify the installation

Copy/paste the following to verify the required installation.

```bash
{
  alias
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

### macOS Step 3: Environment Variables

Copy/paste the following to update your `.zprofile` to execute the git-utilities
`profile.sh` script that will:

* export environment variable `FEATURE_USER` with that unique identifier
* add `$GIT_UTILITIES_ROOT/bin` to your `$PATH`

```zsh
{
  printf '\nsource "%s/dotfiles/zsh/profile.sh" "%s"\n' \
    "$GIT_UTILITIES_ROOT" "$FEATURE_USER" >> "$HOME/.zprofile"

  source "$GIT_UTILITIES_ROOT/dotfiles/zsh/profile.sh" "$FEATURE_USER"
}
```

### macOS Step 4 Add tab completion (OPTIONAL)

Tab completion suggests `feature` subcommands and filesystem paths as you type.
This convenience is not required to use `feature` or `xgrep`.

Copy/paste the following to add tab completion to your `.zshrc` and load it into
your current shell:

```zsh
{
  printf '\nsource "%s/dotfiles/zsh/tab_completion.sh"\n' \
    "$GIT_UTILITIES_ROOT" >> "$HOME/.zshrc"

  source "$GIT_UTILITIES_ROOT/dotfiles/zsh/tab_completion.sh"
}
```

### macOS Step 5 Install aliases (OPTIONAL)

The optional aliases define short command names that may replace aliases you
already use. [Review the available aliases](dotfiles/shared/aliases.sh) before
enabling them.

Copy/paste the following to add the aliases to your `.zshrc` and load them into
your current shell:

```zsh
{
  printf '\nsource "%s/dotfiles/shared/aliases.sh"\n' \
    "$GIT_UTILITIES_ROOT" >> "$HOME/.zshrc"

  source "$GIT_UTILITIES_ROOT/dotfiles/shared/aliases.sh"
}
```

### macOS Step 6: Verify the installation

Copy/paste the following to verify the required installation.

```zsh
{
  alias
  command -v feature
  command -v xgrep
}
```
