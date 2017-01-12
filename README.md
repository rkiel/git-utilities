## Introduction

This is a collection of simple command-line scripts, bash aliases, and bash utilities that make using `git` even easier.

The command-line scripts include:

* feature - make working with feature branches easier
* xgrep - make using `git-grep` easier

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

## Feature utility

### Usage

This utility is built around some standard branch names: `master`, `develop`, and `integration`.

Feature branches have specific format: USER-BASE-FEATURE.

* USER is the username as specificied by the USER environment variable
* BASE is the standard branch to base the feature branch on
* FEATURE is the name of the feature

#### Start

To start a new feature, go to one of the standard branches.

```
git checkout master
```

Use the `start` subcommand with a feature name.

```
feature start my new feature
```

For example, a new branch will be created called `rkiel-master-my-new-feature`

#### Rebase

Use the `rebase` subcommand to pull down any changes from the standard branch and then rebase with your feature branch changes.
In addition, a backup copy of your feature changes will be pushed out to `origin`.
This backup should not be used to collaborate with others.  It is just a personal backup and will be deleted and recreated with each `rebase`.

```
feature rebase
```

For example, `rkiel-master-my-new-feature` will be pushed out to `origin`.

#### Merge

Use the `merge` subcommand to merge your feature branch changes to the standard branch.

```
feature merge
```

You can also override the default standard branch by specifying another branch.

```
feature merge integration
```

#### Commit

Use the `commit` subcommand to make it easier to write commit messages.
No need to specify the `-m` parameter or wrapping the message in quotes.
If you forget and pass in `-m` anyway, it will ignore it.
For example,

```
feature commit this is a sample commit message
feature commit -m this is a sample commit message
```

generates the command `git commit -m "this is a sample commit message"`.

The commit message will be prepended with the feature name.  For example,

```
my-feature-name: this is a sample commit message
```
If you need to by-pass any git pre-commit hooks, you can use the `-f` option to force the commit.
This will invoke the commit with the `--no-verify` option.
It will also add `(no-verify)` to the end of your commit message. For example,

```
feature commit -f this is a sample commit message
feature commit -m this is a sample commit message -f
```

generates the command `git commit -m "this is a sample commit message (no-verify)" --no-verify`.


#### End

Use the `end` subcommand to safely close out the feature.
The standard branch will be checkout and the local feature branch will be deleted.
This command will fail if you have not merged your changes.
If successful and there is a backup copy on `origin`, it will also be removed.

```
feature end
```

#### Trash

Use the `trash` subcommand to forcibly close out the feature.
The standard branch will be checkout and the local feature branch will be forcibly deleted.
Make sure that your changes have been merged because they will be lost.
If there is a backup copy on `origin`, it will also be removed.

```
feature trash
```

## Xgrep utility

This utility makes it easier to use git-grep.
