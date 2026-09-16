# Feature Workflow

`bin/feature` is a Bash helper for short-lived, personal feature branches. The
remote feature branch is treated as a backup and code-review copy of local work;
the branch owner is expected to be the only person changing it.

## Branch Format

Feature branches created by the script use:

```text
f-<initial-branch>-<ticket>-<user>-<description>
```

Example:

```bash
FEATURE_USER=sam feature start 123 add login
# f-main-123-sam-add-login
```

`FEATURE_USER` overrides the user field. If unset, the script uses `id -un`.
The user field may contain only letters, numbers, and underscores.

The initial branch must contain only letters and numbers, such as `main`,
`master`, or `release2026`.

## Commands

```bash
feature help
feature status
feature start <ticket-number> <words...>
feature commit <message...>
feature rebase
feature merge
feature end
feature trash <feature-branch>
```

`feature start` must be run from an initial branch. It fetches all remotes,
prunes stale refs, fetches tags, rebases the initial branch on
`origin/<initial-branch>` with autostash, creates the feature branch, pushes it
to `origin`, and sets upstream tracking.

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

`feature status` reports the current branch, parsed feature metadata when
available, staged changes, unstaged tracked changes, untracked files, remote
branch presence, and ahead/behind counts.

## Safety Rules

- Feature branches are considered personal and single-owner.
- Feature branch pushes use `--force` because local work is the source of truth.
- Initial branch pushes are normal pushes, never force pushes.
- `rebase` and `merge` block staged changes and unstaged tracked changes.
- Untracked files are allowed so local scratch files do not block the workflow.
- `trash` requires the exact feature branch name as confirmation.
- `end` only deletes a feature branch after it agrees with the initial branch.

## Testing

Run the regression tests after changing `bin/feature`:

```bash
tests/feature_test.sh
```

The tests create disposable Git repositories and bare remotes under `/tmp`.
They do not touch real repositories or remotes.

## Maintenance Rule

Any behavior change to `bin/feature` must update `tests/feature_test.sh` in the
same change. New subcommands need at least one happy-path test and one
guard/error test. Branch-format or safety-rule changes must update both this
document and the tests. Before considering a change complete, run:

```bash
tests/feature_test.sh
```

## Open Question

`feature merge` pushes directly to the initial branch. That fits repos where the
user may push to `main`/`master` directly. For repos with protected branches or
PR-only policies, this command may need a different final step.
