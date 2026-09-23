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
      --fzf                   Select a matching file with fzf and open it.
  -h, --help                  Show the help message.
  -i, --ignore-case           Ignore case distinctions.
  -l, --files-with-matches    Show only names of files containing matches.
  -p, --include-path PATH     Include a pathspec.
  -P, --exclude-path PATH     Exclude a pathspec.
  -t, --include-type TYPE     Include a file extension.
  -T, --exclude-type TYPE     Exclude a file extension.
```

Every search term is an extended regular expression. Quote terms containing
shell characters:

```bash
xgrep 'error|warning'
xgrep 'item-[0-9]+'
```

Searches are case-sensitive by default. Use `-i` or `--ignore-case` to match
regardless of letter case:

```bash
xgrep -i error
```

Use the Boolean `not` operator to exclude matching terms. The Bash
implementation does not provide a separate inverted-search option.

Use `-l` or `--files-with-matches` to print each matching filename once without
showing the matching lines:

```bash
xgrep -l error warning
```

### Interactive selection

Use `--fzf` to search in filename mode, select a matching file interactively,
preview it, and open it in an editor:

```bash
xgrep --fzf error warning
```

The preview displays the first 200 lines. When `bat` or `batcat` is available,
it adds line numbers and syntax highlighting. Otherwise, `xgrep` falls back to
`head`. Setting `NO_COLOR` or using `TERM=dumb` also selects the plain preview.

The editor is selected from `VISUAL`, then `EDITOR`, and defaults to `vi`.
`fzf` must be available on `PATH`; `bat` is optional.

Set `NO_COLOR` to a nonempty value to disable colored output. Colors are also
disabled when `TERM` is `dumb`:

```bash
NO_COLOR=1 xgrep alpha beta
```

### Boolean searches

Terms begin in the required group, so this searches for lines containing both
`alpha` and `beta`:

```bash
xgrep alpha beta
```

This uses the following search logic:

```text
alpha AND beta
```

The operators switch the group used for all following terms. This searches for
`alpha`, either `beta` or `gamma`, and neither `generated` nor `vendor`:

```bash
xgrep alpha or beta gamma not generated vendor
```

This uses the following search logic:

```text
alpha AND (beta OR gamma) AND NOT (generated OR vendor)
```

Start with `or` for a pure OR search:

```bash
xgrep or alpha beta
```

This uses the following search logic:

```text
alpha OR beta
```

Use `and` to switch back to the required group:

```bash
xgrep alpha or beta gamma and delta
```

This uses the following search logic:

```text
alpha AND (beta OR gamma) AND delta
```

To search for the literal words `and`, `or`, or `not`, prefix the word with one
or more dashes and place it after `--`:

```bash
xgrep -- --and
```

#### A real-world workflow

Start by searching for one term, or a few required terms. The first search often
casts a wide net and produces too much output:

```bash
xgrep payment error
```

Review the results, press Up Arrow to recall the command, and add `not` followed
by a term that identifies unwanted results:

```bash
xgrep payment error not deprecated
```

Repeat as needed. Additional terms after `not` join the same excluded OR group,
so this removes lines containing either `deprecated` or `generated`:

```bash
xgrep payment error not deprecated generated
```

This iterative approach makes it easy to begin with a broad search and refine it
until the remaining output is useful.

### Debug output

Use `-d` to inspect the underlying `git grep` command without running it:

```console
$ xgrep -d alpha or beta gamma not generated vendor
git grep -E -e alpha --and \( -e beta --or -e gamma \) --and --not \( -e generated --or -e vendor \) -- .
```

### Paths and types

Lowercase options include paths or file types. Their uppercase counterparts
exclude them:

```text
-p, --include-path
-P, --exclude-path
-t, --include-type
-T, --exclude-type
```

Options can be repeated to include or exclude multiple values.

Search for `foo` in JavaScript files while ignoring JavaScript test files whose
names end in `.spec.js`:

```bash
xgrep foo -t js -T spec.js
```

Search for `foo` only in the `src` and `lib` directories:

```bash
xgrep foo -p src -p lib
```

Search everywhere except the `spec` directory:

```bash
xgrep foo -P spec
```

When exclusions are used without an inclusion, `xgrep` searches from `.` and
applies the exclusions. All patterns and pathspecs are passed to Git as distinct
arguments and are not evaluated by the shell.

### Project defaults

If `.xgrep` exists in the current directory, its whitespace-separated options
and terms are prepended to the command line. It is useful for project-specific
type or path filters. The file is intended to be committed to source control so
everyone working on the project shares the same defaults:

```text
-T min.js
-T lock
-P vendor
-P tmp
```

### Maintenance

Behavior changes must update `tests/xgrep_test.sh` in the same change. Keep the
script compatible with Bash 3.2 and with Git versions available by default on
supported Linux and macOS systems.
