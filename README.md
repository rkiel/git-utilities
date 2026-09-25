## Introduction

This is a collection of simple command-line scripts/wrappers and a few aliases to make using `git` even easier.

The command-line scripts include:

- `feature` - Feature branches are now easier to use and provide consistency across your team.
- `xgrep` - Search with `git grep` inside repositories and `find`/`grep` everywhere else.

## Releases

The command-line scripts are written in Bash 3.2 and should work out of the box
on Linux and macOS.

## Documentation

- `feature` - [Documentation](docs/FEATURE.md)
- `xgrep` - [Documentation](docs/XGREP.md)

## Installation

Please follow either the **Linux user** installation or the **macOS user** installation.

### Linux user installation

This repository needs to be cloned.  Copy/paste the following to be prompted for the location to clone into.

```bash
{
  read -r -p "Clone this repo into which directory? [$HOME/GitHub/rkiel] " GITHUB_REPOS_DIR
  GITHUB_REPOS_DIR=${GITHUB_REPOS_DIR:-"$HOME/GitHub/rkiel"}
  GIT_UTILITIES_ROOT="$GITHUB_REPOS_DIR/git-utilities"

  mkdir -p "$GITHUB_REPOS_DIR"

  git clone https://github.com/rkiel/git-utilities.git "$GIT_UTILITIES_ROOT"
}
```

When you create a feature branch, it will include a name that identifies and distinguishes
your branches from branches created by other members of your team. Choose a
short name containing only letters, numbers, and underscores.

Update your `.bash_profile` to load the git-utilities `profile.sh` script that will:

* export environment variable `FEATURE_USER` with that short name
* add `$GIT_UTILITIES_ROOT/bin` to your `$PATH`

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
  command -v xgrep
}
```

### macOS user installation

This repository needs to be cloned.  Copy/paste the following to be prompted for the location to clone into.

```zsh
  read -r "GITHUB_REPOS_DIR?Clone this repo into which directory? [$HOME/GitHub/rkiel] "
  GITHUB_REPOS_DIR=${GITHUB_REPOS_DIR:-"$HOME/GitHub/rkiel"}
  GIT_UTILITIES_ROOT="$GITHUB_REPOS_DIR/git-utilities"

  mkdir -p "$GITHUB_REPOS_DIR"

  git clone https://github.com/rkiel/git-utilities.git "$GIT_UTILITIES_ROOT"
```

When you create a feature branch, it will include a name that identifies and distinguishes
your branches from branches created by other members of your team. Choose a
short name containing only letters, numbers, and underscores.

Update your `.zprofile` to load the git-utilities `profile.sh` script that will:

* export environment variable `FEATURE_USER` with that short name
* add `$GIT_UTILITIES_ROOT/bin` to your `$PATH`

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
  command -v xgrep
}
```
