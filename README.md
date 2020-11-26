## Introduction

This is a collection of simple command-line scripts, bash aliases, and bash utilities that make using `git` even easier.

The command-line scripts include:

- [feature](FEATURE.md) - make working with feature branches easier
- [release](RELEASE.md)- make working with release branches and tags easier (DEPRECATED)
- [xgrep](XGREP.md)- make using `git-grep` easier
- [xfind](XFIND.md)- make using `find` easier

The command-line scripts are written in Ruby 2.x using just the standard libraries and do not require any gems to be installed.
For OS X users, these should just work out-of-box.

The `bash` utilities come directly from the [git source contrib](https://github.com/git/git/tree/master/contrib) and include:

- support for [tab completion](https://github.com/git/git/tree/master/contrib/completion/git-completion.bash)
- support for repository status in your [shell prompt](https://github.com/git/git/tree/master/contrib/completion/git-prompt.sh)

## Installation

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

## Documention

- [See feature](FEATURE.md)
- [See release](RELEASE.md) (DEPRECATED)
- [See xgrep](XGREP.md)
- [See xfind](XFIND.md)
