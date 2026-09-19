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

Clone the repository

```
mkdir -p ~/GitHub/rkiel && cd $_
git clone https://github.com/rkiel/git-utilities.git
```

### Linux users (bash)

Update your `.bash_profile`

```
source ~/GitHub/rkiel/git-utilities/dotfiles/bash/profile.sh bob
```

Update your `.bashrc`

```
source ~/GitHub/rkiel/git-utilities/dotfiles/bash/rc.sh
```

### macOS users (zsh)

Update your `.zprofile`

```
source ~/GitHub/rkiel/git-utilities/dotfiles/zsh/profile.sh bob
```

Update your `.zshrc`

```
source ~/GitHub/rkiel/git-utilities/dotfiles/zsh/rc.sh
```


## Documentation

- `feature` - [ [classic Ruby version](docs/ruby/FEATURE.md) ] [ [new Bash version](docs/bash/FEATURE.md) ]
- `xgrep` - [ [classic Ruby version](docs/ruby/XGREP.md) ]
- `xfind` - [ [classic Ruby version](docs/ruby/XFIND.md) ]
