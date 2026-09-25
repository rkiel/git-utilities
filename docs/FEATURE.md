# Feature

`feature` is a Bash helper for short-lived, personal feature branches. The
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
feature add <git-add-arguments...>
feature commit <message...>
feature end
feature help
feature info
feature log [<pretty-format>]
feature merge
feature rebase
feature start <ticket-number> <words...>
feature status [<git-status-arguments...>]
feature tab [<prefix>]
feature trash <feature-branch>
feature unstage <paths...>
```

`feature add <git-add-arguments...>` must be run from a feature branch. It
passes all arguments directly to `git add`, allowing files, pathspecs, and Git
options such as `--patch` or `--all`. It stages changes but does not commit or
push them.

`feature commit` must be run from a feature branch. It runs `git add --patch`,
commits with a message in the form `#<ticket> <message>`, then force-pushes the
feature branch to `origin`.

`feature end` must be run from a feature branch. It fails unless the feature
branch and initial branch agree. If they do, it switches to the initial branch,
deletes the remote feature branch, deletes the local feature branch, and prunes
`origin`.

`feature help` prints the command usage, examples, branch format, and
`FEATURE_USER` environment-variable guidance.

`feature info` reports the current branch, parsed feature metadata when
available, staged changes, unstaged tracked changes, untracked files, remote
branch presence, and ahead/behind counts.

`feature log [<pretty-format>]` displays the current branch history as a graph.
With no argument, each commit includes a colored abbreviated hash, short date,
author, subject, and ref decorations. One quoted argument replaces the Git
pretty-format string while retaining `--graph` and `--date=short`, for example
`feature log '%h %ad %an %s'`.

`feature merge` does everything `feature rebase` does, then switches to the
initial branch, fast-forwards it from the feature branch, pushes the initial
branch normally to `origin`, and switches back to the feature branch.

`feature rebase` must be run from a feature branch with no staged changes and no
unstaged tracked changes. Untracked files are allowed. It updates the initial
branch, interactively rebases the feature branch onto it using `;` as Git's
comment character, then force-pushes the feature branch to `origin`.

`feature start` must be run from an initial branch. It fetches all remotes,
prunes stale refs, fetches tags, rebases the initial branch on
`origin/<initial-branch>` with autostash, creates the feature branch, pushes it
to `origin`, and sets upstream tracking. It rejects feature branches and any
other initial branch containing the reserved `--` delimiter.

`feature status [<git-status-arguments...>]` passes all arguments to
`git status`, then checks `git stash list`. When stashes exist, it prints a
blank line, a `STASH:` heading, the stash list, and a final blank line. It omits
the entire stash section when the stash list is empty. Options such as
`--short --branch` and `--porcelain` apply to the `git status` portion only.

`feature tab [<prefix>]` prints the available feature subcommands, one per line,
for use by shell completion. With no prefix it prints every subcommand; with one
prefix it prints only commands beginning with that literal, case-sensitive
text. It does not require a Git repository.

`feature trash <feature-branch>` must be run from that exact feature branch. It
does not check whether work was merged. It switches to the initial branch,
deletes the remote feature branch, deletes the local feature branch, and prunes
`origin`.

`feature unstage <paths...>` must be run from a feature branch. It runs
`git restore --staged -- <paths...>` to remove the specified paths from the
index without discarding their working-tree changes. It does not commit or
push anything.

## Shell Completion

The completion setups in `dotfiles/bash/rc.sh` and `dotfiles/zsh/rc.sh` call
`feature tab` while completing the first argument to `feature`. Source the file
for your shell or copy its `get_feature_commands` function and completion
registration into your shell configuration. For later arguments, both shells
fall back to filesystem path completion.

## Git Command Output

`feature` prints selected Git commands to standard error immediately before
running them so users can follow branch-changing and work-recording operations.
The displayed command groups are `git add`, `git commit`, `git fetch`,
`git merge`, `git pull`, `git push`, `git rebase`, and `git switch`. The script
does not currently run `git pull`, but it belongs to the display policy if
introduced later. Internal and supporting commands such as `git branch`,
`git diff`, `git rev-parse`, and `git show-ref` remain quiet. When standard
error is connected to a terminal, the entire displayed command is green. Color
is disabled when output is redirected, `NO_COLOR` is set, or `TERM` is `dumb`.

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
- `tab` only reports subcommand names and does not run Git commands.

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

Run the regression tests after changing `bin/feature`:

```bash
tests/feature_test.sh
```

The tests create disposable Git repositories and bare remotes under `/tmp`.
They do not touch real repositories or remotes.

## Maintenance Rule

Any behavior change to `bin/feature` must update `tests/feature_test.sh` in
the same change. Any subcommand addition, removal, or rename must update the
command implementation and dispatcher, `FEATURE_COMMANDS`, help usage and
relevant examples, the command inventory and descriptions above, and the
regression tests. Keep all command inventories and descriptions alphabetized.
`FEATURE_COMMANDS` must exactly match the supported subcommands because
`feature tab` reports that list to shell completion. New subcommands need at
least one happy-path test and one guard/error test. Branch-format or safety-rule
changes must update both this document and the tests. Every change must also be
reviewed against the cross-platform compatibility rules above. Calls to Git
commands named in the Git Command Output section must use `run_git`; other Git
commands must remain quiet unless that documented list is deliberately changed.
Before considering a change complete, run:

```bash
tests/feature_test.sh
```

## Open Question

`feature merge` pushes directly to the initial branch. That fits repos where the
user may push to `main`/`master` directly. For repos with protected branches or
PR-only policies, this command may need a different final step.

## Credit

The code and documentation for the `bash` implementation of `feature` was generated by Codex but a human drove the ideas, design, review, and validation of everything. Caveat Emptor.
