## Introduction

This is a collection of simple command-line scripts, bash aliases, and bash utilities that make using `git` even easier.

The command-line scripts include:

- `feature` - make working with feature branches easier
- `xgrep` - make using `git-grep` easier
- `xfind` - make using `find` easier

The "classic" version command-line scripts are written in Ruby 2.x using just the standard libraries and do not require any gems to be installed.

The "new" version command-line scripts are written in Bash 3.2 which should work out-of-the-box on Linux and macOS.

The `bash` utilities come directly from the [git source contrib](https://github.com/git/git/tree/master/contrib) and include:

- support for repository status in your [shell prompt](https://github.com/git/git/tree/master/contrib/completion/git-prompt.sh)

## Installation - classic Ruby version

Clone the repository

```
mkdir -p ~/GitHub/rkiel && cd $_
git clone https://github.com/rkiel/git-utilities.git
```

To update your `.bash_profile` and `.bashrc`.

```
cd ~/GitHub/rkiel/git-utilities
./install/bin/setup $USER
```

## Installation - new Bash version


#### Linux users (bash)

This repository needs to be cloned.  Copy/paste the following to be prompted for the location to clone into.

```bash
{
  read -r -p "Clone into which directory? [$HOME/GitHub/rkiel] " GIT_UTILITIES_ROOT
  GIT_UTILITIES_ROOT=${GIT_UTILITIES_ROOT:-"$HOME/GitHub/rkiel"}
  mkdir -p "$GIT_UTILITIES_ROOT"
  git clone https://github.com/rkiel/git-utilities.git "$GIT_UTILITIES_ROOT/git-utilities"
  GIT_UTILITIES_ROOT="$GIT_UTILITIES_ROOT/git-utilities"
}
```

When you create a feature branch, it will include a name that identifies and distinguishes
your branches from branches created by other members of your team. Choose a
short name containing only letters, numbers, and underscores.

Your bash dot files will be updated appropriately.

```bash
{
  read -r -p 'Enter a user name: ' FEATURE_USER
  printf '\nsource "%s/dotfiles/bash/profile.sh" "%s"\n' \
    "$GIT_UTILITIES_ROOT" "$FEATURE_USER" >> "$HOME/.bash_profile"
  printf '\nsource "%s/dotfiles/bash/rc.sh"\n' \
    "$GIT_UTILITIES_ROOT" >> "$HOME/.bashrc"
}
```

Load the configuration into the current shell.

```bash
{
  source "$GIT_UTILITIES_ROOT/dotfiles/bash/profile.sh" "$FEATURE_USER"
  source "$GIT_UTILITIES_ROOT/dotfiles/bash/rc.sh"
}
```

#### macOS users (zsh)

This repository needs to be cloned.  Copy/paste the following to be prompted for the location to clone into.

```zsh
{
  read -r 'GIT_UTILITIES_ROOT?Clone into which directory? [$HOME/GitHub/rkiel] '
  GIT_UTILITIES_ROOT=${GIT_UTILITIES_ROOT:-"$HOME/GitHub/rkiel"}
  mkdir -p "$GIT_UTILITIES_ROOT"
  git clone https://github.com/rkiel/git-utilities.git "$GIT_UTILITIES_ROOT/git-utilities"
  GIT_UTILITIES_ROOT="$GIT_UTILITIES_ROOT/git-utilities"
}
```

When you create a feature branch, it will include a name that identifies and distinguishes
your branches from branches created by other members of your team. Choose a
short name containing only letters, numbers, and underscores.

Your zsh dot files will be updated appropriately.

```zsh
{
  read -r 'FEATURE_USER?Enter a user name: '
  printf '\nsource "%s/dotfiles/zsh/profile.sh" "%s"\n' \
    "$GIT_UTILITIES_ROOT" "$FEATURE_USER" >> "$HOME/.zprofile"
  printf '\nsource "%s/dotfiles/zsh/rc.sh"\n' \
    "$GIT_UTILITIES_ROOT" >> "$HOME/.zshrc"
}
```

Load the configuration into the current shell.

```zsh
{
  source "$GIT_UTILITIES_ROOT/dotfiles/zsh/profile.sh" "$FEATURE_USER"
  source "$GIT_UTILITIES_ROOT/dotfiles/zsh/rc.sh"
}
```

## Documentation

- `feature` - [ [classic Ruby version](docs/ruby/FEATURE.md) ] [ [new Bash version](docs/bash/FEATURE.md) ]
- `xgrep` - [ [classic Ruby version](docs/ruby/XGREP.md) ]
- `xfind` - [ [classic Ruby version](docs/ruby/XFIND.md) ]
