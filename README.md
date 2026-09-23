## Introduction

This is a collection of simple command-line scripts/wrappers and a few aliases to make using `git` even easier.

The command-line scripts include:

- `feature` - Feature branches are now easier to use and provide consistency across your team.
- `xgrep` - Searching in a repository is now easier by harnessing the power of `git-grep`.
- `xfind` - Searching outside a repository is now easier by harnessing the power of `find` and `grep`.

## Releases

For 2026, the command-line scripts have been re-written in Bash 3.2 which should work out-of-the-box on Linux and macOS.

The previous version, was written in Ruby 2.x using just the standard libraries and do not require any gems to be installed.
It is now deprecated but you can still it by [following these instructions](docs/ruby/INSTALL.md).

## Documentation

- `feature` - [ [new Bash version](docs/bash/FEATURE.md) ] [ [deprecated Ruby version](docs/ruby/FEATURE.md) ]
- `xgrep` - [ [new Bash version](docs/bash/XGREP.md) ] [ [deprecated Ruby version](docs/ruby/XGREP.md) ]
- `xfind` - [ [new Bash version](docs/bash/XFIND.md) ] [ [deprecated Ruby version](docs/ruby/XFIND.md) ]

## Installation

Please follow either the **Linux user** installation or the **macOS user** installation.

### Linux user

This repository needs to be cloned.  Copy/paste the following to be prompted for the location to clone into.

```bash
{
  read -r -p "Clone into which directory? [$HOME/GitHub/rkiel] " GITHUB_REPOS_DIR
  GITHUB_REPOS_DIR=${GITHUB_REPOS_DIR:-"$HOME/GitHub/rkiel"}

  mkdir -p "$GITHUB_REPOS_DIR"

  GIT_UTILITIES_ROOT="$GITHUB_REPOS_DIR/git-utilities"
  git clone https://github.com/rkiel/git-utilities.git "$GIT_UTILITIES_ROOT"

  ls -l "$GIT_UTILITIES_ROOT"
}
```

When you create a feature branch, it will include a name that identifies and distinguishes
your branches from branches created by other members of your team. Choose a
short name containing only letters, numbers, and underscores.

Update your `.bash_profile` to load the git-utilities `profile.sh` script that will:

* export environment variable `FEATURE_USER` with that short name
* add `$GIT_UTILITIES_ROOT/bin/bash` to your `$PATH`

```bash
{
  read -r -p 'Enter a user name: ' FEATURE_USER

  printf '\nsource "%s/dotfiles/bash/profile.sh" "%s"\n' \
    "$GIT_UTILITIES_ROOT" "$FEATURE_USER" >> "$HOME/.bash_profile"

  cat "$HOME/.bash_profile"
}
```

Update your `.bashrc` to load the git-utilities `rc.sh` script that will:

* define some aliases
* add support for shell tab completion

```bash
{
  printf '\nsource "%s/dotfiles/bash/rc.sh"\n' \
    "$GIT_UTILITIES_ROOT" >> "$HOME/.bashrc"

  cat "$HOME/.bashrc"
}
```

Load the `profile.sh` and `rc.sh` into your current shell and verify correctness.

```bash
{
  source "$GIT_UTILITIES_ROOT/dotfiles/bash/profile.sh" "$FEATURE_USER"
  source "$GIT_UTILITIES_ROOT/dotfiles/bash/rc.sh"
  command -v feature
  command -v xfind
  command -v xgrep
}
```

### macOS user

This repository needs to be cloned.  Copy/paste the following to be prompted for the location to clone into.

```zsh
{
  read -r "GITHUB_REPOS_DIR?Clone into which directory? [$HOME/GitHub/rkiel] "
  GITHUB_REPOS_DIR=${GITHUB_REPOS_DIR:-"$HOME/GitHub/rkiel"}

  mkdir -p "$GITHUB_REPOS_DIR"

  GIT_UTILITIES_ROOT="$GITHUB_REPOS_DIR/git-utilities"
  git clone https://github.com/rkiel/git-utilities.git "$GIT_UTILITIES_ROOT"

  ls -l "$GIT_UTILITIES_ROOT"
}
```

When you create a feature branch, it will include a name that identifies and distinguishes
your branches from branches created by other members of your team. Choose a
short name containing only letters, numbers, and underscores.

Update your `.zprofile` to load the git-utilities `profile.sh` script that will:

* export environment variable `FEATURE_USER` with that short name
* add `$GIT_UTILITIES_ROOT/bin/bash` to your `$PATH`

```zsh
{
  read -r 'FEATURE_USER?Enter a user name: '

  printf '\nsource "%s/dotfiles/zsh/profile.sh" "%s"\n' \
    "$GIT_UTILITIES_ROOT" "$FEATURE_USER" >> "$HOME/.zprofile"

  cat "$HOME/.zprofile"
}
```

Update your `.zshrc` to load the git-utilities `rc.sh` script that will:

* define some aliases
* add support for shell tab completion

```zsh
{
  printf '\nsource "%s/dotfiles/zsh/rc.sh"\n' \
    "$GIT_UTILITIES_ROOT" >> "$HOME/.zshrc"

  cat "$HOME/.zshrc"
}
```

Load the `profile.sh` and `rc.sh` into your current shell and verify correctness.

```zsh
{
  source "$GIT_UTILITIES_ROOT/dotfiles/zsh/profile.sh" "$FEATURE_USER"
  source "$GIT_UTILITIES_ROOT/dotfiles/zsh/rc.sh"
  command -v feature
  command -v xfind
  command -v xgrep
}
```

