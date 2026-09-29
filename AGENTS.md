# Repository Guidance

## Purpose

This repository contains small Bash command-line utilities that make Git easier
to use:

- `feature` manages personal, short-lived feature branches.
- `xgrep` provides one Boolean-search interface backed by `git grep` inside a
  Git work tree and `find`/`grep` elsewhere.
- `dotfiles` contains optional shell integration for Bash and zsh.

Bash is the only supported implementation. Do not reintroduce the removed Ruby
implementation or the removed standalone `xfind` command unless explicitly
requested.

## Source Of Truth

Read the documentation relevant to the code being changed before editing it:

- `README.md` covers installation and the public project overview.
- `docs/FEATURE.md` defines `feature` behavior, safety rules, compatibility,
  and maintenance requirements.
- `docs/XGREP.md` defines `xgrep` behavior and its two search engines.
- Tests are executable specifications and must agree with the documentation.

Keep this file focused on durable repository-wide guidance. Put detailed user
behavior in the command documentation and use Git commits or issues for
temporary work-in-progress notes. Do not add credentials, secrets,
machine-specific paths, or conversation transcripts here.

## Compatibility

- Support Linux and macOS.
- Keep executable scripts compatible with Bash 3.2 or newer. Do not use Bash 4
  features such as associative arrays.
- `feature` supports Git 2.23 or newer because it uses `git switch`. Do not add
  newer Git commands or options without deliberately raising and documenting
  the minimum version.
- Use commands and options that work with both GNU utilities on Linux and BSD
  utilities on macOS, or provide a portable fallback.
- Keep `#!/usr/bin/env bash` on Bash executables. The user's interactive shell
  must not affect script behavior.
- Avoid adding required dependencies. Optional integrations must remain
  optional and behave as documented.

## Implementation Structure

- Keep `bin/feature` self-contained unless a clear maintenance benefit justifies
  a new file.
- Keep shared `xgrep` argument parsing and orchestration in `bin/xgrep`.
- Keep the Git search engine in `lib/xgrep/git.sh` and the filesystem search
  engine in `lib/xgrep/find.sh`.
- Preserve equivalent options and Boolean behavior between the two `xgrep`
  engines unless an engine-specific limitation is documented and tested.
- Prefer straightforward, readable Bash over clever compression or new
  abstractions. Do not introduce a shared Bash library merely to remove small
  amounts of duplication.

## Change Rules

- Any user-visible behavior change must update the relevant documentation and
  regression tests in the same change.
- Keep help text, examples, implementation, documentation, and tests in sync.
- Preserve existing safety checks unless the requested behavior explicitly
  changes them.
- Allow untracked files where `feature` currently permits them; staged and
  tracked-working-tree checks have separate safety purposes.
- Keep output suitable for terminals and pipelines. Respect `NO_COLOR` and
  non-terminal output where documented.
- Keep installation instructions simple, inspectable, and suitable for direct
  copy and paste. Maintain shell-specific Bash and zsh syntax where required.

For `feature`, follow the full Maintenance Rule in `docs/FEATURE.md`. In
particular, when adding, removing, or renaming a subcommand:

- Update the implementation, dispatcher, `FEATURE_COMMANDS`, help, examples,
  documentation, shell completion behavior, and tests.
- Keep every subcommand inventory and description alphabetized.
- Add at least one happy-path test and one guard or error test.
- Route documented visible Git commands through `run_git`; keep supporting Git
  commands quiet unless the display policy is intentionally changed.

For `xgrep`, preserve the single frontend with two distinct engines. Changes to
shared behavior normally require coverage in both `tests/xgrep_test.sh` and
`tests/xgrep_filesystem_test.sh`.

## Verification

Run the focused tests for every changed area. Before completing a change that
can affect shared behavior, run the full suite:

```bash
tests/feature_test.sh
tests/xgrep_test.sh
tests/xgrep_filesystem_test.sh
tests/profile_test.sh
```

Also run Bash syntax checks on every changed shell file, for example:

```bash
bash -n bin/feature
bash -n bin/xgrep lib/xgrep/git.sh lib/xgrep/find.sh
```

Review the final diff for stale paths, command names, help entries, and
documentation examples. Do not report completion when required tests are still
running. If a test cannot be run, state that clearly.
