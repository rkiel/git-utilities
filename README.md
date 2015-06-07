## Introduction

This is a collection of simple command-line scripts, bash aliases, and bash utilities that make using `git` even easier.

The command-line scripts include:

* commit - make using `git-commmit` easier
* feature - make working with feature branches easier
* xgrep - make using `git-grep` easier

The `bash` utilities come directly from the [git source contrib](https://github.com/git/git/tree/master/contrib) and include:

* support for [tab completion](https://github.com/git/git/tree/master/contrib/completion)
* support for customizing [shell prompt](https://github.com/git/git/tree/master/contrib/completion)

## Installation

Clone the repository

```
mkdir -p ~/GitHub/rkiel
cd ~/GitHub/rkiel
git clone git@github.com:rkiel/git-utilities.git
```

To add the scripts to your path, add the following to `.bash_profile`

```
export GIT_UTILITIES_BIN="~/GitHub/rkiel/git-utilities/bin"

export PATH=${GIT_UTILITIES_BIN}:$PATH
```

To enable `bash` tab completion for `git` commands, add the following to `.bash_profile`

```
source ~/GitHub/rkiel/git-utilities/dotfiles/git-completion.bash
```

To enable your `bash` prompt to display the current `git` branch, add the following to `.bash_profile`
```
source ~/GitHub/rkiel/git-utilities/dotfiles/git-prompt.sh
```

To include the `bash` aliases and enable tab completion for the `feature` script, add the following to `.bashrc`

```
source ~/GitHub/rkiel/git-utilities/dotfiles/bashrc
```

## Commit utility

This utility makes it easier to write commit messages.
No need to specify the `-m` parameter or wrapping the message in quotes.
For example,

```
commit this is a sample commit message
```

generates the command `git commit -m "this is a sample commit message"`.

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
feature start my-new-feature
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

#### End

Use the `end` subcommand to close out the feature.
The standard branch will be checkout and the local feature branch will be forcibly deleted.
Make sure that your changes have been merged.
If there is a backup copy on `origin`, it will also be removed.

```
feature end
```

## Xgrep utility

This utility makes it easier to use git-grep.
