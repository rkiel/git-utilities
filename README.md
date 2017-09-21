## Introduction

This is a collection of simple command-line scripts, bash aliases, and bash utilities that make using `git` even easier.

The command-line scripts include:

* [feature](FEATURE.md) - make working with feature branches easier
* [release](RELEASE.md)- make working with release branches and tags easier
* [xgrep](XGREP.md)- make using `git-grep` easier

The command-line scripts are written in Ruby 2.x using just the standard libraries and do not require any gems to be installed.
For OS X users, these should just work out-of-box.

The `bash` utilities come directly from the [git source contrib](https://github.com/git/git/tree/master/contrib) and include:

* support for [tab completion](https://github.com/git/git/tree/master/contrib/completion/git-completion.bash)
* support for repository status in your [shell prompt](https://github.com/git/git/tree/master/contrib/completion/git-prompt.sh)

## Installation

Clone the repository

```
mkdir -p ~/GitHub/rkiel
cd ~/GitHub/rkiel
git clone https://github.com/rkiel/git-utilities.git
```

To add the scripts to your path, add the following to `.bash_profile`

```
export GIT_UTILITIES_BIN="~/GitHub/rkiel/git-utilities/bin"

export PATH=${GIT_UTILITIES_BIN}:$PATH
```

To enable `bash` tab completion for `git` commands, add the following to `.bash_profile` (OS X) or `.bashrc` (Linux)

```
source ~/GitHub/rkiel/git-utilities/dotfiles/git-completion.bash
```

To enable your `bash` prompt to display repository status, add the following to `.bash_profile` (OS X) or `.bashrc` (Linux).
```
source ~/GitHub/rkiel/git-utilities/dotfiles/git-prompt.sh
```

Here's a sample prompt that includes the current branch (i.e. `$(__git_ps1 " %s")`)

```
export PS1='[\[\e[0;35m\]\u@\h\[\e[0m\] \[\e[1;34m\]\W\[\e[0;32m\]$(__git_ps1 " %s")\[\e[0m\]]\$ '
```

To include the `bash` aliases and enable tab completion for the `feature` script, add the following to `.bashrc`.

```
source ~/GitHub/rkiel/git-utilities/dotfiles/bashrc
```

If your user id (i.e. `env|grep USER`) is generic, such as `ec2-user` or `centos` or `ubuntu`, set a `FEATURE_USER` environment variable in your `.bash_profile`.  Either your `USER` or `FEATURE_USER` should be unique relative to all the users who will be creating feature branches in your git repository.

```
export FEATURE_USER=rkiel
```
## Documention

* [See feature](FEATURE.md)
* [See release](RELEASE.md)
* [See xgrep](XGREP.md)
