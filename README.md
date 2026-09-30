## Introduction

This is a collection of simple command-line scripts and wrappers, along with a
few aliases, that make Git easier to use.

The command-line scripts include:

- `feature` - Create, rebase, merge, and discard personal feature branches with simplicity and ease.
  Provide process consistency across your team, whether you are new to Git or an experienced
  Git practitioner. [See documentation](docs/FEATURE.md)
- `xgrep` - File searching using simple keywords and/or complex Boolean logic.
[See documentation](docs/XGREP.md)

**New for 2026:** The command-line scripts were rewritten in Bash 3.2:
 * provide a simpler installation experience on Linux and macOS without any external dependencies
 * `feature` now includes many new sub-commands to better support the entire life-cycle of a feature branch
 * `xgrep` not only supports searching from within Git repositories but also searching from within any directory.
In repositories, it uses the power and speed of `git grep`. Outside of repositories, it falls back to using `find`/`grep`. Either way, it uses the same command-line interface.

## Installation for Linux users

### Linux Step 1: Clone the repository

First, copy/paste the following to choose the full path for the repository.

```bash
{
  read -r -p "Clone git-utilities into which directory? [$HOME/GitHub/rkiel/git-utilities] " GIT_UTILITIES_ROOT
  GIT_UTILITIES_ROOT=${GIT_UTILITIES_ROOT:-"$HOME/GitHub/rkiel/git-utilities"}
}
```

Then, copy/paste the following to create the directory and clone the repository.

```bash
{
  mkdir -p "$GIT_UTILITIES_ROOT"
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

  if [ -z "$FEATURE_USER" ] ||
      printf '%s\n' "$FEATURE_USER" | LC_ALL=C grep -Eq '[^A-Za-z0-9_]'; then
    printf 'FEATURE_USER must contain only letters, numbers, and underscores\n' >&2
    unset FEATURE_USER
    false
  fi
}
```

### Linux Step 3: Environment Variables

Copy/paste the following to update your `.bashrc` to execute the git-utilities
`profile.sh` script for every interactive shell. The script will:

* export environment variable `FEATURE_USER` with that unique identifier
* add `$GIT_UTILITIES_ROOT/bin` to your `$PATH`

`FEATURE_USER` and the source file are checked before `.bashrc` is updated. The
generated entry checks the file again before sourcing it, so the shell will
still start normally if the repository is later moved or removed.

```bash
{
  if [ -z "${FEATURE_USER+x}" ]; then
    printf 'git-utilities: FEATURE_USER is not defined\n' >&2
  elif [ ! -r "$GIT_UTILITIES_ROOT/dotfiles/bash/profile.sh" ]; then
    printf 'git-utilities: cannot read %s\n' \
      '$GIT_UTILITIES_ROOT/dotfiles/bash/profile.sh' >&2

    printf '$GIT_UTILITIES_ROOT is defined as: %s\n' \
      "$GIT_UTILITIES_ROOT" >&2
  else
    printf '\nif [ -r "%s/dotfiles/bash/profile.sh" ]; then\n  source "%s/dotfiles/bash/profile.sh" "%s"\nfi\n' \
      "$GIT_UTILITIES_ROOT" "$GIT_UTILITIES_ROOT" "$FEATURE_USER" >> "$HOME/.bashrc"

    source "$GIT_UTILITIES_ROOT/dotfiles/bash/profile.sh" "$FEATURE_USER"
    printf '\nSUCCESS: updated %s\n' "$HOME/.bashrc"
  fi
}
```

### Linux Step 4: Add tab completion (OPTIONAL)

Tab completion suggests `feature` subcommands and filesystem paths as you type.
This convenience is not required to use `feature` or `xgrep`.

Copy/paste the following to add tab completion to your `.bashrc` and load it into
your current shell:

```bash
{
  if [ -r "$GIT_UTILITIES_ROOT/dotfiles/bash/tab_completion.sh" ]; then
    printf '\nif [ -r "%s/dotfiles/bash/tab_completion.sh" ]; then\n  source "%s/dotfiles/bash/tab_completion.sh"\nfi\n' \
      "$GIT_UTILITIES_ROOT" "$GIT_UTILITIES_ROOT" >> "$HOME/.bashrc"

    source "$GIT_UTILITIES_ROOT/dotfiles/bash/tab_completion.sh"
    printf '\nSUCCESS: updated %s\n' "$HOME/.bashrc"
  else
    printf 'git-utilities: cannot read %s\n' \
      '$GIT_UTILITIES_ROOT/dotfiles/bash/tab_completion.sh' >&2

    printf '$GIT_UTILITIES_ROOT is defined as: %s\n' \
      "$GIT_UTILITIES_ROOT" >&2
  fi
}
```

### Linux Step 5: Install aliases (OPTIONAL)

The optional shell helpers define short command names that may replace aliases
you already use. They also provide `ssh-start`, which starts an SSH agent when
needed and loads `$HOME/.ssh/id_ed25519`. This remembers the key's passphrase
for the agent session. [Review the available helpers](dotfiles/shared/aliases.sh)
before enabling them.

Copy/paste the following to add the aliases to your `.bashrc` and load them into
your current shell:

```bash
{
  if [ -r "$GIT_UTILITIES_ROOT/dotfiles/shared/aliases.sh" ]; then
    printf '\nif [ -r "%s/dotfiles/shared/aliases.sh" ]; then\n  source "%s/dotfiles/shared/aliases.sh"\nfi\n' \
      "$GIT_UTILITIES_ROOT" "$GIT_UTILITIES_ROOT" >> "$HOME/.bashrc"

    source "$GIT_UTILITIES_ROOT/dotfiles/shared/aliases.sh"
    printf '\nSUCCESS: updated %s\n' "$HOME/.bashrc"
  else
    printf 'git-utilities: cannot read %s\n' \
      '$GIT_UTILITIES_ROOT/dotfiles/shared/aliases.sh' >&2

    printf '$GIT_UTILITIES_ROOT is defined as: %s\n' \
      "$GIT_UTILITIES_ROOT" >&2
  fi
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

First, copy/paste the following to choose the full path for the repository.

```zsh
{
  read -r "GIT_UTILITIES_ROOT?Clone git-utilities into which directory? [$HOME/GitHub/rkiel/git-utilities] "
  GIT_UTILITIES_ROOT=${GIT_UTILITIES_ROOT:-"$HOME/GitHub/rkiel/git-utilities"}
}
```

Then, copy/paste the following to create the directory and clone the repository.

```zsh
{
  mkdir -p "$GIT_UTILITIES_ROOT"
  git clone https://github.com/rkiel/git-utilities.git "$GIT_UTILITIES_ROOT"
}
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

  if [ -z "$FEATURE_USER" ] ||
      printf '%s\n' "$FEATURE_USER" | LC_ALL=C grep -Eq '[^A-Za-z0-9_]'; then
    printf 'FEATURE_USER must contain only letters, numbers, and underscores\n' >&2
    unset FEATURE_USER
    false
  fi
}
```

### macOS Step 3: Environment Variables

Copy/paste the following to update your `.zprofile` to execute the git-utilities
`profile.sh` script that will:

* export environment variable `FEATURE_USER` with that unique identifier
* add `$GIT_UTILITIES_ROOT/bin` to your `$PATH`

`FEATURE_USER` and the source file are checked before `.zprofile` is updated.
The generated entry checks the file again before sourcing it, so the shell will
still start normally if the repository is later moved or removed.

```zsh
{
  if [ -z "${FEATURE_USER+x}" ]; then
    printf 'git-utilities: FEATURE_USER is not defined\n' >&2
  elif [ ! -r "$GIT_UTILITIES_ROOT/dotfiles/zsh/profile.sh" ]; then
    printf 'git-utilities: cannot read %s\n' \
      '$GIT_UTILITIES_ROOT/dotfiles/zsh/profile.sh' >&2

    printf '$GIT_UTILITIES_ROOT is defined as: %s\n' \
      "$GIT_UTILITIES_ROOT" >&2
  else
    printf '\nif [ -r "%s/dotfiles/zsh/profile.sh" ]; then\n  source "%s/dotfiles/zsh/profile.sh" "%s"\nfi\n' \
      "$GIT_UTILITIES_ROOT" "$GIT_UTILITIES_ROOT" "$FEATURE_USER" >> "$HOME/.zprofile"

    source "$GIT_UTILITIES_ROOT/dotfiles/zsh/profile.sh" "$FEATURE_USER"
    printf '\nSUCCESS: updated %s\n' "$HOME/.zprofile"
  fi
}
```

### macOS Step 4: Add tab completion (OPTIONAL)

Tab completion suggests `feature` subcommands and filesystem paths as you type.
This convenience is not required to use `feature` or `xgrep`.

Copy/paste the following to add tab completion to your `.zshrc` and load it into
your current shell:

```zsh
{
  if [ -r "$GIT_UTILITIES_ROOT/dotfiles/zsh/tab_completion.sh" ]; then
    printf '\nif [ -r "%s/dotfiles/zsh/tab_completion.sh" ]; then\n  source "%s/dotfiles/zsh/tab_completion.sh"\nfi\n' \
      "$GIT_UTILITIES_ROOT" "$GIT_UTILITIES_ROOT" >> "$HOME/.zshrc"

    source "$GIT_UTILITIES_ROOT/dotfiles/zsh/tab_completion.sh"
    printf '\nSUCCESS: updated %s\n' "$HOME/.bashrc"
  else
    printf 'git-utilities: cannot read %s\n' \
      '$GIT_UTILITIES_ROOT/dotfiles/zsh/tab_completion.sh' >&2

    printf '$GIT_UTILITIES_ROOT is defined as: %s\n' \
      "$GIT_UTILITIES_ROOT" >&2
  fi
}
```

### macOS Step 5: Install aliases (OPTIONAL)

The optional shell helpers define short command names that may replace aliases
you already use. They also provide `ssh-start`, which starts an SSH agent when
needed and loads `$HOME/.ssh/id_ed25519`. This remembers the key's passphrase
for the agent session. [Review the available helpers](dotfiles/shared/aliases.sh)
before enabling them.

Copy/paste the following to add the aliases to your `.zshrc` and load them into
your current shell:

```zsh
{
  if [ -r "$GIT_UTILITIES_ROOT/dotfiles/shared/aliases.sh" ]; then
    printf '\nif [ -r "%s/dotfiles/shared/aliases.sh" ]; then\n  source "%s/dotfiles/shared/aliases.sh"\nfi\n' \
      "$GIT_UTILITIES_ROOT" "$GIT_UTILITIES_ROOT" >> "$HOME/.zshrc"

    source "$GIT_UTILITIES_ROOT/dotfiles/shared/aliases.sh"
    printf '\nSUCCESS: updated %s\n' "$HOME/.bashrc"
  else
    printf 'git-utilities: cannot read %s\n' \
      '$GIT_UTILITIES_ROOT/dotfiles/shared/aliases.sh' >&2

    printf '$GIT_UTILITIES_ROOT is defined as: %s\n' \
      "$GIT_UTILITIES_ROOT" >&2
  fi
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
