## Xgrep utility

`xgrep` is a Bash 3.2-compatible wrapper around `git grep` for composing common
Boolean searches without writing Git's expression syntax directly.

```text
Usage:
  xgrep [options] <term>...

Boolean terms:
  Terms are required by default and are combined with AND.
  and  Add following terms to the required group.
  or   Add following terms to a single OR group.
  not  Add following terms to a single excluded OR group.

Options:
  -d, --debug                 Print the git grep command without running it.
      --no-debug              Disable debug mode, including one set by .xgrep.
  -f, --file                  Show files without a match (git grep -L).
  -h, --help                  Show the help message.
  -i, --invert                Select non-matching lines (git grep -v).
  -p, --include-path PATHS    Include comma-separated pathspecs.
  -P, --exclude-path PATHS    Exclude comma-separated pathspecs.
  -t, --include-type TYPES    Include comma-separated file extensions.
  -T, --exclude-type TYPES    Exclude comma-separated file extensions.
```

### Boolean searches

Terms begin in the required group, so this searches for lines containing both
`alpha` and `beta`:

```bash
xgrep alpha beta
```

The operators switch the group used for all following terms. This searches for
`alpha`, either `beta` or `gamma`, and neither `generated` nor `vendor`:

```bash
xgrep alpha or beta gamma not generated vendor
```

Start with `or` for a pure OR search:

```bash
xgrep or alpha beta
```

Use `and` to switch back to the required group:

```bash
xgrep alpha or beta gamma and delta
```

To search for the literal words `and`, `or`, or `not`, prefix the word with one
or more dashes and place it after `--`:

```bash
xgrep -- --and
```

### Paths and types

Path and type arguments accept comma-separated values:

```bash
xgrep -p src,lib -t rb,sh alpha
xgrep -P vendor,tmp -T min.js,lock alpha
```

When exclusions are used without an inclusion, `xgrep` searches from `.` and
applies the exclusions. All patterns and pathspecs are passed to Git as distinct
arguments and are not evaluated by the shell.

### Project defaults

If `.xgrep` exists in the current directory, its whitespace-separated options
and terms are prepended to the command line. It is useful for project-specific
type or path filters:

```text
-T min.js,lock
-P vendor,tmp
```

Command-line `--no-debug` can disable debug mode enabled by `.xgrep`.

### Maintenance

Behavior changes must update `tests/xgrep_test.sh` in the same change. Keep the
script compatible with Bash 3.2 and with Git versions available by default on
supported Linux and macOS systems.
