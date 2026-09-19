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

When you create a feature branch, it will include a name that identifies and distinguishes
your branches from branches created by other members of your team. Choose a
short name containing only letters, numbers, and underscores.

Your bash/zsh dot files will be updated appropriately.

#### Linux users (bash)

```bash
{
  read -r -p "Clone into which directory? [$HOME/GitHub/rkiel] " GIT_UTILITIES_ROOT
  GIT_UTILITIES_ROOT=${GIT_UTILITIES_ROOT:-"$HOME/GitHub/rkiel"}
  mkdir -p "$GIT_UTILITIES_ROOT"
  git clone https://github.com/rkiel/git-utilities.git "$GIT_UTILITIES_ROOT/git-utilities"
  GIT_UTILITIES_ROOT="$GIT_UTILITIES_ROOT/git-utilities"
}
```

```bash
{
  read -r -p 'Enter a user name: ' FEATURE_USER
  printf '\nsource "%s/dotfiles/bash/profile.sh" "%s"\n' \
    "$GIT_UTILITIES_ROOT" "$FEATURE_USER" >> "$HOME/.bash_profile"
  printf '\nsource "%s/dotfiles/bash/rc.sh"\n' \
    "$GIT_UTILITIES_ROOT" >> "$HOME/.bashrc"
  unset FEATURE_USER GIT_UTILITIES_ROOT
}
```

#### macOS users (zsh)

```zsh
{
  read -r 'GIT_UTILITIES_ROOT?Clone into which directory? [$HOME/GitHub/rkiel] '
  GIT_UTILITIES_ROOT=${GIT_UTILITIES_ROOT:-"$HOME/GitHub/rkiel"}
  mkdir -p "$GIT_UTILITIES_ROOT"
  git clone https://github.com/rkiel/git-utilities.git "$GIT_UTILITIES_ROOT/git-utilities"
  GIT_UTILITIES_ROOT="$GIT_UTILITIES_ROOT/git-utilities"
}
```

```zsh
{
  read -r 'FEATURE_USER?Enter a user name: '
  printf '\nsource "%s/dotfiles/zsh/profile.sh" "%s"\n' \
    "$GIT_UTILITIES_ROOT" "$FEATURE_USER" >> "$HOME/.zprofile"
  printf '\nsource "%s/dotfiles/zsh/rc.sh"\n' \
    "$GIT_UTILITIES_ROOT" >> "$HOME/.zshrc"
  unset FEATURE_USER GIT_UTILITIES_ROOT
}
```

Open a new terminal after completing the shell-specific step.

## Documentation

- `feature` - [ [classic Ruby version](docs/ruby/FEATURE.md) ] [ [new Bash version](docs/bash/FEATURE.md) ]
- `xgrep` - [ [classic Ruby version](docs/ruby/XGREP.md) ]
- `xfind` - [ [classic Ruby version](docs/ruby/XFIND.md) ]
