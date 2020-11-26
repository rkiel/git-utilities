[<<back](README.md)

## Feature utility

### Usage

This feature branch utility is built to work with a set of standard branches (`develop`,`main`,`master`,`release`).
These are the starting point branches from which you can create feature branches.
It is assumed that your starting point branch exists both locally and remotely.

You can override the default set of standard branches by incorporating a `.git-utilities-rc` file (JSON) into your project repository.
Branch names should be limited to a single word.

```json
{
  "branches": ["develop", "test", "production"]
}
```

Feature branch names have a specific format: USER-BRANCH-DESCRIPTION.

- USER is the owner of the feature branch and is specified by either the FEATURE_USER or USER environment variables. This should prevent any feature branch name conflicts and make it easier to know who to talk to about deleting old/unused feature branches.
- BRANCH is the standard branch from which the feature branch was started
- DESCRIPTION is a series of one or more words which describe the feature. The description will be prepended to all commit messages.

#### Start

To start a new feature, checkout one of the standard branches.
Use the `start` subcommand followed by a short series of words to describe the feature.
For example, use a bug number and a short phrase as the description.

```
git checkout develop
feature start 4365 update help
```

In this example, user `bob` will create a new branch called `bob-develop-4365-update-help`.

If you start with a branch other than one of the standard branches you will get an error.
For example,

```
git checkout hotfixes
feature start 4365 update help

ERROR: invalid base branch. must be one of: develop, main, master, release
```

#### Commit

Use the `commit` subcommand to make it easier to write commit messages.
No need to specify the `-m` parameter or wrapping the message in quotes.
Of course, if you forget and pass in `-m` anyway, it will be ignore it.
The feature branch description will be prepended to your commit message.
For example,

```
feature commit corrected spelling mistakes
```

will generate the following commit message:

```
4365-update-help: corrected spelling mistakes
```

If you need to by-pass any git pre-commit hooks, you can use the `-f` option to force the commit.
This will invoke the commit with the `--no-verify` option.
It will also add `(no-verify)` to the end of your commit message. For example,

```
feature commit -f corrected spelling mistakes
```

will generate the following commit message:

```
4365-update-help: corrected spelling mistakes (no-verify)
```

#### Rebase

Use the `rebase` subcommand to pull down any changes from the standard branch and then rebase with your feature branch changes.
In addition, a backup copy of your feature changes will be pushed out to `origin`.
This remote backup branch should NEVER be used to collaborate with others.
It is just a personal backup and will be deleted and recreated with each `rebase`.

```
feature rebase
```

For example, the `bob-develop-4365-update-help` branch will be pushed out to `origin`.

#### Merge

Use the `merge` subcommand to merge your feature branch changes to the standard branch.
A `rebase` will be performed automatically before the merge.

```
feature merge
```

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
If there is a backup copy on `origin`, it will also be removed.
As a safety precaution, you must supply the name of the local feature branch on the command line as
a confirmation. This will hopefully protect you from accidentally running `feature trash` when you meant `feature end`.

WARNING: Make sure that your changes have been merged because they will be lost.

For example,

```
feature trash bob-develop-4365-update-help
```
