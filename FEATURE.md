# Feature Workflow

`bin/bash/feature` is a Bash helper for short-lived, personal feature branches. The
remote feature branch is treated as a backup and code-review copy of local work;
the branch owner is expected to be the only person changing it.

## Branch Format

Feature branches created by the script use:

```text
<initial-branch>--<user>--<ticket>--<description>
```

Example:

```bash
FEATURE_USER=sam feature start 123 add login
# main--sam--123--add-login
```

`FEATURE_USER` overrides the user field. If unset, the script uses `id -un`.
The user field may contain only letters, numbers, and underscores.

The initial branch may use any valid Git branch name except one containing
`--`. The double dash is reserved for separating feature branch metadata, so
names such as `main`, `release/1.2.3`, and `release_candidate/2.0+qa` are
supported.

## Commands

```bash
feature help
feature info
feature status [<git-status-arguments...>]
feature start <ticket-number> <words...>
feature add <git-add-arguments...>
feature unstage <paths...>
feature commit <message...>
feature rebase
feature merge
feature end
feature trash <feature-branch>
```

`feature start` must be run from an initial branch. It fetches all remotes,
prunes stale refs, fetches tags, rebases the initial branch on
`origin/<initial-branch>` with autostash, creates the feature branch, pushes it
to `origin`, and sets upstream tracking. It rejects feature branches and any
other initial branch containing the reserved `--` delimiter.

`feature add <git-add-arguments...>` must be run from a feature branch. It
passes all arguments directly to `git add`, allowing files, pathspecs, and Git
options such as `--patch` or `--all`. It stages changes but does not commit or
push them.

`feature unstage <paths...>` must be run from a feature branch. It runs
`git restore --staged -- <paths...>` to remove the specified paths from the
index without discarding their working-tree changes. It does not commit or
push anything.

`feature commit` must be run from a feature branch. It runs `git add --patch`,
commits with a message in the form `#<ticket> <message>`, then force-pushes the
feature branch to `origin`.

`feature rebase` must be run from a feature branch with no staged changes and no
unstaged tracked changes. Untracked files are allowed. It updates the initial
branch, interactively rebases the feature branch onto it using `;` as Git's
comment character, then force-pushes the feature branch to `origin`.

`feature merge` does everything `feature rebase` does, then switches to the
initial branch, fast-forwards it from the feature branch, pushes the initial
branch normally to `origin`, and switches back to the feature branch.

`feature end` must be run from a feature branch. It fails unless the feature
branch and initial branch agree. If they do, it switches to the initial branch,
deletes the remote feature branch, deletes the local feature branch, and prunes
`origin`.

`feature trash <feature-branch>` must be run from that exact feature branch. It
does not check whether work was merged. It switches to the initial branch,
deletes the remote feature branch, deletes the local feature branch, and prunes
`origin`.

`feature info` reports the current branch, parsed feature metadata when
available, staged changes, unstaged tracked changes, untracked files, remote
branch presence, and ahead/behind counts.

`feature status [<git-status-arguments...>]` passes all arguments directly to
`git status` and returns its output and exit status without adding wrapper
output. With no arguments it displays the normal Git status. Options such as
`--short --branch` and `--porcelain` behave exactly as they do with Git.

## Safety Rules

- Feature branches are considered personal and single-owner.
- Feature branches use `<initial>--<user>--<ticket>--<description>`.
- Initial branches may use any Git-valid name except one containing `--`.
- A feature branch cannot be started from another feature branch.
- `add` and `unstage` operate only on feature branches and never push.
- Feature branch pushes use `--force` because local work is the source of truth.
- Initial branch pushes are normal pushes, never force pushes.
- `rebase` and `merge` block staged changes and unstaged tracked changes.
- Untracked files are allowed so local scratch files do not block the workflow.
- `trash` requires the exact feature branch name as confirmation.
- `end` only deletes a feature branch after it agrees with the initial branch.

## Cross-Platform Compatibility

- `feature` supports Linux and macOS and assumes that Bash and Git are
  installed.
- The script must remain compatible with Bash 3.2 or newer so it works with
  the Bash version included with macOS. Do not use features introduced in Bash
  4 or later.
- Git 2.23 is the minimum supported version because the script uses
  `git switch`. Do not introduce commands or options from newer Git versions
  without deliberately raising and documenting the minimum version.
- External commands and command-line options must behave consistently with
  both GNU utilities on Linux and BSD utilities on macOS. Avoid GNU-only
  options unless a portable fallback is provided.
- Keep the `#!/usr/bin/env bash` interpreter line. A user's interactive shell,
  including zsh on macOS, must not change how the script runs.
- Compatibility changes must be covered by the regression suite and verified
  on both Linux and macOS before release.

## Testing

Run the regression tests after changing `bin/bash/feature`:

```bash
tests/feature_test.sh
```

The tests create disposable Git repositories and bare remotes under `/tmp`.
They do not touch real repositories or remotes.

## Maintenance Rule

Any behavior change to `bin/bash/feature` must update `tests/feature_test.sh` in the
same change. New subcommands need at least one happy-path test and one
guard/error test. Branch-format or safety-rule changes must update both this
document and the tests. Every change must also be reviewed against the
cross-platform compatibility rules above. Before considering a change
complete, run:

```bash
tests/feature_test.sh
```

## Open Question

`feature merge` pushes directly to the initial branch. That fits repos where the
user may push to `main`/`master` directly. For repos with protected branches or
PR-only policies, this command may need a different final step.
